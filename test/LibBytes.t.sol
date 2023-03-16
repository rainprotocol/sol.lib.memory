// SPDX-License-Identifier: CAL
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/LibBytes.sol";

contract LibBytesTest is Test {
    using LibBytes for bytes;

    function testCopyFuzz(bytes memory source_) public {
        bytes memory target_ = new bytes(source_.length);
        LibBytes.unsafeCopyBytesTo(source_.cursor(), target_.cursor(), source_.length);
        assertEq(source_, target_);
    }
}