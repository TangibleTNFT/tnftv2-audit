// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "./interfaces/ISellFeeDistributor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./abstract/FactoryModifiers.sol";
import "./interfaces/IExchange.sol";
import "./interfaces/IUSTB.sol";

/**
 * @title SellFeeDistributorV2
 * @author Veljko Mihailovic
 * @notice This contract collects fees and distributes it to the correct places;
 * @dev All the fees are sent to revenueShare.
 */
contract SellFeeDistributorV2 is ISellFeeDistributor, FactoryModifiers {
    using SafeERC20 for IERC20;

    // ~ State Variables ~

    /// @notice Stores the address for REVENUE_TOKEN stablecoin.
    IERC20 public REVENUE_TOKEN;

    /// @notice Stores the address where the revenue portion of fees are distributed.
    address public revenueShare;

    /// @notice Stores the exchange contract reference.
    IExchange public exchange;

    // ~ Events ~

    /// @notice This event is emitted when fees are distributed.
    event FeeDistributed(address indexed to, address indexed paymentToken, uint256 usdcAmount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ~ Initializer ~

    /**
     * @notice Initializes SellFeeDistributor.
     * @param _factory Address of  Factory contract.
     * @param _revenueShare Address of RevenueShare.
     * @param _revenueToken Address of Revenue token .
     */
    function initialize(
        address _factory,
        address _revenueShare,
        address _revenueToken
    ) external initializer {
        __FactoryModifiers_init(_factory);
        require(_revenueShare != address(0) && _revenueToken != address(0), "ZA 0");
        REVENUE_TOKEN = IERC20(_revenueToken);
        revenueShare = _revenueShare;
    }

    // ~ Functions ~

    /**
     * @notice This method is used for the Factory owner to update the `revenueShare` variable.
     * @param _revenueShare New revenueShare address.
     */
    function setRevenueShare(address _revenueShare) external onlyFactoryOwner {
        require(_revenueShare != address(0) && _revenueShare != revenueShare, "Wrong revenue");
        revenueShare = _revenueShare;
    }

    /**
     * @notice This method is used for the Factory owner to update the `revenueToken` variable.
     * @param _revenueToken New revenue token address.
     */
    function setRevenueToken(address _revenueToken) external onlyFactoryOwner {
        require(
            (_revenueToken != address(0)) && (_revenueToken != address(REVENUE_TOKEN)),
            "Wrong revenue token"
        );
        REVENUE_TOKEN = IERC20(_revenueToken);
    }

    /**
     * @notice This method is used for the Factory owner to update the `exchange` variable.
     * @param _exchange New exchange address.
     */
    function setExchange(address _exchange) external onlyFactoryOwner {
        require(_exchange != address(0), "za");
        exchange = IExchange(_exchange);
    }

    /**
     * @notice This method is used for the Factory owner to withdraw any token from the contract.
     * @param _token Erc20 token to be witdrawn from this contract.
     */
    function withdrawToken(IERC20 _token) external onlyFactoryOwner {
        _token.safeTransfer(msg.sender, _token.balanceOf(address(this)));
    }

    /**
     * @notice This method is used to initiate the distribution of fees.
     * @param _paymentToken Erc20 token to take as payment.
     * @param _feeAmount Amount of `paymentToken` being used for payment.
     */
    function distributeFee(IERC20 _paymentToken, uint256 _feeAmount) external {
        _distributeFee(_paymentToken, _feeAmount);
    }

    /**
     * @dev Function to disable rebasing of tngbl foundation tokens.
     * @param _token The address of the rebasing token.
     * @param _disable True if we want to disable rebase, false if we want to enable it.
     */
    function disableRebaseOfToken(
        address _token,
        bool _disable
    ) external onlyFactoryOwner {
        require(_token != address(0), "Token address cannot be 0");
        IUSTB(_token).disableRebase(address(this), _disable);
    }

    /**
     * @notice This method allocates an amount of tokens to the revenueShare contract.
     * @dev If passed token is not revenue token - swap to revenue token.
     * @param _paymentToken Erc20 token to take as payment.
     * @param _feeAmount Amount of `_paymentToken` being used for payment.
     */
    function _distributeFee(IERC20 _paymentToken, uint256 _feeAmount) internal {
        uint256 balance = _paymentToken.balanceOf(address(this));
        _feeAmount = _feeAmount > balance ? balance : _feeAmount;
        _paymentToken.safeTransfer(revenueShare, _feeAmount);
        emit FeeDistributed(revenueShare, address(_paymentToken), _feeAmount);
    }
}
