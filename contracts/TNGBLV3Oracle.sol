// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import "@openzeppelin/contracts-v0.7/access/Ownable.sol";

/**
 * @title TNGBLV3Oracle
 * @author Veljko Mihailovic
 * @notice Oracle reader contract, adjusted for TNGBL protocol. Uses the same logic as Uniswap V3 oracle example.
 * @dev Logic is abstracted for our purposes and to fit our ecosystem.
 */
contract TNGBLV3Oracle is Ownable {
    // ~ Constants ~

    // 100% pool fee, used for calculating amountIn for given pool fee
    uint24 public constant POOL_FEE_100 = 100e4;
    // 0.3% pool fee
    uint24 public constant POOL_FEE_03 = 0.3e4;
    // 0.01% pool fee
    uint24 public constant POOL_FEE_001 = 0.01e4;
    // 0.0001% pool fee used for rounding errors
    uint24 public constant POOL_FEE_00001 = 0.0001e4;
    // 1% pool fee
    uint24 public constant POOL_FEE_1 = 1e4;
    // 0.05% pool fee
    uint24 public constant POOL_FEE_005 = 0.05e4;
    // Default seconds ago for the oracle
    uint32 public constant DEFAULT_SECONDS_AGO = 300;
    // ~ State Variables ~

    // @dev Uniswap v3 factory address.
    address public uniV3Factory;

    // 0.1% pool fee
    uint24 public constant POOL_FEE_01 = 0.1e4;
    // ~ Events ~

    /// @dev This event is emitted when the uniswap v3 factory is changed.
    event UniFactoryChanged(address indexed uniV3Factory_new, address indexed uniV3Factory_old);

    constructor(address _uniV3Factory) Ownable() {
        require(_uniV3Factory != address(0), "ZA 0");
        emit UniFactoryChanged(_uniV3Factory, uniV3Factory);
        uniV3Factory = _uniV3Factory;
    }

    /**
     * @dev Sets new uniswap v3 factory
     * @param _uniV3Factory Address of new uniswap v3 factory.
     */
    function setUniV3Factory(address _uniV3Factory) external onlyOwner {
        require(_uniV3Factory != address(0), "ZA 0");
        emit UniFactoryChanged(_uniV3Factory, uniV3Factory);
        uniV3Factory = _uniV3Factory;
    }

    /**
     * @dev Returns amountOut for given amountIn. Fee is set to 0.3%.
     * @param tokenIn Address of tokenIn.
     * @param amountIn Amount of tokenIn.
     * @param tokenOut Address of tokenOut.
     * @param secondsAgo Seconds ago tells how much in the past to look.
     */
    function consult03(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo
    ) external view returns (uint256 amountOut) {
        amountOut = _consultWithFee(tokenIn, amountIn, tokenOut, secondsAgo, POOL_FEE_03);
    }

    /**
     * @dev Returns amountOut for given amountIn. Fee is set to 0.01%.
     * @param tokenIn Address of tokenIn.
     * @param amountIn Amount of tokenIn.
     * @param tokenOut Address of tokenOut.
     * @param secondsAgo Seconds ago tells how much in the past to look.
     */
    function consult001(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo
    ) external view returns (uint256 amountOut) {
        amountOut = _consultWithFee(tokenIn, amountIn, tokenOut, secondsAgo, POOL_FEE_001);
    }

    /**
     * @dev Returns amountOut for given amountIn. Fee is set to 0.05%.
     * @param tokenIn Address of tokenIn.
     * @param amountIn Amount of tokenIn.
     * @param tokenOut Address of tokenOut.
     * @param secondsAgo Seconds ago tells how much in the past to look.
     */
    function consult005(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo
    ) external view returns (uint256 amountOut) {
        amountOut = _consultWithFee(tokenIn, amountIn, tokenOut, secondsAgo, POOL_FEE_005);
    }

    /**
     * @dev Returns amountOut for given amountIn. Fee is set to 1%.
     * @param tokenIn Address of tokenIn.
     * @param amountIn Amount of tokenIn.
     * @param tokenOut Address of tokenOut.
     * @param secondsAgo Seconds ago tells how much in the past to look.
     */
    function consult1(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo
    ) external view returns (uint256 amountOut) {
        amountOut = _consultWithFee(tokenIn, amountIn, tokenOut, secondsAgo, POOL_FEE_1);
    }

    /**
     * @dev Returns amountOut for given amountIn. Accepts custom fee parameter
     * @param tokenIn Address of tokenIn.
     * @param amountIn Amount of tokenIn.
     * @param tokenOut Address of tokenOut.
     * @param secondsAgo Seconds ago tells how much in the past to look.
     * @param fee Pool fee.
     */
    function consultWithFee(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo,
        uint24 fee
    ) external view returns (uint256 amountOut) {
        amountOut = _consultWithFee(tokenIn, amountIn, tokenOut, secondsAgo, fee);
    }

    function _consultWithFee(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo,
        uint24 fee
    ) internal view returns (uint256 amountOut) {
        address _pool = _fetchPool(tokenIn, tokenOut, fee);
        require(_pool != address(0), "pool doesn't exist");

        amountOut = _estimateAmountOut(tokenIn, tokenOut, _pool, amountIn, secondsAgo);
    }

    // ~ Internal Functions ~

    /**
     * @dev Fetches pool address for given tokenIn, tokenOut and fee.
     * @param tokenIn Address of tokenIn.
     * @param tokenOut Address of tokenOut.
     * @param fee Pool fee.
     */
    function _fetchPool(
        address tokenIn,
        address tokenOut,
        uint24 fee
    ) internal view returns (address pool) {
        pool = IUniswapV3Factory(uniV3Factory).getPool(tokenIn, tokenOut, fee);
    }

    /**
     * @dev Estimates amountOut for given amountIn. Taken example from OracleLibrary.sol.
     * @param tokenIn Address of tokenIn.
     * @param tokenOut Address of tokenOut.
     * @param pool Address of pool.
     * @param amountIn Amount of tokenIn.
     * @param secondsAgo Seconds ago tells how much in the past to look.
     */
    function _estimateAmountOut(
        address tokenIn,
        address tokenOut,
        address pool,
        uint128 amountIn,
        uint32 secondsAgo
    ) internal view returns (uint256 amountOut) {
        // Code copied from OracleLibrary.sol, consult()
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        // int56 since tick * time = int24 * uint32
        // 56 = 24 + 32
        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        // int56 / uint32 = int24
        int24 tick = int24(tickCumulativesDelta / int56(int32(secondsAgo)));
        // Always round to negative infinity
        /*
        int doesn't round down when it is negative
        int56 a = -3
        -3 / 10 = -3.3333... so round down to -4
        but we get
        a / 10 = -3
        so if tickCumulativeDelta < 0 and division has remainder, then round
        down
        */
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int56(int32(secondsAgo)) != 0)) {
            tick--;
        }

        amountOut = OracleLibrary.getQuoteAtTick(tick, amountIn, tokenIn, tokenOut);
    }
}
