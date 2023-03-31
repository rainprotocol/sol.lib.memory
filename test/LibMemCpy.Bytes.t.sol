// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibMemCpy.sol";
import "../src/LibBytes.sol";
import "../src/LibPointer.sol";

contract LibMemCpyBytesTest is Test {
    using LibPointer for Pointer;
    using LibBytes for bytes;

    function testCopyFuzz(bytes memory source_, uint256 suffix_) public {
        bytes memory target_ = new bytes(source_.length);
        uint256 end_;
        assembly {
            end_ := add(add(target_, 0x20), mload(target_))
            mstore(end_, suffix_)
        }
        LibMemCpy.unsafeCopyBytesTo(source_.dataPointer(), target_.dataPointer(), source_.length);
        assertEq(source_, target_);
        uint256 suffixAfter_;
        assembly {
            suffixAfter_ := mload(end_)
        }
        assertEq(suffix_, suffixAfter_);
    }

    function testCopyMultiWordFuzz(bytes memory source_, uint256 suffix_) public {
        vm.assume(source_.length > 0x20);
        testCopyFuzz(source_, suffix_);
    }

    function testCopyMaxSuffixFuzz(bytes memory source_) public {
        testCopyFuzz(source_, type(uint256).max);
    }

    function testCopySimple() public {
        testCopyFuzz(hex"010203", type(uint256).max);
    }

    // Uses somewhat circular logic to test that existing data in target cannot
    // corrupt copying from source somehow.
    function testCopyDirtyTargetFuzz(bytes memory source_, bytes memory target_) public {
        vm.assume(target_.length >= source_.length);
        bytes memory remainder_ = new bytes(target_.length - source_.length);
        LibMemCpy.unsafeCopyBytesTo(
            target_.dataPointer().addBytes(source_.length), remainder_.dataPointer(), remainder_.length
        );
        bytes memory remainderCopy_ = new bytes(remainder_.length);
        LibMemCpy.unsafeCopyBytesTo(remainder_.dataPointer(), remainderCopy_.dataPointer(), remainder_.length);

        LibMemCpy.unsafeCopyBytesTo(source_.dataPointer(), target_.dataPointer(), source_.length);
        target_.truncate(source_.length);
        assertEq(source_, target_);
        assertEq(remainder_, remainderCopy_);
    }
}
