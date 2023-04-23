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
        //slither-disable-next-line calls-loop
        for (uint256 i = 0; i < stack.length; i++) {
            vm.assume(stack[i] != Sentinel.unwrap(sentinel));
        }
        vm.assume(sentinelIndex < stack.length);
        // Align the sentinels with clean tuples.
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
        assertEq(tuples.length * 2, stack.length - (sentinelIndex + 1));
    }

    function testConsumeSentinelTuple2MissingSentinel(uint256[] memory stack, Sentinel sentinel) public {
        //slither-disable-next-line calls-loop
        for (uint256 i = 0; i < stack.length; i++) {
            vm.assume(stack[i] != Sentinel.unwrap(sentinel));
        }

        vm.expectRevert(abi.encodeWithSelector(MissingSentinel.selector, sentinel));
        (Pointer sentinelPointer, uint256[2][] memory tuples) =
            stack.dataPointer().consumeSentinelTuple2(stack.endPointer(), sentinel);
        (sentinelPointer);
        (tuples);
    }

    function testConsumeSentinelTuple2OddSentinel(uint256[] memory stack, Sentinel sentinel, uint8 sentinelIndex)
        public
    {
        //slither-disable-next-line calls-loop
        for (uint256 i = 0; i < stack.length; i++) {
            vm.assume(stack[i] != Sentinel.unwrap(sentinel));
        }
        vm.assume(sentinelIndex < stack.length);
        // UNalign the sentinel with clean tuples.
        vm.assume((stack.length - (sentinelIndex + 1)) % 2 == 1);

        stack[sentinelIndex] = Sentinel.unwrap(sentinel);

        vm.expectRevert(abi.encodeWithSelector(MissingSentinel.selector, sentinel));
        (Pointer sentinelPointer, uint256[2][] memory tuples) =
            stack.dataPointer().consumeSentinelTuple2(stack.endPointer(), sentinel);
        (sentinelPointer);
        (tuples);
    }

    function testConsumeSentinelTuple2ReservedPointerError(Pointer lower, Pointer upper, Sentinel sentinel) public {
        vm.assume(Pointer.unwrap(lower) < 0x80);

        vm.expectRevert(abi.encodeWithSelector(ReservedPointer.selector, lower));
        (Pointer sentinelPointer, uint256[2][] memory tuples) = lower.consumeSentinelTuple2(upper, sentinel);
        (sentinelPointer);
        (tuples);
    }

    function testConsumeSentinelTuple2InitialStateUnderflowError(Pointer lower, Pointer upper, Sentinel sentinel)
        public
    {
        vm.assume(Pointer.unwrap(lower) >= 0x80);
        vm.assume(Pointer.unwrap(upper) < Pointer.unwrap(lower));

        vm.expectRevert(abi.encodeWithSelector(InitialStateUnderflow.selector, lower, upper));
        (Pointer sentinelPointer, uint256[2][] memory tuples) = lower.consumeSentinelTuple2(upper, sentinel);
        (sentinelPointer);
        (tuples);
    }

    function testConsumeSentinelTuple2Empty(Sentinel sentinel) public {
        Pointer lower;
        assembly ("memory-safe") {
            lower := mload(0x40)
            mstore(lower, sentinel)
        }

        vm.expectRevert(abi.encodeWithSelector(MissingSentinel.selector, sentinel));
        (Pointer sentinelPointer0, uint256[2][] memory tuples0) = lower.consumeSentinelTuple2(lower, sentinel);
        (sentinelPointer0);
        (tuples0);

        (Pointer sentinelPointer1, uint256[2][] memory tuples1) =
            lower.consumeSentinelTuple2(lower.unsafeAddWord(), sentinel);
        (sentinelPointer1);
        (tuples1);
        assertEq(Pointer.unwrap(sentinelPointer1), Pointer.unwrap(lower));
        assertEq(tuples1.length, 0);
    }

    function testConsumeSentinelTuple2Gas0() public pure {
        Pointer lower;
        Pointer upper;
        Sentinel sentinel = Sentinel.wrap(50);
        assembly ("memory-safe") {
            lower := mload(0x40)
            upper := add(lower, 0x20)
            mstore(lower, sentinel)
        }
        (Pointer sentinelPointer, uint256[2][] memory tuples) = lower.consumeSentinelTuple2(upper, sentinel);
        (sentinelPointer);
        (tuples);
    }

    function testConsumeSentinelTuple2Gas1() public pure {
        Pointer lower;
        Pointer upper;
        Sentinel sentinel = Sentinel.wrap(50);
        assembly ("memory-safe") {
            lower := mload(0x40)
            upper := add(lower, 0x60)
            mstore(lower, sentinel)
        }
        (Pointer sentinelPointer, uint256[2][] memory tuples) = lower.consumeSentinelTuple2(upper, sentinel);
        (sentinelPointer);
        (tuples);
    }

    function testConsumeSentinelTuple2Gas2() public pure {
        Pointer lower;
        Pointer upper;
        Sentinel sentinel = Sentinel.wrap(50);
        assembly ("memory-safe") {
            lower := mload(0x40)
            upper := add(lower, 0xa0)
            mstore(lower, sentinel)
        }
        (Pointer sentinelPointer, uint256[2][] memory tuples) = lower.consumeSentinelTuple2(upper, sentinel);
        (sentinelPointer);
        (tuples);
    }

    function testConsumeSentinelTuple2Gas3() public pure {
        Pointer lower;
        Pointer upper;
        Sentinel sentinel = Sentinel.wrap(50);
        assembly ("memory-safe") {
            lower := mload(0x40)
            upper := add(lower, 0xe0)
            mstore(lower, sentinel)
        }
        (Pointer sentinelPointer, uint256[2][] memory tuples) = lower.consumeSentinelTuple2(upper, sentinel);
        (sentinelPointer);
        (tuples);
    }
}
