# Solidity API

## ITangiblePriceManager

### oracleForCategory

```solidity
function oracleForCategory(contract ITangibleNFT category) external view returns (contract IPriceOracle)
```

_The function returns contract oracle for category._

### setOracleForCategory

```solidity
function setOracleForCategory(contract ITangibleNFT category, contract IPriceOracle oracle) external
```

_The function returns current price from oracle for provided category._

