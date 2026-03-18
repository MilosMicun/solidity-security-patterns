// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessControlBrokenTxOrigin {
    address public owner;

    error NotOwner();

    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (tx.origin != owner) revert NotOwner();
        _;
    }

    function deposit() external payable {}

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
