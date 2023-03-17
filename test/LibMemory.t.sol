// SPDX-License-Identifier: CAL
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/LibMemory.sol";

contract LibBytesTest is Test {
    using LibMemory for bytes;

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

    function testCopyMaxSuffixFuzz(bytes memory source_) public {
        testCopyFuzz(source_, type(uint256).max);
    }

    function testCopySimple() public {
        testCopyFuzz(hex"010203", type(uint256).max);
    }
}
