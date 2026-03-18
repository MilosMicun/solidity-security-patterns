// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessControlVulnerable {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function deposti() external payable {}

    function changeOwner(address newOwner) external {
        owner = newOwner;
    }

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
