# Solidity API

## SellFeeDistributorV2

This contract collects fees and distributes it to the correct places;

_All the fees are sent to revenueShare._

### REVENUE_TOKEN

```solidity
contract IERC20 REVENUE_TOKEN
```

Stores the address for REVENUE_TOKEN stablecoin.

### revenueShare

```solidity
address revenueShare
```

Stores the address where the revenue portion of fees are distributed.

### exchange

```solidity
contract IExchange exchange
```

Stores the exchange contract reference.

### FeeDistributed

```solidity
event FeeDistributed(address to, uint256 usdcAmount)
```

This event is emitted when fees are distributed.

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory, address _revenueShare, address _revenueToken) external
```

Initializes SellFeeDistributor.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Address of  Factory contract. |
| _revenueShare | address | Address of RevenueShare. |
| _revenueToken | address | Address of Revenue token . |

### setRevenueShare

```solidity
function setRevenueShare(address _revenueShare) external
```

This method is used for the Factory owner to update the `revenueShare` variable.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _revenueShare | address | New revenueShare address. |

### setRevenueToken

```solidity
function setRevenueToken(address _revenueToken) external
```

This method is used for the Factory owner to update the `revenueToken` variable.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _revenueToken | address | New revenue token address. |

### setExchange

```solidity
function setExchange(address _exchange) external
```

This method is used for the Factory owner to update the `exchange` variable.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _exchange | address | New exchange address. |

### withdrawToken

```solidity
function withdrawToken(contract IERC20 _token) external
```

This method is used for the Factory owner to withdraw any token from the contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | contract IERC20 | Erc20 token to be witdrawn from this contract. |

### distributeFee

```solidity
function distributeFee(contract IERC20 _paymentToken, uint256 _feeAmount) external
```

This method is used to initiate the distribution of fees.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _paymentToken | contract IERC20 | Erc20 token to take as payment. |
| _feeAmount | uint256 | Amount of `paymentToken` being used for payment. |

### _distributeFee

```solidity
function _distributeFee(contract IERC20 _paymentToken, uint256 _feeAmount) internal
```

This method allocates an amount of tokens to the revenueShare contract.

_If passed token is not revenue token - swap to revenue token._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _paymentToken | contract IERC20 | Erc20 token to take as payment. |
| _feeAmount | uint256 | Amount of `_paymentToken` being used for payment. |

