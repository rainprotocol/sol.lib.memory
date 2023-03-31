// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibPointer.sol";
import "../src/LibBytes.sol";

contract LibPointerTest is Test {
    using LibPointer for Pointer;
    using LibBytes for bytes;

    function testAsBytesRound(Pointer pointer_) public {
        assertEq(Pointer.unwrap(pointer_), Pointer.unwrap(pointer_.asBytes().asPointer()));
    }

    function testAddBytesFuzz(uint32 pointer_, uint32 n_) public {
        assertEq(uint256(pointer_) + uint256(n_), Pointer.unwrap(Pointer.wrap(pointer_).addBytes(n_)));
    }

    function testAddWordsFuzz(uint32 pointer_, uint32 n_) public {
        assertEq(uint256(pointer_) + uint256(n_) * 0x20, Pointer.unwrap(Pointer.wrap(pointer_).addWords(n_)));
    }

    function testAllocatedMemoryPointer(uint8 length_) public {
        vm.assume(length_ > 0);
        Pointer a_ = LibPointer.allocatedMemoryPointer();
        new uint256[](length_);
        Pointer b_ = LibPointer.allocatedMemoryPointer();
        assertEq(uint256(length_) * 0x20 + 0x20, Pointer.unwrap(b_) - Pointer.unwrap(a_));
    }
}
