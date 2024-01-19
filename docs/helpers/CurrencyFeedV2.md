# Solidity API

## CurrencyFeedV2

This smart contract is used to store ISO codes(Numbers converted to integer eg 001-> 1, for contract simplicity)
 for countries/currencies and manages price feed oracles for each currency supported.

_This contract utilizes the International Organization for Standardization (ISO)'s standard
 for representing global currencies and countries.
     country codes: https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
     currency codes: https://en.wikipedia.org/wiki/ISO_4217
It is also providing information that is complementary for the whole ecosystem to provide
calculation from various currencies to US$. Stores oracle feeds so if anyone wants
oracle for GBP all it need to provide is ISO code like 846.
Also, to protect against ratio fluctuation between chain and real world, option
for adding a premium on top of the exchange ratio is provided.
Few notes:
 - Feeds can be any verified oracle feed, from chainlink, dia, redstone etc.
 - Premiums must be in decimals that are a match to the corresponding feed.(with same ISO)_

### currencyPriceFeeds

```solidity
mapping(string => contract AggregatorV3Interface) currencyPriceFeeds
```

This mapping is used to store a price feed oracle for a specific currency ISO alpha code.

### conversionPremiums

```solidity
mapping(string => uint256) conversionPremiums
```

A premium taken by Tangible. It's tacked on top of the existing exchange rate of 2 currencies. This one is stored using the ISO alpha code for the key.

### currencyPriceFeedsISONum

```solidity
mapping(uint16 => contract AggregatorV3Interface) currencyPriceFeedsISONum
```

This mapping is used to store a price feed oracle for a specific currency ISO numeric code converted to integer.

### conversionPremiumsISONum

```solidity
mapping(uint16 => uint256) conversionPremiumsISONum
```

A premium taken by Tangible. It's tacked on top of the existing exchange rate of 2 currencies. This one is stored using the ISO numeric code converted to integer for the key.

### ISOcurrencyCodeToNum

```solidity
mapping(string => uint16) ISOcurrencyCodeToNum
```

Used to store ISO curency numeric code using it's alpha code as reference.

_i.e. ISOCurrencyCodeToNum["AUD"] = 36_

### ISOcurrencyNumToCode

```solidity
mapping(uint16 => string) ISOcurrencyNumToCode
```

Used to store ISO curency alpha code using it's numeric code as reference.

_i.e. ISOcurrencyNumToCode[36] = "AUD"_

### ISOcountryCodeToNum

```solidity
mapping(string => uint16) ISOcountryCodeToNum
```

Used to store ISO country numeric code using it's alpha code as reference.

_i.e. ISOcountryCodeToNum["AUS"] = 36_

### ISOcountryNumToCode

```solidity
mapping(uint16 => string) ISOcountryNumToCode
```

Used to store ISO curency alpha code using it's numeric code as reference.

_i.e. ISOcountryNumToCode[36] = "AUS"_

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory) external
```

### setISOCurrencyData

```solidity
function setISOCurrencyData(string _currency, uint16 _currencyISONum) external
```

This method is used to update the state of `ISOcurrencyCodeToNum` and `ISOcurrencyNumToCode`.

_Only factory owner can call this method._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _currency | string | ISO-4217 alpha code. @dev I.e. if currency is Australian dollar, this value would be "AUD". |
| _currencyISONum | uint16 | ISO-4217 numeric code converted to integer. @dev I.e. if currency is Australian dollar, this value would be `36`). |

### setISOCountryData

```solidity
function setISOCountryData(string _country, uint16 _countryISONum) external
```

This method is used to update the state of `ISOcountryCodeToNum` and `ISOcountryNumToCode`.

_Only factory owner can call this method._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _country | string | ISO-3166 alpha code. @dev I.e. if country is Australia, this value would be "AUS". |
| _countryISONum | uint16 | ISO-3166 numeric code converted to integer. @dev I.e. if country is Australia, this value would be `36`. |

### setCurrencyFeed

```solidity
function setCurrencyFeed(string _currency, contract AggregatorV3Interface _priceFeed) external
```

This method is used to update the state of `currencyPriceFeeds` and `currencyPriceFeedsISONum`.

_Only factory owner can call this method._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _currency | string | ISO-4217 alpha code. @dev I.e. if currency is Australian dollar, this value would be "AUD". |
| _priceFeed | contract AggregatorV3Interface | Price feed contract for the specified currency. |

### setCurrencyConversionPremium

```solidity
function setCurrencyConversionPremium(string _currency, uint256 _conversionPremium) external
```

This method is used to update the state of `conversionPremiums` and `conversionPremiumsISONum`.

_Only factory owner can call this method._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _currency | string | ISO-4217 alpha code. @dev I.e. if currency is Australian dollar, this value would be "AUD". |
| _conversionPremium | uint256 | A premium taken by Tangible when exchanging 2 currencies. (i.e. gbp/usd rate is 1.34, premium is 0.01) |

