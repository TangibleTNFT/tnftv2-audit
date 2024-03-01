// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "./interfaces/IFactory.sol";
import "./interfaces/ITangibleMarketplace.sol";
import "./interfaces/IMarketplace.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TangibleReaderHelperV2
 * @author Veljko Mihailovic
 * @notice This contract allows for batch reads to several Tangible contracts for various purposes.
 */
contract TangibleReaderHelperV2 {
    // ~ State Variables ~

    /// @notice Stores a reference to the Factory contract.
    IFactory public immutable factory;

    // ~ Constructor ~

    /**
     * @notice Initializes TangibleReaderHelper
     * @param _factory Factory contract reference.
     */
    constructor(IFactory _factory) {
        require(
            address(_factory) != address(0),
            "ZA 0"
        );
        factory = _factory;
    }

    // ~ Functions ~

    /**
     * @notice This function takes an array of `tokenIds` and fetches the array of owners.
     * @param tokenIds Array of tokenIds to query owners of.
     * @param contractAddress NFT contract we wish to query token ownership of.
     * @return owners -> Array of owners. Indexes correspond with the indexes of tokenIds.
     */
    function ownersOBatch(
        uint256[] calldata tokenIds,
        address contractAddress
    ) external view returns (address[] memory owners) {
        uint256 length = tokenIds.length;
        owners = new address[](length);

        for (uint256 i; i < length; ) {
            owners[i] = IERC721(contractAddress).ownerOf(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This function takes an array of `tokenIds` and fetches the corresponding fingerprints.
     * @param tokenIds Array of tokenIds to query fingerprints for.
     * @param tnft TangibleNFT contract address.
     * @return fingerprints -> Array of fingerprints. Indexes correspond with the indexes of tokenIds.
     */
    function tokensFingerprintBatch(
        uint256[] calldata tokenIds,
        ITangibleNFT tnft
    ) external view returns (uint256[] memory fingerprints) {
        uint256 length = tokenIds.length;
        fingerprints = new uint256[](length);

        for (uint256 i; i < length; ) {
            fingerprints[i] = tnft.tokensFingerprint(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This function takes an array of `tokenIds` and fetches the corresponding storage expiration date.
     * @param tokenIds Array of tokenIds to query expiration for.
     * @param tnft TangibleNFT contract address.
     * @return endTimes -> Array of timestamps of when each tokenIds storage expires.
     */
    function tnftsStorageEndTime(
        uint256[] calldata tokenIds,
        ITangibleNFT tnft
    ) external view returns (uint256[] memory endTimes) {
        uint256 length = tokenIds.length;
        endTimes = new uint256[](length);

        for (uint256 i; i < length; ) {
            endTimes[i] = tnft.storageEndTime(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This method returns an array of tokenIds given the indexes.
     * @param indexes Array of indexes.
     * @param enumrableContract Enumerable erc721 contract address.
     * @return tokenIds -> Array of tokenIds.
     */
    function tokenByIndexBatch(
        uint256[] calldata indexes,
        address enumrableContract
    ) external view returns (uint256[] memory tokenIds) {
        uint256 length = indexes.length;
        tokenIds = new uint256[](length);

        for (uint256 i; i < length; ) {
            tokenIds[i] = IERC721Enumerable(enumrableContract).tokenByIndex(indexes[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This method is used to fetch a batch of Lot metadata objects for each `tokenId` provided.
     * @param nft TangibleNFT contract address.
     * @param tokenIds Array of tokenIds.
     * @return result Array of Lot metadata.
     */
    function lotBatch(
        address nft,
        uint256[] calldata tokenIds
    ) external view returns (ITangibleMarketplaceExt.Lot[] memory result) {
        uint256 length = tokenIds.length;

        result = new ITangibleMarketplaceExt.Lot[](length);

        ITangibleMarketplaceExt marketplace = ITangibleMarketplaceExt(
            IFactory(factory).marketplace()
        );

        for (uint256 i; i < length; ) {
            result[i] = marketplace.marketplaceLot(nft, tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }
}
