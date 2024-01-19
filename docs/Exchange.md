# Solidity API

## ExchangeV2

This contract is used to exchange Erc20 tokens.

_Helper contract in the TNFT marketplace ecosystem.
Supports UniV3 exchange type, and before exchanging the tokens,
it requires for token data to be submitted which is:
- SwapRouter address
- Fee used on pair pool, UniV3
- Seconds ago for the oracle

To properly protect against sandwich attacks, it has a reference to ITNGBLV3Oracle
which is implementation of Uniswap V3 oracle, abstracted for our purposes.

Based on pool info we can compare if PoolFactory returns what we need._

### SwapRouter

This struct is used to store data for a pair.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct SwapRouter {
  address swap;
  uint24 fee;
  uint32 secondsAgo;
}
```

### DEFAULT_SECONDS_AGO

```solidity
uint32 DEFAULT_SECONDS_AGO
```

Default seconds ago for the oracle

### routers

```solidity
mapping(bytes => struct ExchangeV2.SwapRouter) routers
```

Mapping of concatenated pairs to SwapRouter data used on pair pool, UniV3.

### oracle

```solidity
contract ITNGBLV3Oracle oracle
```

UniV3 oracle.

### percentageDeviation

```solidity
uint256 percentageDeviation
```

Percentage deviation used on the oracle, tolerated slippage.

### OracleChanged

```solidity
event OracleChanged(address oracle_new, address oracle_old)
```

This event is emitted when the oracle address is changed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| oracle_new | address | New oracle address. |
| oracle_old | address | Old oracle address. |

### PercentageDeviationChanged

```solidity
event PercentageDeviationChanged(uint256 percentageDeviation_new, uint256 percentageDeviation_old)
```

This event is emitted when the percentage deviation is changed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| percentageDeviation_new | uint256 | New percentage deviation. |
| percentageDeviation_old | uint256 | Old percentage deviation. |

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory, address _oracle) external
```

Initializes the Exchange contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Address for the  Factory contract. |
| _oracle | address |  |

### addFeesTokens

```solidity
function addFeesTokens(address tokenInAddress, address tokenOutAddress, address _swapRouter, uint24 _fee, uint32 _secondsAgo) external
```

This function allows the factory owner to add a new pair to exchange.

_Only factory owner can call this method._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenInAddress | address | Address of Erc20 token we're exchanging from. |
| tokenOutAddress | address | Address of Erc20 token we're exchanging to. |
| _swapRouter | address | Address of the swap router. |
| _fee | uint24 | Fee used on pair pool, UniV3. |
| _secondsAgo | uint32 | Seconds ago for the oracle. |

### setPercentageDeviation

```solidity
function setPercentageDeviation(uint256 _percentageDeviation) external
```

This function allows the factory owner to change the percentage deviation.

_Only factory owner can call this method._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _percentageDeviation | uint256 | Percentage deviation used on the oracle. |

### setOracle

```solidity
function setOracle(address _oracle) external
```

This function allows the factory owner change oracle address,
in case it gets redeployed.

_Only factory owner can call this method._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _oracle | address | Address of the new oracle. |

### setSecondsAgo

```solidity
function setSecondsAgo(address tokenInAddress, address tokenOutAddress, uint32 _secondsAgo) external
```

This functions updates seconds ago for a pair.

_Only factory owner can call this method._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenInAddress | address | token in address |
| tokenOutAddress | address | token out address |
| _secondsAgo | uint32 | seconds ago used for the oracle |

### exchange

```solidity
function exchange(address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut) external returns (uint256 amountOut)
```

This function exchanges a specified Erc20 token for another Erc20 token.

_It can be used by anyone and it has sandwich attack protection._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Address of Erc20 token being token from owner. |
| tokenOut | address | Address of Erc20 token being given to the owner. |
| amountIn | uint256 | Amount of `tokenIn` to be exchanged. |
| minAmountOut | uint256 | The minimum amount expected from `tokenOut`. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| amountOut | uint256 | Amount of returned `tokenOut` tokens. |

### quoteOut

```solidity
function quoteOut(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256 amountOut)
```

This method is used to fetch a quote for an exchange.

_It can be used by anyone. It relies on the UniV3 oracle to fetch the quote._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIn | address | Address of Erc20 token being token from owner. |
| tokenOut | address | Address of Erc20 token being given to the owner. |
| amountIn | uint256 | Amount of `tokenIn` to be exchanged. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| amountOut | uint256 | Amount of `tokenOut` tokens for quote. |

