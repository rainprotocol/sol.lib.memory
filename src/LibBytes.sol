// SPDX-License-Identifier: CAL
pragma solidity ^0.8.15;

type Cursor is uint256;

library LibBytes {
    function unsafeCopyBytesTo(Cursor inputCursor_, Cursor outputCursor_, uint256 remaining_) internal pure {
        assembly ("memory-safe") {
            for {} iszero(lt(remaining_, 0x20)) {
                remaining_ := sub(remaining_, 0x20)
                inputCursor_ := add(inputCursor_, 0x20)
                outputCursor_ := add(outputCursor_, 0x20)
            } { mstore(outputCursor_, mload(inputCursor_)) }

            if gt(remaining_, 0) {
                // Slither false positive here due to the variable shift of a
                // constant value to create a mask.
                let mask_ := shr(mul(remaining_, 8), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                // preserve existing bytes
                mstore(
                    outputCursor_,
                    or(
                        // input
                        and(mload(inputCursor_), not(mask_)),
                        and(mload(outputCursor_), mask_)
                    )
                )
            }
        }
    }

    function cursor(bytes memory data_) internal pure returns (Cursor cursor_) {
        assembly ("memory-safe") {
            cursor_ := add(data_, 0x20)
        }
    }
}
