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

    function consumeSentinelTuple2(Pointer lower, Pointer upper, Sentinel sentinel)
        internal
        pure
        returns (Pointer sentinelPointer, uint256[2][] memory tuples)
    {
        unchecked {
            // Can't consume memory reserved by Solidity. Prevents underflow.
            if (Pointer.unwrap(lower) < 0x80) revert ReservedPointer(lower);
            // Upper must not be less than lower.
            if (Pointer.unwrap(upper) < Pointer.unwrap(lower)) revert InitialStateUnderflow(lower, upper);

            assembly ("memory-safe") {
                tuples := mload(0x40)
                for {
                    let cursor := upper
                    let tuplesCursor := add(tuples, 0x20)
                } gt(cursor, lower) {
                    cursor := sub(cursor, 0x40)
                    // Write the reference to the tuple
                    mstore(tuplesCursor, cursor)
                    tuplesCursor := add(tuplesCursor, 0x20)
                } {
                    let potentialSentinelPointer := sub(cursor, 0x20)
                    if eq(mload(potentialSentinelPointer), sentinel) {
                        sentinelPointer := potentialSentinelPointer
                        // Store tuples length.
                        mstore(tuples, sub(div(sub(tuplesCursor, tuples), 0x20), 1))
                        // Update allocated memory pointer past the tuples.
                        mstore(0x40, tuplesCursor)
                        break
                    }
                }
            }

            if (Pointer.unwrap(sentinelPointer) == 0) {
                revert MissingSentinel(sentinel);
            }
        }
    }

    /// Given two stack pointers that bound a stack build an array of all values
    /// above the given sentinel value. The sentinel will be _replaced_ by the
    /// length of the array, allowing for efficient construction of a valid
    /// `uint256[]` without additional allocation or copying in memory. As the
    /// returned value is a `uint256[]` it can be treated as a substack and the
    /// same (or different) sentinel can be consumed many times to build many
    /// arrays from the main stack.
    ///
    /// As the sentinel is mutated in place into a length it is NOT safe to call
    /// this in a context where the stack is expected to be immutable.
    ///
    /// The sentinel MUST be chosen to have a negligible chance of colliding with
    /// a real value in the array, otherwise an intended array item will be
    /// interpreted as a sentinel and the array will be split into two slices.
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
    /// @param stepSize Number of items to move over in the array per loop
    /// iteration. If the array has a known multiple of items it can be more
    /// efficient to find a sentinel moving in N-item increments rather than
    /// reading every item individually.
    function consumeSentinel(Pointer upper, Pointer lower, uint256 sentinel, uint256 stepSize)
        internal
        pure
        returns (Pointer, uint256[] memory)
    {
        // Disallowed or we hit infinite loop.
        if (stepSize == 0) revert ZeroStepSize();
        uint256[] memory array;
        assembly ("memory-safe") {
            // Underflow is not allowed and pointing at position 0 in memory is
            // corrupt behaviour anyway.
            if iszero(lower) { revert(0, 0) }
            let sentinelLocation := 0
            let length := 0
            let step := mul(stepSize, 0x20)
            for {
                upper := sub(upper, 0x20)
                let end := sub(lower, 0x20)
            } gt(upper, end) {
                upper := sub(upper, step)
                length := add(length, stepSize)
            } {
                if eq(sentinel, mload(upper)) {
                    sentinelLocation := upper
                    break
                }
            }
            // Sentinel MUST exist in the stack if consumer expects it to there.
            if iszero(sentinelLocation) { revert(0, 0) }
            mstore(sentinelLocation, length)
            array := sentinelLocation
        }
        return (upper, array);
    }

    /// Abstraction over `consumeSentinel` to build an array of solidity structs.
    /// Solidity won't exactly allow this due to its type system not supporting
    /// generics, so instead we return an array of references to struct data that
    /// can be assigned/cast to an array of structs easily with assembly. This
    /// is NOT intended to be a general purpose workhorse for this task, only
    /// structs of pointers to `uint256[]` values are supported.
    ///
    /// ```
    /// struct Foo {
    ///   uint256[] a;
    ///   uint256[] b;
    /// }
    ///
    /// (StackPointer stackPointer_, uint256[] memory refs_) = consumeStructs(...);
    /// Foo[] memory foo_;
    /// assembly ("memory-safe") {
    ///   mstore(foo_, refs_)
    /// }
    /// ```
    ///
    /// @param stackTop The top of the stack as per `consumeSentinel`.
    /// @param stackBottom The bottom of the stack as per `consumeSentinel`.
    /// @param sentinel The sentinel as per `consumeSentinel`.
    /// @param structSize The number of `uint256[]` fields on the struct.
    function consumeStructs(Pointer stackTop, Pointer stackBottom, uint256 sentinel, uint256 structSize)
        internal
        pure
        returns (Pointer, uint256[] memory)
    {
        (Pointer stackTopAfter, uint256[] memory tempArray) =
            stackTop.consumeSentinel(stackBottom, sentinel, structSize);
        uint256 structsLength = tempArray.length / structSize;
        uint256[] memory refs = new uint256[](structsLength);
        assembly ("memory-safe") {
            for {
                let refCursor := add(refs, 0x20)
                let refEnd := add(refCursor, mul(mload(refs), 0x20))
                let tempCursor := add(tempArray, 0x20)
                let tempStepSize := mul(structSize, 0x20)
            } lt(refCursor, refEnd) {
                refCursor := add(refCursor, 0x20)
                tempCursor := add(tempCursor, tempStepSize)
            } { mstore(refCursor, tempCursor) }
        }
        return (stackTopAfter, refs);
    }
}
