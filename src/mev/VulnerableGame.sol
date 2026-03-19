// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableGame {
    uint256 public highestNumber;
    address public winner;

    function submitNumber(uint256 number) external {
        require(number > highestNumber, "Number too low");
        highestNumber = number;
        winner = msg.sender;
    }
}
