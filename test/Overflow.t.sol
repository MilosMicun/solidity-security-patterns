// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {OverflowLegacy} from "../src/OverflowLegacy.sol";
import {OverflowChecked} from "../src/OverflowChecked.sol";
import {OverflowUnchecked} from "../src/OverflowUnchecked.sol";

contract overflowTest is Test {
    OverflowLegacy legacy;
    OverflowChecked checked;
    OverflowUnchecked uncheckedDemo;

    function setUp() public {
        legacy = new OverflowLegacy();
        checked = new OverflowChecked();
        uncheckedDemo = new OverflowUnchecked();
    }

    function testLegacyAddWrapsToZero() public {
        uint256 result = legacy.add(type(uint256).max, 1);
        assertEq(result, 0);
    }

    function testLegacySubWrapsToMax() public {
        uint256 result = legacy.sub(0, 1);
        assertEq(result, type(uint256).max);
    }

    function testCheckedAddRevertsOnOverflow() public {
        vm.expectRevert();
        checked.add(type(uint256).max, 1);
    }

    function testCheckedSubRevertsOnUnderflow() public {
        vm.expectRevert();
        checked.sub(0, 1);
    }

    function testUncheckedAddWithGuardWorks() public {
        uint256 result = uncheckedDemo.add(10, 20);
        assertEq(result, 30);
    }

    function testUncheckedSubWithGuardWorks() public {
        uint256 result = uncheckedDemo.sub(20, 10);
        assertEq(result, 10);
    }

    function testUncheckedAddRevertsWhenGuardFails() public {
        vm.expectRevert(OverflowUnchecked.Overflow.selector);
        uncheckedDemo.add(type(uint256).max, 1);
    }

    function testUncheckedSubRevertsWhenGuardFails() public {
        vm.expectRevert(OverflowUnchecked.Underflow.selector);
        uncheckedDemo.sub(0, 1);
    }

    function testUncheckedAddWrapFunctionWrapsToZero() public {
        uint256 result = uncheckedDemo.addWrap(type(uint256).max, 1);
        assertEq(result, 0);
    }

    function testUncheckedSubWrapFunctionWrapsToMax() public {
        uint256 result = uncheckedDemo.subWrap(0, 1);
        assertEq(result, type(uint256).max);
    }
}
