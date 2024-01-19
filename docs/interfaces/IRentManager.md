# Solidity API

## IRentManager

### RentInfo

```solidity
struct RentInfo {
  uint256 depositAmount;
  uint256 claimedAmount;
  uint256 claimedAmountTotal;
  uint256 unclaimedAmount;
  uint256 depositTime;
  uint256 endTime;
  address rentToken;
  bool distributionRunning;
}
```

### updateDepositor

```solidity
function updateDepositor(address _newDepositor) external
```

### deposit

```solidity
function deposit(uint256 tokenId, address tokenAddress, uint256 amount, uint256 month, uint256 endTime, bool skipBackpayment) external
```

### claimableRentForToken

```solidity
function claimableRentForToken(uint256 tokenId) external view returns (uint256)
```

### claimRentForToken

```solidity
function claimRentForToken(uint256 tokenId) external returns (uint256)
```

### claimableRentForTokenBatch

```solidity
function claimableRentForTokenBatch(uint256[] tokenIds) external view returns (uint256[])
```

### claimableRentForTokenBatchTotal

```solidity
function claimableRentForTokenBatchTotal(uint256[] tokenIds) external view returns (uint256 claimable)
```

### claimRentForTokenBatch

```solidity
function claimRentForTokenBatch(uint256[] tokenIds) external returns (uint256[])
```

### TNFT_ADDRESS

```solidity
function TNFT_ADDRESS() external view returns (address)
```

### depositor

```solidity
function depositor() external view returns (address)
```

### notificationDispatcher

```solidity
function notificationDispatcher() external view returns (address)
```

## IRentManagerExt

### rentInfo

```solidity
function rentInfo(uint256) external view returns (struct IRentManager.RentInfo)
```

