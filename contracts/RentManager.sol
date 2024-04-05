// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "./interfaces/IRentManager.sol";
import "./interfaces/IRentNotificationDispatcher.sol";

import "./interfaces/ITangibleNFT.sol";
import "./interfaces/IUSTB.sol";

import "./abstract/FactoryModifiers.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title Rent Manager
 * @author Veljko Mihailovic, Caesar LaVey
 * @dev This contract is a system for managing the deposit, vesting, and claiming of rent for NFTs.
 *
 * This contract allows depositor to deposit rent for specific NFTs, users can check how much rent is claimable for a token, claim the
 * rent for a token, depositor can do stop of vesting, claim remaining and reset data for tokenId.
 *
 * The system supports regular NFTs (TNFTs).
 *
 * The contract uses a time-based linear vesting system. A user can deposit rent for a token for a specified period of
 * time. We have 2 options - enum based values representing months with 31, 30, 28 and 29 days. For custom end time it can
 * be from moment of depositing up to 2 months period.
 * The rent then vests linearly over that period, and the owner of the token can claim the vested rent at any time.
 *
 * The contract keeps track of the deposited, claimed, and unclaimed amounts for each token.
 * Also it takes care of backpayment so if there was no rent deposited for 10 days after previous rent vest expired,
 * It starts vesting from the moment the old vest stopped.
 * With pause and claim back, you reset end time, take what is left, claim what is for the owner.
 *
 * The contract also provides a function to calculate the claimable rent for a token.
 *
 * The contract emits events for rent deposits.
 *
 * @custom:tester Milica Mihailovic
 */
contract RentManager is IRentManager, FactoryModifiers {
    using EnumerableSet for EnumerableSet.UintSet;
    using Math for uint256;
    using SafeERC20 for IERC20;

    // ~ State Variables ~

    /// @notice Used to store the contract address of the TangibleNFT contract address(this) manages rent for.
    address public TNFT_ADDRESS;

    /// @notice Used to store the address that deposits rent into this contract.
    address public depositor;

    // Mapping: tokenId => RentInfo
    mapping(uint256 => RentInfo) public rentInfo;

    // @notice Used to store the address that will be notified when rent is deposited for a token.
    address public notificationDispatcher;

    // ~ Events ~

    /**
     * @notice Emitted when rent is deposited for a token.
     * @param depositor The address of the user who deposited the rent.
     * @param tokenId The ID of the token for which rent was deposited.
     * @param rentToken The address of the token used to pay the rent.
     * @param amount The amount of rent deposited.
     */
    event RentDeposited(
        address depositor,
        uint256 indexed tokenId,
        address rentToken,
        uint256 amount
    );

    /**
     * @notice Emitted when rent is claimed for a token.
     * @param claimer The address of the user who claimed the rent.
     * @param nft The address of the NFT contract.
     * @param tokenId The ID of the token for which rent was claimed.
     * @param rentToken The address of the token used to pay the rent.
     * @param amount The amount of rent claimed.
     */
    event RentClaimed(
        address indexed claimer,
        address indexed nft,
        uint256 indexed tokenId,
        address rentToken,
        uint256 amount
    );

    /**
     * @notice Emitted when rent distribution is paused for token.
     * @param rentToken Token used for the rent.
     * @param tokenId The tokenId for which we stopped distribution.
     * @param claimedBack The amount we claimed back when stopping the distribution.
     * @param depositAmount Original deposit amount.
     * @param vestedFor Time between deposit and stop.
     * @param depositTime Original deposit time of the distribution amount.
     */
    event DistributionPaused(
        address indexed rentToken,
        uint256 indexed tokenId,
        uint256 claimedBack,
        uint256 depositAmount,
        uint256 vestedFor,
        uint256 depositTime
    );

    // ~ Enums ~

    /**
     * @notice Enum object to identify a custom contract data type via an enumerable.
     * @param DAYS_31 Month has 31 days (0)
     * @param DAYS_30 Month has 30 days (1)
     * @param DAYS_28 Month has 28 days (2)
     * @param DAYS_29 Month has 29 days (3)
     */
    enum DEPOSIT_MONTH {
        DAYS_31,
        DAYS_30,
        DAYS_28,
        DAYS_29
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ~ Initializer ~

    /**
     * @dev Constructor that initializes the TNFT contract address.
     * @param _tnftAddress The address of the TNFT contract.
     */
    function initialize(address _tnftAddress, address _factory) external initializer {
        require(_tnftAddress != address(0), "zero address");
        __FactoryModifiers_init(_factory);
        TNFT_ADDRESS = _tnftAddress;
        depositor = IFactory(_factory).categoryOwner(ITangibleNFT(_tnftAddress));
    }

    // ~ Functions ~

    /**
     * @dev Function to update the address of the rent depositor.
     * Only callable by the owner of the contract.
     * @param _newDepositor The address of the new rent depositor.
     */
    function updateDepositor(
        address _newDepositor
    ) external onlyCategoryOwner(ITangibleNFT(TNFT_ADDRESS)) {
        require(_newDepositor != address(0), "Depositor address cannot be 0");
        depositor = _newDepositor;
    }

    /**
     * @dev Function to disable rebasing of tngbl foundation tokens.
     * @param _token The address of the rebasing token.
     * @param _disable True if we want to disable rebase, false if we want to enable it.
     */
    function disableRebaseOfRentToken(
        address _token,
        bool _disable
    ) external onlyCategoryOwner(ITangibleNFT(TNFT_ADDRESS)) {
        require(_token != address(0), "Token address cannot be 0");
        IUSTB(_token).disableRebase(address(this), _disable);
    }

    /**
     * @dev Function to update the address of the rent depositor.
     * Only callable by the owner of the contract.
     * @param _newNotificationDistpatcher The address of the new rent depositor.
     */
    function updateNotificationDispatcher(
        address _newNotificationDistpatcher
    ) external onlyCategoryOwner(ITangibleNFT(TNFT_ADDRESS)) {
        require(_newNotificationDistpatcher != address(0), "address 0");
        notificationDispatcher = _newNotificationDistpatcher;
    }

    /**
     * @notice Allows the rent depositor to deposit rent for a specific token.
     *
     * @dev This function requires the caller to be the current rent depositor.
     * It also checks whether the specified end time is in the future.
     * If the token's current rent token is either the zero address or the same as the provided token address,
     * the function allows the deposit.
     *
     * The function first transfers the specified amount of the rent token from the depositor to the contract.
     * If the token's rent token is the zero address, it sets the rent token to the provided token address.
     *
     * The function then calculates the token's vested amount.

     * The function then calculates the token's unvested amount, updates the token's unclaimed amount,
     * resets the token's claimed amount, adds the deposit amount to the token's unvested amount,
     * updates the deposit time, and sets the end time.
     *
     * Finally, the function emits a `RentDeposited` event.
     *
     * @param tokenId The ID of the token for which to deposit rent.
     * @param tokenAddress The address of the rent token to deposit.
     * @param amount The amount of the rent token to deposit.
     * @param month Enum representing length of a month in days.
     * @param endTime The end time of the rent deposit.
     * @param skipBackpayment By default - we backpay every rent.
     */
    function deposit(
        uint256 tokenId,
        address tokenAddress,
        uint256 amount,
        uint256 month,
        uint256 endTime,
        bool skipBackpayment
    ) external {
        require(msg.sender == depositor, "Only the rent depositor can call this function");
        if (endTime != 0) {
            require(endTime > block.timestamp, "End time must be in the future");
            require(
                endTime <= block.timestamp + 2 * _monthLength(DEPOSIT_MONTH.DAYS_31),
                "End time must be in 2 months tops"
            );
        }
        RentInfo storage rent = rentInfo[tokenId];
        require(
            rent.rentToken == address(0) || rent.rentToken == tokenAddress,
            "Invalid rent token"
        );
        // with this we ensure to put rent only when everything is vested
        require(rent.endTime < block.timestamp, "Not completely vested");

        uint256 balance = IERC20(tokenAddress).balanceOf(msg.sender);
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
        uint256 balanceAfter = IERC20(tokenAddress).balanceOf(msg.sender);
        // just in case it's rebase token, set the proper taken amount
        amount = balance - balanceAfter;

        if (rent.rentToken == address(0)) {
            rent.rentToken = tokenAddress;
        }
        if (!rent.distributionRunning) {
            rent.distributionRunning = true;
        }
        // vested amount is complete because of condition above
        rent.unclaimedAmount += rent.depositAmount - rent.claimedAmount;
        rent.depositAmount = amount;
        rent.claimedAmount = 0;

        if (!skipBackpayment) {
            // first deposit
            rent.depositTime = rent.endTime != 0 ? rent.endTime : block.timestamp;
        } else {
            rent.depositTime = block.timestamp;
        }
        // set end time
        rent.endTime = endTime == 0
            ? rent.depositTime + _monthLength(DEPOSIT_MONTH(month))
            : endTime;

        emit RentDeposited(msg.sender, tokenId, tokenAddress, amount);
        if (notificationDispatcher != address(0)) {
            IRentNotificationDispatcher(notificationDispatcher).notify(
                address(this),
                tokenId,
                rent.unclaimedAmount,
                amount,
                rent.depositTime,
                rent.endTime
            );
        }
    }

    /**
     * @notice Checks if distribution for specified tokenId is running or not.
     * @dev Useful for checking if rent distro is stopped.
     * @param tokenId TokenId for which to check if rent distribution is running
     * @return True if running, false if not
     */
    function distributionRunning(uint256 tokenId) external view returns (bool) {
        return rentInfo[tokenId].distributionRunning;
    }

    /**
     * @notice Pause distribution and claim back deposited amount.
     * @dev Claim for the owner.
     *  Reset everything to default values, except claimedAmountTotal.
     * @param tokenId TokenId for which to check if rent distribution is paused
     * @return amount Amount that we claimed back
     */
    function pauseAndClaimBackDistribution(uint256 tokenId) external returns (uint256 amount) {
        require(msg.sender == depositor, "Only the rent depositor can call this function");
        RentInfo storage rent = rentInfo[tokenId];
        // claim for owner of tnft
        _claimRentForToken(IERC721(TNFT_ADDRESS).ownerOf(tokenId), tokenId);
        // take the rest of the rent and reset
        amount = rent.depositAmount - rent.claimedAmount;
        emit DistributionPaused(
            rent.rentToken,
            tokenId,
            amount,
            rent.depositAmount,
            block.timestamp - rent.depositTime,
            rent.depositTime
        );
        IERC20(rent.rentToken).safeTransfer(depositor, amount);
        // reset
        rent.claimedAmount = 0;
        rent.depositAmount = 0;
        rent.distributionRunning = false;
        rent.endTime = 0;
        rent.depositTime = 0;
        rent.rentToken = address(0);
    }

    /**
     * @notice Returns the amount of rent that can be claimed for a given token.
     * @dev The function calculates the claimable rent based on the rent info of the token.
     * @param tokenId The ID of the token.
     * @return The amount of claimable rent for the token.
     */
    function claimableRentForToken(uint256 tokenId) public view returns (uint256) {
        return _claimableRentForToken(tokenId);
    }

    /**
     * @notice Returns the amount of rent that can be claimed for a given tokens.
     * @dev Returns the array of claimable rent for the tokens.
     * @param tokenIds The IDs of the tokens.
     * @return claimables The amounts of claimable rent per tokens.
     */
    function claimableRentForTokenBatch(
        uint256[] calldata tokenIds
    ) public view returns (uint256[] memory claimables) {
        uint256 length = tokenIds.length;
        claimables = new uint256[](length);
        for (uint256 i; i < length; ) {
            claimables[i] = _claimableRentForToken(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
        return claimables;
    }

    /**
     * @notice Returns the rent info array and claimables for a given tokenIds.
     * @param tokenIds The IDs of the tokens.
     */
    function claimableRentInfoBatch(
        uint256[] calldata tokenIds
    ) external view returns (RentInfo[] memory rentInfos, uint256[] memory claimables) {
        uint256 length = tokenIds.length;
        rentInfos = new RentInfo[](length);
        claimables = new uint256[](length);
        for (uint256 i; i < length; ) {
            (claimables[i], rentInfos[i]) = _claimableRentInfoForToken(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Returns the total amount of rent that can be claimed for a given tokens.
     * @dev The function calculates the total claimable rent based on the rent info of the tokens.
     * @param tokenIds The IDs of the tokens.
     * @return claimable The amount of claimable rent in total.
     */
    function claimableRentForTokenBatchTotal(
        uint256[] calldata tokenIds
    ) public view returns (uint256 claimable) {
        uint256 length = tokenIds.length;
        for (uint256 i; i < length; ) {
            claimable += _claimableRentForToken(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
        return claimable;
    }

    /**
     * @notice Internal function that returns how much you can claim for the token
     * @dev If distribution is not running, you can't claim anything.
     * @param tokenId TokenId for which return the claimable rent
     */
    function _claimableRentForToken(uint256 tokenId) internal view returns (uint256) {
        RentInfo storage rent = rentInfo[tokenId];
        if (!rent.distributionRunning) {
            return 0;
        }
        return rent.unclaimedAmount + _vestedAmount(rent) - rent.claimedAmount;
    }

    /**
     * @notice Internal function that returns how much you can claim for the token and whole rentInfo
     * @param tokenId TokenId for which return the claimable rent
     */
    function _claimableRentInfoForToken(
        uint256 tokenId
    ) internal view returns (uint256 claimable, RentInfo memory rInfo) {
        RentInfo storage rent = rentInfo[tokenId];
        if (rInfo.distributionRunning) {
            claimable = rent.unclaimedAmount + _vestedAmount(rent) - rent.claimedAmount;
            rInfo = rent;
        }
    }

    /**
     * @notice Allows the owner of a token to claim their rent.
     * @dev The function first checks that the caller is the owner of the token.
     * It then retrieves the amount of claimable rent for the token and requires that the amount is greater than zero,
     * and that the token is either not a TNFT.
     *
     * In both cases, the function updates the claimed and unclaimed amounts of the rent info of the corresponding TNFT
     * token.
     *
     * The function then transfers the claimable rent to the caller and emits a `RentClaimed` event.
     *
     * @param tokenId The ID of the token.
     */
    function claimRentForToken(uint256 tokenId) external returns (uint256) {
        IERC721 nftContract = IERC721(TNFT_ADDRESS);
        require(nftContract.ownerOf(tokenId) == msg.sender, "Caller is not the owner of the token");

        return _claimRentForToken(msg.sender, tokenId);
    }

    /**
     * @notice Allows the owner of a tokens to claim their rent.
     * @dev Returns how much you have claimed for each token.
     * @param tokenIds The IDs of the tokens.
     */
    function claimRentForTokenBatch(
        uint256[] calldata tokenIds
    ) external returns (uint256[] memory claimed) {
        IERC721 nftContract = IERC721(TNFT_ADDRESS);
        uint256 length = tokenIds.length;
        claimed = new uint256[](length);
        for (uint256 i; i < length; ) {
            require(
                nftContract.ownerOf(tokenIds[i]) == msg.sender,
                "Caller is not the owner of the token"
            );
            claimed[i] = _claimRentForToken(msg.sender, tokenIds[i]);
            unchecked {
                ++i;
            }
        }

        return claimed;
    }

    /**
     * @notice Allows the owner of a tokens to claim their rent. Internal helper function.
     * @param to To whom to send the rent
     * @param tokenId TokenId for which to claim the rent
     */
    function _claimRentForToken(
        address to,
        uint256 tokenId
    ) internal returns (uint256 claimableRent) {
        claimableRent = _claimableRentForToken(tokenId);
        require(claimableRent != 0, "No rent to claim");

        RentInfo storage rent = rentInfo[tokenId];

        if (rent.unclaimedAmount > 0) {
            if (rent.unclaimedAmount < claimableRent) {
                unchecked {
                    rent.claimedAmount += claimableRent - rent.unclaimedAmount;
                    rent.claimedAmountTotal += claimableRent;
                    rent.unclaimedAmount = 0;
                }
            } else {
                // this should never happen
                unchecked {
                    rent.unclaimedAmount -= claimableRent;
                    rent.claimedAmountTotal += claimableRent;
                }
            }
        } else {
            rent.claimedAmount += claimableRent;
            rent.claimedAmountTotal += claimableRent;
        }
        uint256 balance = IERC20(rent.rentToken).balanceOf(address(this));
        IERC20(rent.rentToken).safeTransfer(to, claimableRent);
        uint256 balanceAfter = IERC20(rent.rentToken).balanceOf(address(this));
        if((balance - balanceAfter) < claimableRent) {
            // if we have a difference it's rebasing token and, we need to adjust
            // rentInfo
            uint256 diff = claimableRent - (balance - balanceAfter);
            rent.claimedAmount -= diff;
            rent.claimedAmountTotal -= diff;
            claimableRent -= diff;
        }


        emit RentClaimed(to, TNFT_ADDRESS, tokenId, rent.rentToken, claimableRent);
    }

    /**
     * @notice Calculates the vested amount for a rent deposit - public function.
     * @dev If the current time is past the end time of the rent period, the function returns the deposit amount.
     * If the current time is before the end time of the rent period, the function calculates the vested amount based on
     * the elapsed time and the vesting duration.
     *
     * @param tokenId TokenId for which to check vested amount.
     * @return The vested amount for the rent deposit.
     */
    function vestedAmount(uint256 tokenId) external view returns (uint256) {
        return _vestedAmount(rentInfo[tokenId]);
    }

    /**
     * @notice Calculates the vested amount for a rent deposit.
     *
     * @dev If the current time is past the end time of the rent period, the function returns the deposit amount.
     * If the current time is before the end time of the rent period, the function calculates the vested amount based on
     * the elapsed time and the vesting duration.
     *
     * @param rent The storage pointer to the rent info of a token.
     * @return The vested amount for the rent deposit.
     */
    function _vestedAmount(RentInfo storage rent) private view returns (uint256) {
        if (block.timestamp >= rent.endTime) {
            return rent.depositAmount;
        } else {
            uint256 elapsedTime = block.timestamp - rent.depositTime;
            uint256 vestingDuration = rent.endTime - rent.depositTime;
            return rent.depositAmount.mulDiv(elapsedTime, vestingDuration);
        }
    }

    /**
     * @notice Returns number of days depending on a month in seconds.
     *
     * @param month Enum representing on of 4 lengths of a month.
     * @return The number of seconds that each month has.
     */
    function _monthLength(DEPOSIT_MONTH month) internal pure returns (uint256) {
        if (month == DEPOSIT_MONTH.DAYS_31) {
            return 31 days;
        } else if (month == DEPOSIT_MONTH.DAYS_30) {
            return 30 days;
        } else if (month == DEPOSIT_MONTH.DAYS_28) {
            return 28 days;
        } else if (month == DEPOSIT_MONTH.DAYS_29) {
            return 29 days;
        } else {
            return 30 days;
        }
    }
}
