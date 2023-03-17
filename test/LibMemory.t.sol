// SPDX-License-Identifier: CAL
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/LibMemory.sol";

contract LibBytesTest is Test {
    using LibMemory for bytes;
    using LibMemory for Pointer;

    function testCopyFuzz(bytes memory source_, uint256 suffix_) public {
        bytes memory target_ = new bytes(source_.length);
        uint256 end_;
        assembly {
            end_ := add(add(target_, 0x20), mload(target_))
            mstore(end_, suffix_)
        }
        LibMemory.unsafeCopyBytesTo(source_.dataPointer(), target_.dataPointer(), source_.length);
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

    function testTruncateFuzz(bytes memory data_, uint256 length_) public {
        vm.assume(data_.length >= length_);
        data_.truncate(length_);
        assertEq(data_.length, length_);
    }

    function testTruncateError(bytes memory data_, uint256 length_) public {
        vm.assume(data_.length < length_);
        vm.expectRevert(abi.encodeWithSelector(TruncateError.selector, data_.length, length_));
        data_.truncate(length_);
    }

    // Uses somewhat circular logic to test that existing data in target cannot
    // corrupt copying from source somehow.
    function testCopyDirtyTargetFuzz(bytes memory source_, bytes memory target_) public {
        vm.assume(target_.length >= source_.length);
        bytes memory remainder_ = new bytes(target_.length - source_.length);
        LibMemory.unsafeCopyBytesTo(
            target_.dataPointer().addBytes(source_.length), remainder_.dataPointer(), remainder_.length
        );
        bytes memory remainderCopy_ = new bytes(remainder_.length);
        LibMemory.unsafeCopyBytesTo(remainder_.dataPointer(), remainderCopy_.dataPointer(), remainder_.length);

        LibMemory.unsafeCopyBytesTo(source_.dataPointer(), target_.dataPointer(), source_.length);
        target_.truncate(source_.length);
        assertEq(source_, target_);
        assertEq(remainder_, remainderCopy_);
    }

    function testDataPointerFuzz(bytes memory data_) public {
        assertEq(Pointer.unwrap(data_.dataPointer()), Pointer.unwrap(data_.asPointer().addWords(1)));
    }

    function testAddBytesFuzz(uint32 pointer_, uint32 n_) public {
        assertEq(uint256(pointer_) + uint256(n_), Pointer.unwrap(Pointer.wrap(pointer_).addBytes(n_)));
    }

    function testAddWordsFuzz(uint32 pointer_, uint32 n_) public {
        assertEq(uint256(pointer_) + uint256(n_) * 0x20, Pointer.unwrap(Pointer.wrap(pointer_).addWords(n_)));
    }

    function testRoundBytesPointer(bytes memory data_) public {
        assertEq(data_, data_.asPointer().asBytes());
    }
}
