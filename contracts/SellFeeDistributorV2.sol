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

    // ~ State Variables -> packed: (165 bytes -> 8 slots) ~

    /// @notice Stores The percentage of fees to allocate for revenue.
    uint256 public revenuePercent;

    /// @notice Stores The full portion of fees with 9 basis points.
    uint256 private constant FULL_PORTION = 100_000000000;

    /// @notice Stores the address for REVENUE_TOKEN stablecoin.
    IERC20 public REVENUE_TOKEN;

    /// @notice Stores the address of the native RWA_TOKEN Erc20 token.
    IERC20 public RWA_TOKEN;

    /// @notice Stores the address where the revenue portion of fees are distributed.
    address public revenueShare;

    /// @notice Stores the exchange contract reference.
    IExchange public exchange;

    /// @notice If the contract is deployed to mainnet, will be true.
    bool public isMainnet;

    // ~ Events ~

    /// @notice This event is emitted when fees are distributed.
    event FeeDistributed(address indexed to, uint256 usdcAmount);

    /// @notice This event is emitted when RWA_TOKEN tokens are burned.
    event TangibleBurned(uint256 burnedTngbl);

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
     * @param _rwaToken Address of RWA token.
     * @param _isMainnet If deploying to mainnet will be true.
     */
    function initialize(
        address _factory,
        address _revenueShare,
        address _revenueToken,
        address _rwaToken,
        bool _isMainnet
    ) external initializer {
        __FactoryModifiers_init(_factory);
        require(_revenueShare != address(0) && _revenueToken != address(0) && _rwaToken != address(0), "ZA 0");
        REVENUE_TOKEN = IERC20(_revenueToken);
        RWA_TOKEN = IERC20(_rwaToken);
        revenueShare = _revenueShare;
        revenuePercent = 66_666666666;
        isMainnet = _isMainnet;
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
        require((_revenueToken != address(0)) && (_revenueToken != address(REVENUE_TOKEN)), "Wrong revenue token");
        REVENUE_TOKEN = IERC20(_revenueToken);
    }

    /**
     * @notice This method is used for the Factory owner to update the `rwaToken` variable.
     * @param _rwaToken New rwa token address.
     */
    function setRWAToken(address _rwaToken) external onlyFactoryOwner {
        require((_rwaToken != address(0)) && (_rwaToken != address(RWA_TOKEN)), "Wrong rwa token");
        RWA_TOKEN = IERC20(_rwaToken);
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
     * @notice This method is used for the Factory owner to update the `revenuePercent` variable.
     * @dev If `_revenuePercent` is less than `FULL_PORTION`, the rest will be burned
     * @param _revenuePercent New percentage for revenue portion.
     */
    function setRevPercentage(uint256 _revenuePercent) external onlyFactoryOwner {
        require(_revenuePercent <= FULL_PORTION, "Wrong percentages");
        revenuePercent = _revenuePercent;
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
     * @dev This method will exchange a `revenuePercent` of `_feeAmount` for REVENUE_TOKEN and transfer that REVENUE_TOKEN
     *      to the `revenueShare` contract. The rest will be exchanged for RWA_TOKEN tokens and burned.
     */
    function _distributeFee(IERC20 _paymentToken, uint256 _feeAmount) internal {
        //take 66.6666% and send to revenueShare
        uint256 amountForRevenue = (_feeAmount * revenuePercent) / FULL_PORTION;
        uint256 amountForBurn = _feeAmount - amountForRevenue;
        if (address(_paymentToken) != address(REVENUE_TOKEN)) {
            //we need to convert the payment token to usdc
            _paymentToken.approve(address(exchange), amountForRevenue);
            amountForRevenue = exchange.exchange(
                address(_paymentToken),
                address(REVENUE_TOKEN),
                amountForRevenue,
                exchange.quoteOut(address(_paymentToken), address(REVENUE_TOKEN), amountForRevenue)
            );
        }
        REVENUE_TOKEN.safeTransfer(revenueShare, amountForRevenue);
        emit FeeDistributed(revenueShare, amountForRevenue);

        //convert 33.334% to tngbl and burn it
        // exchange usdc for tngbl
        _paymentToken.approve(address(exchange), amountForBurn);
        uint256 tngblToBurn = exchange.exchange(
            address(_paymentToken),
            address(RWA_TOKEN),
            amountForBurn,
            exchange.quoteOut(address(_paymentToken), address(RWA_TOKEN), amountForBurn)
        );

        if (isMainnet) {
            //burn the tngbl
            RWA_TOKEN.approve(address(this), tngblToBurn);
            ERC20Burnable(address(RWA_TOKEN)).burn(tngblToBurn);

            emit TangibleBurned(tngblToBurn);
        } else {
            //send to dead address
            RWA_TOKEN.safeTransfer(0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD, tngblToBurn);
            emit TangibleBurned(tngblToBurn);
        }
    }
}
