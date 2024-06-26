// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "../interfaces/ICurrencyFeedV2.sol";
import "../abstract/FactoryModifiers.sol";

/**
 * @title CurrencyFeedV2
 * @author Veljko Mihailovic
 * @notice This smart contract is used to store ISO codes(Numbers converted to integer eg 001-> 1, for contract simplicity)
 *  for countries/currencies and manages price feed oracles for each currency supported.
 * @dev This contract utilizes the International Organization for Standardization (ISO)'s standard
 *  for representing global currencies and countries.
 *      country codes: https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
 *      currency codes: https://en.wikipedia.org/wiki/ISO_4217
 * It is also providing information that is complementary for the whole ecosystem to provide
 * calculation from various currencies to US$. Stores oracle feeds so if anyone wants
 * oracle for GBP all it need to provide is ISO code like 846.
 * Also, to protect against ratio fluctuation between chain and real world, option
 * for adding a premium on top of the exchange ratio is provided.
 * Few notes:
 *  - Feeds can be any verified oracle feed, from chainlink, dia, redstone etc.
 *  - Premiums must be in decimals that are a match to the corresponding feed.(with same ISO)
 *
 */
contract CurrencyFeedV2 is ICurrencyFeedV2, FactoryModifiers {
    // ~ State Variables ~

    /// @notice This mapping is used to store a price feed oracle for a specific currency ISO alpha code.
    mapping(string => AggregatorV3Interface) public currencyPriceFeeds;

    /// @notice A premium taken by Tangible. It's tacked on top of the existing exchange rate of 2 currencies. This one is stored using the ISO alpha code for the key.
    mapping(string => uint256) public conversionPremiums;

    /// @notice This mapping is used to store a price feed oracle for a specific currency ISO numeric code converted to integer.
    mapping(uint16 => AggregatorV3Interface) public currencyPriceFeedsISONum;

    /// @notice A premium taken by Tangible. It's tacked on top of the existing exchange rate of 2 currencies. This one is stored using the ISO numeric code converted to integer for the key.
    mapping(uint16 => uint256) public conversionPremiumsISONum;

    /// @notice Used to store ISO curency numeric code using it's alpha code as reference.
    /// @dev i.e. ISOCurrencyCodeToNum["AUD"] = 36
    mapping(string => uint16) public ISOcurrencyCodeToNum;

    /// @notice Used to store ISO curency alpha code using it's numeric code as reference.
    /// @dev i.e. ISOcurrencyNumToCode[36] = "AUD"
    mapping(uint16 => string) public ISOcurrencyNumToCode;

    /// @notice Used to store ISO country numeric code using it's alpha code as reference.
    /// @dev i.e. ISOcountryCodeToNum["AUS"] = 36
    mapping(string => uint16) public ISOcountryCodeToNum;

    /// @notice Used to store ISO curency alpha code using it's numeric code as reference.
    /// @dev i.e. ISOcountryNumToCode[36] = "AUS"
    mapping(uint16 => string) public ISOcountryNumToCode;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _factory) external initializer {
        __FactoryModifiers_init(_factory);
    }

    /**
     * @notice This method is used to update the state of `ISOcurrencyCodeToNum` and `ISOcurrencyNumToCode`.
     * @dev Only factory owner can call this method.
     * @param _currency ISO-4217 alpha code. @dev I.e. if currency is Australian dollar, this value would be "AUD".
     * @param _currencyISONum ISO-4217 numeric code converted to integer. @dev I.e. if currency is Australian dollar, this value would be `36`).
     */
    function setISOCurrencyData(
        string memory _currency,
        uint16 _currencyISONum
    ) external onlyFactoryOwner {
        ISOcurrencyCodeToNum[_currency] = _currencyISONum;
        ISOcurrencyNumToCode[_currencyISONum] = _currency;
    }

    /**
     * @notice This method is used to update the state of `ISOcountryCodeToNum` and `ISOcountryNumToCode`.
     * @dev Only factory owner can call this method.
     * @param _country ISO-3166 alpha code. @dev I.e. if country is Australia, this value would be "AUS".
     * @param _countryISONum ISO-3166 numeric code converted to integer. @dev I.e. if country is Australia, this value would be `36`.
     */
    function setISOCountryData(
        string memory _country,
        uint16 _countryISONum
    ) external onlyFactoryOwner {
        ISOcountryCodeToNum[_country] = _countryISONum;
        ISOcountryNumToCode[_countryISONum] = _country;
    }

    /**
     * @notice This method is used to update the state of `currencyPriceFeeds` and `currencyPriceFeedsISONum`.
     * @dev Only factory owner can call this method.
     * @param _currency ISO-4217 alpha code. @dev I.e. if currency is Australian dollar, this value would be "AUD".
     * @param _priceFeed Price feed contract for the specified currency.
     */
    function setCurrencyFeed(
        string calldata _currency,
        AggregatorV3Interface _priceFeed
    ) external onlyFactoryOwner {
        currencyPriceFeeds[_currency] = _priceFeed;
        require(ISOcurrencyCodeToNum[_currency] != 0, "Currency not set");
        // set for iso
        currencyPriceFeedsISONum[ISOcurrencyCodeToNum[_currency]] = _priceFeed;
    }

    /**
     * @notice This method is used to update the state of `conversionPremiums` and `conversionPremiumsISONum`.
     * @dev Only factory owner can call this method.
     * @param _currency ISO-4217 alpha code. @dev I.e. if currency is Australian dollar, this value would be "AUD".
     * @param _conversionPremium A premium taken by Tangible when exchanging 2 currencies. (i.e. gbp/usd rate is 1.34, premium is 0.01)
     */
    function setCurrencyConversionPremium(
        string calldata _currency,
        uint256 _conversionPremium
    ) external onlyFactoryOwner {
        conversionPremiums[_currency] = _conversionPremium;
        require(ISOcurrencyCodeToNum[_currency] != 0, "Curency code 0");
        // set for iso
        conversionPremiumsISONum[ISOcurrencyCodeToNum[_currency]] = _conversionPremium;
    }
}
