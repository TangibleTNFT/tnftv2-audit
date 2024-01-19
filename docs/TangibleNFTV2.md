# Solidity API

## TangibleNFTV2

This is the Erc721 contract for the Tangible NFTs. Manages each asset's unique metadata and category.

_The contract is designed in a way to fit the needs of the Tangible NFTs.

Since the contract represent real world assets, couple of functions are added to support the real world use case.
Those are:
- `blacklistToken` -> used to blacklist a token if it is stolen or lost.
- `setCustody` -> used to set custody of a token. If the asset is redeemed by the user, it is in our custody thus the NFT should not be sold.
- `addMetadata` -> used to add metadata to a token. Metadata is used to describe the asset.(like beach house etc)
- `removeMetadata` -> used to remove metadata from a token.
- `addFingerprints` -> used to add fingerprints to the contract. Fingerprints are used to identify the asset. It is
a unique identifier for the asset used across the whole Tangible ecosystem, both on-chain and off-chain.
- `setStoragePricePerYear` -> used to set the price per year for storage.
- `setStorageDecimals` -> used to set the decimal precision for storage price. Decimal is share between both percentage and fixed price.
- `setStoragePercentPricePerYear` -> used to set the percentage price per year for storage.
- `adjustStorage` -> used to adjust the storage expiration date for a token. Callable only by the Factory.
- `toggleStorageFee` -> used to switch storage fee from fixed to percentage and vice versa.
- `toggleStorageRequired` -> used to switch storage requirement on/off.
- `setBaseURI` -> used to set the base URI for fetching metadata.
- `togglePause` -> used to pause/unpause the contract. To prevent tokens misuse.
- `produceMultipleTNFTtoStock` -> used to mint multiple TNFTs at once. Callable only by Factory
- `burn` -> used to burn a token. Callable only by category owner when he owns the token.
- `isStorageFeePaid` -> used to check if storage fee is paid for a token.
- `blacklistedTokens` -> used to check if a token is blacklisted.
- `tnftCustody` -> used to check if a token is in custody.
- `isFingerprintApproved` -> used to check if a fingerprint is approved. Category owner can't just add new fingerprints, it must be
approved by fingerprint approval manager.

Each TangibleNFT belongs to a tnftType which is used to identify the type of products the TangibleNFT mints.
There can be multiple categories that belong to the same type and they can belong to different vendors._

### storageEndTime

```solidity
mapping(uint256 => uint256) storageEndTime
```

This mapping is used to store the storage expiration date of each tokenId.

### fingerprintAdded

```solidity
mapping(uint256 => bool) fingerprintAdded
```

This mapping keeps track of all fingerprints that have been added.

### tokensFingerprint

```solidity
mapping(uint256 => uint256) tokensFingerprint
```

A mapping from tokenId to fingerprint identifier.

_eg 0x0000001 -> 3._

### fingerprintTokens

```solidity
mapping(uint256 => uint256[]) fingerprintTokens
```

A mapping from fingerprint identifier to an array of tokenIds.

### fingeprintsInTnft

```solidity
uint256[] fingeprintsInTnft
```

Array for storing fingerprint identifiers.

### lastTokenId

```solidity
uint256 lastTokenId
```

Used to assign a unique tokenId identifier to each NFT minted.

### blackListedTokens

```solidity
mapping(uint256 => bool) blackListedTokens
```

A mapping from tokenId to bool. If a tokenId is set to true.

### tnftCustody

```solidity
mapping(uint256 => bool) tnftCustody
```

A mapping from tokenId to bool. If tokenId is set to true, it is in the custody of Tangible.

### tokenFeatureAdded

```solidity
mapping(uint256 => mapping(uint256 => struct ITangibleNFT.FeatureInfo)) tokenFeatureAdded
```

A mapping to store TNFT metadata tokenId -> feature -> feature Info.

### tokenFeatures

```solidity
mapping(uint256 => uint256[]) tokenFeatures
```

A mapping to store features added per tokenId.

### storagePricePerYear

```solidity
uint256 storagePricePerYear
```

The price per year for storage.

### tnftType

```solidity
uint256 tnftType
```

Identifier for product type

_Categories are no longer unique, tnftType will be used to identify the type of products the TangibleNFT mints.
There can be multiple categories that belong to the same type_

### deploymentBlock

```solidity
uint256 deploymentBlock
```

Used to store the block timestamp when this contract was deployed.

### storageDecimals

```solidity
uint8 storageDecimals
```

TODO

### storagePercentagePricePerYear

```solidity
uint16 storagePercentagePricePerYear
```

Used to store the percentage price per year for storage.

_Max percent precision is 2 decimals (i.e 100% is 10000 // 0.01% is 1)._

### storagePriceFixed

```solidity
bool storagePriceFixed
```

If true, the storage price is a fixed price.

### storageRequired

```solidity
bool storageRequired
```

If true, storage is required for these NFTs.

### symbolInUri

```solidity
bool symbolInUri
```

If true, the symbol is used in the metadata URI.

### StoragePricePerYearSet

```solidity
event StoragePricePerYearSet(uint256 oldPrice, uint256 newPrice)
```

This event is emitted when `storagePricePerYear` is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| oldPrice | uint256 | The old yearly storage price. |
| newPrice | uint256 | The new yearly storage price. |

### StoragePercentagePricePerYearSet

```solidity
event StoragePercentagePricePerYearSet(uint256 oldPercentage, uint256 newPercentage)
```

This event is emitted when `storagePercentagePricePerYear` is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| oldPercentage | uint256 | The old yearly storage percent price. |
| newPercentage | uint256 | The new yearly storage percent price. |

### StorageExtended

```solidity
event StorageExtended(uint256 tokenId, uint256 _years, uint256 storageEnd)
```

This event is emitted when storage for a specified token has been extended & paid for.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier. |
| _years | uint256 | Num of years to extend storage. |
| storageEnd | uint256 | New expiration date. |

### ProducedTNFTs

```solidity
event ProducedTNFTs(uint256[] tokenId)
```

This event is emitted when a new TNFT is minted.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256[] | TNFT identifier. |

### BlackListedToken

```solidity
event BlackListedToken(uint256 tokenId, bool blacklisted)
```

This event is emitted when `blackListedTokens` is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier. |
| blacklisted | bool | If true, NFT is blacklisted. |

### FingerprintApproved

```solidity
event FingerprintApproved(uint256 fingerprint)
```

This event is emitted when a new fingerprint has been added.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprint | uint256 | New fingerprint that's been added. |

### StorageRequired

```solidity
event StorageRequired(bool value)
```

This event is emitted when the value of `storageRequired` is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| value | bool | If true, storage is required for this contrat. |

### StorageFixed

```solidity
event StorageFixed(bool value)
```

This event is emitted when the value of `storagePriceFixed` is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| value | bool | If true, storage price is a fixed price. |

### InCustody

```solidity
event InCustody(uint256 tokenId, bool inOurCustody)
```

This event is emitted when a token is in Tangible custody.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier. |
| inOurCustody | bool | If true, the token is in Tangible custody. If false, asset was redeemed. |

### TnftFeature

```solidity
event TnftFeature(uint256 tokenId, uint256 feature, bool added)
```

This event is emitted when a feature or multiple features are added/removed to a token's metadata.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier. |
| feature | uint256 | Feature that was added. |
| added | bool | If true, feature was added. Otherwise, false. |

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory, string _category, string _symbol, string _uri, bool _storagePriceFixed, bool _storageRequired, bool _symbolInUri, uint256 _tnftType) external
```

Initializes TangibleNFT.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Factory contract address. |
| _category | string | TNFT contract name. |
| _symbol | string | TNFT contract symbol. |
| _uri | string | base URI for fetching metadata from provider. |
| _storagePriceFixed | bool | If true, the storage price per year per TNFT is fixed. |
| _storageRequired | bool | If true, storage is required for each minted TNFT. |
| _symbolInUri | bool | If true, `_symbol` will be appended to the `_uri`. |
| _tnftType | uint256 | Tnft Type -> TNFTMetdata tracks all supported types. |

### setBaseURI

```solidity
function setBaseURI(string uri) external
```

This function is used to update `_baseUriLink`.

_Only callable by factory admin._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| uri | string | New base URI. |

### togglePause

```solidity
function togglePause() external
```

This function is meant for the category owner to pause/unpause the contract.

### produceMultipleTNFTtoStock

```solidity
function produceMultipleTNFTtoStock(uint256 count, uint256 fingerprint, address to) external returns (uint256[])
```

Mints multiple TNFTs.

_Only callable by Factory._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| count | uint256 | Amount of TNFTs to mint. |
| fingerprint | uint256 | Product identifier to mint. |
| to | address | Receiver of the newly minted tokens. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256[] | Array of minted tokenIds. |

### burn

```solidity
function burn(uint256 tokenId) external
```

This method is used to burn TNFTs

_Only callable by category owner and msg.sender must be owner of the `tokenId`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier. |

### setCustody

```solidity
function setCustody(uint256[] tokenIds, bool[] inOurCustody) external
```

This method allows a category owner to set the custody status of a TNFT.

_If the asset was redeemed, it should be in categroy owner custody.
It is advised for user to pass KYC before redeeming the asset._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | Array of tokenIds to update custody for. |
| inOurCustody | bool[] | If true, the NFT's asset is in our custody. Otherwise, false. |

### setStoragePricePerYear

```solidity
function setStoragePricePerYear(uint256 _storagePricePerYear) external
```

This function is used to update the storage price per year.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _storagePricePerYear | uint256 | amount to pay for storage per year. |

### setStorageDecimals

```solidity
function setStorageDecimals(uint8 decimals) external
```

This function is used to update `storageDecimals`.

_Decimals are shared between fixed and percentage price._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| decimals | uint8 | New decimal precision for `storageDecimals`. |

### setStoragePercentPricePerYear

```solidity
function setStoragePercentPricePerYear(uint16 _storagePercentagePricePerYear) external
```

This method is used to update the storage percentage price per year.

_Not necessary for TNFT contracts that have a fixed storage pricing model._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _storagePercentagePricePerYear | uint16 | percentage of token value to pay per year for storage. |

### adjustStorage

```solidity
function adjustStorage(uint256 tokenId, uint256 _years) external returns (bool)
```

This function is used to update the storage expiration timestamp for a token.

_Only callable by Factory. Factory is a proxy between markeptlace and TNFT contracts._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier. |
| _years | uint256 | Number of years to extend storage expiration. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | If true, storage price is fixed |

### toggleStorageFee

```solidity
function toggleStorageFee(bool value) external
```

This method allows a category owner to switch fees between fixed and percentage.

_If true, it is fixed, otherwise it is percentage._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| value | bool | If true, there is a storage fee to be paid by TNFT holders. |

### toggleStorageRequired

```solidity
function toggleStorageRequired(bool value) external
```

This method allows a category owner to enable/disable storage requirements

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| value | bool | If true, storage is required. |

### addFingerprints

```solidity
function addFingerprints(uint256[] fingerprints) external
```

This function will push a new set of fingerprints to the fingeprintsInTnft array.

_Only callable by Fingerprint approver manager._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprints | uint256[] | array of fingerprints to add. |

### addMetadata

```solidity
function addMetadata(uint256 tokenId, uint256[] _features) external
```

This function attaches metadata to a token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT tokenId |
| _features | uint256[] | List of features to be added to the token. |

### removeMetadata

```solidity
function removeMetadata(uint256 tokenId, uint256[] _features) external
```

This function removes metadata from a token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT tokenId |
| _features | uint256[] | List of features to be removed from the token. |

### blacklistToken

```solidity
function blacklistToken(uint256 tokenId, bool blacklisted) external
```

This function sets a tokenId to bool value in blacklistedTokens mapping.

_If value is set to true, tokenId will not be able to be transfered.
     Function only callable by Category owner._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier to be blacklisted. |
| blacklisted | bool | If true, tokenId will be blacklisted. |

### baseSymbolURI

```solidity
function baseSymbolURI() external view returns (string)
```

This method returns the contract's `symbol` appended to the `_baseUriLink`.

_Will only return the symbol appended to baseUri if `symbolInUri` is true. Otherwise
just _baseUriLink will be returned._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | baseUri with appended symbol as a string. |

### getTokenFeatures

```solidity
function getTokenFeatures(uint256 tokenId) external view returns (uint256[])
```

This method is used to return the array stored in `tokenFeatures` mapping.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier to return features array for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256[] | Array of features for `tokenId`. |

### getTokenFeaturesSize

```solidity
function getTokenFeaturesSize(uint256 tokenId) external view returns (uint256)
```

This method is used to return the length of `tokenFeatures` mapped array.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier to return features array length for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Length of the array. |

### getFingerprints

```solidity
function getFingerprints() external view returns (uint256[])
```

This method is used to return the `fingeprintsInTnft` array.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256[] | Array of fingerprints stored in `fingeprintsInTnft`. |

### getFingerprintsSize

```solidity
function getFingerprintsSize() external view returns (uint256)
```

This method is used to return the length of the `fingeprintsInTnft` array.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Length of `fingeprintsInTnft` array. |

### getFingerprintTokens

```solidity
function getFingerprintTokens(uint256 fingerprint) external view returns (uint256[])
```

This method is used to return the minted tokens for specified fingerprint.

_For example in gold, you can mint multiple tokens for the same fingerprint._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprint | uint256 | Fingerprint identifier to return tokens array for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256[] | Array of tokens for `fingerprint`. |

### getFingerprintTokensSize

```solidity
function getFingerprintTokensSize(uint256 fingerprint) external view returns (uint256)
```

This method is used to return the length of the `fingerprintTokens` mapped array.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprint | uint256 | Fingerprint identifier to return tokens array length for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Length of the array. |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view returns (string)
```

This view function is used to return the `_baseUriLink` string with appended tokenId.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Unique token identifier for which token's metadata we want to fetch. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | Unique token metadata uri. |

### isApprovedForAll

```solidity
function isApprovedForAll(address account, address operator) public view returns (bool)
```

This method is used to return if an `operator` is allows to manage assets of `account`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Owner of tokens. |
| operator | address | Contract address or EOA allowed to manage tokens on behalf of `account`. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | If true, operator is approved. |

### isStorageFeePaid

```solidity
function isStorageFeePaid(uint256 tokenId) public view returns (bool)
```

This method is used to return whether or not the storage fee has been paid for.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier to see if storage has been paid for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | If true, storage has been paid for, otherwise false. |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

This method is used to see if this contract is registered as an implementer of the interface defined by interfaceId.

_Support of the actual ERC165 interface is automatic and registering its interface id is not required._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| interfaceId | bytes4 | Interface identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | If true, this cotnract supports the interface defined by `interfaceId`. |

### shouldPayStorage

```solidity
function shouldPayStorage() external view returns (bool)
```

_This external function is used to return the boolean value of whether storage has to be paid for token._

### _produceTNFTtoStock

```solidity
function _produceTNFTtoStock(address to, uint256 fingerprint) internal returns (uint256)
```

Internal function which mints and produces a single TNFT.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | Receiver of new token. |
| fingerprint | uint256 | Identifier of product to mint a token for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | tokenId that is minted |

### _setTNFTStatuses

```solidity
function _setTNFTStatuses(uint256[] tokenIds, bool[] inOurCustody) internal
```

Internal function for updating status of token custody.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | tokens to update custody of. |
| inOurCustody | bool[] | If true, in Tangible custody, otherwise false. |

### _setTNFTStatus

```solidity
function _setTNFTStatus(uint256 tokenId, bool inOurCustody) internal
```

Internal function for updating status of token custody.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | token to update custody of. |
| inOurCustody | bool | Status of custody. |

### _update

```solidity
function _update(address to, uint256 tokenId, address auth) internal returns (address from)
```

Internal fucntion to check conditions prior to initiating a transfer of NFT.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | the destination of the token. |
| tokenId | uint256 | TNFT identifier to transfer. |
| auth | address | auth. |

### _increaseBalance

```solidity
function _increaseBalance(address account, uint128 amount) internal
```

Internal function added in new ERC721 version

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | account to check balance for |
| amount | uint128 | amount to increase balance for |

### _isStorageFeePaid

```solidity
function _isStorageFeePaid(uint256 tokenId) internal view returns (bool)
```

This internal method is used to return the boolean value of whether storage has expired for a token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TNFT identifier to see if storage has been expired. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | If true, storage has not expired, otherwise false. |

### _shouldPayStorage

```solidity
function _shouldPayStorage() internal view returns (bool)
```

