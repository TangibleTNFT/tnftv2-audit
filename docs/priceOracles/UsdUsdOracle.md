# Solidity API

## Owned

A contract with helpers for basic contract ownership.

### owner

```solidity
address owner
```

### OwnershipTransferRequested

```solidity
event OwnershipTransferRequested(address from, address to)
```

### OwnershipTransferred

```solidity
event OwnershipTransferred(address from, address to)
```

### constructor

```solidity
constructor() public
```

### transferOwnership

```solidity
function transferOwnership(address _to) external
```

_Allows an owner to begin transferring ownership to a new address,
pending._

### acceptOwnership

```solidity
function acceptOwnership() external
```

_Allows an ownership transfer to be completed by the recipient._

### onlyOwner

```solidity
modifier onlyOwner()
```

_Reverts if called by anyone other than the contract owner._

## AggregatorInterface

### latestAnswer

```solidity
function latestAnswer() external view returns (int256)
```

### latestTimestamp

```solidity
function latestTimestamp() external view returns (uint256)
```

### latestRound

```solidity
function latestRound() external view returns (uint256)
```

### getAnswer

```solidity
function getAnswer(uint256 roundId) external view returns (int256)
```

### getTimestamp

```solidity
function getTimestamp(uint256 roundId) external view returns (uint256)
```

### AnswerUpdated

```solidity
event AnswerUpdated(int256 current, uint256 roundId, uint256 updatedAt)
```

### NewRound

```solidity
event NewRound(uint256 roundId, address startedBy, uint256 startedAt)
```

## AggregatorV3Interface

### decimals

```solidity
function decimals() external view returns (uint8)
```

### description

```solidity
function description() external view returns (string)
```

### version

```solidity
function version() external view returns (uint256)
```

### getRoundData

```solidity
function getRoundData(uint80 _roundId) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
```

### latestRoundData

```solidity
function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
```

## AggregatorV2V3Interface

## UsdUsdOracle

A trusted proxy for updating where current answers are read from
This contract provides a consistent address for the
Aggregator and AggregatorV3Interface but delegates where it reads from to the owner, who is
trusted to update it.
Only access enabled addresses are allowed to access getters for
aggregated answers and round information.

_Implemented for the purpose of Tangible's price oracle system. Each currency
has it's own price feed so technically, USD should have a price feed USD/USD.
Of course, it is always 1, hence this contract._

### latestAnswer

```solidity
function latestAnswer() public view returns (int256)
```

We simply return 1 for the latest answer, to support
our flow in oracles when we do conversions from some other
currencies to USD. In case the currency is indeed USD, we just multiply with 1.

### latestRoundData

```solidity
function latestRoundData() public view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
```

get data about the latest round. Consumers are encouraged to check
that they're receiving fresh data by inspecting the updatedAt and
answeredInRound return values.
Note that different underlying implementations of AggregatorV3Interface
have slightly different semantics for some of the return values. Consumers
should determine what implementations they expect to receive
data from and validate that they can properly handle return data from all
of them.

_Note that answer and updatedAt may change between queries.
Implemented in a way to support Tangible's price oracle system._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| roundId | uint80 | is the round ID from the aggregator for which the data was retrieved combined with a phase to ensure that round IDs get larger as time moves forward. |
| answer | int256 | is the answer for the given round |
| startedAt | uint256 | is the timestamp when the round was started. (Only some AggregatorV3Interface implementations return meaningful values) |
| updatedAt | uint256 | is the timestamp when the round last was updated (i.e. answer was last computed) |
| answeredInRound | uint80 | is the round ID of the round in which the answer was computed. (Only some AggregatorV3Interface implementations return meaningful values) |

### decimals

```solidity
function decimals() external view returns (uint8)
```

represents the number of decimals the aggregator responses represent.

_Implemented in a way to support Tangible's price oracle system._

### version

```solidity
function version() external view returns (uint256)
```

the version number representing the type of aggregator the proxy
points to.

_Implemented in a way to support Tangible's price oracle system._

### description

```solidity
function description() external view returns (string)
```

returns the description of the aggregator the proxy points to.

_Implemented in a way to support Tangible's price oracle system._

### getAnswer

```solidity
function getAnswer(uint256 roundId) external view returns (int256)
```

returns the current round ID.

_Implemented in a way to support Tangible's price oracle system._

### getTimestamp

```solidity
function getTimestamp(uint256 roundId) external view returns (uint256)
```

returns the timestamp of the last update to the data.

_Implemented in a way to support Tangible's price oracle system._

### latestRound

```solidity
function latestRound() external view returns (uint256)
```

returns the current round ID.

_Implemented in a way to support Tangible's price oracle system._

### latestTimestamp

```solidity
function latestTimestamp() external view returns (uint256)
```

returns the timestamp of the last update to the data.

_Implemented in a way to support Tangible's price oracle system._

### getRoundData

```solidity
function getRoundData(uint80 _roundId) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
```

returns the current round ID and additional data.

_Implemented in a way to support Tangible's price oracle system._

