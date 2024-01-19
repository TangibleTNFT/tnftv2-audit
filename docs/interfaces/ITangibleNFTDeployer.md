# Solidity API

## ITangibleNFTDeployer

### deployTnft

```solidity
function deployTnft(string name, string symbol, string uri, bool isStoragePriceFixedAmount, bool storageRequired, bool _symbolInUri, uint256 _tnftType) external returns (contract ITangibleNFT)
```

_Will deploy a new TangibleNFT contract and return the TangibleNFT reference._

