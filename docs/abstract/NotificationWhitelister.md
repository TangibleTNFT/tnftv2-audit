# Solidity API

## NotificationWhitelister

Meant to be inherited by implementation contracts for specific Notifications

_This contract is keep track of couple of things:
- Which addresses are whitelisted to register for notification
- Which addresses are approved to whitelist other addresses
- Which addresses are registered for notification for specific tnft token
It is used to pass notification to the registered addresses.
The flow is separated in couple of steps:
- We need to approve address that can whitelist other addresses for notification
- We need to whitelist address that can register itself for notification
- And finally, whitelisted address, can register for notifications regarding specific token_

### NotificationWhitelisterStorage

```solidity
struct NotificationWhitelisterStorage {
  mapping(address => mapping(uint256 => address)) registeredForNotification;
  mapping(address => bool) whitelistedReceiver;
  mapping(address => bool) approvedWhitelisters;
  contract ITangibleNFT tnft;
}
```

### onlyApprovedWhitelister

```solidity
modifier onlyApprovedWhitelister()
```

This modifier is used to check if the caller is approved whitelister

### __NotificationWhitelister_init

```solidity
function __NotificationWhitelister_init(address _factory, address _tnft) internal
```

This is init function for NotificationWhitelister contract, to be
used by inheritor.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Address of the factory contract |
| _tnft | address | Address of the tnft contract for which it handles notifications |

### tnft

```solidity
function tnft() public view virtual returns (contract ITangibleNFT)
```

Returns the tnft address for which it handles notifications

### registeredForNotification

```solidity
function registeredForNotification(address _tnft, uint256 _tokenId) public view virtual returns (address)
```

Returns the address that is registered for notification for specific tnft token

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tnft | address | Address of the tnft contract for which it handles notifications |
| _tokenId | uint256 | TokenId for which the address will be registered for notification |

### whitelistedReceiver

```solidity
function whitelistedReceiver(address _receiver) public view virtual returns (bool)
```

Returns the address that is whitelisted that can register for notification

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _receiver | address | The address to check if it is whitelisted |

### approvedWhitelisters

```solidity
function approvedWhitelisters(address _whitelister) public view virtual returns (bool)
```

Returns the address that is approved whitelister

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _whitelister | address | The address to check if it is approved whitelister |

### addWhitelister

```solidity
function addWhitelister(address _whitelister) external
```

adds an address that can whitelist others,

_only callable by the category owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _whitelister | address | Address that can whitelist other addresses besides category owner |

### removeWhitelister

```solidity
function removeWhitelister(address _whitelister) external
```

removes an address that can whitelist others,

_only callable by the category owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _whitelister | address | Address that can whitelist other addresses besides category owner |

### whitelistAddressAndReceiver

```solidity
function whitelistAddressAndReceiver(address receiver) external
```

Adds an address that will be whitelisted so that it
 register for notification

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver | address | Address that will be whitelisted |

### blacklistAddress

```solidity
function blacklistAddress(address receiver) external
```

Removes an address and that address can't register for notification
anymore

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver | address | Address that will be blacklisted |

### registerUnregisterForNotification

```solidity
function registerUnregisterForNotification(uint256 tokenId, address receiver, bool register) external
```

Registers or unregisters an address for notification,

_only callable by the category owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TokenId for which the address will be registered for notification |
| receiver | address | Address that will be registered for notification |
| register | bool | Boolean that determines if the address will be registered or unregistered |

### registerForNotification

```solidity
function registerForNotification(uint256 tokenId) external
```

@notice Whitelisted address calls this to registed for notification
for specific token id

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TokenId for which the address will be registered for notification |

### unregisterForNotification

```solidity
function unregisterForNotification(uint256 tokenId) external
```

Whitelisted address is unregistering from notifications
for specific token id

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TokenId for which the address will be unregistered for notification |

### _checkApprover

```solidity
function _checkApprover() internal view
```

Checks if the address is approved whitelister

