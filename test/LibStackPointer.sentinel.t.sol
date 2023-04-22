// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibPointer.sol";
import "../src/LibStackPointer.sol";

contract LibStackPointerSentinelTest is Test {
    using LibUint256Array for uint256[];
    using LibPointer for Pointer;

    function testConsumeSentinelOneSentinel(uint256[] memory stack, uint256 sentinel, uint32 stepSize) public {
        vm.assume(stepSize < stack.length);
        for (uint256 i = 0; i < stack.length; i++) {
            vm.assume(stack[i] != sentinel);
        }
        stack[stack.length - stepSize - 1] = sentinel;

        uint256[] memory expectedConsumed = new uint256[](stepSize);
        uint256 j = 0;
        for (uint256 i = stack.length - stepSize; i < stack.length; i++) {
            expectedConsumed[j] = stack[i];
            j++;
        }

        (Pointer sentinelPointer, uint256[] memory consumed) =
            LibStackPointer.consumeSentinel(stack.endPointer(), stack.dataPointer(), sentinel, stepSize);

        // Sentinel is replaced with length.
        assertEq(Pointer.unwrap(sentinelPointer), Pointer.unwrap(consumed.startPointer()));
        assertEq(sentinelPointer.unsafeReadWord(), stepSize);
        assertEq(expectedConsumed, consumed);
    }
}
