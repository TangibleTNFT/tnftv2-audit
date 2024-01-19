# Solidity API

## ICurrencyFeedV2

### currencyPriceFeeds

```solidity
function currencyPriceFeeds(string currency) external view returns (contract AggregatorV3Interface priceFeed)
```

_Returns the price feed oracle used for the specified currency._

### conversionPremiums

```solidity
function conversionPremiums(string currency) external view returns (uint256 conversionPremium)
```

_Returns the conversion premium taken when exchanging currencies._

### currencyPriceFeedsISONum

```solidity
function currencyPriceFeedsISONum(uint16 currencyISONum) external view returns (contract AggregatorV3Interface priceFeed)
```

_Returns the price feed oracle used for the specified currency._

### conversionPremiumsISONum

```solidity
function conversionPremiumsISONum(uint16 currencyISONum) external view returns (uint256 conversionPremium)
```

_Returns the conversion premium taken when exchanging currencies._

### ISOcurrencyCodeToNum

```solidity
function ISOcurrencyCodeToNum(string currencyCode) external view returns (uint16 currencyISONum)
```

_Given the currency ISO alpha code, will return the ISO numeric code._

### ISOcurrencyNumToCode

```solidity
function ISOcurrencyNumToCode(uint16 currencyISONum) external view returns (string currencyCode)
```

_Given the currency ISO numeric code, will return the ISO alpha code._

### ISOcountryCodeToNum

```solidity
function ISOcountryCodeToNum(string countryCode) external view returns (uint16 countryISONum)
```

_Given the country ISO alpha code, will return the ISO numeric code._

### ISOcountryNumToCode

```solidity
function ISOcountryNumToCode(uint16 countryISONum) external view returns (string countryCode)
```

_Given the country ISO numeric code, will return the ISO alpha code._

