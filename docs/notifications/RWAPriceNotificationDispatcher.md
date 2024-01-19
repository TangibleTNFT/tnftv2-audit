# Solidity API

## RWAPriceNotificationDispatcher

This contract is used to push notification on rwa price change.

_When a price is updated in the Tnft oracle(an underlying oracle
developed with chainlink standard) for specific fingerprint,
this contract is called to notify the registered addresses for that fingerprint.
Registered addresses must be owners of the tnft token which has that specific fingerprint.
Tnft oracles can have this dispatcher in them like RealtyOracle._

### Notified

```solidity
event Notified(address receiver, uint256 fingerprint, uint16 currency, uint256 oldNativePrice, uint256 newNativePrice)
```

This event is emitted when a notification is sent to a registered address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver | address | Address that is notified |
| fingerprint | uint256 | Item ofr which the price has ben updated |
| currency | uint16 | Currency in which the price is expressed |
| oldNativePrice | uint256 | old price of the item, native currency |
| newNativePrice | uint256 | old price of the item, native currency |

### onlyTnftOracle

```solidity
modifier onlyTnftOracle()
```

This modifier is used to check if the caller is the oracle for the tnft

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
function notify(uint256 fingerprint, uint256 oldNativePrice, uint256 newNativePrice, uint16 currency) external
```

This function is used to notify registered addresses for specific fingerprint.

_This function is called by the Tnft oracle it belongs to._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprint | uint256 | Item ofr which the price has changed |
| oldNativePrice | uint256 | old price of the item, native currency |
| newNativePrice | uint256 | old price of the item, native currency |
| currency | uint16 | Currency in which the price is expressed |

