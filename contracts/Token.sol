pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

contract Token is ERC20, Initializable {
    function __Token_init() external initializer {
        __ERC20_init("Gold", "GLD");
        _mint(msg.sender, 100000);
    }
}
