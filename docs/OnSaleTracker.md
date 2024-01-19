# Solidity API

## OnSaleTracker

This contract tracks the status of TNFTs listed on the Marketplace

_This contract is used to track the status of TNFTs listed on the Marketplace.
     Using this contract, it is easy to fetch all TNFTs that are listed for sale._

### TokenArray

```solidity
struct TokenArray {
  uint256[] tokenIds;
}
```

### ContractItem

```solidity
struct ContractItem {
  bool selling;
  uint256 index;
}
```

### TnftSaleItem

```solidity
struct TnftSaleItem {
  contract ITangibleNFT tnft;
  uint256 tokenId;
  uint256 indexInCurrentlySelling;
}
```

### tnftCategoriesOnSale

```solidity
contract ITangibleNFT[] tnftCategoriesOnSale
```

Array of TangibleNFT categories that are being sold on the marketplace.

### isTnftOnSale

```solidity
mapping(contract ITangibleNFT => struct OnSaleTracker.ContractItem) isTnftOnSale
```

Used to map TNFT category to whether it has tokens for sale and where it exists in `tnftCategoriesOnSale`.

### tnftTokensOnSale

```solidity
mapping(contract ITangibleNFT => uint256[]) tnftTokensOnSale
```

Used to store an array of tokenIds that are listed on sale for each TNFT category.

### tnftSaleMapper

```solidity
mapping(contract ITangibleNFT => mapping(uint256 => struct OnSaleTracker.TnftSaleItem)) tnftSaleMapper
```

Used to track each TNFT item that's on sale and where it exists inside `tnftTokensOnSale[]`.

### marketplace

```solidity
address marketplace
```

Stores the address of the Marketplace contract.

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory) external
```

Initialize OnSaleTracker

### tnftSalePlaced

```solidity
function tnftSalePlaced(contract ITangibleNFT tnft, uint256 tokenId, bool place) external
```

This external function is used to update the status of any listings on the Marketplace contract.

_Only callable by `marketplace`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract reference -> TNFT contract the `tokenId` derives from. |
| tokenId | uint256 | TNFT identifier. |
| place | bool | If true, the TNFT is being listed for sale, otherwise false. |

### _removeCurrentlySellingTnft

```solidity
function _removeCurrentlySellingTnft(contract ITangibleNFT tnft, uint256 index) internal
```

This internal function removes a token from `tnftTokensOnSale`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNft contract. From which category we're removing a token for. |
| index | uint256 | Index in the `tnftTokensOnSale` we're removing the token from. |

### _removeCategory

```solidity
function _removeCategory(uint256 index) internal
```

This internal method removes a category from `tnftCategoriesOnSale`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| index | uint256 | Index of category in the array to remove. |

### setMarketplace

```solidity
function setMarketplace(address _marketplace) external
```

This restricted function allows the admin to update the `marketplace` state variable.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _marketplace | address | Address of new Marketplace contract. |

### getTnftTokensOnSaleBatch

```solidity
function getTnftTokensOnSaleBatch(contract ITangibleNFT[] tnfts) external view returns (struct OnSaleTracker.TokenArray[] result)
```

This view function returns the TNFTs listed for sale from a specified category.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnfts | contract ITangibleNFT[] | TangibleNFT contract reference -> Category identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| result | struct OnSaleTracker.TokenArray[] | Array of tokenIds that are listed for sale on the Marketplace. |

### tnftTokensOnSaleSize

```solidity
function tnftTokensOnSaleSize(contract ITangibleNFT tnft) external view returns (uint256)
```

This view method returns the size of the `tnftTokensOnSale` mapped array.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Length of array. |

### getTnftCategoriesOnSale

```solidity
function getTnftCategoriesOnSale() external view returns (contract ITangibleNFT[])
```

This function returns the `tnftCategoriesOnSale` array.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | contract ITangibleNFT[] | Array of type ITangibleNFT. |

### tnftCategoriesOnSaleSize

```solidity
function tnftCategoriesOnSaleSize() external view returns (uint256)
```

This function returns the length of `tnftCategoriesOnSale` array.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Length of array. |

### getTnftTokensOnSale

```solidity
function getTnftTokensOnSale(contract ITangibleNFT tnft) external view returns (uint256[])
```

This view method returns the `tnftTokensOnSale` mapped array.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256[] | Array of type uint26. |

