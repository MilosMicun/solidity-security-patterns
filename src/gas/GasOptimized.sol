// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error NotOwner();

contract GasOptimized {
    address public immutable owner;
    uint256[] public numbers;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function sumBalanceTimes() external view returns (uint256 total) {
        if (msg.sender != owner) revert NotOwner();

        uint256 balance = balances[msg.sender];

        for (uint256 i = 0; i < balance; i++) {
            total += i;
        }
    }

    function setNumbers(uint256[] calldata _numbers) external {
        delete numbers;

        uint256 len = _numbers.length;
        for (uint256 i = 0; i < len; i++) {
            numbers.push(_numbers[i]);
        }
    }

    function sumNumbers() external view returns (uint256 total) {
        if (msg.sender != owner) revert NotOwner();

        uint256 len = numbers.length;
        for (uint256 i = 0; i < len; i++) {
            total += numbers[i];
        }
    }

    function setBalance(address user, uint256 amount) external {
        balances[user] = amount;
    }
}
