# Solidity API

## TangibleProfile

This contract is used to track and manage user profiles from the front end.

### userProfiles

```solidity
mapping(address => struct ITangibleProfile.Profile) userProfiles
```

This mapping is used to map EOA address to profile object.

### update

```solidity
function update(struct ITangibleProfile.Profile profile) external
```

This method is used to update profile objects.

_The profile we're updating is the msg.sender._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| profile | struct ITangibleProfile.Profile | The new profile object. |

### remove

```solidity
function remove() external
```

This method is used to delete profiles.

_The profile we're updating is the msg.sender._

### namesOf

```solidity
function namesOf(address[] owners) external view returns (string[] names)
```

This method is used to fetch a list of usernames of profiles, given the addresses.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| owners | address[] | Array of addresses we wish to query usernames from. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| names | string[] | -> An array of usernames (type string). |

