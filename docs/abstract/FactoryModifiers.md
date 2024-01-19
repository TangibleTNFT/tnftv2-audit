# Solidity API

## FactoryModifiers

This contract offers permissioned modifiers for contracts that have factory.

_The whole TNFT marketplace contracts system is revolving around the Factory and through it,
then management and maintenance system. Every contract in the ecosystem inherits this contract
and thus has the same ownership. The reason behind this is that we have couple
of factories that spawn contracts. The protocol is designed to be dynamic, to support various
vendors comming and offering their RWA products on our marketplace.
With this contract, we enable proper access management and that all contracts have the latest factory.
Being a protocol, we have a couple of different roles that any vendor must oblige and has
its own responsibilities. The roles are:
- Factory owner: The owner of the factory is the one that deployed the factory contract.
- Factory: The factory is the contract that spawns other contracts, is proxy for others etc. Since it is
 being a proxy for others, means that only Factory contract can make state changes on various places
- Category owner: The owner of the category is the one that deployed the category contract. Vendor.
- Fingerprint approver: The fingerprint approver is the one that approves the fingerprints of the NFT.
  Address should be a multisig that is not controlled by the vendor, a 3rd party that will verify that
 the NFT is not a copy of some other NFT.products they want to bring to marketplace are ok.
- Tangible Labs: The Tangible Labs is the multisig that is controlled by the Tangible Labs team._

### FactoryModifiersStorage

```solidity
struct FactoryModifiersStorage {
  address _factory;
}
```

### factory

```solidity
function factory() public view virtual returns (address)
```

This internal method is used to get the Factory contract address.

### onlyFactoryOwner

```solidity
modifier onlyFactoryOwner()
```

This modifier is used to verify msg.sender is the factory contract owner.

### onlyFactory

```solidity
modifier onlyFactory()
```

This modifier is used to verify msg.sender is the Factory contract.

### onlyCategoryOwner

```solidity
modifier onlyCategoryOwner(contract ITangibleNFT tnft)
```

This modifier is used to verify msg.sender is the category owner.

### onlyFingerprintApprover

```solidity
modifier onlyFingerprintApprover()
```

This modifier is used to verify msg.sender is approval manager.

### onlyTangibleLabs

```solidity
modifier onlyTangibleLabs()
```

This modifier is used to verify msg.sender is the tangible labs multisig.

### __FactoryModifiers_init

```solidity
function __FactoryModifiers_init(address _factory) internal
```

### _checkFactoryOwner

```solidity
function _checkFactoryOwner() internal view
```

This internal method is used to check if msg.sender is the Factory owner.

_Only called by modifier `onlyFactoryOwner`. Meant to reduce bytecode size_

### _checkFactory

```solidity
function _checkFactory() internal view
```

This internal method is used to check if msg.sender is the Factory contract.

_Only called by modifier `onlyFactory`. Meant to reduce bytecode size_

### _checkCategoryOwner

```solidity
function _checkCategoryOwner(contract ITangibleNFT tnft) internal view
```

This internal method is used to check if msg.sender is the category owner.

_Only called by modifier `onlyCategoryOwner`. Meant to reduce bytecode size_

### _checkFingerprintApprover

```solidity
function _checkFingerprintApprover() internal view
```

This internal method is used to check if msg.sender is the fingerprint approval manager.

_Only called by modifier `onlyFingerprintApprover`. Meant to reduce bytecode size_

### _checkTangibleLabs

```solidity
function _checkTangibleLabs() internal view
```

This internal method is used to check if msg.sender is the Tangible Labs multisig.

_Only called by modifier `onlyTangibleLabs`. Meant to reduce bytecode size_

