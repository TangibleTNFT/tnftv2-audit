# Solidity API

## RentNotificationDispatcher

This contract is used to push notification on rent deposits.

_When a rent is deposited in the RentManager for specific tokenId, this contract is called to notify
the registered addresses for that tokenId. If there is no such address, nothing happens._

### rentManager

```solidity
address rentManager
```

### Notified

```solidity
event Notified(address receiver, uint256 tokenID, uint256 unclaimedAmount, uint256 newDeposit)
```

This event is emitted when a notification is sent to a registered address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver | address | Address that is notified |
| tokenID | uint256 | TokenID for which the rent is deposited |
| unclaimedAmount | uint256 | Amount of unclaimed rent |
| newDeposit | uint256 | New deposit of the rent |

### onlyTnftRentManager

```solidity
modifier onlyTnftRentManager()
```

### initialize

```solidity
function initialize(address _factory, address _tnft) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Factory contract address |
| _tnft | address | Tnft address for which notifications are registered |

### notify

```solidity
function notify(address _tnft, uint256 tokenId, uint256 unclaimedAmount, uint256 newDeposit, uint256 startTime, uint256 endTime) external
```

This function is used to notify registered addresses for specific tokenID.

_This function is called by the RentManager contract it belongs to.
 If there is no registered address for the tokenID, nothing happens._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tnft | address | Tnft address for which notifications are registered |
| tokenId | uint256 | tokenID for which the price has changed |
| unclaimedAmount | uint256 | Amount of unclaimed rent |
| newDeposit | uint256 | New deposit of the rent |
| startTime | uint256 | When the rent vesting started |
| endTime | uint256 | When the rent vesting ends |

