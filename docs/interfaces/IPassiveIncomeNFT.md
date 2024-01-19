# Solidity API

## IPassiveIncomeNFT

### Lock

```solidity
struct Lock {
  uint256 startTime;
  uint256 endTime;
  uint256 tokenizationCost;
  uint256 multiplier;
  uint256 claimed;
  uint256 maxPayout;
}
```

### locks

```solidity
function locks(uint256 piTokenId) external view returns (struct IPassiveIncomeNFT.Lock lock)
```

### burn

```solidity
function burn(uint256 tokenId) external returns (uint256 amount)
```

### maxLockDuration

```solidity
function maxLockDuration() external view returns (uint8)
```

### claim

```solidity
function claim(uint256 tokenId, uint256 amount) external
```

### canEarnForAmount

```solidity
function canEarnForAmount(uint256 tngblAmount) external view returns (bool)
```

### claimableIncome

```solidity
function claimableIncome(uint256 tokenId) external view returns (uint256, uint256)
```

### mint

```solidity
function mint(address minter, uint256 tokenizationCost, uint8 lockDurationInMonths, bool onlyLock, bool generateRevenue) external returns (uint256)
```

### claimableIncomes

```solidity
function claimableIncomes(uint256[] tokenIds) external view returns (uint256[] free, uint256[] max)
```

### marketplace

```solidity
function marketplace() external view returns (contract IMarketplace)
```

