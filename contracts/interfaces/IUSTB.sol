// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUSTB is IERC20 {
    function disableRebase(address account, bool disable) external;
}
