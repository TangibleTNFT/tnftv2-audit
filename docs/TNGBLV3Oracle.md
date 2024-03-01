# Solidity API

## IERC20Metadata

_Interface for the optional metadata functions from the ERC20 standard._

### name

```solidity
function name() external view returns (string)
```

_Returns the name of the token._

### symbol

```solidity
function symbol() external view returns (string)
```

_Returns the symbol of the token._

### decimals

```solidity
function decimals() external view returns (uint8)
```

_Returns the decimals places of the token._

## TNGBLV3Oracle

Oracle reader contract, adjusted for TNGBL protocol. Uses the same logic as Uniswap V3 oracle example.

_Logic is abstracted for our purposes and to fit our ecosystem._

### POOL_FEE_100

```solidity
uint24 POOL_FEE_100
```

### POOL_FEE_03

```solidity
uint24 POOL_FEE_03
```

### POOL_FEE_001

```solidity
uint24 POOL_FEE_001
```

### POOL_FEE_00001

```solidity
uint24 POOL_FEE_00001
```

### POOL_FEE_1

```solidity
uint24 POOL_FEE_1
```

### POOL_FEE_005

```solidity
uint24 POOL_FEE_005
```

### DEFAULT_SECONDS_AGO

```solidity
uint32 DEFAULT_SECONDS_AGO
```

### uniV3Factory

```solidity
address uniV3Factory
```

### POOL_FEE_01

```solidity
uint24 POOL_FEE_01
```

### UniFactoryChanged

```solidity
event UniFactoryChanged(address uniV3Factory_new, address uniV3Factory_old)
```

_This event is emitted when the uniswap v3 factory is changed._

### constructor

```solidity
constructor(address _uniV3Factory) public
```

### setUniV3Factory

```solidity
function setUniV3Factory(address _uniV3Factory) external
```

_Sets new uniswap v3 factory_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _uniV3Factory | address | Address of new uniswap v3 factory. |

### consult03

```solidity
function consult03(address tokenIn, uint128 amountIn, address tokenOut, uint32 secondsAgo) external view returns (uint256 amountOut)
```

_Returns amountOut for given amountIn. Fee is set to 0.3%._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Address of tokenIn. |
| amountIn | uint128 | Amount of tokenIn. |
| tokenOut | address | Address of tokenOut. |
| secondsAgo | uint32 | Seconds ago tells how much in the past to look. |

### consult001

```solidity
function consult001(address tokenIn, uint128 amountIn, address tokenOut, uint32 secondsAgo) external view returns (uint256 amountOut)
```

_Returns amountOut for given amountIn. Fee is set to 0.01%._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Address of tokenIn. |
| amountIn | uint128 | Amount of tokenIn. |
| tokenOut | address | Address of tokenOut. |
| secondsAgo | uint32 | Seconds ago tells how much in the past to look. |

### consult005

```solidity
function consult005(address tokenIn, uint128 amountIn, address tokenOut, uint32 secondsAgo) external view returns (uint256 amountOut)
```

_Returns amountOut for given amountIn. Fee is set to 0.05%._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Address of tokenIn. |
| amountIn | uint128 | Amount of tokenIn. |
| tokenOut | address | Address of tokenOut. |
| secondsAgo | uint32 | Seconds ago tells how much in the past to look. |

### consult1

```solidity
function consult1(address tokenIn, uint128 amountIn, address tokenOut, uint32 secondsAgo) external view returns (uint256 amountOut)
```

_Returns amountOut for given amountIn. Fee is set to 1%._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Address of tokenIn. |
| amountIn | uint128 | Amount of tokenIn. |
| tokenOut | address | Address of tokenOut. |
| secondsAgo | uint32 | Seconds ago tells how much in the past to look. |

### consultWithFee

```solidity
function consultWithFee(address tokenIn, uint128 amountIn, address tokenOut, uint32 secondsAgo, uint24 fee) external view returns (uint256 amountOut)
```

_Returns amountOut for given amountIn. Accepts custom fee parameter_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Address of tokenIn. |
| amountIn | uint128 | Amount of tokenIn. |
| tokenOut | address | Address of tokenOut. |
| secondsAgo | uint32 | Seconds ago tells how much in the past to look. |
| fee | uint24 | Pool fee. |

### getQuoteAtCurrentTick

```solidity
function getQuoteAtCurrentTick(address tokenIn, address tokenOut, uint24 fee) external view returns (uint256 quoteAmount)
```

_Get token quote at given tick._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Input token address. |
| tokenOut | address | Output token address. |
| fee | uint24 | Pool fee. |

### _consultWithFee

```solidity
function _consultWithFee(address tokenIn, uint128 amountIn, address tokenOut, uint32 secondsAgo, uint24 fee) internal view returns (uint256 amountOut)
```

### _fetchPool

```solidity
function _fetchPool(address tokenIn, address tokenOut, uint24 fee) internal view returns (address pool)
```

_Fetches pool address for given tokenIn, tokenOut and fee._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Address of tokenIn. |
| tokenOut | address | Address of tokenOut. |
| fee | uint24 | Pool fee. |

### _estimateAmountOut

```solidity
function _estimateAmountOut(address tokenIn, address tokenOut, address pool, uint128 amountIn, uint32 secondsAgo) internal view returns (uint256 amountOut)
```

_Estimates amountOut for given amountIn. Taken example from OracleLibrary.sol._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Address of tokenIn. |
| tokenOut | address | Address of tokenOut. |
| pool | address | Address of pool. |
| amountIn | uint128 | Amount of tokenIn. |
| secondsAgo | uint32 | Seconds ago tells how much in the past to look. |

