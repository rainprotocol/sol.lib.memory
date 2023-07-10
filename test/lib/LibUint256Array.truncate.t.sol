// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

import "forge-std/Test.sol";
import "src/lib/LibUint256Array.sol";
import "src/lib/LibMemory.sol";

import "test/lib/LibUint256ArraySlow.sol";

contract LibUint256ArrayTruncateTest is Test {
    function testTruncate(uint256[] memory a_, uint256 newLength_) public {
        vm.assume(newLength_ <= a_.length);
        uint256[] memory b_ = new uint256[](a_.length);
        for (uint256 i_ = 0; i_ < a_.length; i_++) {
            b_[i_] = a_[i_];
        }
        assertEq(a_, b_);

        LibUint256Array.truncate(a_, newLength_);
        assertTrue(LibMemory.memoryIsAligned());

        b_ = LibUint256ArraySlow.truncateSlow(b_, newLength_);
        assertEq(a_, b_);
    }

    function testTruncateError(uint256[] memory a_, uint256 newLength_) public {
        vm.assume(newLength_ > a_.length);
        vm.expectRevert(abi.encodeWithSelector(OutOfBoundsTruncate.selector, a_.length, newLength_));
        LibUint256Array.truncate(a_, newLength_);
    }

    function testTruncateGas0() public pure {
        LibUint256Array.truncate(LibUint256Array.arrayFrom(1, 2, 3), 1);
    }

    function testTruncateGas1() public pure {
        LibUint256Array.truncate(LibUint256Array.arrayFrom(1, 2, 3), 0);
    }
}
