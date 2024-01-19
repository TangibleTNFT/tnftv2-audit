// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface ERC20Mintable {
    function mint(address _to, uint256 _amount) external;

    function burn(uint256 _amount) external;
}

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

interface ITNGBLV3Oracle {
    function consultWithFee(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32 secondsAgo,
        uint24 fee
    ) external view returns (uint256);

    function POOL_FEE_001() external view returns (uint24);

    function POOL_FEE_005() external view returns (uint24);

    function POOL_FEE_03() external view returns (uint24);

    function POOL_FEE_1() external view returns (uint24);

    function POOL_FEE_01() external view returns (uint24);
}

contract MockRouter is ISwapRouter, ITNGBLV3Oracle {
    // 100% pool fee
    uint24 public constant POOL_FEE_100 = 100_0000;
    // 0.3% pool fee
    uint24 public constant POOL_FEE_03 = 3000;
    // 0.01% pool fee
    uint24 public constant POOL_FEE_001 = 100;
    // 0.01% pool fee
    uint24 public constant POOL_FEE_00001 = 1;
    // 1% pool fee
    uint24 public constant POOL_FEE_1 = 1_0000;
    // 0.05% pool fee
    uint24 public constant POOL_FEE_005 = 500;
    // Default seconds ago for the oracle
    uint32 public constant DEFAULT_SECONDS_AGO = 300;
    // 0.1% pool fee
    uint24 public constant POOL_FEE_01 = 1000;

    function toDecimals(
        uint256 amount,
        uint8 fromDecimal,
        uint8 toDecimal
    ) internal pure returns (uint256) {
        require(toDecimal >= uint8(0) && toDecimal <= uint8(18), "Invalid _decimals");
        if (fromDecimal > toDecimal) {
            amount = amount / (10 ** (fromDecimal - toDecimal));
        } else if (fromDecimal < toDecimal) {
            amount = amount * (10 ** (toDecimal - fromDecimal));
        }
        return amount;
    }

    function consultWithFee(
        address tokenIn,
        uint128 amountIn,
        address tokenOut,
        uint32, //secondsAgo,
        uint24 //fee
    ) external view returns (uint256 amountOut) {
        // Mock implementation, return amountIn in tokenOut decimals
        uint8 tokenOutDecimals = IERC20Metadata(tokenOut).decimals();
        uint8 tokenInDecimals = IERC20Metadata(tokenIn).decimals();
        return toDecimals(amountIn, tokenInDecimals, tokenOutDecimals);
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut) {
        // Mock implementation, mint tokenOut and transfer it to 'to' address
        uint8 tokenInDecimals = IERC20Metadata(params.tokenIn).decimals();
        uint8 tokenOutDecimals = IERC20Metadata(params.tokenOut).decimals();
        amountOut = toDecimals(params.amountIn, tokenInDecimals, tokenOutDecimals);

        IERC20(params.tokenIn).transferFrom(msg.sender, address(this), params.amountIn);
        ERC20Mintable(params.tokenIn).burn(params.amountIn);
        ERC20Mintable(params.tokenOut).mint(params.recipient, amountOut);
    }
}
