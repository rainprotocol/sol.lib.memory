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

    /// Discovered during flow testing. Would revert with missing sentinel and
    /// length of b was 3 instead of 0.
    function testConsumeSentinelTuplesRegression0() public {
        Sentinel sentinel =
            Sentinel.wrap(115183058774379759847873638693462432260838474092724525396123647190314935293775);
        uint256[] memory stack = new uint256[](22);
        uint256[4][] memory a;
        uint256[4][] memory b;
        uint256[5][] memory c;

        stack[0] = 115183058774379759847873638693462432260838474092724525396123647190314935293775;
        stack[1] = 642829559307850963015472508762062935916233390536;
        stack[2] = 845144691605623761611895262923086603930318432472;
        stack[3] = 1234;
        stack[4] = 790541044196308479814548981703200609474602451736;
        stack[5] = 10000000000000000000;
        stack[6] = 1050292306917326452020632068237092216166216650590;
        stack[7] = 10000000000000000000;
        stack[8] = 5000000000000000000;
        stack[9] = 86400;
        stack[10] = 0;
        stack[11] = 115183058774379759847873638693462432260838474092724525396123647190314935293775;
        stack[12] = 115183058774379759847873638693462432260838474092724525396123647190314935293775;
        stack[13] = 115183058774379759847873638693462432260838474092724525396123647190314935293775;
        stack[14] = 790541044196308479814548981703200609474602451736;
        stack[15] = 642829559307850963015472508762062935916233390536;
        stack[16] = 845144691605623761611895262923086603930318432472;
        stack[17] = 10000000000000000000;
        stack[18] = 1050292306917326452020632068237092216166216650590;
        stack[19] = 845144691605623761611895262923086603930318432472;
        stack[20] = 642829559307850963015472508762062935916233390536;
        stack[21] = 10000000000000000000;

        uint256[] memory allocateMoreMemory = new uint256[](5);

        Pointer stackBottom = stack.dataPointer();
        Pointer stackTop = stack.endPointer();

        Pointer tuplesPointer;
        (stackTop, tuplesPointer) = stackBottom.consumeSentinelTuples(stackTop, sentinel, 4);

        assembly ("memory-safe") {
            a := tuplesPointer
        }
        assertEq(a.length, 2);

        (stackTop, tuplesPointer) = stackBottom.consumeSentinelTuples(stackTop, sentinel, 4);

        assembly ("memory-safe") {
            b := tuplesPointer
        }
        assertEq(b.length, 0);

        (stackTop, tuplesPointer) = stackBottom.consumeSentinelTuples(stackTop, sentinel, 5);

        assembly ("memory-safe") {
            c := tuplesPointer
        }
        assertEq(c.length, 0);
    }

    function testConsumeSentinelTuples(uint256[] memory stack, Sentinel sentinel, uint8 sentinelIndex) public {
        for (uint256 i = 0; i < stack.length; i++) {
            //slither-disable-next-line calls-loop
            vm.assume(stack[i] != Sentinel.unwrap(sentinel));
        }
        vm.assume(sentinelIndex < stack.length);
        // Align the sentinels with clean tuples.
        vm.assume((stack.length - (sentinelIndex + 1)) % 2 == 0);
        stack[sentinelIndex] = Sentinel.unwrap(sentinel);

        (Pointer sentinelPointer, Pointer tuplesPointer) =
            stack.dataPointer().consumeSentinelTuples(stack.endPointer(), sentinel, 2);
        uint256[2][] memory tuples;
        assembly ("memory-safe") {
            tuples := tuplesPointer
        }

        Pointer expectedSentinelPointer;
        assembly ("memory-safe") {
            expectedSentinelPointer := add(stack, add(0x20, mul(0x20, sentinelIndex)))
        }
        assertEq(Pointer.unwrap(sentinelPointer), Pointer.unwrap(expectedSentinelPointer));
        assertTrue(((Pointer.unwrap(stack.endPointer()) - (Pointer.unwrap(sentinelPointer) + 0x20)) / 0x20) % 2 == 0);
        uint256 j = 0;
        for (uint256 i = sentinelIndex + 1; i < stack.length; i += 2) {
            assertEq(stack[i], tuples[j][0]);
            assertEq(stack[i + 1], tuples[j][1]);
            j++;
        }
        assertEq(tuples.length * 2, stack.length - (sentinelIndex + 1));

        assertEq(
            Pointer.unwrap(tuplesPointer.unsafeAddWords(tuples.length + 1)),
            Pointer.unwrap(LibPointer.allocatedMemoryPointer())
        );
    }

    function testConsumeSentinelTuples3(uint256[] memory stack, Sentinel sentinel, uint8 sentinelIndex) public {
        for (uint256 i = 0; i < stack.length; i++) {
            //slither-disable-next-line calls-loop
            vm.assume(stack[i] != Sentinel.unwrap(sentinel));
        }
        vm.assume(sentinelIndex < stack.length);
        // Align the sentinels with clean tuples.
        vm.assume((stack.length - (sentinelIndex + 1)) % 3 == 0);
        stack[sentinelIndex] = Sentinel.unwrap(sentinel);

        (Pointer sentinelPointer, Pointer tuplesPointer) =
            stack.dataPointer().consumeSentinelTuples(stack.endPointer(), sentinel, 3);
        uint256[3][] memory tuples;
        assembly ("memory-safe") {
            tuples := tuplesPointer
        }

        Pointer expectedSentinelPointer;
        assembly ("memory-safe") {
            expectedSentinelPointer := add(stack, add(0x20, mul(0x20, sentinelIndex)))
        }
        assertEq(Pointer.unwrap(sentinelPointer), Pointer.unwrap(expectedSentinelPointer));
        assertEq(((Pointer.unwrap(stack.endPointer()) - (Pointer.unwrap(sentinelPointer) + 0x20)) / 0x20) % 3, 0);
        uint256 j = 0;
        for (uint256 i = sentinelIndex + 1; i < stack.length; i += 3) {
            assertEq(stack[i], tuples[j][0]);
            assertEq(stack[i + 1], tuples[j][1]);
            assertEq(stack[i + 2], tuples[j][2]);
            j++;
        }
        assertEq(tuples.length * 3, stack.length - (sentinelIndex + 1));

        assertEq(
            Pointer.unwrap(tuplesPointer.unsafeAddWords(tuples.length + 1)),
            Pointer.unwrap(LibPointer.allocatedMemoryPointer())
        );
    }

    function testConsumeSentinelTuplesMissingSentinel(uint256[] memory stack, Sentinel sentinel) public {
        for (uint256 i = 0; i < stack.length; i++) {
            //slither-disable-next-line calls-loop
            vm.assume(stack[i] != Sentinel.unwrap(sentinel));
        }

        vm.expectRevert(abi.encodeWithSelector(MissingSentinel.selector, sentinel));
        (Pointer sentinelPointer, Pointer tuplesPointer) =
            stack.dataPointer().consumeSentinelTuples(stack.endPointer(), sentinel, 2);
        (sentinelPointer);
        (tuplesPointer);
    }

    function testConsumeSentinelTuplesOddSentinel(uint256[] memory stack, Sentinel sentinel, uint8 sentinelIndex)
        public
    {
        for (uint256 i = 0; i < stack.length; i++) {
            //slither-disable-next-line calls-loop
            vm.assume(stack[i] != Sentinel.unwrap(sentinel));
        }
        vm.assume(sentinelIndex < stack.length);
        // UNalign the sentinel with clean tuples.
        vm.assume((stack.length - (sentinelIndex + 1)) % 2 == 1);

        stack[sentinelIndex] = Sentinel.unwrap(sentinel);

        vm.expectRevert(abi.encodeWithSelector(MissingSentinel.selector, sentinel));
        (Pointer sentinelPointer, Pointer tuplesPointer) =
            stack.dataPointer().consumeSentinelTuples(stack.endPointer(), sentinel, 2);
        (sentinelPointer);
        (tuplesPointer);
    }

    function testConsumeSentinelTuplesUnderflowError(Pointer lower, Pointer upper, Sentinel sentinel, uint256 n)
        public
    {
        // If the sentinel is easy to collide with then it might just match and
        // not underflow, which defeats the purpose of the test.
        vm.assume(Sentinel.unwrap(sentinel) > type(uint128).max);
        vm.assume(Pointer.unwrap(lower) < n);
        vm.assume(Pointer.unwrap(upper) > Pointer.unwrap(lower));

        // Underflow will revert because it will run out of gas attempting to
        // loop over infinity.
        vm.expectRevert();
        (Pointer sentinelPointer, Pointer tuplesPointer) = lower.consumeSentinelTuples(upper, sentinel, n);
        (sentinelPointer);
        (tuplesPointer);
    }

    function testConsumeSentinelTuplesInitialStateUnderflowError(Pointer lower, Pointer upper, Sentinel sentinel)
        public
    {
        vm.assume(Pointer.unwrap(lower) >= 0x80);
        vm.assume(Pointer.unwrap(upper) < Pointer.unwrap(lower));

        vm.expectRevert(abi.encodeWithSelector(InitialStateUnderflow.selector, lower, upper));
        (Pointer sentinelPointer, Pointer tuplesPointer) = lower.consumeSentinelTuples(upper, sentinel, 2);
        (sentinelPointer);
        (tuplesPointer);
    }

    function testConsumeSentinelTuplesEmpty(Sentinel sentinel) public {
        Pointer lower;
        assembly ("memory-safe") {
            lower := mload(0x40)
            mstore(lower, sentinel)
        }

        vm.expectRevert(abi.encodeWithSelector(MissingSentinel.selector, sentinel));
        //slither-disable-next-line similar-names
        (Pointer sentinelPointer0, Pointer tuplesPointer0) = lower.consumeSentinelTuples(lower, sentinel, 2);
        (sentinelPointer0);
        (tuplesPointer0);

        //slither-disable-next-line similar-names
        (Pointer sentinelPointer1, Pointer tuplesPointer1) =
            lower.consumeSentinelTuples(lower.unsafeAddWord(), sentinel, 2);
        (sentinelPointer1);
        (tuplesPointer1);
        assertEq(Pointer.unwrap(sentinelPointer1), Pointer.unwrap(lower));
        assertEq(tuplesPointer1.unsafeReadWord(), 0);
    }

    function testConsumeSentinelTuplesGas0() public pure {
        Pointer lower;
        Pointer upper;
        Sentinel sentinel = Sentinel.wrap(50);
        assembly ("memory-safe") {
            lower := mload(0x40)
            upper := add(lower, 0x20)
            mstore(lower, sentinel)
        }
        (Pointer sentinelPointer, Pointer tuplesPointer) = lower.consumeSentinelTuples(upper, sentinel, 2);
        (sentinelPointer);
        (tuplesPointer);
    }

    function testConsumeSentinelTuplesGas1() public pure {
        Pointer lower;
        Pointer upper;
        Sentinel sentinel = Sentinel.wrap(50);
        assembly ("memory-safe") {
            lower := mload(0x40)
            upper := add(lower, 0x60)
            mstore(lower, sentinel)
        }
        (Pointer sentinelPointer, Pointer tuplesPointer) = lower.consumeSentinelTuples(upper, sentinel, 2);
        (sentinelPointer);
        (tuplesPointer);
    }

    function testConsumeSentinelTuplesGas2() public pure {
        Pointer lower;
        Pointer upper;
        Sentinel sentinel = Sentinel.wrap(50);
        assembly ("memory-safe") {
            lower := mload(0x40)
            upper := add(lower, 0xa0)
            mstore(lower, sentinel)
        }
        (Pointer sentinelPointer, Pointer tuplesPointer) = lower.consumeSentinelTuples(upper, sentinel, 2);
        (sentinelPointer);
        (tuplesPointer);
    }

    function testConsumeSentinelTuplesGas3() public pure {
        Pointer lower;
        Pointer upper;
        Sentinel sentinel = Sentinel.wrap(50);
        assembly ("memory-safe") {
            lower := mload(0x40)
            upper := add(lower, 0xe0)
            mstore(lower, sentinel)
        }
        (Pointer sentinelPointer, Pointer tuplesPointer) = lower.consumeSentinelTuples(upper, sentinel, 2);
        (sentinelPointer);
        (tuplesPointer);
    }
}
