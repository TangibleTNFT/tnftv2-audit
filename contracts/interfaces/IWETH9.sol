// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

interface IWETH9 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}
