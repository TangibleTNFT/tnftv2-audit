# Solidity API

## ITangibleProfile

### Profile

This struct is used to define a Profile object.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct Profile {
  string userName;
  string imageURL;
}
```

### ProfileUpdated

```solidity
event ProfileUpdated(struct ITangibleProfile.Profile oldProfile, struct ITangibleProfile.Profile newProfile)
```

This event is emitted when a profile is updated.

### ProfileDeleted

```solidity
event ProfileDeleted(struct ITangibleProfile.Profile removedProfile)
```

This event is emitted when a profile is removed.

### update

```solidity
function update(struct ITangibleProfile.Profile profile) external
```

_The function updates the user profile._

### remove

```solidity
function remove() external
```

_The function removes the user profile._

### namesOf

```solidity
function namesOf(address[] owners) external view returns (string[])
```

_The function returns name(s) of user(s)._

