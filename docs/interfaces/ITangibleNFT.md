# Solidity API

## ITangibleNFT

### FeatureInfo

This struct defines a Feature object

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct FeatureInfo {
  uint256 feature;
  uint256 index;
  bool added;
}
```

### baseSymbolURI

```solidity
function baseSymbolURI() external view returns (string)
```

_This method returns the contract's `symbol` appended to the `_baseUriLink`._

### storageDecimals

```solidity
function storageDecimals() external view returns (uint8)
```

_This returns the decimal point precision for storage fees._

### produceMultipleTNFTtoStock

```solidity
function produceMultipleTNFTtoStock(uint256 count, uint256 fingerprint, address toStock) external returns (uint256[])
```

_Function allows a Factory to mint multiple tokenIds for provided vendorId to the given address(stock storage, usualy marketplace)
with provided count._

### isStorageFeePaid

```solidity
function isStorageFeePaid(uint256 tokenId) external view returns (bool)
```

_The function returns whether storage fee is paid for the current time._

### storageEndTime

```solidity
function storageEndTime(uint256 tokenId) external view returns (uint256 storageEnd)
```

_This returns the storage expiration date for each `tokenId`._

### blackListedTokens

```solidity
function blackListedTokens(uint256 tokenId) external view returns (bool)
```

_This returns if a specified `tokenId` is blacklisted._

### storagePricePerYear

```solidity
function storagePricePerYear() external view returns (uint256)
```

_The function returns the price per year for storage._

### storagePercentagePricePerYear

```solidity
function storagePercentagePricePerYear() external view returns (uint16)
```

_The function returns the percentage of item price that is used for calculating storage._

### storagePriceFixed

```solidity
function storagePriceFixed() external view returns (bool)
```

_The function returns whether storage for the TNFT is paid in fixed amount or in percentage from price_

### storageRequired

```solidity
function storageRequired() external view returns (bool)
```

_The function returns whether storage for the TNFT is required. For example houses don't have storage_

### tokensFingerprint

```solidity
function tokensFingerprint(uint256 tokenId) external view returns (uint256)
```

_The function returns the token fingerprint - used in oracle_

### adjustStorage

```solidity
function adjustStorage(uint256 tokenId, uint256 _years) external returns (bool)
```

_The function accepts takes tokenId, and years, sets storage and returns if storage is fixed or percentage._

### getTokenFeatures

```solidity
function getTokenFeatures(uint256 tokenId) external view returns (uint256[])
```

_This method is used to return the array stored in `tokenFeatures` mapping._

### getTokenFeaturesSize

```solidity
function getTokenFeaturesSize(uint256 tokenId) external view returns (uint256)
```

_This method is used to return the length of `tokenFeatures` mapped array._

### tnftType

```solidity
function tnftType() external view returns (uint256)
```

_Returns the type identifier for this category._

### fingerprintTokens

```solidity
function fingerprintTokens(uint256 fingerprint, uint256 index) external view returns (uint256)
```

### getFingerprintTokens

```solidity
function getFingerprintTokens(uint256 fingerprint) external view returns (uint256[])
```

### getFingerprintTokensSize

```solidity
function getFingerprintTokensSize(uint256 fingerprint) external view returns (uint256)
```

## ITangibleNFTExt

### tokenFeatureAdded

```solidity
function tokenFeatureAdded(uint256 tokenId, uint256 feature) external view returns (struct ITangibleNFT.FeatureInfo)
```

_Returns the feature status of a `tokenId`._

