// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "../abstract/PriceConverter.sol";
import "../interfaces/IPriceOracle.sol";
import "../abstract/FactoryModifiers.sol";
import "../interfaces/ICurrencyFeedV2.sol";
import "../interfaces/IChainlinkRWAOracle.sol";
import "../interfaces/IRWAPriceNotificationDispatcher.sol";

/**
 * @title RealtyOracleTangibleV2
 * @author Veljko Mihailovic
 * @notice This smart contract is used to manage the stock and pricing for Real Estate properties.
 * @dev It has a IPriceOracle interface, which is created to fit the need of TNFT marketplace infrastructure,
 * and to fill specifics of RWA products on chain.
 * Interface is aligned with part of chainlink interface and extended with options
 * to retrieve the price in native currency and USD$.
 * Handling RWA is different from tokens in blockchain, vendors can come from different
 * parts of the world with their native currency. We are required to be able to
 * conform to USD price but, because ratios fluctuate in Forex, we also need to stora
 * native currency price, so that we are sure that price of the item hasn't changed.
 * For price feeds, every oracle depends on CurrencyFeedV2 contract.
 * It holds the address of chainlink aggregator for real estates. Key link is the fingerprint.
 * That oracle stores the info on where the house is located, price in native currency, when was the
 * last update, stock of the item.
 * Based on this info, different price feeds are fetched from CurrencyFeedV2 contract.
 */
contract RealtyOracleTangibleV2 is IPriceOracle, PriceConverter, FactoryModifiers {
    // ~ State Variables ~

    /// @notice Version of oracle interface this contract uses.
    uint256 public version;

    /// @notice Currency Feed contract reference.
    ICurrencyFeedV2 public currencyFeed;

    /// @notice Tangible Oracle contract reference.
    IChainlinkRWAOracle public chainlinkRWAOracle;

    /// @notice Holds description of oracle.
    string public constant description = "Real estate Oracle";

    /// @notice Holds the address of the notification dispatcher.
    IRWAPriceNotificationDispatcher public notificationDispatcher;

    // ~ Events ~

    /**
     * @notice This event is emitted when CurrencyFeed contract is updated.
     * @param currencyFeed Address of currency feed contract.
     */
    event CurrencyFeedUpdated(address indexed currencyFeed);

    /**
     * @notice This event is emitted when ChainlinkRWAOracle contract is updated.
     * @param chainlinkRWAOracle Address of chainlink RWA oracle contract.
     */
    event ChainlinkOracleUpdated(address indexed chainlinkRWAOracle);

    /**
     * @notice This event is emitted when NotificationDispatcher contract is updated.
     * @param notificationDispatcher Address of notification dispatcher contract.
     */
    event NotificationDispatcherUpdated(address indexed notificationDispatcher);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ~ Initializer ~

    /**
     * @notice Initializes RealtyOracleTangibleV2.
     * @param _factory  Factory contract address.
     * @param _currencyFeed Currency Feed contract address.
     * @param _chainlinkRWAOracle Chainlink Tangible Oracle address.
     */
    function initialize(
        address _factory,
        address _currencyFeed,
        address _chainlinkRWAOracle
    ) external initializer {
        require(
            _currencyFeed != address(0) && _chainlinkRWAOracle != address(0),
            "one address is zero"
        );
        __FactoryModifiers_init(_factory);
        currencyFeed = ICurrencyFeedV2(_currencyFeed);
        chainlinkRWAOracle = IChainlinkRWAOracle(_chainlinkRWAOracle);
        version = 4;
    }

    // ~ Functions ~

    // ~ External Functions ~

    /**
     * @notice This method returns the USD price data of a specified real estate asset.
     * @dev Usefull for fetching the price of a property in USD, regardless of its location.
     * @param _nft TangibleNFT contract reference.
     * @param _paymentUSDToken Token being used as payment.
     * @param _fingerprint Property identifier.
     * @param _tokenId Token identifier.
     * @return weSellAt -> Price of item in oracle, market price.
     * @return weSellAtStock -> Stock of the item. (Quantity)
     * @return tokenizationCost -> Tokenization costs for tokenizing asset.
     */
    function usdPrice(
        ITangibleNFT _nft,
        IERC20Metadata _paymentUSDToken,
        uint256 _fingerprint,
        uint256 _tokenId
    )
        external
        view
        override
        returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost)
    {
        return _usdPrice(_nft, _paymentUSDToken, _fingerprint, _tokenId);
    }

    /**
     * @notice This method returns the USD prices data of a specified real estate assets.
     * @dev Usefull for getting the USD price of multiple assets at once.
     * @param _nft TangibleNFT contract reference.
     * @param _paymentUSDToken Token being used as payment.
     * @param _fingerprints Product identifiers.
     * @param _tokenIds Token identifiers.
     * @return weSellAt -> Prices of item in oracle, market price for corresponding _fingerprints or tokenIds.
     * @return weSellAtStock -> Stock of the item. (Quantity) for corresponding _fingerprints or tokenIds.
     * @return tokenizationCost -> Tokenization costs for tokenizing asset for corresponding _fingerprints or tokenIds.
     */
    function usdPrices(
        ITangibleNFT _nft,
        IERC20Metadata _paymentUSDToken,
        uint256[] calldata _fingerprints,
        uint256[] calldata _tokenIds
    )
        external
        view
        override
        returns (
            uint256[] memory weSellAt,
            uint256[] memory weSellAtStock,
            uint256[] memory tokenizationCost
        )
    {
        bool useFingerprint = !(_fingerprints.length == 0);
        uint256 length = useFingerprint ? _fingerprints.length : _tokenIds.length;
        weSellAt = new uint256[](length);
        weSellAtStock = new uint256[](length);
        tokenizationCost = new uint256[](length);
        if (useFingerprint) {
            for (uint256 i; i < length; ) {
                (weSellAt[i], weSellAtStock[i], tokenizationCost[i]) = _usdPrice(
                    _nft,
                    _paymentUSDToken,
                    _fingerprints[i],
                    0
                );
                unchecked {
                    ++i;
                }
            }
        } else {
            for (uint256 i; i < length; ) {
                (weSellAt[i], weSellAtStock[i], tokenizationCost[i]) = _usdPrice(
                    _nft,
                    _paymentUSDToken,
                    0,
                    _tokenIds[i]
                );
                unchecked {
                    ++i;
                }
            }
        }
    }

    /**
     * @notice This is a restricted function for updating the address of `currencyFeed`.
     * @param _currencyFeed New address to store in `currencyFeed`.
     */
    function setCurrencyFeed(address _currencyFeed) external onlyTangibleLabs {
        require(_currencyFeed != address(0), "CF 0");
        currencyFeed = ICurrencyFeedV2(_currencyFeed);
        emit CurrencyFeedUpdated(_currencyFeed);
    }

    /**
     * @notice This is a restricted function for updating the address of `chainlinkRWAOracle`.
     * @param _chainlinkRWAOracle New address to store in `chainlinkRWAOracle`.
     */
    function setChainlinkOracle(address _chainlinkRWAOracle) external onlyTangibleLabs {
        require(_chainlinkRWAOracle != address(0), "CO 0");
        chainlinkRWAOracle = IChainlinkRWAOracle(_chainlinkRWAOracle);
        emit ChainlinkOracleUpdated(_chainlinkRWAOracle);
    }

    /**
     * @notice This is a restricted function for updating the address of `notificationDispatcher`.
     * @param _notificationDispatcher New address to store in `notificationDispatcher`.
     */
    function setNotificationDispatcher(address _notificationDispatcher) external onlyTangibleLabs {
        require(_notificationDispatcher != address(0), "ND 0");
        notificationDispatcher = IRWAPriceNotificationDispatcher(_notificationDispatcher);
        emit NotificationDispatcherUpdated(_notificationDispatcher);
    }

    /**
     * @notice This function is used to send the price change to notification dispatcher
     * @dev This function is called by the ChainlinkRWAOracle contract only.
     * @param fingerprint Item ofr which the price has changed
     * @param oldNativePrice old price of the item, native currency
     * @param newNativePrice old price of the item, native currency
     * @param currency Currency in which the price is expressed
     */
    function notify(
        uint256 fingerprint,
        uint256 oldNativePrice,
        uint256 newNativePrice,
        uint16 currency
    ) external {
        require(msg.sender == address(chainlinkRWAOracle), "Not allowed");
        if (address(notificationDispatcher) != address(0)) {
            notificationDispatcher.notify(fingerprint, oldNativePrice, newNativePrice, currency);
        }
    }

    /**
     * @notice This is a restricted function for decrementing the stock of a product/property.
     * @dev Only callable by the Factory contract. Factory is proxy in this case.
     * @param _fingerprint Fingerprint to decrement.
     */
    function decrementSellStock(uint256 _fingerprint) external override onlyFactory {
        chainlinkRWAOracle.decrementStock(_fingerprint);
    }

    /**
     * @notice Fetches decimals from ChainlinkRWA oracle.
     * @return Returns the number of decimals the aggregator responses represent.
     */
    function decimals() public view returns (uint8) {
        return chainlinkRWAOracle.getDecimals();
    }

    /**
     * @notice This method is used to fetch the native currency and price for a specified property.
     * @dev Usefull for calculating the price of a property in native currency.
     * @param _fingerprint Property identifier.
     * @return nativePrice -> Price for property in native currency.
     * @return currency -> Native currency as ISO num code.
     */
    function marketPriceNativeCurrency(
        uint256 _fingerprint
    ) external view returns (uint256 nativePrice, uint256 currency) {
        IChainlinkRWAOracle.Data memory data = chainlinkRWAOracle.fingerprintData(_fingerprint);
        currency = data.currency;
        nativePrice = data.weSellAt + data.lockedAmount;
    }

    /**
     * @notice This method is used to fetch the native currency and price for a specified properties.
     * @dev Usefull for calculating the total price of properties in native currency.
     * @param _fingerprints Property identifiers.
     * @return nativePrice -> Prices for properties in native currency.
     * @return currency -> Native currencies as ISO num codes.
     */
    function marketPriceTotalNativeCurrency(
        uint256[] calldata _fingerprints
    ) external view returns (uint256 nativePrice, uint256 currency) {
        uint256 length = _fingerprints.length;
        require(length > 0, "no input");
        IChainlinkRWAOracle.Data memory data = chainlinkRWAOracle.fingerprintData(_fingerprints[0]);
        currency = data.currency;
        nativePrice += data.weSellAt + data.lockedAmount;
        for (uint256 i = 1; i < length; ) {
            data = chainlinkRWAOracle.fingerprintData(_fingerprints[i]);
            require(currency == data.currency, "not same currency");

            nativePrice += data.weSellAt + data.lockedAmount;

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This method is used to fetch the native currency and price for a specified properties.
     * @dev Usefull for getting individual prices in one call.
     * @param fingerprints Property identifiers.
     * @return nativePrices -> Prices for properties in native currency.
     * @return currencies -> Native currencies as ISO num codes.
     */
    function marketPricesNativeCurrencies(
        uint256[] calldata fingerprints
    ) external view returns (uint256[] memory nativePrices, uint256[] memory currencies) {
        uint256 length = fingerprints.length;
        nativePrices = new uint256[](length);
        currencies = new uint256[](length);

        for (uint256 i; i < length; ) {
            IChainlinkRWAOracle.Data memory data = chainlinkRWAOracle.fingerprintData(
                fingerprints[i]
            );
            currencies[i] = data.currency;
            nativePrices[i] = data.weSellAt + data.lockedAmount;

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This method returns the fingerprint from the `chainlinkRWAOracle` at a specified index.
     * @param _index Index where the fingerprint resides.
     * @return fingerprint -> Product/property identifier.
     */
    function fingerprintsInOracle(uint256 _index) public view returns (uint256 fingerprint) {
        // return value from chainlink oracle
        return chainlinkRWAOracle.fingerprints(_index);
    }

    /**
     * @notice This method returns if a specified fingerprint exists in the `chainlinkRWAOracle`.
     * @param _fingerprint Product identifier.
     * @return If fingerprint exists, will return true.
     */
    function fingerprintHasPrice(uint256 _fingerprint) public view returns (bool) {
        // return value from chainlink oracle
        return chainlinkRWAOracle.fingerprintExists(_fingerprint);
    }

    /**
     * @notice This method is used to fetch the last timestamp the oracle was updated for specific fingerprint.
     * @param _fingerprint Product identifier.
     * @return Returns the block timestamp when the oracle was last updated.
     */
    function latestTimeStamp(uint256 _fingerprint) external view override returns (uint256) {
        // return from chainlink oracle
        return chainlinkRWAOracle.fingerprintData(_fingerprint).timestamp;
    }

    /**
     * @notice This method returns the latest block the `chainlinkRWAOracle` was updated.
     * @return Block when last update occurred.
     */
    function lastUpdateOracle() external view returns (uint256) {
        return chainlinkRWAOracle.lastUpdateTime();
    }

    /**
     * @notice This method returns the `latestPrices` var from `chainlinkRWAOracle` contract.
     * @dev It is index that is incremented each time some price is updated.
     * It is a signal to contracts tracking and copying the oracle data to know if they have the latest data.
     * @return Returns `latestPrices`var.
     */
    function latestPrices() public view returns (uint256) {
        return chainlinkRWAOracle.latestPrices();
    }

    /**
     * @notice This method retreives all oracle data for all fingerprints in the oracle.
     * @dev Usefull to fetch all data in one go
     * @return currentData -> All metadata objects in an array.
     */
    function oracleDataAll() public view returns (IChainlinkRWAOracle.Data[] memory currentData) {
        return chainlinkRWAOracle.oracleDataAll();
    }

    /**
     * @notice This method is used to take an array of fingerprints and fetch batch data for those fingerprints from the oracle.
     * @param _fingerprints Array of fingerprints we wish to fetch oracle data for.
     * @return currentData -> Array of data objects or each fingerprint returned.
     */
    function oracleDataBatch(
        uint256[] calldata _fingerprints
    ) public view returns (IChainlinkRWAOracle.Data[] memory currentData) {
        return chainlinkRWAOracle.oracleDataBatch(_fingerprints);
    }

    /**
     * @notice This method is used to fetch the amount of a certain product/product is in stock.
     * @param _fingerprint Property/product identifier.
     * @return weSellAtStock -> Quantity in stock. If == 0, out of stock.
     */
    function availableInStock(
        uint256 _fingerprint
    ) external view override returns (uint256 weSellAtStock) {
        weSellAtStock = chainlinkRWAOracle.fingerprintData(_fingerprint).weSellAtStock;
    }

    /**
     * @notice This method returns an array of fingerprints supported by the oracle.
     * @dev Usefull for fetching all fingerprints in one go. If some fingerptint is not supported,
     * it means that it doesn't exists as far as the chain is concerned.
     * @return Array of fingerprints
     */
    function getFingerprints() external view returns (uint256[] memory) {
        // return from chainlink oracle
        return chainlinkRWAOracle.getFingerprintsAll();
    }

    /**
     * @notice This method is used to get the length of the oracle's fingerprints array.
     * @dev For off-chain purposes
     * @return Num of fingerprints in the oracle aka length of fingerprints array.
     */
    function getFingerprintsLength() external view returns (uint256) {
        // return from chainlink oracle
        return chainlinkRWAOracle.getFingerprintsLength();
    }

    // ~ Internal Functions ~

    /**
     * @notice This method returns the exchange rate between native price and USD,
     * @param nativePrice price in native currency, GBP.
     * @param currencyISONum Numeric ISO code for currency
     * @return Price in USD from native price provided, given the current exchange rate.
     */
    function _convertNativePriceToUSD(
        uint256 nativePrice,
        uint16 currencyISONum
    ) internal view returns (uint256) {
        // take it differently from currency feed
        AggregatorV3Interface priceFeedNativeToUSD = currencyFeed.currencyPriceFeedsISONum(
            currencyISONum
        );
        (, int256 price, , uint256 _latestTimeStamp, ) = priceFeedNativeToUSD.latestRoundData();
        require(block.timestamp - _latestTimeStamp <= 1 days, "Stale currency feed");
        if (price < 0) {
            price = 0;
        }
        //add conversion premium
        uint256 nativeToUSD = uint256(price) +
            currencyFeed.conversionPremiumsISONum(currencyISONum);
        return (nativePrice * nativeToUSD) / 10 ** uint256(priceFeedNativeToUSD.decimals());
    }

    /**
     * @notice This method returns the USD price data of a specified real estate asset.
     */
    function _usdPrice(
        ITangibleNFT _nft,
        IERC20Metadata _paymentUSDToken,
        uint256 _fingerprint,
        uint256 _tokenId
    ) internal view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost) {
        require(
            (address(_nft) != address(0) && _tokenId != 0) || (_fingerprint != 0),
            "Must provide fingerpeint or tokenId"
        );
        if (_fingerprint == 0) {
            _fingerprint = _nft.tokensFingerprint(_tokenId);
        }
        uint8 localDecimals = chainlinkRWAOracle.getDecimals();

        require(
            _fingerprint != 0 && chainlinkRWAOracle.fingerprintExists(_fingerprint),
            "fingerprint must exist"
        );
        IChainlinkRWAOracle.Data memory fingData = chainlinkRWAOracle.fingerprintData(_fingerprint);

        tokenizationCost = toDecimals(
            _convertNativePriceToUSD(fingData.lockedAmount, fingData.currency),
            localDecimals,
            _paymentUSDToken.decimals()
        );

        weSellAt = toDecimals(
            _convertNativePriceToUSD(fingData.weSellAt, fingData.currency),
            localDecimals,
            _paymentUSDToken.decimals()
        );

        weSellAtStock = fingData.weSellAtStock;
    }
}
