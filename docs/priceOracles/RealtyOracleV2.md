# Solidity API

## RealtyOracleTangibleV2

This smart contract is used to manage the stock and pricing for Real Estate properties.

_It has a IPriceOracle interface, which is created to fit the need of TNFT marketplace infrastructure,
and to fill specifics of RWA products on chain.
Interface is aligned with part of chainlink interface and extended with options
to retrieve the price in native currency and USD$.
Handling RWA is different from tokens in blockchain, vendors can come from different
parts of the world with their native currency. We are required to be able to
conform to USD price but, because ratios fluctuate in Forex, we also need to stora
native currency price, so that we are sure that price of the item hasn't changed.
For price feeds, every oracle depends on CurrencyFeedV2 contract.
It holds the address of chainlink aggregator for real estates. Key link is the fingerprint.
That oracle stores the info on where the house is located, price in native currency, when was the
last update, stock of the item.
Based on this info, different price feeds are fetched from CurrencyFeedV2 contract._

### version

```solidity
uint256 version
```

Version of oracle interface this contract uses.

### currencyFeed

```solidity
contract ICurrencyFeedV2 currencyFeed
```

Currency Feed contract reference.

### chainlinkRWAOracle

```solidity
contract IChainlinkRWAOracle chainlinkRWAOracle
```

Tangible Oracle contract reference.

### description

```solidity
string description
```

Holds description of oracle.

### notificationDispatcher

```solidity
contract IRWAPriceNotificationDispatcher notificationDispatcher
```

Holds the address of the notification dispatcher.

### CurrencyFeedUpdated

```solidity
event CurrencyFeedUpdated(address currencyFeed)
```

This event is emitted when CurrencyFeed contract is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| currencyFeed | address | Address of currency feed contract. |

### ChainlinkOracleUpdated

```solidity
event ChainlinkOracleUpdated(address chainlinkRWAOracle)
```

This event is emitted when ChainlinkRWAOracle contract is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| chainlinkRWAOracle | address | Address of chainlink RWA oracle contract. |

### NotificationDispatcherUpdated

```solidity
event NotificationDispatcherUpdated(address notificationDispatcher)
```

This event is emitted when NotificationDispatcher contract is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| notificationDispatcher | address | Address of notification dispatcher contract. |

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory, address _currencyFeed, address _chainlinkRWAOracle) external
```

Initializes RealtyOracleTangibleV2.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Factory contract address. |
| _currencyFeed | address | Currency Feed contract address. |
| _chainlinkRWAOracle | address | Chainlink Tangible Oracle address. |

### usdPrice

```solidity
function usdPrice(contract ITangibleNFT _nft, contract IERC20Metadata _paymentUSDToken, uint256 _fingerprint, uint256 _tokenId) external view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost)
```

This method returns the USD price data of a specified real estate asset.

_Usefull for fetching the price of a property in USD, regardless of its location._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _nft | contract ITangibleNFT | TangibleNFT contract reference. |
| _paymentUSDToken | contract IERC20Metadata | Token being used as payment. |
| _fingerprint | uint256 | Property identifier. |
| _tokenId | uint256 | Token identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAt | uint256 | -> Price of item in oracle, market price. |
| weSellAtStock | uint256 | -> Stock of the item. (Quantity) |
| tokenizationCost | uint256 | -> Tokenization costs for tokenizing asset. |

### usdPrices

```solidity
function usdPrices(contract ITangibleNFT _nft, contract IERC20Metadata _paymentUSDToken, uint256[] _fingerprints, uint256[] _tokenIds) external view returns (uint256[] weSellAt, uint256[] weSellAtStock, uint256[] tokenizationCost)
```

This method returns the USD prices data of a specified real estate assets.

_Usefull for getting the USD price of multiple assets at once._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _nft | contract ITangibleNFT | TangibleNFT contract reference. |
| _paymentUSDToken | contract IERC20Metadata | Token being used as payment. |
| _fingerprints | uint256[] | Product identifiers. |
| _tokenIds | uint256[] | Token identifiers. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAt | uint256[] | -> Prices of item in oracle, market price for corresponding _fingerprints or tokenIds. |
| weSellAtStock | uint256[] | -> Stock of the item. (Quantity) for corresponding _fingerprints or tokenIds. |
| tokenizationCost | uint256[] | -> Tokenization costs for tokenizing asset for corresponding _fingerprints or tokenIds. |

### setCurrencyFeed

```solidity
function setCurrencyFeed(address _currencyFeed) external
```

This is a restricted function for updating the address of `currencyFeed`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _currencyFeed | address | New address to store in `currencyFeed`. |

### setChainlinkOracle

```solidity
function setChainlinkOracle(address _chainlinkRWAOracle) external
```

This is a restricted function for updating the address of `chainlinkRWAOracle`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _chainlinkRWAOracle | address | New address to store in `chainlinkRWAOracle`. |

### setNotificationDispatcher

```solidity
function setNotificationDispatcher(address _notificationDispatcher) external
```

This is a restricted function for updating the address of `notificationDispatcher`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _notificationDispatcher | address | New address to store in `notificationDispatcher`. |

### notify

```solidity
function notify(uint256 fingerprint, uint256 oldNativePrice, uint256 newNativePrice, uint16 currency) external
```

This function is used to send the price change to notification dispatcher

_This function is called by the ChainlinkRWAOracle contract only._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprint | uint256 | Item ofr which the price has changed |
| oldNativePrice | uint256 | old price of the item, native currency |
| newNativePrice | uint256 | old price of the item, native currency |
| currency | uint16 | Currency in which the price is expressed |

### decrementSellStock

```solidity
function decrementSellStock(uint256 _fingerprint) external
```

This is a restricted function for decrementing the stock of a product/property.

_Only callable by the Factory contract. Factory is proxy in this case._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Fingerprint to decrement. |

### decimals

```solidity
function decimals() public view returns (uint8)
```

Fetches decimals from ChainlinkRWA oracle.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint8 | Returns the number of decimals the aggregator responses represent. |

### marketPriceNativeCurrency

```solidity
function marketPriceNativeCurrency(uint256 _fingerprint) external view returns (uint256 nativePrice, uint256 currency)
```

This method is used to fetch the native currency and price for a specified property.

_Usefull for calculating the price of a property in native currency._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Property identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| nativePrice | uint256 | -> Price for property in native currency. |
| currency | uint256 | -> Native currency as ISO num code. |

### marketPriceTotalNativeCurrency

```solidity
function marketPriceTotalNativeCurrency(uint256[] _fingerprints) external view returns (uint256 nativePrice, uint256 currency)
```

This method is used to fetch the native currency and price for a specified properties.

_Usefull for calculating the total price of properties in native currency._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprints | uint256[] | Property identifiers. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| nativePrice | uint256 | -> Prices for properties in native currency. |
| currency | uint256 | -> Native currencies as ISO num codes. |

### marketPricesNativeCurrencies

```solidity
function marketPricesNativeCurrencies(uint256[] fingerprints) external view returns (uint256[] nativePrices, uint256[] currencies)
```

This method is used to fetch the native currency and price for a specified properties.

_Usefull for getting individual prices in one call._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprints | uint256[] | Property identifiers. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| nativePrices | uint256[] | -> Prices for properties in native currency. |
| currencies | uint256[] | -> Native currencies as ISO num codes. |

### fingerprintsInOracle

```solidity
function fingerprintsInOracle(uint256 _index) public view returns (uint256 fingerprint)
```

This method returns the fingerprint from the `chainlinkRWAOracle` at a specified index.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _index | uint256 | Index where the fingerprint resides. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| fingerprint | uint256 | -> Product/property identifier. |

### fingerprintHasPrice

```solidity
function fingerprintHasPrice(uint256 _fingerprint) public view returns (bool)
```

This method returns if a specified fingerprint exists in the `chainlinkRWAOracle`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Product identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | If fingerprint exists, will return true. |

### latestTimeStamp

```solidity
function latestTimeStamp(uint256 _fingerprint) external view returns (uint256)
```

This method is used to fetch the last timestamp the oracle was updated for specific fingerprint.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Product identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Returns the block timestamp when the oracle was last updated. |

### lastUpdateOracle

```solidity
function lastUpdateOracle() external view returns (uint256)
```

This method returns the latest block the `chainlinkRWAOracle` was updated.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Block when last update occurred. |

### latestPrices

```solidity
function latestPrices() public view returns (uint256)
```

This method returns the `latestPrices` var from `chainlinkRWAOracle` contract.

_It is index that is incremented each time some price is updated.
It is a signal to contracts tracking and copying the oracle data to know if they have the latest data._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Returns `latestPrices`var. |

### oracleDataAll

```solidity
function oracleDataAll() public view returns (struct IChainlinkRWAOracle.Data[] currentData)
```

This method retreives all oracle data for all fingerprints in the oracle.

_Usefull to fetch all data in one go_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| currentData | struct IChainlinkRWAOracle.Data[] | -> All metadata objects in an array. |

### oracleDataBatch

```solidity
function oracleDataBatch(uint256[] _fingerprints) public view returns (struct IChainlinkRWAOracle.Data[] currentData)
```

This method is used to take an array of fingerprints and fetch batch data for those fingerprints from the oracle.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprints | uint256[] | Array of fingerprints we wish to fetch oracle data for. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| currentData | struct IChainlinkRWAOracle.Data[] | -> Array of data objects or each fingerprint returned. |

### availableInStock

```solidity
function availableInStock(uint256 _fingerprint) external view returns (uint256 weSellAtStock)
```

This method is used to fetch the amount of a certain product/product is in stock.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _fingerprint | uint256 | Property/product identifier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAtStock | uint256 | -> Quantity in stock. If == 0, out of stock. |

### getFingerprints

```solidity
function getFingerprints() external view returns (uint256[])
```

This method returns an array of fingerprints supported by the oracle.

_Usefull for fetching all fingerprints in one go. If some fingerptint is not supported,
it means that it doesn't exists as far as the chain is concerned._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256[] | Array of fingerprints |

### getFingerprintsLength

```solidity
function getFingerprintsLength() external view returns (uint256)
```

This method is used to get the length of the oracle's fingerprints array.

_For off-chain purposes_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Num of fingerprints in the oracle aka length of fingerprints array. |

### _convertNativePriceToUSD

```solidity
function _convertNativePriceToUSD(uint256 nativePrice, uint16 currencyISONum) internal view returns (uint256)
```

This method returns the exchange rate between native price and USD,

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nativePrice | uint256 | price in native currency, GBP. |
| currencyISONum | uint16 | Numeric ISO code for currency |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Price in USD from native price provided, given the current exchange rate. |

### _usdPrice

```solidity
function _usdPrice(contract ITangibleNFT _nft, contract IERC20Metadata _paymentUSDToken, uint256 _fingerprint, uint256 _tokenId) internal view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost)
```

This method returns the USD price data of a specified real estate asset.

