// SPDX-License-Identifier: CAL
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/LibMemory.sol";
import "../src/LibUint256Array.sol";
import "./LibUint256ArraySlow.sol";

contract LibUint256ArrayExtendTest is Test {
    // This code path hits the inline extension by ensuring that c_ is the most
    // recent thing allocated.
    function testExtendInline(uint256[] memory a_, uint256[] memory b_) public {
        uint256[] memory c_ = new uint256[](a_.length);
        for (uint256 i_; i_ < a_.length; i_++) {
            c_[i_] = a_[i_];
        }
        LibUint256Array.extend(c_, b_);
        assertTrue(LibMemory.memoryIsAligned());

        assertEq(c_, LibUint256ArraySlow.extendSlow(a_, b_));
    }

    // This code path hits extension with allocation due to b_ sitting behind c_.
    function testExtendAllocate(uint256[] memory a_, uint256[] memory b_) public {
        uint256[] memory c_ = new uint256[](b_.length);
        for (uint256 i_; i_ < b_.length; i_++) {
            c_[i_] = b_[i_];
        }
        LibUint256Array.extend(b_, a_);
        assertTrue(LibMemory.memoryIsAligned());

        assertEq(b_, LibUint256ArraySlow.extendSlow(c_, a_));
    }

    // function testTruncateError(uint256[] memory a_, uint256 newLength_) public {
    //     vm.assume(newLength_ > a_.length);
    //     vm.expectRevert(abi.encodeWithSelector(OutOfBoundsTruncate.selector, a_.length, newLength_));
    //     LibUint256Array.truncate(a_, newLength_);
    // }

    // function testTruncateGas0() public {
    //     LibUint256Array.truncate(LibUint256Array.arrayFrom(1, 2, 3), 1);
    // }

    // function testTruncateGas1() public {
    //     LibUint256Array.truncate(LibUint256Array.arrayFrom(1, 2, 3), 0);
    // }
}
