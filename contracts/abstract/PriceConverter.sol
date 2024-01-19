// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title PriceConverter
 * @author Veljko Mihailovic
 * @notice Usable by other contracts to have a unanimous way
 * to convert between decimals.
 */
abstract contract PriceConverter {
    /**
     * @notice This internal method is used to convert between decimals.
     * @param amount Amount of token to convert.
     * @param fromDecimal From which decimal (decimals of amount).
     * @param toDecimal To which decimal amount is converted.
     */
    function toDecimals(
        uint256 amount,
        uint8 fromDecimal,
        uint8 toDecimal
    ) internal pure returns (uint256) {
        require(toDecimal <= 18, "Invalid _decimals");
        uint256 diff;
        if (fromDecimal > toDecimal) {
            unchecked {
                diff = fromDecimal - toDecimal;
            }
            amount = amount / (10 ** diff);
        } else if (fromDecimal < toDecimal) {
            unchecked {
                diff = toDecimal - fromDecimal;
            }
            amount = amount * (10 ** diff);
        }

        return amount;
    }
}
