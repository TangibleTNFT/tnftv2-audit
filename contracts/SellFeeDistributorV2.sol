// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.21;

import "./interfaces/ISellFeeDistributor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./abstract/FactoryModifiers.sol";
import "./interfaces/IExchange.sol";

/**
 * @title SellFeeDistributor
 * @author Veljko Mihailovic
 * @notice This contract collects fees and distributes it to the correct places; Burn or revenuShare. Fees are accrued here and taken from Marketplace transactions.
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
    event FeeDistributed(address indexed to, uint256 usdcAmount);

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
        require(
            _revenueShare != address(0) && _revenueToken != address(0),
            "ZA 0"
        );
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
     * @notice This method is used for the Factory owner to withdraw REVENUE_TOKEN from the contract.
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
     * @notice This method allocates an amount of tokens to the revenueShare contract and burns the rest.
     * @param _paymentToken Erc20 token to take as payment.
     * @param _feeAmount Amount of `_paymentToken` being used for payment.
     * @dev This method will exchange `_feeAmount` for REVENUE_TOKEN(if needed) and transfer that REVENUE_TOKEN
     *      to the `revenueShare` contract.
     */
    function _distributeFee(IERC20 _paymentToken, uint256 _feeAmount) internal {
        // exchange payment token for REVENUE_TOKEN
        if (address(_paymentToken) != address(REVENUE_TOKEN)) {
            //we need to convert the payment token to REVENUE_TOKEN
            _paymentToken.approve(address(exchange), _feeAmount);
            _feeAmount = exchange.exchange(
                address(_paymentToken),
                address(REVENUE_TOKEN),
                _feeAmount,
                exchange.quoteOut(address(_paymentToken), address(REVENUE_TOKEN), _feeAmount)
            );
        }
        //take everything and send to revenueShare
        REVENUE_TOKEN.safeTransfer(revenueShare, _feeAmount);
        emit FeeDistributed(revenueShare, _feeAmount);

    }
}
