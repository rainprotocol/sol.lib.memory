// SPDX-License-Identifier: CAL
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/LibBytes.sol";

contract LibBytesTest is Test {
    function assertMemoryAlignment() internal {
        // Check alignment of memory after allocation.
        uint256 memPtr_;
        assembly ("memory-safe") {
            memPtr_ := mload(0x40)
        }
        assertEq(memPtr_ % 0x20, 0);
    }

    /// Solidity manages memory in the following way. There is a “free memory pointer” at position 0x40 in memory.
    /// If you want to allocate memory, use the memory starting from where this pointer points at and update it.
    /// **There is no guarantee that the memory has not been used before and thus you cannot assume that its contents are zero bytes.**
    function copyPastAllocatedMemory(bytes memory data_) internal pure {
        uint256 outputCursor_;
        uint256 inputCursor_;
        assembly {
            inputCursor_ := data_
            outputCursor_ := mload(0x40)
        }
        unsafeCopyBytesTo(inputCursor_, outputCursor_, data_.length);
    }

    function testCopyFuzz(bytes memory source_) public {
        bytes memory target_ = new bytes(source_.length);
        LibBytes.unsafeCopyBytesTo(source_.cursor(), target_.cursor(), source_.length);
        assertEq(source_, target_);
    }
}