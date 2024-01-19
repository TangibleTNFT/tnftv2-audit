// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "./FactoryModifiers.sol";
import "../interfaces/ITangibleNFT.sol";
import "../interfaces/INotificationWhitelister.sol";

/**
 * @title NotificationWhitelister
 * @author Veljko Mihailovic
 * @notice Meant to be inherited by implementation contracts for specific Notifications
 * @dev This contract is keep track of couple of things:
 * - Which addresses are whitelisted to register for notification
 * - Which addresses are approved to whitelist other addresses
 * - Which addresses are registered for notification for specific tnft token
 * It is used to pass notification to the registered addresses.
 * The flow is separated in couple of steps:
 * - We need to approve address that can whitelist other addresses for notification
 * - We need to whitelist address that can register itself for notification
 * - And finally, whitelisted address, can register for notifications regarding specific token
 */
abstract contract NotificationWhitelister is FactoryModifiers, INotificationWhitelister {
    /// @custom:storage-location erc7201:tangible.storage.NotificationWhitelister
    struct NotificationWhitelisterStorage {
        /// @notice mapping of tnft tokenIds to addresses that are registered for notification
        mapping(address => mapping(uint256 => address)) registeredForNotification;
        /// @notice mapping of whitelisted addresses that can register for notification
        mapping(address => bool) whitelistedReceiver;
        /// @dev mapping of addresses that can whitelist other addresses
        mapping(address => bool) approvedWhitelisters;
        /// @notice  tnft for which tokens are registered for notification
        ITangibleNFT tnft;
    }

    // keccak256(abi.encode(uint256(keccak256("tangible.storage.NotificationWhitelister")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant NotificationWhitelisterStorageLocation =
        0x212c2e666f9b1835ae76799b54e7464b437586737923bee1d2bd33a2e4bfcd00;

    /**
     * @notice This internal method is used to get the NotificationWhitelisterStorage struct.
     */
    function _getNotificationWhitelisterStorage()
        private
        pure
        returns (NotificationWhitelisterStorage storage $)
    {
        assembly {
            $.slot := NotificationWhitelisterStorageLocation
        }
    }

    /**
     * @notice This modifier is used to check if the caller is approved whitelister
     */
    modifier onlyApprovedWhitelister() {
        _checkApprover();
        _;
    }

    /**
     * @notice This is init function for NotificationWhitelister contract, to be
     * used by inheritor.
     * @param _factory Address of the factory contract
     * @param _tnft Address of the tnft contract for which it handles notifications
     */
    function __NotificationWhitelister_init(
        address _factory,
        address _tnft
    ) internal onlyInitializing {
        __FactoryModifiers_init(_factory);
        require(_tnft != address(0), "TNFT 0");
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        $.tnft = ITangibleNFT(_tnft);
    }

    // ~ View function and setters, so that contract can be upgradeable

    /**
     * @notice Returns the tnft address for which it handles notifications
     */
    function tnft() public view virtual returns (ITangibleNFT) {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        return $.tnft;
    }

    /**
     * @notice Returns the address that is registered for notification for specific tnft token
     * @param _tnft Address of the tnft contract for which it handles notifications
     * @param _tokenId TokenId for which the address will be registered for notification
     */
    function registeredForNotification(
        address _tnft,
        uint256 _tokenId
    ) public view virtual returns (address) {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        return $.registeredForNotification[_tnft][_tokenId];
    }

    /**
     * @notice Returns the address that is whitelisted that can register for notification
     * @param _receiver The address to check if it is whitelisted
     */
    function whitelistedReceiver(address _receiver) public view virtual returns (bool) {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        return $.whitelistedReceiver[_receiver];
    }

    /**
     * @notice Returns the address that is approved whitelister
     * @param _whitelister The address to check if it is approved whitelister
     */
    function approvedWhitelisters(address _whitelister) public view virtual returns (bool) {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        return $.approvedWhitelisters[_whitelister];
    }

    // ~ Functions ~

    /**
     * @notice adds an address that can whitelist others,
     * @dev only callable by the category owner
     *
     * @param _whitelister Address that can whitelist other addresses besides category owner
     */
    function addWhitelister(address _whitelister) external onlyCategoryOwner(ITangibleNFT(tnft())) {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        $.approvedWhitelisters[_whitelister] = true;
    }

    /**
     * @notice removes an address that can whitelist others,
     * @dev only callable by the category owner
     *
     * @param _whitelister Address that can whitelist other addresses besides category owner
     */
    function removeWhitelister(
        address _whitelister
    ) external onlyCategoryOwner(ITangibleNFT(tnft())) {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        $.approvedWhitelisters[_whitelister] = false;
    }

    /**
     * @notice Adds an address that will be whitelisted so that it
     *  register for notification
     * @param receiver Address that will be whitelisted
     */
    function whitelistAddressAndReceiver(address receiver) external onlyApprovedWhitelister {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        require(!$.whitelistedReceiver[receiver], "Already whitelisted");
        $.whitelistedReceiver[receiver] = true;
    }

    /**
     * @notice Removes an address and that address can't register for notification
     * anymore
     * @param receiver Address that will be blacklisted
     */
    function blacklistAddress(address receiver) external onlyApprovedWhitelister {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        require($.whitelistedReceiver[receiver], "Not whitelisted");
        $.whitelistedReceiver[receiver] = false;
    }

    /**
     * @notice Registers or unregisters an address for notification,
     * @dev only callable by the category owner
     *
     * @param tokenId TokenId for which the address will be registered for notification
     * @param receiver Address that will be registered for notification
     * @param register Boolean that determines if the address will be registered or unregistered
     */
    function registerUnregisterForNotification(
        uint256 tokenId,
        address receiver,
        bool register
    ) external onlyCategoryOwner(ITangibleNFT(tnft())) {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        if (register) {
            $.registeredForNotification[address($.tnft)][tokenId] = receiver;
        } else {
            delete $.registeredForNotification[address($.tnft)][tokenId];
        }
    }

    /**
     *  @notice Whitelisted address calls this to registed for notification
     * for specific token id
     * @param tokenId TokenId for which the address will be registered for notification
     */
    function registerForNotification(uint256 tokenId) external {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        require($.whitelistedReceiver[msg.sender], "Not whitelisted");
        require($.tnft.ownerOf(tokenId) == msg.sender, "Not owner");
        $.registeredForNotification[address($.tnft)][tokenId] = msg.sender;
    }

    /**
     * @notice Whitelisted address is unregistering from notifications
     * for specific token id
     * @param tokenId TokenId for which the address will be unregistered for notification
     */
    function unregisterForNotification(uint256 tokenId) external {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        require($.whitelistedReceiver[msg.sender], "Not whitelisted");
        require($.tnft.ownerOf(tokenId) == msg.sender, "Not owner");
        delete $.registeredForNotification[address($.tnft)][tokenId];
    }

    /**
     * @notice Checks if the address is approved whitelister
     */
    function _checkApprover() internal view {
        NotificationWhitelisterStorage storage $ = _getNotificationWhitelisterStorage();
        require(
            IFactory(factory()).categoryOwner($.tnft) == msg.sender ||
                $.approvedWhitelisters[msg.sender],
            "NAPPW"
        );
    }
}
