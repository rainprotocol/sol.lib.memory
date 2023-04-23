// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "./LibPointer.sol";

error ZeroStepSize();

error ReservedPointer(Pointer lower);
error InitialStateUnderflow(Pointer lower, Pointer upper);
error MissingSentinel(Sentinel sentinel);

type Sentinel is uint256;

library LibStackSentinel {
    using LibStackSentinel for Pointer;

    /// Given two stack pointers that bound a stack build an array of 2 item
    /// tuples above the given sentinel value. The sentinel will be skipped and
    /// a pointer below it returned alongside the tuples list.
    ///
    /// The tuples can be cast (via assembly) to 2-field structs.
    ///
    /// The caller MUST consider the region of memory consumed for the structs as
    /// mutated/truncated/deallocated and reallocated insitu to the tuples.
    ///
    /// The sentinel MUST be chosen to have a negligible chance of colliding with
    /// a real value in the array, otherwise an intended array item will be
    /// interpreted as a sentinel.
    ///
    /// If the sentinel is absent in the stack this WILL REVERT. The intent is
    /// to represent dynamic length arrays without forcing expression authors to
    /// calculate lengths on the stack. If the expression author wants to model
    /// an empty/optional/absent value they MAY provided a sentinel for a zero
    /// length array and the calling contract SHOULD handle this.
    ///
    /// @param upper Pointer to the top of the stack range.
    /// @param lower Pointer to the bottom of the stack range.
    /// @param sentinel The value to expect as the sentinel. MUST be present in
    /// the stack or `consumeSentinel` will revert. MUST NOT collide with valid
    /// stack items (or be cryptographically improbable to do so).
    function consumeSentinelTuple2(Pointer lower, Pointer upper, Sentinel sentinel)
        internal
        pure
        returns (Pointer sentinelPointer, uint256[2][] memory tuples)
    {
        // Can't consume memory reserved by Solidity. Prevents underflow.
        if (Pointer.unwrap(lower) < 0x80) revert ReservedPointer(lower);
        // Upper must not be less than lower.
        if (Pointer.unwrap(upper) < Pointer.unwrap(lower)) revert InitialStateUnderflow(lower, upper);

        // First pass to find the sentinel.
        assembly ("memory-safe") {
            for { let cursor := upper } gt(cursor, lower) { cursor := sub(cursor, 0x40) } {
                let potentialSentinelPointer := sub(cursor, 0x20)
                if eq(mload(potentialSentinelPointer), sentinel) { sentinelPointer := potentialSentinelPointer }
            }
        }

        if (Pointer.unwrap(sentinelPointer) == 0) {
            revert MissingSentinel(sentinel);
        }

        // Second pass to build references _in order_ from the sentinel back up
        // to upper.
        assembly ("memory-safe") {
            tuples := mload(0x40)
            let tuplesCursor := add(tuples, 0x20)
            for {
                let cursor := add(sentinelPointer, 0x20)
                let end := upper
            } lt(cursor, end) {
                tuplesCursor := add(tuplesCursor, 0x20)
                cursor := add(cursor, 0x40)
            } {
                // Write the reference to the tuple
                mstore(tuplesCursor, cursor)
            }
            // Update allocated memory pointer past the tuples.
            mstore(0x40, tuplesCursor)
            // Store tuples length.
            mstore(tuples, sub(div(sub(tuplesCursor, tuples), 0x20), 1))
        }
    }
}
