// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OverflowUnchecked {
    error Overflow();
    error Underflow();

    function add(uint256 a, uint256 b) external pure returns (uint256) {
        if (a > type(uint256).max - b) revert Overflow();

        unchecked {
            return a + b;
        }
    }

    function sub(uint256 a, uint256 b) external pure returns (uint256) {
        if (a < b) revert Underflow();

        unchecked {
            return a - b;
        }
    }

    function addWrap(uint256 a, uint256 b) external pure returns (uint256) {
        unchecked {
            return a + b;
        }
    }

    function subWrap(uint256 a, uint256 b) external pure returns (uint256) {
        unchecked {
            return a - b;
        }
    }
}
