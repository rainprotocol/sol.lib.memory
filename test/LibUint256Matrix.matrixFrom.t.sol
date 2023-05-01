// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibUint256Array.sol";
import "../src/LibUint256Matrix.sol";
import "./LibUint256ArraySlow.sol";
import "./LibUint256MatrixSlow.sol";
import "../src/LibMemory.sol";

contract LibUint256ArrayMatrixFromTest is Test {
    using LibUint256Array for uint256;
    using LibUint256Matrix for uint256[];
    using LibUint256MatrixSlow for uint256[];

    function compareMatrices(uint256[][] memory a, uint256[][] memory b, uint256 expectedLength_) internal {
        assertEq(a.length, expectedLength_);
        assertEq(a.length, b.length);
        for (uint256 i_ = 0; i_ < a.length; i_++) {
            assertEq(a[i_], b[i_]);
        }
    }

    function testMatrixFromA(uint256[] memory a) public {
        uint256[][] memory matrix = a.matrixFrom();
        assertTrue(LibMemory.memoryIsAligned());
        uint256[][] memory matrixSlow = a.matrixFromSlow();
        compareMatrices(matrix, matrixSlow, 1);
    }

    function testMatrixFromAGas0() public pure returns (uint256[][] memory) {
        return uint256(1).arrayFrom().matrixFrom();
    }

    function testMatrixFromAGasSlow0() public pure returns (uint256[][] memory) {
        return uint256(1).arrayFrom().matrixFromSlow();
    }

    function testMatrixFromAB(uint256[] memory a, uint256[] memory b) public {
        uint256[][] memory matrix = LibUint256Matrix.matrixFrom(a, b);
        assertTrue(LibMemory.memoryIsAligned());
        uint256[][] memory matrixSlow = LibUint256MatrixSlow.matrixFromSlow(a, b);
        compareMatrices(matrix, matrixSlow, 2);
    }

    function testMatrixFromABGas0() public pure returns (uint256[][] memory) {
        return LibUint256Matrix.matrixFrom(uint256(1).arrayFrom(), uint256(2).arrayFrom());
    }

    function testMatrixFromABGasSlow0() public pure returns (uint256[][] memory) {
        return LibUint256MatrixSlow.matrixFromSlow(uint256(1).arrayFrom(), uint256(2).arrayFrom());
    }

    function testMatrixFromABC(uint256[] memory a, uint256[] memory b, uint256[] memory c) public {
        uint256[][] memory matrix = LibUint256Matrix.matrixFrom(a, b, c);
        assertTrue(LibMemory.memoryIsAligned());
        uint256[][] memory matrixSlow = LibUint256MatrixSlow.matrixFromSlow(a, b, c);
        compareMatrices(matrix, matrixSlow, 3);
    }

    function testMatrixFromABCGas0() public pure returns (uint256[][] memory) {
        return LibUint256Matrix.matrixFrom(uint256(1).arrayFrom(), uint256(2).arrayFrom(), uint256(3).arrayFrom());
    }

    function testMatrixFromABCGasSlow0() public pure returns (uint256[][] memory) {
        return
            LibUint256MatrixSlow.matrixFromSlow(uint256(1).arrayFrom(), uint256(2).arrayFrom(), uint256(3).arrayFrom());
    }
}
