// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessControlFixed {
    address public owner;

    error NotOwner();

    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function deposit() external payable {}

    function changeOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
