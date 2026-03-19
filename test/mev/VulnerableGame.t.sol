// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/mev/VulnerableGame.sol";

contract VulnerableGameTest is Test {
    VulnerableGame game;

    address alice = makeAddr("alice");
    address attacker = makeAddr("attacker");

    function setUp() public {
        game = new VulnerableGame();
    }

    function testFrontRunning() public {
        uint256 aliceNumber = 100;
        vm.prank(attacker);
        game.submitNumber(101);

        vm.prank(alice);
        vm.expectRevert("Number too low");
        game.submitNumber(aliceNumber);

        assertEq(game.highestNumber(), 101);
        assertEq(game.winner(), attacker);
    }
}
