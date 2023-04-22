// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibMemCpy.sol";
import "../src/LibBytes.sol";
import "../src/LibPointer.sol";

contract LibMemCpyBytesTest is Test {
    using LibPointer for Pointer;
    using LibBytes for bytes;

    function testCopyFuzz(bytes memory source, uint256 suffix) public {
        bytes memory target = new bytes(source.length);
        uint256 end;
        assembly {
            end := add(add(target, 0x20), mload(target))
            mstore(0x40, add(end, 0x20))
            mstore(end, suffix)
        }
        LibMemCpy.unsafeCopyBytesTo(source.dataPointer(), target.dataPointer(), source.length);
        assertEq(source, target);
        uint256 suffixAfter;
        assembly {
            suffixAfter := mload(end)
        }
        assertEq(suffix, suffixAfter);
    }

    function testCopyMultiWordFuzz(bytes memory source, uint256 suffix) public {
        vm.assume(source.length > 0x20);
        testCopyFuzz(source, suffix);
    }

    function testCopyMaxSuffixFuzz(bytes memory source) public {
        testCopyFuzz(source, type(uint256).max);
    }

    function testCopySimple() public {
        testCopyFuzz(hex"010203", type(uint256).max);
    }

    // Uses somewhat circular logic to test that existing data in target cannot
    // corrupt copying from source somehow.
    function testCopyDirtyTargetFuzz(bytes memory source, bytes memory target) public {
        vm.assume(target.length >= source.length);
        bytes memory remainder = new bytes(target.length - source.length);
        LibMemCpy.unsafeCopyBytesTo(
            target.dataPointer().addBytes(source.length), remainder.dataPointer(), remainder.length
        );
        bytes memory remainderCopy = new bytes(remainder.length);
        LibMemCpy.unsafeCopyBytesTo(remainder.dataPointer(), remainderCopy.dataPointer(), remainder.length);

        LibMemCpy.unsafeCopyBytesTo(source.dataPointer(), target.dataPointer(), source.length);
        target.truncate(source.length);
        assertEq(source, target);
        assertEq(remainder, remainderCopy);
    }
}
