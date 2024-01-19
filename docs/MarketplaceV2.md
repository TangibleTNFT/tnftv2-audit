# Solidity API

## TNFTMarketplaceV2

This smart contract facilitates the buying and selling of Tangible NFTs.

_This contract is used to buy and sell Tangible NFTs. It has couple of functions:
  - `sell` -> Used to list a TNFT for sale. It has Batch version also.
  - `buy` -> Used to buy a TNFT from the marketplace.
  - `stopSelling` -> Used to stop selling a TNFT.
  - `setFeeForCategory` -> Used to set the fee for a category of TNFTs. Fee is taken from
the seller and only on second sales(buyUnminted is not affected).
  - `setSellFeeAddress` -> Used to set the address where the fee is sent to.
  - `setOnSaleTracker` -> Used to set the address of the OnSaleTracker contract. Helper contract
that keeps track of which TNFTs are listed on the marketplace.
  - `buyUnminted` -> Used to buy a unminted TNFT from the marketplace. It uses Factory as proxy
 to mint the tnft, factory sends it to vendor, then marketplace and them marketplace sends it
to buyer. If storage is required, it will be paid in the same transaction. User can specify how many years
of storage he wants.
  - `payStorage` -> Used to pay for storage of a TNFT(anyone can pay for any token).
  - `setDesignatedBuyer` -> Used to set a designated buyer for a token. If you agree with someone to buy
your item, designated buyer is the only one who can buy it._

### BuyHelper

This struct is used to help with stack too deep error.

```solidity
struct BuyHelper {
  address buyer;
  uint256 cost;
  uint256 toPaySeller;
}
```

### DEFAULT_SELL_FEE

```solidity
uint256 DEFAULT_SELL_FEE
```

This constant stores the default sell fee of 2.5% (2 basis points).

### marketplaceLot

```solidity
mapping(address => mapping(uint256 => struct ITangibleMarketplace.Lot)) marketplaceLot
```

This mapping is used to store Lot data for each token listed on the marketplace.

### sellFeeAddress

```solidity
address sellFeeAddress
```

This stores the address where sell fees are allocated to.

### onSaleTracker

```solidity
contract IOnSaleTracker onSaleTracker
```

OnSaleTracker contract reference.

### feesPerCategory

```solidity
mapping(contract ITangibleNFT => uint256) feesPerCategory
```

This mapping is used to store the marketplace fees attached to each category of TNFTs.

_The fees use 2 basis points for precision (i.e. 15% == 1500 // 2.5% == 250).
If not set, the DEFAULT_SELL_FEE is used._

### initialSaleCompleted

```solidity
mapping(contract ITangibleNFT => mapping(uint256 => bool)) initialSaleCompleted
```

This mapping is used to store the initial sale status of each TNFT.

_If true, the TNFT has been sold at least once since minting._

### MarketplaceFeePaid

```solidity
event MarketplaceFeePaid(address nft, uint256 tokenId, address paymentToken, uint256 feeAmount)
```

This event is emitted when the marketplace fee is paid by a buyer.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | address | Address of TangibleNFT contract. |
| tokenId | uint256 | TNFT identifier. |
| paymentToken | address | Token used to pay for fee |
| feeAmount | uint256 | Fee amount paid. |

### Selling

```solidity
event Selling(address seller, address nft, uint256 tokenId, address paymentToken, uint256 price)
```

This event is emitted when a TNFT is listed for sale.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| seller | address | The original owner of the token. |
| nft | address | Address of TangibleNFT contract. |
| tokenId | uint256 | TNFT identifier. |
| paymentToken | address | Token used to pay for the item. |
| price | uint256 | Price TNFT is listed at. |

### StopSelling

```solidity
event StopSelling(address seller, address nft, uint256 tokenId)
```

This event is emitted when a token that was listed for sale is stopped by the owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| seller | address | The owner of the token. |
| nft | address | Address of TangibleNFT contract. |
| tokenId | uint256 | TNFT identifier. |

### TnftBought

```solidity
event TnftBought(address nft, uint256 tokenId, address paymentToken, address buyer, uint256 price)
```

This event is emitted when a TNFT has been purchased from the marketplace.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | address | Address of TangibleNFT contract. |
| tokenId | uint256 | TNFT identifier. |
| paymentToken | address | Token used to pay for the item. |
| buyer | address | Address of EOA that purchased the TNFT |
| price | uint256 | Price at which the token was purchased. |

### TnftSold

```solidity
event TnftSold(address nft, uint256 tokenId, address paymentToken, address seller, uint256 price)
```

This event is emitted when a TNFT has been sold from the marketplace.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | address | Address of TangibleNFT contract. |
| tokenId | uint256 | TNFT identifier. |
| paymentToken | address | Token used to pay for the item. |
| seller | address | Address of seller that was selling |
| price | uint256 | Price at which the token was sold. |

### SellFeeAddressSet

```solidity
event SellFeeAddressSet(address oldFeeAddress, address newFeeAddress)
```

This event is emitted when `sellFeeAddress` is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| oldFeeAddress | address | The previous `sellFeeAddress`. |
| newFeeAddress | address | The new `sellFeeAddress`. |

### SaleTrackerSet

```solidity
event SaleTrackerSet(address oldSaleTracker, address newSaleTracker)
```

This event is emitted when the value stored in `onSaleTracker` is updated

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| oldSaleTracker | address | The previous address stored in `onSaleTracker`. |
| newSaleTracker | address | The new address stored in `onSaleTracker`. |

### SellFeeChanged

```solidity
event SellFeeChanged(contract ITangibleNFT nft, uint256 oldFee, uint256 newFee)
```

This event is emitted when there is an update to `feesPerCategory`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| oldFee | uint256 | Previous fee. |
| newFee | uint256 | New fee. |

### StorageFeePaid

```solidity
event StorageFeePaid(address nft, uint256 tokenId, address paymentToken, address payer, uint256 amount)
```

This event is emitted when we have a successful execution of `_payStorage`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | address | Address of TangibleNFT contract. |
| tokenId | uint256 | NFT identifier. |
| paymentToken | address | Address of Erc20 token that was accepted as payment. |
| payer | address | Address of account that paid for storage. |
| amount | uint256 | Amount quoted for storage. |

### DesignatedBuyer

```solidity
event DesignatedBuyer(address nft, uint256 tokenId, address oldBuyer, address newBuyer)
```

This event is emitted when a designated buyer is set for a token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | address | Address of TangibleNFT contract. |
| tokenId | uint256 | NFT identifier. |
| oldBuyer | address | Previous designated buyer. |
| newBuyer | address | New designated buyer. |

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _factory) external
```

Initializes Marketplace contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _factory | address | Address of Factory provider contract |

### sellBatch

```solidity
function sellBatch(contract ITangibleNFT nft, contract IERC20 paymentToken, uint256[] tokenIds, uint256[] price, address designatedBuyer) external
```

This function is used to list a batch of TNFTs at once instead of one at a time.

_This function allows anyone to sell a batch of TNFTs they own.
     If `price` is 0, purchase price is taken from the Oracle for the item.
     If `designatedBuyer` is not 0 address, only that address can buy the item.
     Callable by anyone who owns the tokens._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentToken | contract IERC20 | Erc20 token being used as payment. |
| tokenIds | uint256[] | Array of tokenIds to sell. |
| price | uint256[] | Price per token. |
| designatedBuyer | address | If not zero address, only this address can buy. |

### _updateTrackerTnft

```solidity
function _updateTrackerTnft(contract ITangibleNFT tnft, uint256 tokenId, bool placed) internal
```

This function is used to update the `onSaleTracker::tnftSalePlaced()` tracker state.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract reference. |
| tokenId | uint256 | TNFT identifier. |
| placed | bool | If true, the token is being listed for sale, otherwise false. |

### _sell

```solidity
function _sell(contract ITangibleNFT nft, contract IERC20 paymentToken, uint256 tokenId, uint256 price, address designatedBuyer) internal
```

This internal function is called when a TNFT is listed for sale on the marketplace.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentToken | contract IERC20 | Erc20 token being accepted as payment by seller. |
| tokenId | uint256 | TNFT token identifier. |
| price | uint256 | Price the token is being listed for. |
| designatedBuyer | address | If not zero address, only this address can buy. |

### setOnSaleTracker

```solidity
function setOnSaleTracker(contract IOnSaleTracker _onSaleTracker) external
```

This is a restricted function for updating the `onSaleTracker` contract reference.

_This function is only callable by the Factory contract owner._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _onSaleTracker | contract IOnSaleTracker | The new OnSaleTracker contract. |

### setFeeForCategory

```solidity
function setFeeForCategory(contract ITangibleNFT tnft, uint256 fee) external
```

This is a restricted function to update the `feesPerCategory` mapping.

_This function is only callable by the Category owner._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract reference aka category of TNFTs. |
| fee | uint256 | New fee to charge for category. |

### stopBatchSale

```solidity
function stopBatchSale(contract ITangibleNFT nft, uint256[] tokenIds) external
```

This function allows a TNFT owner to stop the sale of their TNFTs batch.

_User can stop multiple tokens sale at once._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| tokenIds | uint256[] | Array of tokenIds. |

### _stopSale

```solidity
function _stopSale(contract ITangibleNFT nft, uint256 tokenId) internal
```

This function stops the sale of a TNFT and transfers it back to it's original owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| tokenId | uint256 | Array of tokenIds. |

### buy

```solidity
function buy(contract ITangibleNFT nft, uint256 tokenId, uint256 _years, uint256 _maxStorageAmount, address _paymentToken, uint256 _paymentAmount) external
```

This function allows the user to buy any TangibleNFT that is listed on Marketplace.

_If user is not designated buyer, he can't buy the token. If designated buyer is 0 address, anyone can buy.
User is protected against price manipulation._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| tokenId | uint256 | TNFT identifier. |
| _years | uint256 | Num of years to pay for storage. |
| _maxStorageAmount | uint256 | Max amount to pay for storage. |
| _paymentToken | address | Erc20 token being used as payment ,sent as param to protect payer. |
| _paymentAmount | uint256 | Price of in Lot, to protect the payer. |

### payStorage

```solidity
function payStorage(contract ITangibleNFT nft, contract IERC20Metadata paymentToken, uint256 tokenId, uint256 _years, uint256 _maxStorageAmount) external
```

The function which buys additional storage for the token.

_Anyone can extend storage for any token._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentToken | contract IERC20Metadata | Erc20 token being used to pay for storage. |
| tokenId | uint256 | TNFT identifier. |
| _years | uint256 | Num of years to pay for storage. |
| _maxStorageAmount | uint256 | Max amount to pay for storage. |

### _payStorage

```solidity
function _payStorage(contract ITangibleNFT nft, contract IERC20Metadata paymentToken, uint256 tokenId, uint256 _years, uint256 _maxAmount) internal
```

This internal function updates the storage tracker on the factory and charges the owner for quoted storage.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentToken | contract IERC20Metadata | Erc20 token reference being used as payement for storage. |
| tokenId | uint256 | TNFT identifier. |
| _years | uint256 | Num of years to extend storage for. |
| _maxAmount | uint256 |  |

### buyUnminted

```solidity
function buyUnminted(contract ITangibleNFT nft, contract IERC20 paymentToken, uint256 _fingerprint, uint256 _years, uint256 _maxStorageAmount) external returns (uint256 tokenId)
```

This funcion allows accounts to purchase items for the first time, that
      were not previously minted.

_Since we are dealing with real world assets, tokenizing them before actually selling
     is not an option since those items either sit in a warehouse or are Real estate
     properties. The process is explained in the docs and in the whitepaper._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentToken | contract IERC20 | Erc20 token being used as payment. |
| _fingerprint | uint256 | Fingerprint of token. |
| _years | uint256 | Num of years to store item in advance. |
| _maxStorageAmount | uint256 | Max amount to pay for storage. |

### _itemPrice

```solidity
function _itemPrice(contract ITangibleNFT nft, contract IERC20Metadata paymentUSDToken, uint256 data, bool fromFingerprints) internal view returns (uint256 weSellAt, uint256 weSellAtStock, uint256 tokenizationCost)
```

This function is used to return the price for the `data` item provided.

_Fetches the price through Factory and PriceManager._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| paymentUSDToken | contract IERC20Metadata | Erc20 token being used as payment. |
| data | uint256 | Token identifier, will be a fingerprint or a tokenId. |
| fromFingerprints | bool | If true, `data` will be a fingerprint, othwise it'll be a tokenId. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| weSellAt | uint256 | -> Price of item in oracle, market price. |
| weSellAtStock | uint256 | -> Stock of the item. |
| tokenizationCost | uint256 | -> Tokenization costs for tokenizing asset. Real Estate will never be 0. |

### _buy

```solidity
function _buy(contract ITangibleNFT nft, uint256 tokenId, bool chargeFee, address _paymentToken, uint256 _price) internal
```

This internal function is used to update marketplace state when an account buys a listed TNFT.

_Makes sure that tokens are transferred correctly and that fees are paid._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |
| tokenId | uint256 | TNFT identifier to buy. |
| chargeFee | bool | If true, a fee will be charged from buyer. |
| _paymentToken | address |  |
| _price | uint256 |  |

### setSellFeeAddress

```solidity
function setSellFeeAddress(address _sellFeeAddress) external
```

Sets the sellFeeAddress

_This function is only callable by the Factory contract owner.
Will emit SellFeeAddressSet on change._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _sellFeeAddress | address | A new address for fee storage. |

### setDesignatedBuyer

```solidity
function setDesignatedBuyer(contract ITangibleNFT nft, uint256 tokenId, address designatedBuyer) external
```

This function is used to set the designated buyer on already listed token.

_Only seller or factory can call this function. Factory because of the first purchase.
If designatedBuyer is 0 address, anyone can buy the token._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | Address of the TNFT |
| tokenId | uint256 | TokenId for which you want to set the designatedBuyer |
| designatedBuyer | address | address to set the designated buyer. |

### onERC721Received

```solidity
function onERC721Received(address operator, address seller, uint256 tokenId, bytes data) external returns (bytes4)
```

Needed to receive Erc721 tokens.

_The ERC721 smart contract calls this function on the recipient
     after a `transfer`. This function MAY throw to revert and reject the
     transfer. Return of other than the magic value MUST result in the
     transaction being reverted.
     Note: the contract address is always the message sender._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| operator | address | The address which called `safeTransferFrom` function (not used), but here to support interface. |
| seller | address | Seller EOA address. |
| tokenId | uint256 | Unique token identifier that is being transferred. |
| data | bytes | Additional data with no specified format. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes4 | A bytes4 `selector` is returned to the caller to verify contract is an ERC721Receiver implementer. |

