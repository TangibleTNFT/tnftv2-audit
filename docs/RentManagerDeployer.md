# Solidity API

## RentManagerDeployer

This contract is used to deploy new RentManager contracts.

_Implement Beacon proxy mechanism to deploy new RentManager contracts.
It is possible to upgrade RentManager implementation when needed and it
is reflected to all RentManagers._

### rentManagersBeaconProxy

```solidity
mapping(address => address) rentManagersBeaconProxy
```

notice Tnft contract address => RentManager beacon proxy address.

### beacon

```solidity
contract UpgradeableBeacon beacon
```

UpgradeableBeacon contract instance. Deployed by this contract upon initialization.

### implementation

```solidity
contract RentManager implementation
```

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory) external
```

Initializes the RentManagerDeployer contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Address for the  Factory contract. |

### deployRentManager

```solidity
function deployRentManager(address tnft) external returns (contract IRentManager)
```

This method will deploy a new RentManager contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | address | Address of TangibleNFT contract the new RentManager will manage rent for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | contract IRentManager | Returns a reference to the new RentManager. |

### updateRentManagerImplementation

```solidity
function updateRentManagerImplementation() external
```

This function allows the factory owner to update the RentManager implementation.

