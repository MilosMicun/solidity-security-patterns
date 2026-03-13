// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VulnerableBank} from "../src/VulnerableBank.sol";
import {Attacker} from "../src/Attacker.sol";

contract ReentrancyTest is Test {
    VulnerableBank bank;
    Attacker attacker;

    address victim = makeAddr("victim");

    function setUp() public {
        bank = new VulnerableBank();
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        bank.deposit{value: 10 ether}();
        attacker = new Attacker(address(bank));
    }

    function testReentrancyAttack() public {
        vm.deal(address(attacker), 1 ether);
        attacker.attack{value: 1 ether}();
        assertEq(address(bank).balance, 0);
        assertGt(address(attacker).balance, 1 ether);
    }
}
