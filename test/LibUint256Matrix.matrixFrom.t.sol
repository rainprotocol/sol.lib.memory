// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibUint256Array.sol";
import "../src/LibUint256Matrix.sol";
import "./LibUint256ArraySlow.sol";
import "./LibUint256MatrixSlow.sol";
import "../src/LibMemory.sol";

contract LibUint256ArrayArrayFromTest is Test {
    using LibUint256Array for uint256;
    using LibUint256Matrix for uint256[];
    using LibUint256MatrixSlow for uint256[];

    function compareMatrices(uint256[][] memory a_, uint256[][] memory b_, uint256 expectedLength_) internal {
        assertEq(a_.length, expectedLength_);
        assertEq(a_.length, b_.length);
        for (uint256 i_ = 0; i_ < a_.length; i_++) {
            assertEq(a_[i_], b_[i_]);
        }
    }

    function testArrayFromMatrix(uint256[] memory a_) public {
        uint256[][] memory matrix_ = a_.matrixFrom();
        assertTrue(LibMemory.memoryIsAligned());
        uint256[][] memory matrixSlow_ = a_.matrixFromSlow();
        compareMatrices(matrix_, matrixSlow_, 1);
    }

    function testArrayFromMatrixGas0() public pure returns (uint256[][] memory) {
        return uint256(1).arrayFrom().matrixFrom();
    }

    function testArrayFromMatrixGasSlow0() public pure returns (uint256[][] memory) {
        return uint256(1).arrayFrom().matrixFromSlow();
    }
}
