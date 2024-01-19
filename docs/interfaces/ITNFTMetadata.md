# Solidity API

## ITNFTMetadata

### FeatureInfo

_FeatureInfo struct object for storing features metadata._

```solidity
struct FeatureInfo {
  uint256[] tnftTypes;
  bool added;
  string description;
}
```

### TNFTType

_TNFTType struct object for storing tnft-type metadata._

```solidity
struct TNFTType {
  bool added;
  bool paysRent;
  string description;
}
```

### tnftTypesArray

```solidity
function tnftTypesArray(uint256 index) external view returns (uint256)
```

_Returns an array of all supported tnft types._

### tnftTypes

```solidity
function tnftTypes(uint256 _tnftType) external view returns (bool added, bool paysRent, string description)
```

_Returns a tnft type metadata object given the tnft type._

### typeFeatures

```solidity
function typeFeatures(uint256 _tnftType, uint256 index) external view returns (uint256)
```

_Returns a feature given the tnft type and index in the array where it resides.
     features that are in specific type so that you can't add a type
     to tnft that is not for that type (can't add beach house for gold)._

### featureInfo

```solidity
function featureInfo(uint256 _feature) external view returns (struct ITNFTMetadata.FeatureInfo)
```

_Returns a feature metadata object given the feature._

### featureList

```solidity
function featureList(uint256 index) external view returns (uint256)
```

_Returns a supported feature from the `featureList` array._

### featureInType

```solidity
function featureInType(uint256 _tnftType, uint256 _feature) external view returns (bool)
```

_Returns whether a feature exists in `typeFeatures`._

### getTNFTTypes

```solidity
function getTNFTTypes() external view returns (uint256[])
```

_Returns the `tnftTypesArray` array._

### getTNFTTypesFeatures

```solidity
function getTNFTTypesFeatures(uint256 _tnftType) external view returns (uint256[])
```

_Returns the `typeFeatures` mapped array._

### getFeatureList

```solidity
function getFeatureList() external view returns (uint256[])
```

_Returns the `featureList` array._

