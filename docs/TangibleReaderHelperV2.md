# Solidity API

## TangibleReaderHelperV2

This contract allows for batch reads to several Tangible contracts for various purposes.

### factory

```solidity
contract IFactory factory
```

Stores a reference to the Factory contract.

### passiveNft

```solidity
contract IPassiveIncomeNFT passiveNft
```

Stores a reference to the passiveNFT contract.

### revenueShare

```solidity
contract RevenueShare revenueShare
```

Stores a reference to the revenueShare contract.

### constructor

```solidity
constructor(contract IFactory _factory, contract IPassiveIncomeNFT _passiveNft, contract RevenueShare _revenueShare) public
```

Initializes TangibleReaderHelper

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | contract IFactory | Factory contract reference. |
| _passiveNft | contract IPassiveIncomeNFT | PassiveNFT contract reference. |
| _revenueShare | contract RevenueShare | RevenueShare contract reference. |

### getLocksBatch

```solidity
function getLocksBatch(uint256[] tokenIds) external view returns (struct IPassiveIncomeNFT.Lock[] locksBatch)
```

This method fetches a batch of lock data given an array of `tokenIds`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | Array of token identifiers. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| locksBatch | struct IPassiveIncomeNFT.Lock[] | -> Array of Lock data for each tokenId provided. |

### getSharesBatch

```solidity
function getSharesBatch(uint256[] tokenIds, address fromAddress) external view returns (int256[] sharesBatch, uint256 totalShare)
```

This method is used to fetch a batch of rev shares for each tokenId provided.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | Array of tokenIds. |
| fromAddress | address | TangibleNFT contract. TODO: Verify |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| sharesBatch | int256[] | -> Array of shares |
| totalShare | uint256 | -> Total shares. |

### getPiNFTMarketItemBatch

```solidity
function getPiNFTMarketItemBatch(uint256[] tokenIds) external view returns (struct IMarketplace.MarketItem[] marketItems)
```

This method returns MarketItem data for each tokenId provided.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | Array of token identifiers |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| marketItems | struct IMarketplace.MarketItem[] | -> Array of MarketItem objects for each tokenId provided. |

### ownersOBatch

```solidity
function ownersOBatch(uint256[] tokenIds, address contractAddress) external view returns (address[] owners)
```

This function takes an array of `tokenIds` and fetches the array of owners.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | Array of tokenIds to query owners of. |
| contractAddress | address | NFT contract we wish to query token ownership of. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| owners | address[] | -> Array of owners. Indexes correspond with the indexes of tokenIds. |

### tokensFingerprintBatch

```solidity
function tokensFingerprintBatch(uint256[] tokenIds, contract ITangibleNFT tnft) external view returns (uint256[] fingerprints)
```

This function takes an array of `tokenIds` and fetches the corresponding fingerprints.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | Array of tokenIds to query fingerprints for. |
| tnft | contract ITangibleNFT | TangibleNFT contract address. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprints | uint256[] | -> Array of fingerprints. Indexes correspond with the indexes of tokenIds. |

### tnftsStorageEndTime

```solidity
function tnftsStorageEndTime(uint256[] tokenIds, contract ITangibleNFT tnft) external view returns (uint256[] endTimes)
```

This function takes an array of `tokenIds` and fetches the corresponding storage expiration date.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | Array of tokenIds to query expiration for. |
| tnft | contract ITangibleNFT | TangibleNFT contract address. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| endTimes | uint256[] | -> Array of timestamps of when each tokenIds storage expires. |

### tokenByIndexBatch

```solidity
function tokenByIndexBatch(uint256[] indexes, address enumrableContract) external view returns (uint256[] tokenIds)
```

This method returns an array of tokenIds given the indexes.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| indexes | uint256[] | Array of indexes. |
| enumrableContract | address | Enumerable erc721 contract address. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | -> Array of tokenIds. |

### lotBatch

```solidity
function lotBatch(address nft, uint256[] tokenIds) external view returns (struct ITangibleMarketplace.Lot[] result)
```

This method is used to fetch a batch of Lot metadata objects for each `tokenId` provided.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | address | TangibleNFT contract address. |
| tokenIds | uint256[] | Array of tokenIds. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | struct ITangibleMarketplace.Lot[] | Array of Lot metadata. |

