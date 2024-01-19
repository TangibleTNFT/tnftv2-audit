# Solidity API

## RevenueShare

### claimForToken

```solidity
function claimForToken(address contractAddress, uint256 tokenId) external
```

### share

```solidity
function share(bytes token) external view returns (int256)
```

### updateShare

```solidity
function updateShare(address contractAddress, uint256 tokenId, int256 amount) external
```

### unregisterContract

```solidity
function unregisterContract(address contractAddress) external
```

### total

```solidity
function total() external view returns (uint256)
```

## RentShare

### forToken

```solidity
function forToken(address contractAddress, uint256 tokenId) external returns (contract RevenueShare)
```

## IFactory

### mint

```solidity
function mint(struct IVoucher.MintVoucher voucher) external returns (uint256[])
```

_The function which does lazy minting._

### marketplace

```solidity
function marketplace() external view returns (address)
```

_The function returns the address of the marketplace._

### tangibleLabs

```solidity
function tangibleLabs() external view returns (address)
```

_Returns labs owner._

### tnftDeployer

```solidity
function tnftDeployer() external view returns (address)
```

_The function returns the address of the tnft deployer._

### priceManager

```solidity
function priceManager() external view returns (contract ITangiblePriceManager)
```

_The function returns the address of the priceManager._

### category

```solidity
function category(string name) external view returns (contract ITangibleNFT)
```

_The function returns an address of category NFT._

### adjustStorageAndGetAmount

```solidity
function adjustStorageAndGetAmount(contract ITangibleNFT tnft, contract IERC20Metadata paymentToken, uint256 tokenId, uint256 _years) external returns (uint256)
```

_The function pays for storage, called only by marketplace._

### defUSD

```solidity
function defUSD() external returns (contract IERC20)
```

_Returns the Erc20 token reference of the default USD stablecoin payment method._

### rentManager

```solidity
function rentManager(contract ITangibleNFT) external view returns (contract IRentManager)
```

_RentManager contract for specific TNFT._

### basketsManager

```solidity
function basketsManager() external view returns (address)
```

Baskets manager address

### currencyFeed

```solidity
function currencyFeed() external view returns (address)
```

Currency feed address

### onlyWhitelistedForUnmintedCategory

```solidity
function onlyWhitelistedForUnmintedCategory(contract ITangibleNFT nft) external view returns (bool)
```

_Returns if the `nft` is a whitelisted category. If true, tnft's are whitelisted buyers only._

### whitelistForBuyUnminted

```solidity
function whitelistForBuyUnminted(contract ITangibleNFT tnft, address buyer) external view returns (bool)
```

_Returns if a specified `buyer` is whitelisted to mint from `tnft`._

### categoryMinter

```solidity
function categoryMinter(address minter) external view returns (bool)
```

_Returns if a `minter` address is a defined as a category minter._

### paymentTokens

```solidity
function paymentTokens(contract IERC20 token) external view returns (bool)
```

_Returns if a specified `token` is accepted as a payment Erc20 method._

### categoryOwner

```solidity
function categoryOwner(contract ITangibleNFT nft) external view returns (address)
```

_Returns the address of the category owner for a specified `nft`._

### fingerprintApprovalManager

```solidity
function fingerprintApprovalManager(contract ITangibleNFT nft) external view returns (address)
```

_Returns the address of the "approval manager" for a specified `nft`._

### tnftMetadata

```solidity
function tnftMetadata() external view returns (address)
```

_Returns the address of the TangibleNFTMetadata contract._

### categoryOwnerWallet

```solidity
function categoryOwnerWallet(contract ITangibleNFT nft) external view returns (address)
```

_Returns the address to be used while sending payments to categoryOwner (buyUnminted,storage)._

