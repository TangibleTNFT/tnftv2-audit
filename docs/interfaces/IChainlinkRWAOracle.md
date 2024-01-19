# Solidity API

## IChainlinkRWAOracle

### Data

```solidity
struct Data {
  uint256 fingerprint;
  uint256 weSellAt;
  uint256 lockedAmount;
  uint256 weSellAtStock;
  uint16 currency;
  uint16 location;
  uint256 timestamp;
}
```

### fingerprints

```solidity
function fingerprints(uint256 index) external view returns (uint256 fingerprint)
```

### getFingerprintsAll

```solidity
function getFingerprintsAll() external view returns (uint256[] fingerprints)
```

### getFingerprintsLength

```solidity
function getFingerprintsLength() external view returns (uint256 length)
```

### fingerprintData

```solidity
function fingerprintData(uint256 fingerprint) external view returns (struct IChainlinkRWAOracle.Data data)
```

### lastUpdateTime

```solidity
function lastUpdateTime() external view returns (uint256 timestamp)
```

### updateInterval

```solidity
function updateInterval() external view returns (uint256 secondsInterval)
```

### oracleDataAll

```solidity
function oracleDataAll() external view returns (struct IChainlinkRWAOracle.Data[])
```

### oracleDataBatch

```solidity
function oracleDataBatch(uint256[] fingerprints) external view returns (struct IChainlinkRWAOracle.Data[])
```

### getDecimals

```solidity
function getDecimals() external view returns (uint8 decimals)
```

### decrementStock

```solidity
function decrementStock(uint256 fingerprint) external
```

### latestPrices

```solidity
function latestPrices() external view returns (uint256 latestUpdate)
```

### fingerprintExists

```solidity
function fingerprintExists(uint256 fingerprint) external view returns (bool)
```

