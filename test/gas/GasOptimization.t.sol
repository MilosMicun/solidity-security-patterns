// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/gas/GasInefficient.sol";
import "../../src/gas/GasOptimized.sol";

contract GasOptimizationTest is Test {
    GasInefficient inefficient;
    GasOptimized optimized;

    address owner = makeAddr("owner");

    function setUp() public {
        vm.startPrank(owner);
        inefficient = new GasInefficient();
        optimized = new GasOptimized();

        uint256[] memory nums = new uint256[](5);
        nums[0] = 1;
        nums[1] = 2;
        nums[2] = 3;
        nums[3] = 4;
        nums[4] = 5;

        inefficient.setNumbers(nums);
        optimized.setNumbers(nums);

        inefficient.setBalance(owner, 5);
        optimized.setBalance(owner, 5);

        vm.stopPrank();
    }

    function testSumNumbersSameResult() public {
        vm.startPrank(owner);

        uint256 inefficientResult = inefficient.sumNumbers();
        uint256 optimizedResult = optimized.sumNumbers();

        vm.stopPrank();

        assertEq(inefficientResult, optimizedResult);
    }

    function testSumBalanceTimesSameResult() public {
        vm.startPrank(owner);

        uint256 inefficientResult = inefficient.sumBalanceTimes();
        uint256 optimizedResult = optimized.sumBalanceTimes();

        vm.stopPrank();

        assertEq(inefficientResult, optimizedResult);
    }
}
