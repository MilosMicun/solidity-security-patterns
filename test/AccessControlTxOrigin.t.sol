// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AccessControlBrokenTxOrigin.sol";
import "../src/TxOriginAttacker.sol";

contract AccessControlTxOriginTest is Test {
    AccessControlBrokenTxOrigin broken;
    TxOriginAttacker attackerContract;

    address owner = makeAddr("owner");
    address payable attacker = payable(makeAddr("attacker"));

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(attacker, 10 ether);

        vm.prank(owner);
        broken = new AccessControlBrokenTxOrigin{value: 5 ether}();

        attackerContract = new TxOriginAttacker(attacker, address(broken));
    }

    function testTxOriginExploit() public {
        uint256 attackerBalanceBefore = attacker.balance;

        assertEq(broken.owner(), owner);
        assertEq(address(broken).balance, 5 ether);

        vm.prank(owner, owner);
        attackerContract.attack();

        assertEq(address(broken).balance, 0);
        assertEq(address(attackerContract).balance, 5 ether);

        attackerContract.sweep();

        assertEq(address(attackerContract).balance, 0);
        assertEq(attacker.balance, attackerBalanceBefore + 5 ether);
    }
}
