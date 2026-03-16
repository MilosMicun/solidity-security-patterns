// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VulnerableBank} from "../src/VulnerableBank.sol";
import {Attacker} from "../src/Attacker.sol";
import {SafeBank} from "../src/SafeBank.sol";
import {GuardedBank} from "../src/GuardedBank.sol";

contract ReentrancyTest is Test {
    VulnerableBank bank;
    SafeBank safeBank;
    GuardedBank guardedBank;

    address victim = makeAddr("victim");

    function setUp() public {
        bank = new VulnerableBank();
        safeBank = new SafeBank();
        guardedBank = new GuardedBank();
    }

    function testReentrancyAttack() public {
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        bank.deposit{value: 10 ether}();

        Attacker attacker = new Attacker(address(bank));

        attacker.attack{value: 1 ether}();

        assertEq(address(bank).balance, 0);
        assertGt(address(attacker).balance, 1 ether);
        assertEq(bank.balances(victim), 10 ether);
    }

    function testReentrancyFailsOnSafeBank() public {
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        safeBank.deposit{value: 10 ether}();

        Attacker safeAttacker = new Attacker(address(safeBank));

        vm.expectRevert();
        safeAttacker.attack{value: 1 ether}();

        assertEq(address(safeBank).balance, 10 ether);
        assertEq(address(safeAttacker).balance, 0);
        assertEq(safeBank.balances(victim), 10 ether);
    }

    function testReentrancyFailsOnGuardedBank() public {
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        guardedBank.deposit{value: 10 ether}();

        Attacker guardedAttacker = new Attacker(address(guardedBank));

        vm.expectRevert();
        guardedAttacker.attack{value: 1 ether}();

        assertEq(address(guardedBank).balance, 10 ether);
        assertEq(address(guardedAttacker).balance, 0);
        assertEq(guardedBank.balances(victim), 10 ether);
    }
}
