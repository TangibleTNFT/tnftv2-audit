# Solidity API

## BalanceBatchReader

This contract is used to fetch multiple balances of a single token.

_Helper contract as extension to Erc20 contract._

### balancesOfAddresses

```solidity
function balancesOfAddresses(contract IERC20 tokenAddress, address[] wallets) external view returns (uint256[] balances)
```

This method is used to return the balances for an array of wallet addresses.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenAddress | contract IERC20 | Erc20 token contract address we wish to fetch balances for. |
| wallets | address[] | Array of EOAs containing some amount of `tokenAddress` tokens. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| balances | uint256[] | -> Array of balances corresponding with the array of wallets provided. |

