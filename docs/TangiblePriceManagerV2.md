# Solidity API

## TangiblePriceManagerV2

This contract is used to facilitate the fetching/response of TangibleNFT prices

_This contract is used to fetch proper oracles for each TangibleNFT category._

### oracleForCategory

```solidity
mapping(contract ITangibleNFT => contract IPriceOracle) oracleForCategory
```

This maps TangibleNFT contracts to it's corresponding oracle.

### CategoryPriceOracleAdded

```solidity
event CategoryPriceOracleAdded(address category, address priceOracle)
```

This event is emitted when the `oracleForCategory` variable is updated.

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory) external
```

Initialized TangiblePriceManager.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Factory provider contract address. |

### setOracleForCategory

```solidity
function setOracleForCategory(contract ITangibleNFT category, contract IPriceOracle oracle) external
```

The function is used to set oracle contracts in the `oracleForCategory` mapping.

_Each TangibleNFT category(contract) has it's own oracle contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| category | contract ITangibleNFT | TangibleNFT contract. |
| oracle | contract IPriceOracle | PriceOracle contract. |

### itemPriceBatchFingerprints

```solidity
function itemPriceBatchFingerprints(contract ITangibleNFT nft, contract IERC20Metadata paymentUSDToken, uint256[] fingerprints) external view returns (uint256[] weSellAt, uint256[] weSellAtStock, uint256[] tokenizationCost)
```

This function fetches pricing data for an array of products, from fingerprints

_Price is indicated in USD $ in paymentUSDToken decimals._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentUSDToken | contract IERC20Metadata | Token being used as payment. |
| fingerprints | uint256[] | Array of token fingerprints data. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAt | uint256[] | -> Price of item in oracle, market price. |
| weSellAtStock | uint256[] | -> Stock of the item. |
| tokenizationCost | uint256[] | -> Tokenization costs for tokenizing asset. Real Estate will never be 0. |

### itemPriceFingerprint

```solidity
function itemPriceFingerprint(contract ITangibleNFT nft, contract IERC20Metadata paymentUSDToken, uint256 fingerprint) external view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost)
```

This function fetches pricing data for specific product, from fingerprint

_Price is indicated in USD $ in paymentUSDToken decimals_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentUSDToken | contract IERC20Metadata | Token being used as payment. |
| fingerprint | uint256 | product fingerprint. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAt | uint256 | -> Price of item in oracle, market price. |
| weSellAtStock | uint256 | -> Stock of the item. |
| tokenizationCost | uint256 | -> Tokenization costs for tokenizing asset. |

### itemPriceBatchTokenIds

```solidity
function itemPriceBatchTokenIds(contract ITangibleNFT nft, contract IERC20Metadata paymentUSDToken, uint256[] tokenIds) external view returns (uint256[] weSellAt, uint256[] weSellAtStock, uint256[] tokenizationCost)
```

This function fetches pricing data for an array of tokenIds.

_Price is indicated in USD $ in paymentUSDToken decimals_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentUSDToken | contract IERC20Metadata | Token being used as payment. |
| tokenIds | uint256[] | Array of tokenIds. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAt | uint256[] | -> Price of item in oracle, market price. |
| weSellAtStock | uint256[] | -> Stock of the item. |
| tokenizationCost | uint256[] | -> Tokenization costs for tokenizing asset. Real Estate will never be 0. |

### itemPriceTokenId

```solidity
function itemPriceTokenId(contract ITangibleNFT nft, contract IERC20Metadata paymentUSDToken, uint256 tokenId) external view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost)
```

This function fetches USD pricing data for tokenId.

_Price is indicated in USD $ in paymentUSDToken decimals_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentUSDToken | contract IERC20Metadata | Token being used as payment. |
| tokenId | uint256 | tokenId to fetch the price for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAt | uint256 | -> Price of item in oracle, market price. |
| weSellAtStock | uint256 | -> Stock of the item. |
| tokenizationCost | uint256 | -> Tokenization costs for tokenizing asset. |

