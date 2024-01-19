# Solidity API

## IVoucher

### MintVoucher

_Voucher for minting_

```solidity
struct MintVoucher {
  contract ITangibleNFT token;
  uint256 mintCount;
  uint256 price;
  address vendor;
  address buyer;
  uint256 fingerprint;
  bool sendToVendor;
}
```

### RedeemVoucher

_Voucher for lazy-burning_

```solidity
struct RedeemVoucher {
  contract ITangibleNFT token;
  uint256[] tokenIds;
  bool[] inOurCustody;
}
```

