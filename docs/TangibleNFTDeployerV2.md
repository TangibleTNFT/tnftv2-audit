# Solidity API

## TangibleNFTDeployerV2

This contract is used to deploy new TangibleNFT contracts.

_Implements Beacon proxy mechanism to deploy new TangibleNFT contracts.
It is possible to upgrade TangibleNFT implementation when needed and it
is reflected to all TangibleNFTs._

### tnftBeaconProxy

```solidity
mapping(string => address) tnftBeaconProxy
```

notice tnft symbol => TangibleNFT beacon proxy address.

### beacon

```solidity
contract UpgradeableBeacon beacon
```

UpgradeableBeacon contract instance. Deployed by this contract upon initialization.

### implementation

```solidity
contract TangibleNFTV2 implementation
```

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory) external
```

Initializes the TangibleNFTDeployer contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Address for the  Factory contract. |

### deployTnft

```solidity
function deployTnft(string name, string symbol, string uri, bool isStoragePriceFixedAmount, bool storageRequired, bool _symbolInUri, uint256 _tnftType) external returns (contract ITangibleNFT)
```

This method will deploy a new TangibleNFT contract.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | contract ITangibleNFT | Returns a reference to the new TangibleNFT contract. |

### updateTnftImplementation

```solidity
function updateTnftImplementation() external
```

This function allows the factory owner to update the TangibleNFTV2 implementation.

