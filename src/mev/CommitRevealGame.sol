// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CommitRevealGame {
    mapping(address => bytes32) public commitments;

    uint256 public highestNumber;
    address public winner;

    function commit(bytes32 commitment) external {
        commitments[msg.sender] = commitment;
    }

    function reveal(uint256 number, bytes32 salt) external {
        bytes32 expected = keccak256(abi.encodePacked(msg.sender, number, salt));
        require(commitments[msg.sender] == expected, "Invalid reveal");
        if (number > highestNumber) {
            highestNumber = number;
            winner = msg.sender;
        }
        delete commitments[msg.sender];
    }
}
