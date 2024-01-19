# Solidity API

## ITangibleMarketplace

### Lot

This struct is used to track a token's status when listed on the Marketplace

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct Lot {
  contract ITangibleNFT nft;
  contract IERC20 paymentToken;
  uint256 tokenId;
  address seller;
  uint256 price;
  address designatedBuyer;
}
```

### sellBatch

```solidity
function sellBatch(contract ITangibleNFT nft, contract IERC20 paymentToken, uint256[] tokenIds, uint256[] price, address designatedBuyer) external
```

_The function allows anyone to put on sale the TangibleNFTs they own
if price is 0 - use oracle price when someone buys_

### stopBatchSale

```solidity
function stopBatchSale(contract ITangibleNFT nft, uint256[] tokenIds) external
```

_The function allows the owner of the minted TangibleNFT items to remove them from the Marketplace_

### buy

```solidity
function buy(contract ITangibleNFT nft, uint256 tokenId, uint256 _years, uint256 _maxStorageAmount, address _paymentToken, uint256 _paymentAmount) external
```

_The function allows the user to buy any TangibleNFT
from the Marketplace for payment token that seller wants_

### buyUnminted

```solidity
function buyUnminted(contract ITangibleNFT nft, contract IERC20 paymentToken, uint256 _fingerprint, uint256 _years, uint256 _maxStorageAmount) external returns (uint256 tokenId)
```

_The function allows the user to buy any TangibleNFT from the Marketplace
for defaultUSD token if paymentToken is empty, only for unminted items_

### sellFeeAddress

```solidity
function sellFeeAddress() external view returns (address)
```

_The function returns the address of the fee storage._

### payStorage

```solidity
function payStorage(contract ITangibleNFT nft, contract IERC20Metadata paymentToken, uint256 tokenId, uint256 _years, uint256 _maxStorageAmount) external
```

_The function which buys additional storage to token._

### setDesignatedBuyer

```solidity
function setDesignatedBuyer(contract ITangibleNFT nft, uint256 tokenId, address designatedBuyer) external
```

## ITangibleMarketplaceExt

### marketplaceLot

```solidity
function marketplaceLot(address tnft, uint256 tokenId) external view returns (struct ITangibleMarketplace.Lot)
```

