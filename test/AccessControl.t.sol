// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AccessControlVulnerable.sol";
import "../src/AccessControlFixed.sol";

contract AccessControlTest is Test {
    AccessControlVulnerable vulnerable;
    AccessControlFixed fixedContract;

    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(attacker, 10 ether);

        vm.startPrank(owner);
        vulnerable = new AccessControlVulnerable{value: 5 ether}();
        fixedContract = new AccessControlFixed{value: 5 ether}();
        vm.stopPrank();
    }

    function testAttackerCanChangeOwner() public {
        vm.prank(attacker);
        vulnerable.changeOwner(attacker);
        assertEq(vulnerable.owner(), attacker);
    }

    function testAttackerCanWithdraw() public {
        uint256 attackerBalanceBefore = attacker.balance;

        vm.prank(attacker);
        vulnerable.withdraw();

        assertEq(address(vulnerable).balance, 0);
        assertEq(attacker.balance, attackerBalanceBefore + 5 ether);
    }

    function testFixedChangeOwnerRevertsForAttacker() public {
        vm.prank(attacker);
        vm.expectRevert(AccessControlFixed.NotOwner.selector);
        fixedContract.changeOwner(attacker);
    }

    function testFixedWithdrawRevertsForAttacker() public {
        vm.prank(attacker);
        vm.expectRevert(AccessControlFixed.NotOwner.selector);
        fixedContract.withdraw();
    }

    function testOwnerCanWithdrawFromFixed() public {
        uint256 ownerBalanceBefore = owner.balance;
        vm.prank(owner);
        fixedContract.withdraw();

        assertEq(address(fixedContract).balance, 0);
        assertEq(owner.balance, ownerBalanceBefore + 5 ether);
    }
}
