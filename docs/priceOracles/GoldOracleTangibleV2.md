# Solidity API

## GoldOracleTangibleV2

This smart contract is used to manage the stock and pricing for gold products for the gold TNFTs.

_It has a IPriceOracle interface, which is created to fit the need of TNFT marketplace infrastructure,
and to fill specifics of RWA products on chain.
Interface is aligned with part of chainlink interface and extended with options
to retrieve the price in native currency and USD$.
Handling RWA is different from tokens in blockchain, vendors can come from different
parts of the world with their native currency. We are required to be able to
conform to USD price but, because ratios fluctuate in Forex, we also need to stora
native currency price, so that we are sure that price of the item hasn't changed.
For price feeds, every oracle depends on CurrencyFeedV2 contract._

### GoldBar

This struct is used to create a gold bar object.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct GoldBar {
  uint256 grams;
  uint256 weSellAtStock;
}
```

### currencyFeed

```solidity
contract ICurrencyFeedV2 currencyFeed
```

Stores a reference to the CurrencyFeedV2 contract.

### goldBars

```solidity
mapping(uint256 => struct GoldOracleTangibleV2.GoldBar) goldBars
```

Mapping used to store GoldBar metadata for each gold bar fingerprint.

### unz

```solidity
uint256 unz
```

Grams per ounce of gold.

### currencyISONum

```solidity
uint16 currencyISONum
```

ISO code for XAU (gold)

### GoldBarAdded

```solidity
event GoldBarAdded(uint256 fingerprint, uint256 grams)
```

This event is emitted when a new gold bar product is added

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprint | uint256 | Product identifier that was added. |
| grams | uint256 | Weight of gold bar. |

### GoldBarStockChanged

```solidity
event GoldBarStockChanged(uint256 fingerprint, uint256 oldStock, uint256 newStock)
```

This event is emitted when the stock of gold bars has been updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprint | uint256 | Product identifier that was updated stock. |
| oldStock | uint256 | Old stock. |
| newStock | uint256 | New stock. |

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory, address _currencyFeed) external
```

This initializes the GoldOracleTangible contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Factory contract address. |
| _currencyFeed | address | Address of price feed oracle. |

### updateCurrencyFeed

```solidity
function updateCurrencyFeed(contract ICurrencyFeedV2 _currencyFeed) external
```

This method is used to update this contract with latest address
of currency feed.

_Only Tangible labs owner can call this method since it is our oracle implementation._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _currencyFeed | contract ICurrencyFeedV2 | Address of price feed oracle. |

### latestTimeStamp

```solidity
function latestTimeStamp(uint256 _fingerprint) external view returns (uint256)
```

Get the latest completed round where the answer was updated.

_Inherited from IPriceOracle._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Product identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Returns the latest block timestamp. |

### decimals

```solidity
function decimals() external view returns (uint8)
```

This internal method is used to fetch the decimals the oracle uses.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint8 | Returns the number of decimals the aggregator responses represent. |

### description

```solidity
function description() external view returns (string desc)
```

View method for fetching oracle description.

_Inherited from IPriceOracle_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| desc | string | -> Returns the description of the aggregator the proxy points to. (i.e. "GBP / USD"). |

### version

```solidity
function version() external view returns (uint256)
```

This view method is for fetching oracle version.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Returns the version number representing the type of aggregator the proxy points to. (i.e. `4`). |

### decrementSellStock

```solidity
function decrementSellStock(uint256 _fingerprint) external
```

This method decrements amount of a product is in available stock.

_It it called after a purchase of this product represented by fingerprint.
 Only factory can call this method. Factory is acting as proxy here._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Product that is decrementing in stock. |

### availableInStock

```solidity
function availableInStock(uint256 _fingerprint) external view returns (uint256)
```

This method returns the amount of a gold bar product is still in stock.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Product identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Returns amount that is available to be purchased. |

### usdPrice

```solidity
function usdPrice(contract ITangibleNFT _nft, contract IERC20Metadata _paymentUSDToken, uint256 _fingerprint, uint256 _tokenId) external view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost)
```

This method returns the USD price data of a specified gold bar

_This method is used to get the price of a single gold bar. Usefull to get the
price of desired gold bar_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _nft | contract ITangibleNFT | TangibleNFT contract reference. |
| _paymentUSDToken | contract IERC20Metadata | Token being used as payment. |
| _fingerprint | uint256 | Product identifier. |
| _tokenId | uint256 | Token identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAt | uint256 | -> Price of item in oracle, market price. |
| weSellAtStock | uint256 | -> Stock of the item. (Quantity) |
| tokenizationCost | uint256 | -> Tokenization costs for tokenizing asset. For gold, is 0. |

### usdPrices

```solidity
function usdPrices(contract ITangibleNFT _nft, contract IERC20Metadata _paymentUSDToken, uint256[] _fingerprints, uint256[] _tokenIds) external view returns (uint256[] weSellAt, uint256[] weSellAtStock, uint256[] tokenizationCost)
```

This method returns the USD prices data of a specified gold bars

_This method is used to get the price of multiple gold bars. Useful for
batch infor fetching._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _nft | contract ITangibleNFT | TangibleNFT contract reference. |
| _paymentUSDToken | contract IERC20Metadata | Token being used as payment. Used to convert to correct decimals |
| _fingerprints | uint256[] | Product identifiers. |
| _tokenIds | uint256[] | Token identifiers. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAt | uint256[] | -> Prices of item in oracle, rwa price, market price for corresponding _fingerprints or tokenIds. |
| weSellAtStock | uint256[] | -> Stock of the item. (Quantity) for corresponding _fingerprints or tokenIds. |
| tokenizationCost | uint256[] | -> Tokenization costs for tokenizing asset and bringing it on-chain. For gold, is 0. |

### addGoldBar

```solidity
function addGoldBar(uint256 _fingerprint, uint256 _grams) external
```

This method allows the Tangible Labs multisig to add new gold bars

_Only called by Tangible Labs multisig._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Fingerprint product identifier. |
| _grams | uint256 | Amount of grams of gold bar. |

### addGoldBarStock

```solidity
function addGoldBarStock(uint256 _fingerprint, uint256 _weSellAtStock) external
```

This method allows the Tangible Labs multisig to update the stock of specific gold bars

_Only called by Tangible Labs multisig._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Fingerprint product identifier. |
| _weSellAtStock | uint256 | New stock of product. |

### marketPriceNativeCurrency

```solidity
function marketPriceNativeCurrency(uint256 _fingerprint) external view returns (uint256 nativePrice, uint256 currency)
```

This method returns the native currency and grams of the gold bar

_This method is used to get the price of a single gold bar._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Product identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| nativePrice | uint256 | -> Price of item in oracle, market price. |
| currency | uint256 | -> Currency of the price. |

### marketPriceTotalNativeCurrency

```solidity
function marketPriceTotalNativeCurrency(uint256[] _fingerprints) external view returns (uint256 nativePrice, uint256 currency)
```

This method returns the native currency and total price of the passed gold bars

_This method is used to get the total price of multiple gold bars._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprints | uint256[] | Product identifiers. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| nativePrice | uint256 | -> Prices of item in oracle, market native price for corresponding _fingerprints. |
| currency | uint256 | -> Currencies of the price for corresponding _fingerprints. |

### marketPricesNativeCurrencies

```solidity
function marketPricesNativeCurrencies(uint256[] _fingerprints) external view returns (uint256[] nativePrices, uint256[] currencies)
```

This method returns the native prices ISO currencies for passed gold bars

_This method is used to get arrays of prices and ISO currencies_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprints | uint256[] | Product identifiers. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| nativePrices | uint256[] | -> Prices of item in oracle, market native price for corresponding _fingerprints. |
| currencies | uint256[] | -> Currencies of the price for corresponding _fingerprints. |

### _decimals

```solidity
function _decimals() internal view returns (uint8)
```

Fetches decimals from price feed oracle.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint8 | Returns the number of decimals the aggregator responses represent. |

### _latestAnswer

```solidity
function _latestAnswer(uint256 _fingerprint) internal view returns (uint256)
```

This returns the latest USD value for gold using the price feed oracle.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Product fingerprint to fetch GoldBar metadata. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Returns USD price for grams of gold. |

### _usdPrice

```solidity
function _usdPrice(contract ITangibleNFT _nft, contract IERC20Metadata _paymentUSDToken, uint256 _fingerprint, uint256 _tokenId) internal view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost)
```

This internal method returns the USD price data of a specified gold bar

