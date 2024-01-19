# Solidity API

## IMarketplace

### MarketItem

```solidity
struct MarketItem {
  uint256 tokenId;
  address seller;
  address owner;
  address paymentToken;
  uint256 price;
  bool listed;
}
```

### _idToMarketItem

```solidity
function _idToMarketItem(uint256 tokenId) external view returns (struct IMarketplace.MarketItem)
```

