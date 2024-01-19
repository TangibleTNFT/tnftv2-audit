# Solidity API

## IPriceOracle

### latestTimeStamp

```solidity
function latestTimeStamp(uint256 fingerprint) external view returns (uint256)
```

_The function latest price and latest timestamp when price was updated from oracle._

### decimals

```solidity
function decimals() external view returns (uint8)
```

_The function that returns price decimals from oracle._

### description

```solidity
function description() external view returns (string desc)
```

_The function that returns rescription for oracle._

### version

```solidity
function version() external view returns (uint256)
```

_The function that returns version of the oracle._

### decrementSellStock

```solidity
function decrementSellStock(uint256 fingerprint) external
```

_The function that reduces sell stock when token is bought._

### availableInStock

```solidity
function availableInStock(uint256 fingerprint) external returns (uint256 weSellAtStock)
```

_The function reduces buy stock when we buy token._

### usdPrices

```solidity
function usdPrices(contract ITangibleNFT nft, contract IERC20Metadata paymentUSDToken, uint256[] fingerprint, uint256[] tokenId) external view returns (uint256[] weSellAt, uint256[] weSellAtStock, uint256[] tokenizationCost)
```

_The function that returns item price in USD, indexed in payment token._

### usdPrice

```solidity
function usdPrice(contract ITangibleNFT nft, contract IERC20Metadata paymentUSDToken, uint256 fingerprint, uint256 tokenId) external view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost)
```

### marketPriceNativeCurrency

```solidity
function marketPriceNativeCurrency(uint256 fingerprint) external view returns (uint256 nativePrice, uint256 currency)
```

### marketPriceTotalNativeCurrency

```solidity
function marketPriceTotalNativeCurrency(uint256[] fingerprints) external view returns (uint256 nativePrice, uint256 currency)
```

### marketPricesNativeCurrencies

```solidity
function marketPricesNativeCurrencies(uint256[] fingerprints) external view returns (uint256[] nativePrices, uint256[] currencies)
```

