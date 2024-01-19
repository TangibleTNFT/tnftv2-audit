// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "../abstract/NotificationWhitelister.sol";
import "../interfaces/ITangibleNFT.sol";
import "../interfaces/ITangiblePriceManager.sol";
import "../interfaces/IPriceOracle.sol";
import "../interfaces/IRWAPriceNotificationDispatcher.sol";
import "./IRWAPriceNotificationReceiver.sol";

/**
 * @title RWAPriceNotificationDispatcher
 * @author Veljko Mihailovic
 * @notice This contract is used to push notification on rwa price change.
 * @dev When a price is updated in the Tnft oracle(an underlying oracle
 * developed with chainlink standard) for specific fingerprint,
 * this contract is called to notify the registered addresses for that fingerprint.
 * Registered addresses must be owners of the tnft token which has that specific fingerprint.
 * Tnft oracles can have this dispatcher in them like RealtyOracle.
 */
contract RWAPriceNotificationDispatcher is
    IRWAPriceNotificationDispatcher,
    NotificationWhitelister
{
    // ~ Events ~
    /**
     * @notice This event is emitted when a notification is sent to a registered address.
     * @param receiver Address that is notified
     * @param fingerprint Item ofr which the price has ben updated
     * @param currency Currency in which the price is expressed
     * @param oldNativePrice old price of the item, native currency
     * @param newNativePrice old price of the item, native currency
     */
    event Notified(
        address indexed receiver,
        uint256 indexed fingerprint,
        uint16 indexed currency,
        uint256 oldNativePrice,
        uint256 newNativePrice
    );

    // ~ Modifiers ~
    /**
     * @notice This modifier is used to check if the caller is the oracle for the tnft
     */
    modifier onlyTnftOracle() {
        require(
            msg.sender == address(IFactory(factory()).priceManager().oracleForCategory(tnft())),
            "Not ok oracle"
        );
        _;
    }

    // ~ Initialize ~
    /**
     *
     * @param _factory Factory contract address
     * @param _tnft Tnft address for which notifications are registered
     */
    function initialize(address _factory, address _tnft) external initializer {
        __NotificationWhitelister_init(_factory, _tnft);
    }

    // ~ External Functions ~
    /**
     * @notice This function is used to notify registered addresses for specific fingerprint.
     * @dev This function is called by the Tnft oracle it belongs to.
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
    ) external onlyTnftOracle {
        ITangibleNFT _tnft = tnft();
        uint256 tokenId = _tnft.fingerprintTokens(fingerprint, 0);
        if (tokenId != 0) {
            // if in if to save gas
            address receiver = registeredForNotification(address(_tnft), tokenId);
            if (receiver != address(0)) {
                IRWAPriceNotificationReceiver(receiver).notify(
                    address(_tnft),
                    tokenId,
                    fingerprint,
                    oldNativePrice,
                    newNativePrice,
                    currency
                );
                emit Notified(receiver, fingerprint, currency, oldNativePrice, newNativePrice);
            }
        }
    }
}
