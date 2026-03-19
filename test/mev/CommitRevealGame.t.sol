// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/mev/CommitRevealGame.sol";

contract CommitRevealGameTest is Test {
    CommitRevealGame game;

    address alice = makeAddr("alice");
    address attacker = makeAddr("attacker");

    function setUp() public {
        game = new CommitRevealGame();
    }

    function testCommitRevealPreventsFrontRunning() public {
        uint256 aliceNumber = 100;
        bytes32 aliceSalt = keccak256("alice secret");
        bytes32 aliceCommit = keccak256(abi.encodePacked(alice, aliceNumber, aliceSalt));
        vm.prank(alice);
        game.commit(aliceCommit);

        uint256 attackerNumber = 99;
        bytes32 attackerSalt = keccak256("attacker secret");
        bytes32 attackerCommit = keccak256(abi.encodePacked(attacker, attackerNumber, attackerSalt));

        vm.prank(attacker);
        game.commit(attackerCommit);

        vm.prank(alice);
        game.reveal(aliceNumber, aliceSalt);
        assertEq(game.highestNumber(), 100);
        assertEq(game.winner(), alice);

        vm.prank(attacker);
        game.reveal(attackerNumber, attackerSalt);

        assertEq(game.highestNumber(), 100);
        assertEq(game.winner(), alice);
    }

    function testAttackerWinsIfCommittedHigher() public {
        uint256 aliceNumber = 100;
        bytes32 aliceSalt = keccak256("alice secret");
        bytes32 aliceCommit = keccak256(abi.encodePacked(alice, aliceNumber, aliceSalt));

        vm.prank(alice);
        game.commit(aliceCommit);

        uint256 attackerNumber = 101;
        bytes32 attackerSalt = keccak256("attacker secret");
        bytes32 attackerCommit = keccak256(abi.encodePacked(attacker, attackerNumber, attackerSalt));

        vm.prank(attacker);
        game.commit(attackerCommit);

        vm.prank(alice);
        game.reveal(aliceNumber, aliceSalt);

        assertEq(game.highestNumber(), 100);
        assertEq(game.winner(), alice);

        vm.prank(attacker);
        game.reveal(attackerNumber, attackerSalt);

        assertEq(game.highestNumber(), 101);
        assertEq(game.winner(), attacker);
    }

    function testRevealRevertsWithInvalidCommit() public {
        uint256 number = 100;
        bytes32 salt = keccak256("some secret");

        vm.prank(attacker);
        vm.expectRevert("Invalid reveal");
        game.reveal(number, salt);
    }

    function testAttackerCannotCopyCommit() public {
        uint256 aliceNumber = 100;
        bytes32 aliceSalt = keccak256("secret");

        bytes32 aliceCommit = keccak256(abi.encodePacked(alice, aliceNumber, aliceSalt));

        vm.prank(alice);
        game.commit(aliceCommit);

        vm.prank(attacker);
        game.commit(aliceCommit);

        vm.prank(attacker);
        vm.expectRevert("Invalid reveal");
        game.reveal(aliceNumber, aliceSalt);
    }
}
