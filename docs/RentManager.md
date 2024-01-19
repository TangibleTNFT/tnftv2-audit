# Solidity API

## RentManager

_This contract is a system for managing the deposit, vesting, and claiming of rent for NFTs.

This contract allows depositor to deposit rent for specific NFTs, users can check how much rent is claimable for a token, claim the
rent for a token, depositor can do stop of vesting, claim remaining and reset data for tokenId.

The system supports regular NFTs (TNFTs).

The contract uses a time-based linear vesting system. A user can deposit rent for a token for a specified period of
time. We have 2 options - enum based values representing months with 31, 30, 28 and 29 days. For custom end time it can
be from moment of depositing up to 2 months period.
The rent then vests linearly over that period, and the owner of the token can claim the vested rent at any time.

The contract keeps track of the deposited, claimed, and unclaimed amounts for each token.
Also it takes care of backpayment so if there was no rent deposited for 10 days after previous rent vest expired,
It starts vesting from the moment the old vest stopped.
With pause and claim back, you reset end time, take what is left, claim what is for the owner.

The contract also provides a function to calculate the claimable rent for a token.

The contract emits events for rent deposits._

### TNFT_ADDRESS

```solidity
address TNFT_ADDRESS
```

Used to store the contract address of the TangibleNFT contract address(this) manages rent for.

### depositor

```solidity
address depositor
```

Used to store the address that deposits rent into this contract.

### rentInfo

```solidity
mapping(uint256 => struct IRentManager.RentInfo) rentInfo
```

### notificationDispatcher

```solidity
address notificationDispatcher
```

### RentDeposited

```solidity
event RentDeposited(address depositor, uint256 tokenId, address rentToken, uint256 amount)
```

Emitted when rent is deposited for a token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| depositor | address | The address of the user who deposited the rent. |
| tokenId | uint256 | The ID of the token for which rent was deposited. |
| rentToken | address | The address of the token used to pay the rent. |
| amount | uint256 | The amount of rent deposited. |

### RentClaimed

```solidity
event RentClaimed(address claimer, address nft, uint256 tokenId, address rentToken, uint256 amount)
```

Emitted when rent is claimed for a token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| claimer | address | The address of the user who claimed the rent. |
| nft | address | The address of the NFT contract. |
| tokenId | uint256 | The ID of the token for which rent was claimed. |
| rentToken | address | The address of the token used to pay the rent. |
| amount | uint256 | The amount of rent claimed. |

### DistributionPaused

```solidity
event DistributionPaused(address rentToken, uint256 tokenId, uint256 claimedBack, uint256 depositAmount, uint256 vestedFor, uint256 depositTime)
```

Emitted when rent distribution is paused for token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rentToken | address | Token used for the rent. |
| tokenId | uint256 | The tokenId for which we stopped distribution. |
| claimedBack | uint256 | The amount we claimed back when stopping the distribution. |
| depositAmount | uint256 | Original deposit amount. |
| vestedFor | uint256 | Time between deposit and stop. |
| depositTime | uint256 | Original deposit time of the distribution amount. |

### DEPOSIT_MONTH

Enum object to identify a custom contract data type via an enumerable.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
enum DEPOSIT_MONTH {
  DAYS_31,
  DAYS_30,
  DAYS_28,
  DAYS_29
}
```

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _tnftAddress, address _factory) external
```

_Constructor that initializes the TNFT contract address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tnftAddress | address | The address of the TNFT contract. |
| _factory | address |  |

### updateDepositor

```solidity
function updateDepositor(address _newDepositor) external
```

_Function to update the address of the rent depositor.
Only callable by the owner of the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newDepositor | address | The address of the new rent depositor. |

### disableRebaseOfRentToken

```solidity
function disableRebaseOfRentToken(address _token, bool _disable) external
```

_Function to disable rebasing of tngbl foundation tokens._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | The address of the rebasing token. |
| _disable | bool | True if we want to disable rebase, false if we want to enable it. |

### updateNotificationDispatcher

```solidity
function updateNotificationDispatcher(address _newNotificationDistpatcher) external
```

_Function to update the address of the rent depositor.
Only callable by the owner of the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newNotificationDistpatcher | address | The address of the new rent depositor. |

### deposit

```solidity
function deposit(uint256 tokenId, address tokenAddress, uint256 amount, uint256 month, uint256 endTime, bool skipBackpayment) external
```

Allows the rent depositor to deposit rent for a specific token.

_This function requires the caller to be the current rent depositor.
It also checks whether the specified end time is in the future.
If the token's current rent token is either the zero address or the same as the provided token address,
the function allows the deposit.

The function first transfers the specified amount of the rent token from the depositor to the contract.
If the token's rent token is the zero address, it sets the rent token to the provided token address.

The function then calculates the token's vested amount.

The function then calculates the token's unvested amount, updates the token's unclaimed amount,
resets the token's claimed amount, adds the deposit amount to the token's unvested amount,
updates the deposit time, and sets the end time.

Finally, the function emits a `RentDeposited` event._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token for which to deposit rent. |
| tokenAddress | address | The address of the rent token to deposit. |
| amount | uint256 | The amount of the rent token to deposit. |
| month | uint256 | Enum representing length of a month in days. |
| endTime | uint256 | The end time of the rent deposit. |
| skipBackpayment | bool | By default - we backpay every rent. |

### distributionRunning

```solidity
function distributionRunning(uint256 tokenId) external view returns (bool)
```

Checks if distribution for specified tokenId is running or not.

_Useful for checking if rent distro is stopped._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TokenId for which to check if rent distribution is running |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if running, false if not |

### pauseAndClaimBackDistribution

```solidity
function pauseAndClaimBackDistribution(uint256 tokenId) external returns (uint256 amount)
```

Pause distribution and claim back deposited amount.

_Claim for the owner.
 Reset everything to default values, except claimedAmountTotal._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TokenId for which to check if rent distribution is paused |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | Amount that we claimed back |

### claimableRentForToken

```solidity
function claimableRentForToken(uint256 tokenId) public view returns (uint256)
```

Returns the amount of rent that can be claimed for a given token.

_The function calculates the claimable rent based on the rent info of the token._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The amount of claimable rent for the token. |

### claimableRentForTokenBatch

```solidity
function claimableRentForTokenBatch(uint256[] tokenIds) public view returns (uint256[] claimables)
```

Returns the amount of rent that can be claimed for a given tokens.

_Returns the array of claimable rent for the tokens._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | The IDs of the tokens. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| claimables | uint256[] | The amounts of claimable rent per tokens. |

### claimableRentInfoBatch

```solidity
function claimableRentInfoBatch(uint256[] tokenIds) external view returns (struct IRentManager.RentInfo[] rentInfos, uint256[] claimables)
```

Returns the rent info array and claimables for a given tokenIds.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | The IDs of the tokens. |

### claimableRentForTokenBatchTotal

```solidity
function claimableRentForTokenBatchTotal(uint256[] tokenIds) public view returns (uint256 claimable)
```

Returns the total amount of rent that can be claimed for a given tokens.

_The function calculates the total claimable rent based on the rent info of the tokens._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | The IDs of the tokens. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| claimable | uint256 | The amount of claimable rent in total. |

### _claimableRentForToken

```solidity
function _claimableRentForToken(uint256 tokenId) internal view returns (uint256)
```

Internal function that returns how much you can claim for the token

_If distribution is not running, you can't claim anything._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TokenId for which return the claimable rent |

### _claimableRentInfoForToken

```solidity
function _claimableRentInfoForToken(uint256 tokenId) internal view returns (uint256 claimable, struct IRentManager.RentInfo rInfo)
```

Internal function that returns how much you can claim for the token and whole rentInfo

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TokenId for which return the claimable rent |

### claimRentForToken

```solidity
function claimRentForToken(uint256 tokenId) external returns (uint256)
```

Allows the owner of a token to claim their rent.

_The function first checks that the caller is the owner of the token.
It then retrieves the amount of claimable rent for the token and requires that the amount is greater than zero,
and that the token is either not a TNFT.

In both cases, the function updates the claimed and unclaimed amounts of the rent info of the corresponding TNFT
token.

The function then transfers the claimable rent to the caller and emits a `RentClaimed` event._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token. |

### claimRentForTokenBatch

```solidity
function claimRentForTokenBatch(uint256[] tokenIds) external returns (uint256[] claimed)
```

Allows the owner of a tokens to claim their rent.

_Returns how much you have claimed for each token._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenIds | uint256[] | The IDs of the tokens. |

### _claimRentForToken

```solidity
function _claimRentForToken(address to, uint256 tokenId) internal returns (uint256 claimableRent)
```

Allows the owner of a tokens to claim their rent. Internal helper function.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | To whom to send the rent |
| tokenId | uint256 | TokenId for which to claim the rent |

### vestedAmount

```solidity
function vestedAmount(uint256 tokenId) external view returns (uint256)
```

Calculates the vested amount for a rent deposit - public function.

_If the current time is past the end time of the rent period, the function returns the deposit amount.
If the current time is before the end time of the rent period, the function calculates the vested amount based on
the elapsed time and the vesting duration._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | TokenId for which to check vested amount. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The vested amount for the rent deposit. |

### _monthLength

```solidity
function _monthLength(enum RentManager.DEPOSIT_MONTH month) internal pure returns (uint256)
```

Returns number of days depending on a month in seconds.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| month | enum RentManager.DEPOSIT_MONTH | Enum representing on of 4 lengths of a month. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The number of seconds that each month has. |

