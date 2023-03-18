// SPDX-License-Identifier: CAL
pragma solidity ^0.8.16;

import "./LibPointer.sol";

/// Thrown when asked to truncate data to a longer length.
/// @param length Actual bytes length.
/// @param truncate Attempted truncation length.
error TruncateError(uint256 length, uint256 truncate);

/// @title LibBytes
/// @notice Tools for working directly with memory in a Solidity compatible way.
library LibBytes {
    function truncate(bytes memory bytes_, uint256 length_) internal pure {
        if (bytes_.length < length_) {
            revert TruncateError(bytes_.length, length_);
        }
        assembly ("memory-safe") {
            mstore(bytes_, length_)
        }
    }

    /// Pointer to the data of a bytes array NOT the length prefix.
    function dataPointer(bytes memory data_) internal pure returns (Pointer pointer_) {
        assembly ("memory-safe") {
            pointer_ := add(data_, 0x20)
        }
    }

    function asPointer(bytes memory bytes_) internal pure returns (Pointer pointer_) {
        assembly ("memory-safe") {
            pointer_ := bytes_
        }
    }
}
