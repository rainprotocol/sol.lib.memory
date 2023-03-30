// SPDX-License-Identifier: CAL
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/LibUint256Array.sol";
import "./LibUint256ArraySlow.sol";

contract LibUint256ArrayArrayFromTest is Test {
    using LibUint256Array for uint256;
    using LibUint256ArraySlow for uint256;

    function testArrayFromA(uint256 a_) public {
        assertEq(a_.arrayFrom(), a_.arrayFromSlow());
    }

    function testArrayFromAGas0() public pure {
        uint256(1).arrayFrom();
    }

    function testArrayFromAGasSlow0() public pure {
        uint256(1).arrayFromSlow();
    }

    function testArrayFromAB(uint256 a_, uint256 b_) public {
        assertEq(a_.arrayFrom(b_), a_.arrayFromSlow(b_));
    }

    function testArrayFromABGas0() public pure {
        uint256(1).arrayFrom(2);
    }

    function testArrayFromABGasSlow0() public pure {
        uint256(1).arrayFromSlow(2);
    }

    function testArrayFromABC(uint256 a_, uint256 b_, uint256 c_) public {
        assertEq(a_.arrayFrom(b_, c_), a_.arrayFromSlow(b_, c_));
    }

    function testArrayFromABCGas0() public pure {
        uint256(1).arrayFrom(2, 3);
    }

    function testArrayFromABCGasSlow0() public pure {
        uint256(1).arrayFromSlow(2, 3);
    }

    function testArrayFromABCD(uint256 a_, uint256 b_, uint256 c_, uint256 d_) public {
        assertEq(a_.arrayFrom(b_, c_, d_), a_.arrayFromSlow(b_, c_, d_));
    }

    function testArrayFromABCDGas0() public pure {
        uint256(1).arrayFrom(2, 3, 4);
    }

    function testArrayFromABCDGasSlow0() public pure {
        uint256(1).arrayFromSlow(2, 3, 4);
    }

    function testArrayFromABCDE(uint256 a_, uint256 b_, uint256 c_, uint256 d_, uint256 e_) public {
        assertEq(a_.arrayFrom(b_, c_, d_, e_), a_.arrayFromSlow(b_, c_, d_, e_));
    }

    function testArrayFromABCDEGas0() public pure {
        uint256(1).arrayFrom(2, 3, 4, 5);
    }

    function testArrayFromABCDEGasSlow0() public pure {
        uint256(1).arrayFromSlow(2, 3, 4, 5);
    }

    function testArrayFromABCDEF(uint256 a_, uint256 b_, uint256 c_, uint256 d_, uint256 e_, uint256 f_) public {
        assertEq(a_.arrayFrom(b_, c_, d_, e_, f_), a_.arrayFromSlow(b_, c_, d_, e_, f_));
    }

    function testArrayFromABCDEFGas0() public pure {
        uint256(1).arrayFrom(2, 3, 4, 5, 6);
    }

    function testArrayFromABCDEFGasSlow0() public pure {
        uint256(1).arrayFromSlow(2, 3, 4, 5, 6);
    }

    function testArrayFromATail(uint256 a_, uint256[] memory tail_) public {
        assertEq(a_.arrayFrom(tail_), a_.arrayFromSlow(tail_));
    }

    function testArrayFromATailGas0() public pure {
        uint256(1).arrayFrom(uint256(2).arrayFrom());
    }

    function testArrayFromATailGasSlow0() public pure {
        uint256(1).arrayFromSlow(uint256(2).arrayFrom());
    }
}