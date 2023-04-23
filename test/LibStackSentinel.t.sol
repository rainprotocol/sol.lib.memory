// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibPointer.sol";
import "../src/LibStackPointer.sol";
import "../src/LibStackSentinel.sol";

contract LibStackSentinelTest is Test {
    using LibUint256Array for uint256[];
    using LibPointer for Pointer;
    using LibStackSentinel for Pointer;

    function testConsumeSentinelTuple2(uint256[] memory stack, Sentinel sentinel, uint8 sentinelIndex) public {
        for (uint256 i = 0; i < stack.length; i++) {
            vm.assume(stack[i] != Sentinel.unwrap(sentinel));
        }
        vm.assume(sentinelIndex < stack.length);
        vm.assume((stack.length - (sentinelIndex + 1)) % 2 == 0);
        stack[sentinelIndex] = Sentinel.unwrap(sentinel);

        (Pointer sentinelPointer, uint256[2][] memory tuples) =
            stack.dataPointer().consumeSentinelTuple2(stack.endPointer(), sentinel);

        Pointer expectedSentinelPointer;
        assembly ("memory-safe") {
            expectedSentinelPointer := add(stack, add(0x20, mul(0x20, sentinelIndex)))
        }
        assertEq(Pointer.unwrap(sentinelPointer), Pointer.unwrap(expectedSentinelPointer));
        assertTrue((((Pointer.unwrap(stack.endPointer()) - Pointer.unwrap(sentinelPointer)) / 0x20) + 1) % 2 == 0);
        uint256 j = 0;
        for (uint256 i = sentinelIndex + 1; i < stack.length; i += 2) {
            assertEq(stack[i], tuples[j][0]);
            assertEq(stack[i + 1], tuples[j][1]);
            j++;
        }
    }

    // function testConsumeSentinelOneSentinel(uint256[] memory stack, uint256 sentinel, uint32 stepSize) public {
    //     vm.assume(stepSize > 0);
    //     vm.assume(stepSize < stack.length);
    //     for (uint256 i = 0; i < stack.length; i++) {
    //         vm.assume(stack[i] != sentinel);
    //     }
    //     stack[stack.length - stepSize - 1] = sentinel;

    //     uint256[] memory expectedConsumed = new uint256[](stepSize);
    //     uint256 j = 0;
    //     for (uint256 i = stack.length - stepSize; i < stack.length; i++) {
    //         expectedConsumed[j] = stack[i];
    //         j++;
    //     }

    //     (Pointer sentinelPointer, uint256[] memory consumed) =
    //         stack.endPointer().consumeSentinel(stack.dataPointer(), sentinel, stepSize);

    //     // Sentinel is replaced with length.
    //     assertEq(Pointer.unwrap(sentinelPointer), Pointer.unwrap(consumed.startPointer()));
    //     assertEq(sentinelPointer.unsafeReadWord(), stepSize);
    //     assertEq(expectedConsumed, consumed);
    // }

    // function testConsumeSentinelZeroStep(uint256[] memory stack, uint256 sentinel, bytes memory seed) public {
    //     if (stack.length > 0) {
    //         stack[uint256(keccak256(seed)) % stack.length] = sentinel;
    //     }
    //     vm.expectRevert(ZeroStepSize.selector);
    //     (Pointer sentinelPointer, uint256[] memory consumed) =
    //         stack.endPointer().consumeSentinel(stack.dataPointer(), sentinel, 0);
    // }
}
