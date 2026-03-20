// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GasInefficient {
    address public owner;
    uint256[] public numbers;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function sumBalanceTimes() external view returns (uint256 total) {
        require(msg.sender == owner, "Not owner");

        for (uint256 i = 0; i < balances[msg.sender]; i++) {
            total += i;
        }
    }

    function setNumbers(uint256[] memory _numbers) external {
        delete numbers;

        for (uint256 i = 0; i < _numbers.length; i++) {
            numbers.push(_numbers[i]);
        }
    }

    function sumNumbers() external view returns (uint256 total) {
        require(msg.sender == owner, "Not owner");

        for (uint256 i = 0; i < numbers.length; i++) {
            total += numbers[i];
        }
    }

    function setBalance(address user, uint256 amount) external {
        balances[user] = amount;
    }
}
