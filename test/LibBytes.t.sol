// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/LibBytes.sol";
import "../src/LibMemCpy.sol";

contract LibBytesTest is Test {
    using LibBytes for bytes;
    using LibPointer for Pointer;

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

    function testDataPointerFuzz(bytes memory data_) public {
        assertEq(Pointer.unwrap(data_.dataPointer()), Pointer.unwrap(data_.asPointer().addWords(1)));
    }

    function testRoundBytesPointer(bytes memory data_) public {
        assertEq(data_, data_.asPointer().asBytes());
    }
}
