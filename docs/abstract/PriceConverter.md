# Solidity API

## PriceConverter

Usable by other contracts to have a unanimous way
to convert between decimals.

### toDecimals

```solidity
function toDecimals(uint256 amount, uint8 fromDecimal, uint8 toDecimal) internal pure returns (uint256)
```

This internal method is used to convert between decimals.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | Amount of token to convert. |
| fromDecimal | uint8 | From which decimal (decimals of amount). |
| toDecimal | uint8 | To which decimal amount is converted. |

