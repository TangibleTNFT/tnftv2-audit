# Solidity API

## TNFTMetadata

This contract is used to manage TangibleNFT metadata.

_It handles types and features.
We can have infinite number of types. But each type is unique and represents item type:
- sneakers
- cars
- houses
- gold
- wint
- etc
Based on types, vendors can create a new category - category is instance of type. It is an
actual TNFT contract. They are stored in Factory. So:
- there can be only type (like real estate, sneakers)
- but there can be infinite number of categories (TNFT contracts) for that type
- - For example Adidas, Nike, nSport can have each own TNFT contract(category)
- - Tangible, Company X etc can have each their own RealEstate TNFT contract(category)
Features are used to describe TNFTs. They are stored in this contract. Each feature can belongs to
a type(ocean house, luxury, blue). It can also exist acros various types(blue house, blue sneakers).
Each feature has it's own id and it's description, and can be used across types.

Both features and types must exist here, before they can be assigned to TNFT contract/tokenId
Types are assigned to contracts, features are assigned to tokenIds.
One unofficial feature that is not handled here, but in Oracles is location - house located
in UK, sneakers in Australia etc.._

### FeatureInfo

FeatureInfo struct object for storing features metadata.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct FeatureInfo {
  uint256[] tnftTypes;
  bool added;
  string description;
}
```

### TNFTType

TNFTType struct object for storing tnft-type metadata.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct TNFTType {
  bool added;
  bool paysRent;
  string description;
}
```

### tnftTypesArray

```solidity
uint256[] tnftTypesArray
```

Array of supported Tnft Types.

### featureList

```solidity
uint256[] featureList
```

Array of supported features.

### tnftTypes

```solidity
mapping(uint256 => struct TNFTMetadata.TNFTType) tnftTypes
```

Used to store/fetch tnft type metadata.

### featureInfo

```solidity
mapping(uint256 => struct TNFTMetadata.FeatureInfo) featureInfo
```

Used to store/fetch feature metadata.

### typeFeatures

```solidity
mapping(uint256 => uint256[]) typeFeatures
```

This mapping stores an array of features for a tnft type as the key.

_i.e. RE: beach housem pool || wine bottle size etc, gold if it is coins, tablets etc_

### featureInType

```solidity
mapping(uint256 => mapping(uint256 => bool)) featureInType
```

Mapping used to track if a feature is added in type tnftType.

_tnftType -> feature -> bool (if added)_

### featureIndexInList

```solidity
mapping(uint256 => uint256) featureIndexInList
```

Stores the index where a feature(key) resides in featureList.

### TnftTypeAdded

```solidity
event TnftTypeAdded(uint256 tnftType, string description)
```

This event is emitted when a new Tnft type has been added to `tnftTypesArray`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnftType | uint256 | Tnft type being added. |
| description | string | Description of tnft type. |

### FeatureAdded

```solidity
event FeatureAdded(uint256 feature, string description)
```

This event is emitted when a new feature has been added to `featureList`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feature | uint256 | feature being added. |
| description | string | Description of feature. |

### FeatureRemoved

```solidity
event FeatureRemoved(uint256 feature)
```

This event is emitted when a feature is removed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feature | uint256 | feature being removed. |

### FeatureModified

```solidity
event FeatureModified(uint256 feature, string description)
```

This event is emitted when a feature's description has been modified.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feature | uint256 | feature being modified. |
| description | string | New description of feature. |

### FeatureAddedToTnftType

```solidity
event FeatureAddedToTnftType(uint256 tnftType, uint256 feature)
```

This event is emitted when a feature is added to `featureInType`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnftType | uint256 | tnft type we're adding features to. |
| feature | uint256 | New feature to add. |

### FeatureRemovedFromTnftType

```solidity
event FeatureRemovedFromTnftType(uint256 tnftType, uint256 feature)
```

This event is emitted when a feature is removed from `featureInType`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnftType | uint256 | tnft type we're removing features from. |
| feature | uint256 | Feature to remove. |

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory) external
```

Used to initialize TNFTMetadata.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Address of Factory contract. |

### addFeatures

```solidity
function addFeatures(uint256[] _featureList, string[] _featureDescriptions) external
```

This method allows the Factory owner to add new supported features to this contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _featureList | uint256[] | Array of new features to add. |
| _featureDescriptions | string[] | Array of corresponding descriptions for each new feature. |

### modifyFeature

```solidity
function modifyFeature(uint256[] _featureList, string[] _featureDescriptions) external
```

This method allows the Factory owner to modify existing features' descriptions.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _featureList | uint256[] | Array of features to modify. |
| _featureDescriptions | string[] | Array of corresponding descriptions for each feature. |

### removeFeatures

```solidity
function removeFeatures(uint256[] _featureList) external
```

This method allows the Factory owner to remove features.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _featureList | uint256[] | Array of features to remove. |

### _findElementIntypeFeatures

```solidity
function _findElementIntypeFeatures(uint256 _type, uint256 _feature) internal view returns (uint256)
```

Helper function to find element in typeFeatures array.

### addTNFTType

```solidity
function addTNFTType(uint256 _tnftType, string _description, bool _paysRent) external
```

This method allows the Factory owner to add new Tnft types.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tnftType | uint256 | New tnft type. |
| _description | string | Description for new tnft type. |
| _paysRent | bool | If true, TangibleNFT will have a rent manager. |

### addFeaturesForTNFTType

```solidity
function addFeaturesForTNFTType(uint256 _tnftType, uint256[] _features) external
```

This method allows the Factory owner to add a existing features to existing tnft type.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tnftType | uint256 | Existing tnft type. |
| _features | uint256[] | Features to add to tnft type. |

### getTNFTTypes

```solidity
function getTNFTTypes() external view returns (uint256[])
```

This function is used to return the `tnftTypesArray`.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256[] | Array of Tnft types as uint256. |

### getFeatureInfo

```solidity
function getFeatureInfo(uint256 feature) external view returns (struct TNFTMetadata.FeatureInfo)
```

Returns information about feature.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feature | uint256 | Feature we want to return the info for. |

### getTNFTTypesFeatures

```solidity
function getTNFTTypesFeatures(uint256 _tnftType) external view returns (uint256[])
```

This function is used to return the `typeFeatures` mapped array.

_It returns all features that are added to specific type._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tnftType | uint256 | The tnft type we want to return the array of features for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256[] | Array of features. |

### getTNFTTypesFeaturesLength

```solidity
function getTNFTTypesFeaturesLength(uint256 _tnftType) external view returns (uint256)
```

This function is used to return the length of `typeFeatures` array for TNFT Type.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tnftType | uint256 | The tnft type we want to return the array of features for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Length of array. |

### getTNFTTypesFeaturesDescriptions

```solidity
function getTNFTTypesFeaturesDescriptions(uint256 _tnftType) external view returns (string[])
```

This function is used to return the descriptions of features array for TNFT type.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tnftType | uint256 | The tnft type we want to return the array of features for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string[] | Array of features descriptions. |

### getTNFTTypesFeaturesDescriptionsAndIds

```solidity
function getTNFTTypesFeaturesDescriptionsAndIds(uint256 _tnftType) external view returns (string[] desc, uint256[] ids)
```

This function is used to return the descriptions of features array for TNFT type.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tnftType | uint256 | The tnft type we want to return the array of features for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| desc | string[] | Array of features descriptions. |
| ids | uint256[] | Array of features ids. |

### getFeatureList

```solidity
function getFeatureList() external view returns (uint256[])
```

This function is used to return the `featureList` array.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256[] | Array of all features supported. |

### getFeatureListLength

```solidity
function getFeatureListLength() external view returns (uint256)
```

This function is used to return the length of `featureList` array.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Length of array. |

### getFeatureDescriptions

```solidity
function getFeatureDescriptions() external view returns (string[])
```

This function is used to return the descriptions of features array.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string[] | Array of all features descriptions. |

### getFeatureDescriptionsAndIds

```solidity
function getFeatureDescriptionsAndIds() external view returns (string[] desc, uint256[] ids)
```

This function is used to return the descriptions of features array.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| desc | string[] | Array of all features descriptions. |
| ids | uint256[] | Array of all features ids. |

