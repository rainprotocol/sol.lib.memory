// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibUint256Array.sol";
import "./LibUint256ArraySlow.sol";
import "../src/LibMemory.sol";

contract LibUint256ArrayArrayFromTest is Test {
    using LibUint256Array for uint256;
    using LibUint256ArraySlow for uint256;
    using LibUint256Array for uint256[];
    using LibUint256ArraySlow for uint256[];

    function testArrayFromA(uint256 a_) public {
        uint256[] memory actual_ = a_.arrayFrom();
        assertTrue(LibMemory.memoryIsAligned());
        assertEq(actual_, a_.arrayFromSlow());
    }

    function testArrayFromAGas0() public pure {
        uint256(1).arrayFrom();
    }

    function testArrayFromAGasSlow0() public pure {
        uint256(1).arrayFromSlow();
    }

    function testArrayFromAB(uint256 a_, uint256 b_) public {
        uint256[] memory actual_ = a_.arrayFrom(b_);
        assertTrue(LibMemory.memoryIsAligned());
        assertEq(actual_, a_.arrayFromSlow(b_));
    }

    function testArrayFromABGas0() public pure {
        uint256(1).arrayFrom(2);
    }

    function testArrayFromABGasSlow0() public pure {
        uint256(1).arrayFromSlow(2);
    }

    function testArrayFromABC(uint256 a_, uint256 b_, uint256 c_) public {
        uint256[] memory actual_ = a_.arrayFrom(b_, c_);
        assertTrue(LibMemory.memoryIsAligned());
        assertEq(actual_, a_.arrayFromSlow(b_, c_));
    }

    function testArrayFromABCGas0() public pure {
        uint256(1).arrayFrom(2, 3);
    }

    function testArrayFromABCGasSlow0() public pure {
        uint256(1).arrayFromSlow(2, 3);
    }

    function testArrayFromABCD(uint256 a_, uint256 b_, uint256 c_, uint256 d_) public {
        uint256[] memory actual_ = a_.arrayFrom(b_, c_, d_);
        assertTrue(LibMemory.memoryIsAligned());
        assertEq(actual_, a_.arrayFromSlow(b_, c_, d_));
    }

    function testArrayFromABCDGas0() public pure {
        uint256(1).arrayFrom(2, 3, 4);
    }

    function testArrayFromABCDGasSlow0() public pure {
        uint256(1).arrayFromSlow(2, 3, 4);
    }

    function testArrayFromABCDE(uint256 a_, uint256 b_, uint256 c_, uint256 d_, uint256 e_) public {
        uint256[] memory actual_ = a_.arrayFrom(b_, c_, d_, e_);
        assertTrue(LibMemory.memoryIsAligned());
        assertEq(actual_, a_.arrayFromSlow(b_, c_, d_, e_));
    }

    function testArrayFromABCDEGas0() public pure {
        uint256(1).arrayFrom(2, 3, 4, 5);
    }

    function testArrayFromABCDEGasSlow0() public pure {
        uint256(1).arrayFromSlow(2, 3, 4, 5);
    }

    function testArrayFromABCDEF(uint256 a_, uint256 b_, uint256 c_, uint256 d_, uint256 e_, uint256 f_) public {
        uint256[] memory actual_ = a_.arrayFrom(b_, c_, d_, e_, f_);
        assertTrue(LibMemory.memoryIsAligned());
        assertEq(actual_, a_.arrayFromSlow(b_, c_, d_, e_, f_));
    }

    function testArrayFromABCDEFGas0() public pure {
        uint256(1).arrayFrom(2, 3, 4, 5, 6);
    }

    function testArrayFromABCDEFGasSlow0() public pure {
        uint256(1).arrayFromSlow(2, 3, 4, 5, 6);
    }

    function testArrayFromATail(uint256 a_, uint256[] memory tail_) public {
        uint256[] memory actual_ = a_.arrayFrom(tail_);
        assertTrue(LibMemory.memoryIsAligned());
        assertEq(actual_, a_.arrayFromSlow(tail_));
    }

    function testArrayFromATailGas0() public pure {
        uint256(1).arrayFrom(uint256(2).arrayFrom(3, 4));
    }

    function testArrayFromATailGasSlow0() public pure {
        uint256(1).arrayFromSlow(uint256(2).arrayFrom(3, 4));
    }

    function testArrayFromABTail(uint256 a_, uint256 b_, uint256[] memory tail_) public {
        uint256[] memory actual_ = a_.arrayFrom(b_, tail_);
        assertTrue(LibMemory.memoryIsAligned());
        assertEq(actual_, a_.arrayFromSlow(b_, tail_));
    }

    function testArrayFromABTailGas0() public pure {
        uint256(1).arrayFrom(2, uint256(3).arrayFrom(4, 5));
    }

    function testArrayFromABTailGasSlow0() public pure {
        uint256(1).arrayFromSlow(2, uint256(3).arrayFrom(4, 5));
    }

    function testArrayFromMatrix(uint256[] memory a_) public {
        uint256[][] memory matrix_ = a_.matrixFrom();
        assertTrue(LibMemory.memoryIsAligned());
        uint256[][] memory matrixSlow_ = a_.matrixFromSlow();
        assertEq(matrix_.length, 1);
        assertEq(matrix_.length, matrixSlow_.length);
        for (uint256 i_ = 0; i_ < matrix_.length; i_++) {
            assertEq(matrix_[i_], matrixSlow_[i_]);
        }
    }

    function testArrayFromMatrixGas0() public pure {
        uint256(1).arrayFrom().matrixFrom();
    }

    function testArrayFromMatrixGasSlow0() public pure {
        uint256(1).arrayFrom().matrixFromSlow();
    }
}
