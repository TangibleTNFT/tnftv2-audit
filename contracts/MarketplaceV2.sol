// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "./interfaces/ITangibleMarketplace.sol";
import "./interfaces/IRentManager.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/ISellFeeDistributor.sol";
import "./interfaces/IOnSaleTracker.sol";
import "./interfaces/IVoucher.sol";

import "./abstract/FactoryModifiers.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/**
 * @title TNFTMarketplaceV2
 * @author Veljko Mihailovic
 * @notice This smart contract facilitates the buying and selling of Tangible NFTs.
 * @dev This contract is used to buy and sell Tangible NFTs. It has couple of functions:
 *   - `sell` -> Used to list a TNFT for sale. It has Batch version also.
 *   - `buy` -> Used to buy a TNFT from the marketplace.
 *   - `stopSelling` -> Used to stop selling a TNFT.
 *   - `setFeeForCategory` -> Used to set the fee for a category of TNFTs. Fee is taken from
 * the seller and only on second sales(buyUnminted is not affected).
 *   - `setSellFeeAddress` -> Used to set the address where the fee is sent to.
 *   - `setOnSaleTracker` -> Used to set the address of the OnSaleTracker contract. Helper contract
 * that keeps track of which TNFTs are listed on the marketplace.
 *   - `buyUnminted` -> Used to buy a unminted TNFT from the marketplace. It uses Factory as proxy
 *  to mint the tnft, factory sends it to vendor, then marketplace and them marketplace sends it
 * to buyer. If storage is required, it will be paid in the same transaction. User can specify how many years
 * of storage he wants.
 *   - `payStorage` -> Used to pay for storage of a TNFT(anyone can pay for any token).
 *   - `setDesignatedBuyer` -> Used to set a designated buyer for a token. If you agree with someone to buy
 * your item, designated buyer is the only one who can buy it.
 *
 */
contract TNFTMarketplaceV2 is
    ITangibleMarketplace,
    IERC721Receiver,
    FactoryModifiers,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;

    // ~ State Variables ~

    /**
     * @notice This struct is used to help with stack too deep error.
     */
    struct BuyHelper {
        address buyer;
        uint256 cost;
        uint256 toPaySeller;
    }

    /// @notice This constant stores the default sell fee of 2.5% (2 basis points).
    uint256 public constant DEFAULT_SELL_FEE = 2_50;

    /// @notice This mapping is used to store Lot data for each token listed on the marketplace.
    mapping(address => mapping(uint256 => Lot)) public marketplaceLot;

    /// @notice This stores the address where sell fees are allocated to.
    address public sellFeeAddress;

    /// @notice OnSaleTracker contract reference.
    IOnSaleTracker public onSaleTracker;

    /// @notice This mapping is used to store the marketplace fees attached to each category of TNFTs.
    /// @dev The fees use 2 basis points for precision (i.e. 15% == 1500 // 2.5% == 250).
    /// @dev If not set, the DEFAULT_SELL_FEE is used.
    mapping(ITangibleNFT => uint256) public feesPerCategory;

    /// @notice This mapping is used to store the initial sale status of each TNFT.
    /// @dev If true, the TNFT has been sold at least once since minting.
    mapping(ITangibleNFT => mapping(uint256 => bool)) public initialSaleCompleted;

    // ~ Events ~

    /**
     * @notice This event is emitted when the marketplace fee is paid by a buyer.
     * @param nft Address of TangibleNFT contract.
     * @param tokenId TNFT identifier.
     * @param paymentToken Token used to pay for fee
     * @param feeAmount Fee amount paid.
     */
    event MarketplaceFeePaid(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed paymentToken,
        uint256 feeAmount
    );

    /**
     * @notice This event is emitted when a TNFT is listed for sale.
     * @param seller The original owner of the token.
     * @param nft Address of TangibleNFT contract.
     * @param tokenId TNFT identifier.
     * @param paymentToken Token used to pay for the item.
     * @param price Price TNFT is listed at.
     */
    event Selling(
        address indexed seller,
        address indexed nft,
        uint256 indexed tokenId,
        address paymentToken,
        uint256 price
    );

    /**
     * @notice This event is emitted when a token that was listed for sale is stopped by the owner.
     * @param seller The owner of the token.
     * @param nft Address of TangibleNFT contract.
     * @param tokenId TNFT identifier.
     */
    event StopSelling(address indexed seller, address indexed nft, uint256 indexed tokenId);

    /**
     * @notice This event is emitted when a TNFT has been purchased from the marketplace.
     * @param nft Address of TangibleNFT contract.
     * @param tokenId TNFT identifier.
     * @param paymentToken Token used to pay for the item.
     * @param buyer Address of EOA that purchased the TNFT
     * @param price Price at which the token was purchased.
     */
    event TnftBought(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed paymentToken,
        address buyer,
        uint256 price
    );

    /**
     * @notice This event is emitted when a TNFT has been sold from the marketplace.
     * @param nft Address of TangibleNFT contract.
     * @param tokenId TNFT identifier.
     * @param paymentToken Token used to pay for the item.
     * @param seller Address of seller that was selling
     * @param price Price at which the token was sold.
     */
    event TnftSold(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed paymentToken,
        address seller,
        uint256 price
    );

    /**
     * @notice This event is emitted when `sellFeeAddress` is updated.
     * @param oldFeeAddress The previous `sellFeeAddress`.
     * @param newFeeAddress The new `sellFeeAddress`.
     */
    event SellFeeAddressSet(address indexed oldFeeAddress, address indexed newFeeAddress);

    /**
     * @notice This event is emitted when the value stored in `onSaleTracker` is updated
     * @param oldSaleTracker The previous address stored in `onSaleTracker`.
     * @param newSaleTracker The new address stored in `onSaleTracker`.
     */
    event SaleTrackerSet(address indexed oldSaleTracker, address indexed newSaleTracker);

    /**
     * @notice This event is emitted when there is an update to `feesPerCategory`.
     * @param nft TangibleNFT contract reference.
     * @param oldFee Previous fee.
     * @param newFee New fee.
     */
    event SellFeeChanged(ITangibleNFT indexed nft, uint256 oldFee, uint256 newFee);

    /**
     * @notice This event is emitted when we have a successful execution of `_payStorage`.
     * @param nft Address of TangibleNFT contract.
     * @param tokenId NFT identifier.
     * @param paymentToken Address of Erc20 token that was accepted as payment.
     * @param payer Address of account that paid for storage.
     * @param amount Amount quoted for storage.
     */
    event StorageFeePaid(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed paymentToken,
        address payer,
        uint256 amount
    );

    /**
     * @notice This event is emitted when a designated buyer is set for a token.
     * @param nft Address of TangibleNFT contract.
     * @param tokenId NFT identifier.
     * @param oldBuyer Previous designated buyer.
     * @param newBuyer New designated buyer.
     */
    event DesignatedBuyer(
        address indexed nft,
        uint256 indexed tokenId,
        address indexed oldBuyer,
        address newBuyer
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ~ Initializer ~
    /**
     * @notice Initializes Marketplace contract.
     * @param _factory Address of Factory provider contract
     */
    function initialize(address _factory) external initializer {
        __FactoryModifiers_init(_factory);
        __ReentrancyGuard_init();
    }

    // ~ Functions ~

    /**
     * @notice This function is used to list a batch of TNFTs at once instead of one at a time.
     * @dev This function allows anyone to sell a batch of TNFTs they own.
     *      If `price` is 0, purchase price is taken from the Oracle for the item.
     *      If `designatedBuyer` is not 0 address, only that address can buy the item.
     *      Callable by anyone who owns the tokens.
     * @param nft TangibleNFT contract reference.
     * @param paymentToken Erc20 token being used as payment.
     * @param tokenIds Array of tokenIds to sell.
     * @param price Price per token.
     * @param designatedBuyer If not zero address, only this address can buy.
     */
    function sellBatch(
        ITangibleNFT nft,
        IERC20 paymentToken,
        uint256[] calldata tokenIds,
        uint256[] calldata price,
        address designatedBuyer
    ) external {
        require(IFactory(factory()).paymentTokens(paymentToken), "NAT");
        uint256 length = tokenIds.length;
        for (uint256 i; i < length; ) {
            _sell(nft, paymentToken, tokenIds[i], price[i], designatedBuyer);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This function is used to update the `onSaleTracker::tnftSalePlaced()` tracker state.
     * @param tnft TangibleNFT contract reference.
     * @param tokenId TNFT identifier.
     * @param placed If true, the token is being listed for sale, otherwise false.
     */
    function _updateTrackerTnft(ITangibleNFT tnft, uint256 tokenId, bool placed) internal {
        onSaleTracker.tnftSalePlaced(tnft, tokenId, placed);
    }

    /**
     * @notice This internal function is called when a TNFT is listed for sale on the marketplace.
     * @param nft TangibleNFT contract reference.
     * @param paymentToken Erc20 token being accepted as payment by seller.
     * @param tokenId TNFT token identifier.
     * @param price Price the token is being listed for.
     * @param designatedBuyer If not zero address, only this address can buy.
     */
    function _sell(
        ITangibleNFT nft,
        IERC20 paymentToken,
        uint256 tokenId,
        uint256 price,
        address designatedBuyer
    ) internal {
        //check who is the owner
        address ownerOfNft = nft.ownerOf(tokenId);
        //if marketplace is owner and seller wants to update price
        Lot storage lot = marketplaceLot[address(nft)][tokenId];
        if (address(this) == ownerOfNft && msg.sender == lot.seller) {
            lot.price = price;
            lot.paymentToken = paymentToken;
        } else {
            //here we don't need to check, if not approved trx will fail
            nft.safeTransferFrom(msg.sender, address(this), tokenId, abi.encode(price));

            // set the desired payment token
            lot.paymentToken = paymentToken;
        }
        if (designatedBuyer != address(0)) {
            emit DesignatedBuyer(address(nft), tokenId, lot.designatedBuyer, designatedBuyer);
            lot.designatedBuyer = designatedBuyer;
        }
        emit Selling(
            lot.seller,
            address(lot.nft),
            lot.tokenId,
            address(lot.paymentToken),
            lot.price
        );
    }

    /**
     * @notice This is a restricted function for updating the `onSaleTracker` contract reference.
     * @dev This function is only callable by the Factory contract owner.
     * @param _onSaleTracker The new OnSaleTracker contract.
     */
    function setOnSaleTracker(IOnSaleTracker _onSaleTracker) external onlyFactoryOwner {
        emit SaleTrackerSet(address(onSaleTracker), address(_onSaleTracker));
        onSaleTracker = _onSaleTracker;
    }

    /**
     * @notice This is a restricted function to update the `feesPerCategory` mapping.
     * @dev This function is only callable by the Category owner.
     * @param tnft TangibleNFT contract reference aka category of TNFTs.
     * @param fee New fee to charge for category.
     */
    function setFeeForCategory(ITangibleNFT tnft, uint256 fee) external onlyCategoryOwner(tnft) {
        emit SellFeeChanged(tnft, feesPerCategory[tnft], fee);
        feesPerCategory[tnft] = fee;
    }

    /**
     * @notice This function allows a TNFT owner to stop the sale of their TNFTs batch.
     * @dev User can stop multiple tokens sale at once.
     * @param nft TangibleNFT contract reference.
     * @param tokenIds Array of tokenIds.
     */
    function stopBatchSale(ITangibleNFT nft, uint256[] calldata tokenIds) external {
        uint256 length = tokenIds.length;

        for (uint256 i; i < length; ) {
            _stopSale(nft, tokenIds[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This function stops the sale of a TNFT and transfers it back to it's original owner.
     * @param nft TangibleNFT contract reference.
     * @param tokenId Array of tokenIds.
     */
    function _stopSale(ITangibleNFT nft, uint256 tokenId) internal {
        address seller = msg.sender;
        // gas saving
        mapping(uint256 => Lot) storage marketplaceLotForNft = marketplaceLot[address(nft)];
        Lot memory _lot = marketplaceLotForNft[tokenId];
        require(_lot.seller == seller, "NOS");

        emit StopSelling(seller, address(nft), tokenId);
        delete marketplaceLotForNft[tokenId];
        //update tracker
        _updateTrackerTnft(nft, tokenId, false);

        IERC721(nft).safeTransferFrom(address(this), _lot.seller, _lot.tokenId);
    }

    /**
     * @notice This function allows the user to buy any TangibleNFT that is listed on Marketplace.
     * @dev If user is not designated buyer, he can't buy the token. If designated buyer is 0 address, anyone can buy.
     * @dev User is protected against price manipulation.
     * @param nft TangibleNFT contract reference.
     * @param tokenId TNFT identifier.
     * @param _years Num of years to pay for storage.
     * @param _maxStorageAmount Max amount to pay for storage.
     * @param _paymentToken Erc20 token being used as payment ,sent as param to protect payer.
     * @param _paymentAmount Price of in Lot, to protect the payer.
     */
    function buy(
        ITangibleNFT nft,
        uint256 tokenId,
        uint256 _years,
        uint256 _maxStorageAmount,
        address _paymentToken,
        uint256 _paymentAmount
    ) external nonReentrant {
        //pay for storage
        if ((!nft.isStorageFeePaid(tokenId) || _years > 0) && nft.storageRequired()) {
            require(_years > 0, "YZ");
            _payStorage(nft, IERC20Metadata(_paymentToken), tokenId, _years, _maxStorageAmount);
        }
        // gas optimization
        IFactory _factory = IFactory(factory());
        // if initial sale is not done, and whitelitsing is required, check if buyer is whitelisted
        if (
            _factory.onlyWhitelistedForUnmintedCategory(nft) && !initialSaleCompleted[nft][tokenId]
        ) {
            require(_factory.whitelistForBuyUnminted(nft, msg.sender), "NW");
        }
        //buy the token
        _buy(nft, tokenId, true, _paymentToken, _paymentAmount);
    }

    /**
     * @notice The function which buys additional storage for the token.
     * @dev Anyone can extend storage for any token.
     * @param nft TangibleNFT contract reference.
     * @param paymentToken Erc20 token being used to pay for storage.
     * @param tokenId TNFT identifier.
     * @param _years Num of years to pay for storage.
     * @param _maxStorageAmount Max amount to pay for storage.
     */
    function payStorage(
        ITangibleNFT nft,
        IERC20Metadata paymentToken,
        uint256 tokenId,
        uint256 _years,
        uint256 _maxStorageAmount
    ) external nonReentrant {
        _payStorage(nft, paymentToken, tokenId, _years, _maxStorageAmount);
    }

    /**
     * @notice This internal function updates the storage tracker on the factory and charges the owner for quoted storage.
     * @param nft TangibleNFT contract reference.
     * @param paymentToken Erc20 token reference being used as payement for storage.
     * @param tokenId TNFT identifier.
     * @param _years Num of years to extend storage for.
     */
    function _payStorage(
        ITangibleNFT nft,
        IERC20Metadata paymentToken,
        uint256 tokenId,
        uint256 _years,
        uint256 _maxAmount
    ) internal {
        require(nft.storageRequired(), "STNR");
        require(_years > 0, "YZ");
        IFactory _factory = IFactory(factory());

        uint256 amount = _factory.adjustStorageAndGetAmount(nft, paymentToken, tokenId, _years);
        // make sure not to overpay
        if (_maxAmount != 0) {
            require(amount <= _maxAmount, "MAMT");
        }
        //we take in default USD token
        IERC20(address(paymentToken)).safeTransferFrom(
            msg.sender,
            _factory.categoryOwnerWallet(nft),
            amount
        );
        emit StorageFeePaid(address(nft), tokenId, address(paymentToken), msg.sender, amount);
    }

    /**
     * @notice This funcion allows accounts to purchase items for the first time, that
     *       were not previously minted.
     * @dev Since we are dealing with real world assets, tokenizing them before actually selling
     *      is not an option since those items either sit in a warehouse or are Real estate
     *      properties. The process is explained in the docs and in the whitepaper.
     * @param nft TangibleNFT contract reference.
     * @param paymentToken Erc20 token being used as payment.
     * @param _fingerprint Fingerprint of token.
     * @param _years Num of years to store item in advance.
     * @param _maxStorageAmount Max amount to pay for storage.
     */
    function buyUnminted(
        ITangibleNFT nft,
        IERC20 paymentToken,
        uint256 _fingerprint,
        uint256 _years,
        uint256 _maxStorageAmount
    ) external nonReentrant returns (uint256 tokenId) {
        address _factory = factory();
        if (IFactory(_factory).onlyWhitelistedForUnmintedCategory(nft)) {
            require(IFactory(_factory).whitelistForBuyUnminted(nft, msg.sender), "NW");
        }

        if (address(paymentToken) == address(0)) {
            paymentToken = IFactory(_factory).defUSD();
        }
        require(IFactory(_factory).paymentTokens(paymentToken), "TNAPP");
        //buy unminted is always initial sale!!
        // need to also fetch stock here!! and remove remainingMintsForVendor
        (uint256 tokenPrice, uint256 stock, uint256 tokenizationCost) = _itemPrice(
            nft,
            IERC20Metadata(address(paymentToken)),
            _fingerprint,
            true
        );

        require((tokenPrice + tokenizationCost) > 0 && stock > 0, "!0S");

        MintVoucher memory voucher = MintVoucher({
            token: nft,
            mintCount: 1,
            price: 0,
            vendor: IFactory(_factory).categoryOwnerWallet(nft),
            buyer: msg.sender,
            fingerprint: _fingerprint,
            sendToVendor: false
        });
        uint256[] memory tokenIds = IFactory(_factory).mint(voucher);
        tokenId = tokenIds[0];
        //pay for storage
        if (nft.storageRequired() && !nft.isStorageFeePaid(tokenId)) {
            _payStorage(
                nft,
                IERC20Metadata(address(paymentToken)),
                tokenId,
                _years,
                _maxStorageAmount
            );
        }

        marketplaceLot[address(nft)][tokenId].paymentToken = paymentToken;
        //pricing should be handled from oracle
        _buy(
            voucher.token,
            tokenIds[0],
            false,
            address(paymentToken),
            tokenPrice + tokenizationCost
        );
    }

    /**
     * @notice This function is used to return the price for the `data` item provided.
     * @dev Fetches the price through Factory and PriceManager.
     * @param nft TangibleNFT contract reference.
     * @param paymentUSDToken Erc20 token being used as payment.
     * @param data Token identifier, will be a fingerprint or a tokenId.
     * @param fromFingerprints If true, `data` will be a fingerprint, othwise it'll be a tokenId.
     * @return weSellAt -> Price of item in oracle, market price.
     * @return weSellAtStock -> Stock of the item.
     * @return tokenizationCost -> Tokenization costs for tokenizing asset. Real Estate will never be 0.
     */
    function _itemPrice(
        ITangibleNFT nft,
        IERC20Metadata paymentUSDToken,
        uint256 data,
        bool fromFingerprints
    ) internal view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost) {
        return
            fromFingerprints
                ? IFactory(factory()).priceManager().oracleForCategory(nft).usdPrice(
                    nft,
                    paymentUSDToken,
                    data,
                    0
                )
                : IFactory(factory()).priceManager().oracleForCategory(nft).usdPrice(
                    nft,
                    paymentUSDToken,
                    0,
                    data
                );
    }

    /**
     * @notice This internal function is used to update marketplace state when an account buys a listed TNFT.
     * @dev Makes sure that tokens are transferred correctly and that fees are paid.
     * @param nft TangibleNFT contract reference.
     * @param tokenId TNFT identifier to buy.
     * @param chargeFee If true, a fee will be charged from buyer.
     */
    function _buy(
        ITangibleNFT nft,
        uint256 tokenId,
        bool chargeFee,
        address _paymentToken,
        uint256 _price
    ) internal {
        // gas saving
        BuyHelper memory helper = BuyHelper(msg.sender, 0, 0);
        mapping(uint256 => Lot) storage marketplaceLotForNft = marketplaceLot[address(nft)];
        Lot storage _lot = marketplaceLotForNft[tokenId];
        require(_lot.seller != address(0), "NLO");
        // if there is a buyer set, only that buyer can buy
        if (_lot.designatedBuyer != address(0)) {
            require(_lot.designatedBuyer == helper.buyer, "NDB");
        }
        IERC20 pToken = _lot.paymentToken;

        // if lot.price == 0 it means vendor minted it, we must take price from oracle
        // if lot.price != 0 means some seller posted it and didn't want to use oracle
        helper.cost = _lot.price;
        //protection from over charging
        require(helper.cost <= _price && address(pToken) == _paymentToken, "OC");
        if (helper.cost == 0) {
            uint256 tokenizationCost;
            (helper.cost, , tokenizationCost) = _itemPrice(
                nft,
                IERC20Metadata(address(pToken)),
                tokenId,
                false
            );
            helper.cost += tokenizationCost;
        }

        require(helper.cost != 0, "Price0");

        //take the fee
        helper.toPaySeller = helper.cost;
        uint256 _sellFee = feesPerCategory[nft] == 0 ? DEFAULT_SELL_FEE : feesPerCategory[nft];
        if (_sellFee > 0 && chargeFee) {
            // if there is fee set, decrease amount by the fee and send fee
            uint256 fee = (helper.toPaySeller * _sellFee) / 100_00;
            helper.toPaySeller = helper.toPaySeller - fee;
            pToken.safeTransferFrom(helper.buyer, sellFeeAddress, fee);
            ISellFeeDistributor(sellFeeAddress).distributeFee(pToken, fee);
            emit MarketplaceFeePaid(address(nft), tokenId, address(pToken), fee);
        }
        // fetch rent manager
        IRentManagerExt rentManager = IRentManagerExt(
            address(IFactory(factory()).rentManager(nft))
        );
        if (address(rentManager) != address(0)) {
            if (rentManager.claimableRentForToken(tokenId) != 0) {
                uint256 claimed = rentManager.claimRentForToken(tokenId);
                IERC20(rentManager.rentInfo(tokenId).rentToken).safeTransfer(_lot.seller, claimed);
            }
        }

        pToken.safeTransferFrom(helper.buyer, _lot.seller, helper.toPaySeller);

        emit TnftSold(address(nft), tokenId, address(pToken), _lot.seller, helper.cost);
        emit TnftBought(address(nft), tokenId, address(pToken), helper.buyer, helper.cost);
        delete marketplaceLotForNft[tokenId];
        //update tracker
        _updateTrackerTnft(nft, tokenId, false);
        // gas optimization
        mapping(uint256 => bool) storage initialSaleCompletedForNft = initialSaleCompleted[nft];
        if (!initialSaleCompletedForNft[tokenId]) {
            initialSaleCompletedForNft[tokenId] = true;
        }

        nft.safeTransferFrom(address(this), helper.buyer, tokenId);
    }

    /**
     * @notice Sets the sellFeeAddress
     * @dev This function is only callable by the Factory contract owner.
     * @dev Will emit SellFeeAddressSet on change.
     * @param _sellFeeAddress A new address for fee storage.
     */
    function setSellFeeAddress(address _sellFeeAddress) external onlyFactoryOwner {
        emit SellFeeAddressSet(sellFeeAddress, _sellFeeAddress);
        sellFeeAddress = _sellFeeAddress;
    }

    /**
     * @notice This function is used to set the designated buyer on already listed token.
     * @dev Only seller or factory can call this function. Factory because of the first purchase.
     * @dev If designatedBuyer is 0 address, anyone can buy the token.
     * @param nft Address of the TNFT
     * @param tokenId TokenId for which you want to set the designatedBuyer
     * @param designatedBuyer address to set the designated buyer.
     */
    function setDesignatedBuyer(
        ITangibleNFT nft,
        uint256 tokenId,
        address designatedBuyer
    ) external {
        // gas optimization
        Lot storage _lot = marketplaceLot[address(nft)][tokenId];
        require(msg.sender == _lot.seller || msg.sender == factory(), "NATS");
        emit DesignatedBuyer(address(nft), tokenId, _lot.designatedBuyer, designatedBuyer);
        _lot.designatedBuyer = designatedBuyer;
    }

    /**
     * @notice Needed to receive Erc721 tokens.
     * @dev The ERC721 smart contract calls this function on the recipient
     *      after a `transfer`. This function MAY throw to revert and reject the
     *      transfer. Return of other than the magic value MUST result in the
     *      transaction being reverted.
     *      Note: the contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function (not used), but here to support interface.
     * @param seller Seller EOA address.
     * @param tokenId Unique token identifier that is being transferred.
     * @param data Additional data with no specified format.
     * @return A bytes4 `selector` is returned to the caller to verify contract is an ERC721Receiver implementer.
     */
    function onERC721Received(
        address operator,
        address seller,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return _onERC721Received(operator, seller, tokenId, data);
    }

    /**
     * @notice Needed to receive Erc721 tokens.
     * @dev Besides handling receiving of the ERC721 token, this function is used to list the token on the marketplace.
     *      It has protection in place to make sure only tnft tokens can be listed.
     * @param seller Seller EOA address.
     * @param tokenId Unique token identifier that is being transferred.
     * @param data Additional data with no specified format.
     * @return A bytes4 `selector` is returned to the caller to verify contract is an ERC721Receiver implementer.
     */
    function _onERC721Received(
        address /*operator*/,
        address seller,
        uint256 tokenId,
        bytes calldata data
    ) private returns (bytes4) {
        address nft = msg.sender;
        uint256 price = abi.decode(data, (uint256));
        // gas optimiz
        IFactory _factory = IFactory(factory());
        IERC20 defUSD = _factory.defUSD();
        require(address(_factory.category(ITangibleNFT(nft).name())) == nft, "Not TNFT");

        marketplaceLot[nft][tokenId] = Lot({
            nft: ITangibleNFT(nft),
            paymentToken: defUSD,
            tokenId: tokenId,
            seller: seller,
            price: price,
            designatedBuyer: address(0)
        });
        _updateTrackerTnft(ITangibleNFT(nft), tokenId, true);

        return IERC721Receiver.onERC721Received.selector;
    }
}
