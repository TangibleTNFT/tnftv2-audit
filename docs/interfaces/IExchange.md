# Solidity API

## IExchange

### quoteOut

```solidity
function quoteOut(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256)
```

### exchange

```solidity
function exchange(address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut) external returns (uint256)
```

_Performs an exchange of two Erc20 tokens and returns an amount of `tokenOut`._

