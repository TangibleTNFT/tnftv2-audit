// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract PriceConverter {
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
