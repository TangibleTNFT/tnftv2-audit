// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.21;

import "./abstract/FactoryModifiers.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/IExchange.sol";
import "./interfaces/ITNGBLV3Oracle.sol";
import "../pearl-v2/contracts/interfaces/periphery/ISwapRouter.sol";

/**
 * @title Exchange
 * @author Veljko Mihailovic
 * @notice This contract is used to exchange Erc20 tokens.
 */
contract ExchangeV2 is IExchange, FactoryModifiers {
    using SafeERC20 for IERC20;

    struct SwapRouter {
        address swap;
        uint24 fee;
        uint32 secondsAgo;
    }

    // ~ Constants ~

    // Default seconds ago for the oracle
    uint32 public constant DEFAULT_SECONDS_AGO = 10;

    // ~ State Variables ~

    /// @notice Mapping of concatenated pairs to SwapRouter data used on pair pool, UniV3.
    mapping(bytes => SwapRouter) public routers;

    /// @notice UniV3 oracle.
    ITNGBLV3Oracle public oracle;

    // ~ Events ~

    /**
     * 
     * @param oracle_new New oracle address.
     * @param oracle_old Old oracle address.
     */
    event OracleChanged(address indexed oracle_new, address indexed oracle_old);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ~ Initialize ~

    /**
     * @notice Initializes the Exchange contract
     * @param _factory Address for the  Factory contract.
     */
    function initialize(address _factory, address _oracle) external initializer {
        __FactoryModifiers_init(_factory);
        require(_oracle != address(0), "ZA 0");
        emit OracleChanged(_oracle, address(oracle));
        oracle = ITNGBLV3Oracle(_oracle);
    }

    // ~ External Funcions ~

    /**
     * @notice This function allows the factory owner to add a new pair to exchange.
     * @param tokenInAddress Address of Erc20 token we're exchanging from.
     * @param tokenOutAddress Address of Erc20 token we're exchanging to.
     * @param _swapRouter Address of the swap router.
     * @param _fee Fee used on pair pool, UniV3.
     * @param _secondsAgo Seconds ago for the oracle.
     */
    function addFeesTokens(
        address tokenInAddress,
        address tokenOutAddress,
        address _swapRouter,
        uint24 _fee,
        uint32 _secondsAgo
    ) external onlyFactoryOwner {
        require(tokenInAddress != tokenOutAddress, "same token");
        require(_fee == oracle.POOL_FEE_001() || _fee == oracle.POOL_FEE_005() || _fee == oracle.POOL_FEE_03() || _fee == oracle.POOL_FEE_1(), "invalid fee");
        
        bytes memory tokenized = abi.encodePacked(tokenInAddress, tokenOutAddress);
        bytes memory tokenizedReverse = abi.encodePacked(tokenOutAddress, tokenInAddress);
        // set fees
        SwapRouter memory swapRouter = SwapRouter(
            {
                swap: _swapRouter,
                fee: _fee,
                secondsAgo: _secondsAgo
            }
        );
        routers[tokenized] = swapRouter;
        routers[tokenizedReverse] = swapRouter;
        
    }

    /**
     * @notice This function allows the factory owner change oracle address.
     * @param _oracle Address of the new oracle.
     */
    function setOracle(address _oracle) external onlyFactoryOwner {
        require(_oracle != address(0), "ZA 0");
        emit OracleChanged(_oracle, address(oracle));
        oracle = ITNGBLV3Oracle(_oracle);
    }

    /**
     * @notice This functions updates seconds ago for a pair.
     * @param tokenInAddress token in address
     * @param tokenOutAddress token out address
     * @param _secondsAgo  seconds ago used for the oracle
     */
    function setSecondsAgo(address tokenInAddress, address tokenOutAddress, uint32 _secondsAgo) external onlyFactoryOwner {
        require(tokenInAddress != tokenOutAddress, "same token");
        bytes memory tokenized = abi.encodePacked(tokenInAddress, tokenOutAddress);
        bytes memory tokenizedReverse = abi.encodePacked(tokenOutAddress, tokenInAddress);
        SwapRouter memory swapRouter = routers[tokenized];
        swapRouter.secondsAgo = _secondsAgo;
        routers[tokenized] = swapRouter;
        routers[tokenizedReverse] = swapRouter;
    }

    /**
     * @notice This function exchanges a specified Erc20 token for another Erc20 token.
     * @param tokenIn Address of Erc20 token being token from owner.
     * @param tokenOut Address of Erc20 token being given to the owner.
     * @param amountIn Amount of `tokenIn` to be exchanged.
     * @param minAmountOut The minimum amount expected from `tokenOut`.
     * @return amountOut Amount of returned `tokenOut` tokens.
     */
    function exchange(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external returns (uint256 amountOut) {
        bytes memory tokenized = abi.encodePacked(tokenIn, tokenOut);

        SwapRouter storage swapRouter = routers[tokenized];

        require(swapRouter.swap != address(0), "router 0 ng");
        //take the token
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        //approve the router
        IERC20(tokenIn).approve(swapRouter.swap, amountIn);

        //swap
        amountOut = ISwapRouter(swapRouter.swap).exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: swapRouter.fee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: minAmountOut,
                sqrtPriceLimitX96: 0
            })
        );

    }

    /**
     * @notice This method is used to fetch a quote for an exchange.
     * @param tokenIn Address of Erc20 token being token from owner.
     * @param tokenOut Address of Erc20 token being given to the owner.
     * @param amountIn Amount of `tokenIn` to be exchanged.
     * @return amountOut Amount of `tokenOut` tokens for quote.
     */
    function quoteOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256 amountOut) {
        
        bytes memory tokenized = abi.encodePacked(tokenIn, tokenOut);
        SwapRouter memory swapRouter = routers[tokenized];
        
        require(swapRouter.swap != address(0), "router 0 ng");
        if(swapRouter.secondsAgo == 0) {
            swapRouter.secondsAgo = DEFAULT_SECONDS_AGO;
        }

        amountOut = oracle.consultWithFee(tokenIn, uint128(amountIn), tokenOut, swapRouter.secondsAgo, swapRouter.fee);
    }
}
