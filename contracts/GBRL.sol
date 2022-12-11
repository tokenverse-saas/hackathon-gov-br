// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGBRL is IERC20 {
    function deposit(uint256 _amount, address _owner) external;

    function burn(uint256 _amount, address _owner) external;
}

contract GBRL is ERC20, Ownable {
    constructor() ERC20("Brazilian Stable Coin", "GBRL") {}

    mapping(address => bool) public _authorizedContracts;

    modifier isAuthorized() {
        require(
            _authorizedContracts[msg.sender] == true || msg.sender == owner(),
            "[GBRL]: caller is not authorized"
        );

        _;
    }

    function addAuthorizedContract(
        address _authorizedContract
    ) external onlyOwner {
        _authorizedContracts[_authorizedContract] = true;
    }

    function mint(uint256 _amount, address _owner) external isAuthorized {
        _mint(_owner, _amount);
    }

    function burn(uint256 _amount, address _owner) external isAuthorized {
        _burn(_owner, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public override isAuthorized returns (bool) {
        _transfer(_from, _to, _amount);

        return true;
    }
}
