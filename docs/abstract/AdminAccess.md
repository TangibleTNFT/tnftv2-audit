# Solidity API

## AdminAccess

### FACTORY_ROLE

```solidity
bytes32 FACTORY_ROLE
```

### onlyAdmin

```solidity
modifier onlyAdmin()
```

_Restricted to members of the admin role._

### constructor

```solidity
constructor() internal
```

### isAdmin

```solidity
function isAdmin(address account) internal view returns (bool)
```

_Return `true` if the account belongs to the admin role._

### onlyFactory

```solidity
modifier onlyFactory()
```

_Restricted to members of the factory role._

### isFactory

```solidity
function isFactory(address account) internal view returns (bool)
```

_Return `true` if the account belongs to the factory role._

### isAdminOrFactory

```solidity
function isAdminOrFactory(address account) internal view returns (bool)
```

_Return `true` if the account belongs to the factory role or admin role._

### onlyFactoryOrAdmin

```solidity
modifier onlyFactoryOrAdmin()
```

