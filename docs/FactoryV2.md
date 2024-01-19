# Solidity API

## FactoryV2

Central factory contract for the Tangible protocol. Manages contract ownership and metadata for all
        peripheral contracts in the ecosystem.

_Tangible ecosystem is a protocol in essence. Designed to be used by other vendors who wish
to have the access to real world assets marketplace. The whole ecosystem has couple of sections
between marketplace, TNFTs(which are chain representation of real world assets), oracles and TNFT management.
At the sole center of it all is Factory contract. It's roles are following:
- Deployer: Factory contract is the one that handles deployment of new TNFT categories - gold, real estates.
 Litteraly anything can be brought on chain and tokenized.
 -- As part of deploying new TNFTs, depending on their type(defined in TNFTMetadata contract), the Factory
   can deploy RentManager contract that handles rents for the real estate type.
- OwnerManagement: Fsince factory has it's owner, tangible labs, categoryOwners references, all of these access
management roles are provided by Factory contract and are accessible to other contracts via FactoryModifiers
- Metadata: has reference to TNFTMetadata contract, which is used to store metadata for TNFTs, and handles TNFT types,
 and particular features of each type.
- PriceManager: has reference to PriceManager contract, which is used to fetch prices in USD for each TNFT in the
ecosystem, no matter who deployed it. Oracles(each vendor has their own with interface to follow) register to it, and it is good to go.
- RentManagerDeployer: has reference to RentManagerDeployer contract, which is used to deploy RentManager contracts
for each TNFT type that requires it.
- Acts as a proxy between various contracts in the ecosystem. When someone buys unminted TNFT,
through factory it is minted to the vendor, and then transferred to the marketplace and then yo buyer,
taking care about decrementing the stock, calculating the storage fees if needed etc.
- Is always approved by TNFT contract - to manage first purchases and to allow vendors
to reclaim the assets if the owners are not paying storage for example(seize feature)
- Has reference to the marketplace contract, which is used to sell the TNFTs.
- Has reference to the baskets manager contract, which is used to create baskets of TNFTs. Baskets
ecosystem is a separate ecosystem but it relies on the Factory and it's ownership management.
- Handles approved tokens on the marketplace - which tokens are accepted as payment.
- Handles whitelisting of buyers for unminted TNFTs.
- Handles whitelisting of category minters and how much they can mint.
- Handles whitelisting of fingerprint approvers.
- Vendors have the ability to separate category owner to where the payment will go
on the first purchase
- On first purchase, it's the only one who has the right to mint_

### defUSD

```solidity
contract IERC20 defUSD
```

Default USD contract used for buying unminted tokens and paying for storage when required.

_If payment token in marketplace is not specified, defUSD is used._

### paymentTokens

```solidity
mapping(contract IERC20 => bool) paymentTokens
```

Mapping used to store the ERC20 tokens accepted as payment. If bool is true, token is accepted as payment.

### marketplace

```solidity
address marketplace
```

Address of Marketplace contract.

### tnftDeployer

```solidity
address tnftDeployer
```

Address of TangibleNFTDeployer contract.

### tangibleLabs

```solidity
address tangibleLabs
```

Address of Tangible multisig

### revenueShare

```solidity
address revenueShare
```

Address of TangibleRevenueShare contract

### priceManager

```solidity
contract ITangiblePriceManager priceManager
```

PriceManager contract reference.

### tnftMetadata

```solidity
address tnftMetadata
```

TNFTMetadata contract address.

### rentManagerDeployer

```solidity
address rentManagerDeployer
```

RentManagerDeployer contract address.

### onlyWhitelistedForUnmintedCategory

```solidity
mapping(contract ITangibleNFT => bool) onlyWhitelistedForUnmintedCategory
```

Mapping from TangibleNFT contract to bool. If true, whitelist is required to mint from category of TangibleNFT contract.

### whitelistForBuyUnminted

```solidity
mapping(contract ITangibleNFT => mapping(address => bool)) whitelistForBuyUnminted
```

Mapping to identify EOAs that can purchase tokens required by whitelist.

### categoryMinter

```solidity
mapping(address => bool) categoryMinter
```

Mapping of EOA to bool. If true, EOA can create a new category and provide their own products.

### numCategoriesToMint

```solidity
mapping(address => mapping(uint256 => uint256)) numCategoriesToMint
```

Mapping that defines how many categories(TNFT contracts) approved minter can create and manage for given type.

### fingerprintApprovalManager

```solidity
mapping(contract ITangibleNFT => address) fingerprintApprovalManager
```

Manager of TNFT contract to approve fingerprints for new categories.

_Designed to be a multisig different from vendor to provide a 3rd party verification._

### categoryOwner

```solidity
mapping(contract ITangibleNFT => address) categoryOwner
```

Mapping to map the owner EOA of a specified category for a TNFT contract.

### categoryOwnerPaymentAddress

```solidity
mapping(address => address) categoryOwnerPaymentAddress
```

Mapping to map the payment wallet of category owner.

_Useful for protocols who want to split management and payment for their sales._

### category

```solidity
mapping(string => contract ITangibleNFT) category
```

Maps category name to TNFT contract address.

### categorySymbol

```solidity
mapping(string => contract ITangibleNFT) categorySymbol
```

Maps category symbol to TNFT contract address.

### rentManager

```solidity
mapping(contract ITangibleNFT => contract IRentManager) rentManager
```

Mapping of TNFT contract to RentManager contract.

### daysBeforeSeize

```solidity
mapping(contract ITangibleNFT => uint256) daysBeforeSeize
```

Number of days before the TNFT expires.

_If a user does not pay their storage fees, TNFT will expire and be seized._

### DEFAULT_SEIZE_DAYS

```solidity
uint256 DEFAULT_SEIZE_DAYS
```

The constant expiration date for each TNFT.

### ownedByLabs

```solidity
contract ITangibleNFT[] ownedByLabs
```

Array of TNFTs owned by Tangible.

### basketsManager

```solidity
address basketsManager
```

Baskets manager address

### currencyFeed

```solidity
address currencyFeed
```

Currency feed address

### WhitelistedBuyer

```solidity
event WhitelistedBuyer(address tnft, address buyer, bool approved)
```

This event is emitted when the state of whitelistForBuyUnminted is updated.

_Only used in whitelistBuyer()._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | address | Address of tNft contract. |
| buyer | address | Address that is allowed to mint. |
| approved | bool | Status of allowance to mint. If true, buyer can mint. Otherwise false. |

### WhitelistedCategoryMinter

```solidity
event WhitelistedCategoryMinter(address minter, bool approved, uint256 tnftType, uint16 amount)
```

This event is emitted when there is a new minter of a categorized tNft.

_Only used in whitelistCategoryMinter()._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| minter | address | Address of EOA that will be minting tNft(s). |
| approved | bool | If approved to mint will be true, otherwise false. |
| tnftType | uint256 | which category user is allowed to create. |
| amount | uint16 | Amount of categories minter is allowed to create. |

### MintedTokens

```solidity
event MintedTokens(address tnft, uint256[] tokenIds)
```

This event is emitted when a token or multiple tokens are minted.

_Only emitted when mint() is called._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | address | Address of tNft contract. |
| tokenIds | uint256[] | Array of tokenIds that were minted. |

### PaymentToken

```solidity
event PaymentToken(address token, bool approved)
```

This event is emitted when the state of paymentTokens is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | address | Address of ERC20 token that is accepted as payment. |
| approved | bool | If true, token is accepted as payment otherwise false. |

### WalletChanged

```solidity
event WalletChanged(address owner, address wallet)
```

This event is emitted when the walet for payment is changed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| owner | address | Address owner which want to change his wallet for payments. |
| wallet | address | Address of the wallet to use |

### NewCategoryDeployed

```solidity
event NewCategoryDeployed(address tnft, address minter)
```

This event is emitted when a new category of tNFTs is created and deployed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | address | Address of tNft contract that is created. |
| minter | address | Address of deployer EOA or multisig. |

### CategoryOwner

```solidity
event CategoryOwner(address tnft, address owner)
```

This event is emitted when a category owner is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | address | TangibleNFT contract address. |
| owner | address | Category owner address. |

### ContractUpdated

```solidity
event ContractUpdated(uint256 contractType, address oldAddress, address newAddress)
```

This event is emitted when there is a peripherial contract address from FACT_ADDRESSES type that is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| contractType | uint256 | Enum corresponding with FACT_ADDRESSES type. |
| oldAddress | address | Old contract address. |
| newAddress | address | New contract address. |

### onlyCategoryOwner

```solidity
modifier onlyCategoryOwner(contract ITangibleNFT nft)
```

Modifier used to verify the function caller is the category owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| nft | contract ITangibleNFT | TangibleNFT contract reference. |

### onlyCategoryMinter

```solidity
modifier onlyCategoryMinter()
```

Modifier used to verify the function caller is a category minter.

### onlyMarketplace

```solidity
modifier onlyMarketplace()
```

Modifier used to verify that the function caller is the Marketplace contract.

### onlyLabsOrMarketplace

```solidity
modifier onlyLabsOrMarketplace()
```

Modifier used to verify function caller is the marketplace or Tangible multisig.

### FACT_ADDRESSES

Enum object to identify a custom contract data type via an enumerable.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
enum FACT_ADDRESSES {
  MARKETPLACE,
  TNFT_DEPLOYER,
  RENT_MANAGER_DEPLOYER,
  LABS,
  PRICE_MANAGER,
  TNFT_META,
  REVENUE_SHARE,
  BASKETS_MANAGER,
  CURRENCY_FEED
}
```

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _defaultUSDToken, address _tangibleLabs) external
```

Initialize FactoryV2 contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _defaultUSDToken | address | Address of the default USD Erc20 token accepted for payments. |
| _tangibleLabs | address | Tangible multisig address. |

### setDefaultStableUSD

```solidity
function setDefaultStableUSD(contract IERC20 usd) external
```

This onlyOwner function is used to update the defUSD state var.

_Only settable after the token is acceptedd as payment token.
Only callable by the owner._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| usd | contract IERC20 | Erc20 contract to set as new defUSD. |

### configurePaymentToken

```solidity
function configurePaymentToken(contract IERC20 token, bool value) external
```

This function is used to add a new payment token.

_Only callable by the owner._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract IERC20 | Erc20 token to accept as payment method. |
| value | bool | If true, token is accepted, otherwise false. |

### configurePaymentWallet

```solidity
function configurePaymentWallet(address wallet) external
```

This function is used to change wallet address, where payments will go.

_Used by the category owners to change their payment wallet._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | address to where payment will go for msg.sender. |

### setContract

```solidity
function setContract(enum FactoryV2.FACT_ADDRESSES _contractId, address _contractAddress) external
```

This onlyOwner function is used to set a contract address to a FACT_ADDRESSES contract type.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _contractId | enum FactoryV2.FACT_ADDRESSES | Enumerable of custom FACT_ADDRESSES type. |
| _contractAddress | address | Contract address to set. |

### _setContract

```solidity
function _setContract(enum FactoryV2.FACT_ADDRESSES _contractId, address _contractAddress) internal
```

This internal function is used to set a contract address to it's corresponding state var.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _contractId | enum FactoryV2.FACT_ADDRESSES | Enumerable of type FACT_ADDRESSES. Used to identify which state var the _contractAddress is for. |
| _contractAddress | address | Address of smart contract. |

### getCategories

```solidity
function getCategories() external view returns (contract ITangibleNFT[])
```

This view function is used to return the array of TNFT contract addresses supported by the Factory.

_Usefull to know all deployed TNFTs in the protocol_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | contract ITangibleNFT[] | Array returned of type ITangibleNFT. |

### getTangibleLabsCategories

```solidity
function getTangibleLabsCategories() external view returns (contract ITangibleNFT[])
```

This view function is used to return the array of TNFT contract addresses owned by Tangible.

_Usefull to know all the TNFTs owned and deployed by Tangible._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | contract ITangibleNFT[] | Array returned of type ITangibleNFT. |

### categoryOwnerWallet

```solidity
function categoryOwnerWallet(contract ITangibleNFT nft) external view returns (address wallet)
```

This view function is used to return payment wallet that should be used for buyUnminted and storage payments,
 for specific category.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | address to be used as payment. |

### _categoryOwnerWallet

```solidity
function _categoryOwnerWallet(contract ITangibleNFT nft) internal view returns (address wallet)
```

This internal view function is used to return payment wallet that should be used for
         buyUnminted and storage payments.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| wallet | address | address to be used as payment. |

### paysRent

```solidity
function paysRent(contract ITangibleNFT tnft) external view returns (bool)
```

This view function is used to see which TNFT contract needs to pay rent.

_Useful to get the information if the TNFT contract needs to pay rent._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | contract. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | If true, tnft holders receive rent share. Note: Tenants of Real Estate pay rent. |

### _paysRent

```solidity
function _paysRent(contract ITangibleNFT tnft) internal view returns (bool)
```

This function returns whether the `tnft` contract specified has a rent manager.

_If there exists a rent manager, the `tnft` holders receive rent share since tenants pay rent for Real Estate NFTs._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract reference. |

### adjustStorageAndGetAmount

```solidity
function adjustStorageAndGetAmount(contract ITangibleNFT tnft, contract IERC20Metadata paymentToken, uint256 tokenId, uint256 _years) external returns (uint256)
```

This function allows for a token holder to get a quote for storage costs and updates storage metadata.

_Only callable by Marketplace contract. Factory is a proxy in this case, since
     it has access to the information about the storage costs and can adjust the storage of
     TNFT tokenId_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract. |
| paymentToken | contract IERC20Metadata | Erc20 token being accepted as payment. |
| tokenId | uint256 | Token identifier. |
| _years | uint256 | Amount of years to extend expiration && quote for storage costs. |

### setFingerprintApprovalManager

```solidity
function setFingerprintApprovalManager(contract ITangibleNFT tnft, address _manager) external
```

This function allows the owner to set an approval manager EOA to the fingerprintApprovalManager mapping.

_Used to make sure that 3rd party approves new items that vendor want to add to their
     category._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract. |
| _manager | address | Manager EOA address. |

### _setFingerprintApprovalManager

```solidity
function _setFingerprintApprovalManager(contract ITangibleNFT tnft, address _manager) internal
```

Internal function that updates state of fingerprintApprovalManager.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract. |
| _manager | address | Manager EOA address. |

### mint

```solidity
function mint(struct IVoucher.MintVoucher voucher) external returns (uint256[])
```

This function mints the TangibleNFT token from the given MintVoucher.

_Voucher is received and token(s) is minted to vendor (category owner)
     for proof of ownership then transferred to the marketplace so that it can be sold.
     Tokens are minted only on purchase.
     Only tangibleLabs can mint tokens to sell and then put them on sale separatelly.
     otherwise all "orders" come from marketplace.
     RealEstate TNFTs can be purchased only by whitelisted buyers._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| voucher | struct IVoucher.MintVoucher | A mintVoucher is an unminted tNFT. |

### newCategory

```solidity
function newCategory(string name, string symbol, string uri, bool isStoragePriceFixedAmount, bool storageRequired, address priceOracle, bool symbolInUri, uint256 _tnftType) external returns (contract ITangibleNFT)
```

This function allows a category minter to create a new category of Tangible NFTs.

_Only callable by a category minter. Minter is previously approved by the owner and
   has a limit on which categories it can create, and how many. Tangible is not part of those
   limits._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name | string | Name of new TangibleNFT // category. |
| symbol | string | Symbol of new TangibleNFT. |
| uri | string | Base uri for NFT Metadata querying. |
| isStoragePriceFixedAmount | bool | If true, the storage fee is a fixed price. |
| storageRequired | bool | If true, storage is required for this token. Thus, owner has to pay a storage fee. |
| priceOracle | address | Address of price oracle to manage purchase price of tokens. |
| symbolInUri | bool | Will append this symbol to the uri when querying TangibleNFT::tokenURI(). |
| _tnftType | uint256 | TangibleNFT Type. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | contract ITangibleNFT | TangibleNFT contract reference |

### updateOracleForTnft

```solidity
function updateOracleForTnft(string name, address priceOracle) external
```

This function allows a category owner to update the oracle for a category.

_Only callable by the category owner. Every vendor is free to implement their own
oracle for category, it just has to comply with our interface defined IPriceOracle._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name | string | Category. |
| priceOracle | address | Address of PriceOracle contract. |

### whitelistBuyer

```solidity
function whitelistBuyer(contract ITangibleNFT tnft, address buyer, bool approved) external
```

This function allows for a category owner to assign a whitelisted buyer for specific TNFT category.

_Only callable by the category owner. If category requires whitelisting, it is responsibility
of the category owner to whitelist buyers for his own categories._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract that the `buyer` is/isnt whitelisted from. |
| buyer | address | Address of whitelisted minter. |
| approved | bool | Status of whitelist. If true, `buyer` is whitelisted, otherwise false. |

### whitelistCategoryMinter

```solidity
function whitelistCategoryMinter(address minter, bool approved, uint16 amount, uint256 _tnftType) external
```

This function allows for the contract owner to whitelist a minter of a certain category.

_It also specifies how many categories minter is allowed to create._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| minter | address | Address to whitelist. |
| approved | bool | Status of whitelist. If true, able to mint. Otherwise false. |
| amount | uint16 | Amount of tokens the `minter` is allowed to mint. |
| _tnftType | uint256 | categories minter is allowed to create. |

### setRequireWhitelistCategory

```solidity
function setRequireWhitelistCategory(contract ITangibleNFT tnft, bool required) external
```

This function allows a category owner to assign a whitelist status to a category.

_If this is set, buyers must be whitelisted to purchase items the first time._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract. |
| required | bool | Bool of whether or not whitelist is required to mint from the category. |

### setCategoryStorageExpire

```solidity
function setCategoryStorageExpire(contract ITangibleNFT tnft, uint256 numDays) external
```

This function allows the category owner to set number of days before it can
     seize the item, whose storage had expired.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract. |
| numDays | uint256 | amount of days before storage expires. |

### seizeTnft

```solidity
function seizeTnft(contract ITangibleNFT tnft, uint256[] tokenIds) external
```

This function allows a category owner to seize NFTs that whose storage has expired.

_2 types of seizing: one where storage is required and one where the tnft pays rent.
    If storage has expired, owner can seize after daysBeforeSeize or DEFAULT_SEIZE_DAYS.
    If tnft pays rent, owner can seize if the token is blacklisted.
To prevent this, owner can pay storage._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tnft | contract ITangibleNFT | TangibleNFT contract. |
| tokenIds | uint256[] | Array of tokenIds to seize. |

### isOwner

```solidity
function isOwner(address account) internal view returns (bool)
```

This view function is used to return whether or not a specified address is the contract owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | EOA to check owner status. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | If true, account is the contract owner otherwise will be false. |

### isMarketplace

```solidity
function isMarketplace(address account) internal view returns (bool)
```

This view function is used to return whether or not a specified address is the Marketplace contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | address to query marketplace status. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | If true, account is the address of the Marketplace contract. |

### _checkCategoryOwner

```solidity
function _checkCategoryOwner(contract ITangibleNFT nft) internal view
```

This internal method is used to check if msg.sender is a category owner.

_Only called by modifier `onlyCategoryOwner`. Meant to reduce bytecode size_

