// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DAIMock is ERC20("DAI", "DAI") {
    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
