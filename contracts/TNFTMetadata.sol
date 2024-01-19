// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "./interfaces/IFactory.sol";

import "./abstract/FactoryModifiers.sol";

/**
 * @title TNFTMetadata
 * @author Veljko Mihailovic
 * @notice This contract is used to manage TangibleNFT metadata.
 * @dev It handles types and features.
 * We can have infinite number of types. But each type is unique and represents item type:
 * - sneakers
 * - cars
 * - houses
 * - gold
 * - wint
 * - etc
 * Based on types, vendors can create a new category - category is instance of type. It is an
 * actual TNFT contract. They are stored in Factory. So:
 * - there can be only type (like real estate, sneakers)
 * - but there can be infinite number of categories (TNFT contracts) for that type
 * - - For example Adidas, Nike, nSport can have each own TNFT contract(category)
 * - - Tangible, Company X etc can have each their own RealEstate TNFT contract(category)
 * Features are used to describe TNFTs. They are stored in this contract. Each feature can belongs to
 * a type(ocean house, luxury, blue). It can also exist acros various types(blue house, blue sneakers).
 * Each feature has it's own id and it's description, and can be used across types.
 *
 * Both features and types must exist here, before they can be assigned to TNFT contract/tokenId
 * Types are assigned to contracts, features are assigned to tokenIds.
 * One unofficial feature that is not handled here, but in Oracles is location - house located
 * in UK, sneakers in Australia etc..
 */
contract TNFTMetadata is FactoryModifiers {
    // ~ State Variables ~

    /**
     * @notice FeatureInfo struct object for storing features metadata.
     * @param description Description of feature
     * @param tnftTypes Tnft Types that exist under this feature or sub-category.
     * @param added If true, feature is supported.
     */
    struct FeatureInfo {
        uint256[] tnftTypes;
        bool added;
        string description;
    }

    /**
     * @notice TNFTType struct object for storing tnft-type metadata.
     * @param added If true, tnftType is supported.
     * @param paysRent If true, TangibleNFT contract for this type receives rent revenue share.
     *                 @dev If true, contract is most likely manages real estate assets and has rent paying tenants.
     * @param description Description of TnftType.
     */
    struct TNFTType {
        bool added;
        bool paysRent;
        string description;
    }

    /// @notice Array of supported Tnft Types.
    uint256[] public tnftTypesArray;

    /// @notice Array of supported features.
    uint256[] public featureList;

    /// @notice Used to store/fetch tnft type metadata.
    mapping(uint256 => TNFTType) public tnftTypes;

    /// @notice Used to store/fetch feature metadata.
    mapping(uint256 => FeatureInfo) public featureInfo;

    /// @notice This mapping stores an array of features for a tnft type as the key.
    /// @dev i.e. RE: beach housem pool || wine bottle size etc, gold if it is coins, tablets etc
    mapping(uint256 => uint256[]) public typeFeatures;

    /// @notice Mapping used to track if a feature is added in type tnftType.
    /// @dev tnftType -> feature -> bool (if added)
    mapping(uint256 => mapping(uint256 => bool)) public featureInType;

    /// @notice Stores the index where a feature(key) resides in featureList.
    mapping(uint256 => uint256) public featureIndexInList;

    // ~ Events ~

    /**
     * @notice This event is emitted when a new Tnft type has been added to `tnftTypesArray`.
     * @param tnftType Tnft type being added.
     * @param description Description of tnft type.
     */
    event TnftTypeAdded(uint256 indexed tnftType, string description);

    /**
     * @notice This event is emitted when a new feature has been added to `featureList`.
     * @param feature feature being added.
     * @param description Description of feature.
     */
    event FeatureAdded(uint256 indexed feature, string description);

    /**
     * @notice This event is emitted when a feature is removed.
     * @param feature feature being removed.
     */
    event FeatureRemoved(uint256 indexed feature);

    /**
     * @notice This event is emitted when a feature's description has been modified.
     * @param feature feature being modified.
     * @param description New description of feature.
     */
    event FeatureModified(uint256 indexed feature, string description);

    /**
     * @notice This event is emitted when a feature is added to `featureInType`.
     * @param tnftType tnft type we're adding features to.
     * @param feature New feature to add.
     */
    event FeatureAddedToTnftType(uint256 indexed tnftType, uint256 indexed feature);

    /**
     * @notice This event is emitted when a feature is removed from `featureInType`.
     * @param tnftType tnft type we're removing features from.
     * @param feature Feature to remove.
     */
    event FeatureRemovedFromTnftType(uint256 tnftType, uint256 indexed feature);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ~ Initializer ~

    /**
     * @notice Used to initialize TNFTMetadata.
     * @param _factory Address of Factory contract.
     */
    function initialize(address _factory) external initializer {
        __FactoryModifiers_init(_factory);
    }

    // ~ Functions ~

    /**
     * @notice This method allows the Factory owner to add new supported features to this contract.
     * @param _featureList Array of new features to add.
     * @param _featureDescriptions Array of corresponding descriptions for each new feature.
     */
    function addFeatures(
        uint256[] calldata _featureList,
        string[] calldata _featureDescriptions
    ) external onlyFactoryOwner {
        uint256 length = _featureList.length;
        require(length == _featureDescriptions.length, "not the same size");
        uint256 featureListLength = featureList.length;
        for (uint256 i; i < length; ) {
            uint256 item = _featureList[i];
            FeatureInfo storage feature = featureInfo[item];
            require(!feature.added, "already added");

            feature.added = true; // added
            feature.description = _featureDescriptions[i]; // set description
            featureList.push(item); // add to featureList

            featureIndexInList[item] = featureListLength + i; // update mapping for removing

            emit FeatureAdded(item, _featureDescriptions[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This method allows the Factory owner to modify existing features' descriptions.
     * @param _featureList Array of features to modify.
     * @param _featureDescriptions Array of corresponding descriptions for each feature.
     */
    function modifyFeature(
        uint256[] calldata _featureList,
        string[] calldata _featureDescriptions
    ) external onlyFactoryOwner {
        uint256 length = _featureList.length;
        require(length == _featureDescriptions.length, "not the same size");

        for (uint256 i; i < length; ) {
            uint256 item = _featureList[i];
            FeatureInfo storage feature = featureInfo[item];
            require(feature.added, "Add first!");

            feature.description = _featureDescriptions[i];
            emit FeatureModified(item, _featureDescriptions[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This method allows the Factory owner to remove features.
     * @param _featureList Array of features to remove.
     */
    function removeFeatures(uint256[] calldata _featureList) external onlyFactoryOwner {
        uint256 length = _featureList.length;
        for (uint256 i; i < length; ) {
            uint256 featureItem = _featureList[i];
            FeatureInfo storage feature = featureInfo[featureItem];
            require(feature.added, "Add first!");

            // removing feature from types
            uint256 indexArrayLength = feature.tnftTypes.length;
            for (uint256 j; j < indexArrayLength; ) {
                uint256 typeItem = feature.tnftTypes[j];
                delete featureInType[typeItem][featureItem];
                // remove from typeFeatures
                uint256 _index = _findElementIntypeFeatures(typeItem, featureItem);
                uint256[] storage typeFeaturesArray = typeFeatures[typeItem];
                require(_index != type(uint256).max, "NFD");
                typeFeaturesArray[_index] = typeFeaturesArray[typeFeaturesArray.length - 1];
                typeFeaturesArray.pop();
                emit FeatureRemovedFromTnftType(typeItem, featureItem);

                unchecked {
                    ++j;
                }
            }

            // remove from array of added
            uint256 index = featureIndexInList[featureItem];
            uint256 arrLength = featureList.length;
            if (arrLength != 1 && index != arrLength - 1) {
                featureList[index] = featureList[arrLength - 1]; // move last to index of removing
                featureIndexInList[featureList[arrLength - 1]] = index;
            }

            featureList.pop(); // pop last element
            delete featureInfo[featureItem]; // delete from featureInfo mapping
            delete featureIndexInList[featureItem]; // delete from featureIndexInList mapping

            emit FeatureRemoved(featureItem);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Helper function to find element in typeFeatures array.
     */
    function _findElementIntypeFeatures(
        uint256 _type,
        uint256 _feature
    ) internal view returns (uint256) {
        uint256[] storage typeFeaturesArray = typeFeatures[_type];
        uint256 length = typeFeaturesArray.length;
        for (uint256 i; i < length; ) {
            if (typeFeaturesArray[i] == _feature) return i;
            unchecked {
                ++i;
            }
        }
        return type(uint256).max;
    }

    /**
     * @notice This method allows the Factory owner to add new Tnft types.
     * @param _tnftType New tnft type.
     * @param _description Description for new tnft type.
     * @param _paysRent If true, TangibleNFT will have a rent manager.
     */
    function addTNFTType(
        uint256 _tnftType,
        string calldata _description,
        bool _paysRent
    ) external onlyFactoryOwner {
        TNFTType storage tnftTypeStored = tnftTypes[_tnftType];
        require(!tnftTypeStored.added, "already exists");

        tnftTypeStored.added = true;
        tnftTypeStored.description = _description;
        tnftTypeStored.paysRent = _paysRent;
        tnftTypesArray.push(_tnftType);

        emit TnftTypeAdded(_tnftType, _description);
    }

    /**
     * @notice This method allows the Factory owner to add a existing features to existing tnft type.
     * @param _tnftType Existing tnft type.
     * @param _features Features to add to tnft type.
     */
    function addFeaturesForTNFTType(
        uint256 _tnftType,
        uint256[] calldata _features
    ) external onlyFactoryOwner {
        require(tnftTypes[_tnftType].added, "tnftType doesn't exist");
        uint256 length = _features.length;
        uint256[] storage typeFeaturesArray = typeFeatures[_tnftType];
        for (uint256 i; i < length; ) {
            uint256 item = _features[i];
            FeatureInfo storage feature = featureInfo[item];
            mapping(uint256 => bool) storage featureInTypeArray = featureInType[_tnftType];
            require(feature.added, "feature doesn't exist");
            require(!featureInTypeArray[item], "already added");

            typeFeaturesArray.push(item);
            feature.tnftTypes.push(_tnftType);
            featureInTypeArray[item] = true;

            emit FeatureAddedToTnftType(_tnftType, item);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This function is used to return the `tnftTypesArray`.
     * @return Array of Tnft types as uint256.
     */
    function getTNFTTypes() external view returns (uint256[] memory) {
        return tnftTypesArray;
    }

    /**
     * @notice Returns information about feature.
     * @param feature Feature we want to return the info for.
     */
    function getFeatureInfo(uint256 feature) external view returns (FeatureInfo memory) {
        return featureInfo[feature];
    }

    /**
     * @notice This function is used to return the `typeFeatures` mapped array.
     * @dev It returns all features that are added to specific type.
     * @param _tnftType The tnft type we want to return the array of features for.
     * @return Array of features.
     */
    function getTNFTTypesFeatures(uint256 _tnftType) external view returns (uint256[] memory) {
        return typeFeatures[_tnftType];
    }

    /**
     * @notice This function is used to return the length of `typeFeatures` array for TNFT Type.
     * @param _tnftType The tnft type we want to return the array of features for.
     * @return Length of array.
     */
    function getTNFTTypesFeaturesLength(uint256 _tnftType) external view returns (uint256) {
        return typeFeatures[_tnftType].length;
    }

    /**
     * @notice This function is used to return the descriptions of features array for TNFT type.
     * @param _tnftType The tnft type we want to return the array of features for.
     * @return Array of features descriptions.
     */
    function getTNFTTypesFeaturesDescriptions(
        uint256 _tnftType
    ) external view returns (string[] memory) {
        uint256 length = typeFeatures[_tnftType].length;
        string[] memory result = new string[](length);

        for (uint256 i; i < length; ) {
            result[i] = featureInfo[typeFeatures[_tnftType][i]].description;
            unchecked {
                ++i;
            }
        }
        return result;
    }

    /**
     * @notice This function is used to return the descriptions of features array for TNFT type.
     * @param _tnftType The tnft type we want to return the array of features for.
     * @return desc Array of features descriptions.
     * @return ids Array of features ids.
     */
    function getTNFTTypesFeaturesDescriptionsAndIds(
        uint256 _tnftType
    ) external view returns (string[] memory desc, uint256[] memory ids) {
        uint256 length = typeFeatures[_tnftType].length;
        uint256[] storage typeFeaturesArray = typeFeatures[_tnftType];
        desc = new string[](length);
        ids = new uint256[](length);

        for (uint256 i; i < length; ) {
            uint256 id = typeFeaturesArray[i];
            desc[i] = featureInfo[id].description;
            ids[i] = id;
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice This function is used to return the `featureList` array.
     * @return Array of all features supported.
     */
    function getFeatureList() external view returns (uint256[] memory) {
        return featureList;
    }

    /**
     * @notice This function is used to return the length of `featureList` array.
     * @return Length of array.
     */
    function getFeatureListLength() external view returns (uint256) {
        return featureList.length;
    }

    /**
     * @notice This function is used to return the descriptions of features array.
     * @return Array of all features descriptions.
     */
    function getFeatureDescriptions() external view returns (string[] memory) {
        uint256 length = featureList.length;
        string[] memory result = new string[](length);

        for (uint256 i; i < length; ) {
            result[i] = featureInfo[featureList[i]].description;
            unchecked {
                ++i;
            }
        }
        return result;
    }

    /**
     * @notice This function is used to return the descriptions of features array.
     * @return desc Array of all features descriptions.
     * @return ids Array of all features ids.
     */
    function getFeatureDescriptionsAndIds()
        external
        view
        returns (string[] memory desc, uint256[] memory ids)
    {
        uint256 length = featureList.length;
        desc = new string[](length);
        ids = new uint256[](length);

        for (uint256 i; i < length; ) {
            uint256 id = featureList[i];
            desc[i] = featureInfo[id].description;
            ids[i] = id;
            unchecked {
                ++i;
            }
        }
    }
}
