// SPDX-License-Identifier: CAL
pragma solidity ^0.8.15;

import "./LibUint256Array.sol";
import "./LibMemory.sol";
import "./LibMemCpy.sol";

/// Thrown when the length of an array as the result of an applied function does
/// not match expectations.
error UnexpectedResultLength(uint256 expectedLength, uint256 actualLength);

/// @title LibStackPointer
/// @notice A stack `Pointer` is still just a pointer to some memory, but we are
/// going to treat it like it is pointing to a stack data structure. That means
/// it can move "up" and "down" (increment and decrement) by `uint256` (32 bytes)
/// increments. Structurally a stack is a `uint256[]` but we can save a lot of
/// gas vs. default Solidity handling of array indexes by using assembly to
/// bypass runtime bounds checks on every read and write. Of course, this means
/// the caller is responsible for ensuring the stack reads and write are not out
/// of bounds.
///
/// The pointer to the bottom of a stack points at the 0th item, NOT the length
/// of the implied `uint256[]` and the top of a stack points AFTER the last item.
/// e.g. consider a `uint256[]` in memory with values `3 A B C` and assume this
/// starts at position `0` in memory, i.e. `0` points to value `3` for the
/// array length. In this case the stack bottom would be `Pointer.wrap(0x20)`
/// (32 bytes above 0, past the length) and the stack top would be
/// `StackPointer.wrap(0x80)` (96 bytes above the stack bottom).
///
/// Most of the functions in this library are equivalent to each other via
/// composition, i.e. everything could be achieved with just `up`, `down`,
/// `pop`, `push`, `peek`. The reason there is so much overloaded/duplicated
/// logic is that the Solidity compiler seems to fail at inlining equivalent
/// logic quite a lot. Perhaps once the IR compilation of Solidity is better
/// supported by tooling etc. we could remove a lot of this duplication as the
/// compiler itself would handle the optimisations.
library LibStackPointer {
    using LibStackPointer for Pointer;
    using LibStackPointer for uint256[];
    using LibStackPointer for bytes;
    using LibUint256Array for uint256[];
    using LibMemory for uint256;

    /// Read the word immediately below the given stack pointer.
    ///
    /// Treats the given pointer as a pointer to the top of the stack, so `peek`
    /// reads the word below the pointer.
    ///
    /// https://en.wikipedia.org/wiki/Peek_(data_type_operation)
    ///
    /// The caller MUST ensure this read is not out of bounds, e.g. a `peek` to
    /// `0` will underflow (and exhaust gas attempting to read).
    ///
    /// @param pointer Pointer to the top of the stack to read below.
    /// @return word The word that was read.
    function peek(Pointer pointer) internal pure returns (uint256 word) {
        assembly ("memory-safe") {
            word := mload(sub(pointer, 0x20))
        }
    }

    /// Peeks 2 words from the top of the stack.
    ///
    /// Same as `peek` but returns 2 words instead of 1.
    ///
    /// @param pointer The stack top to peek below.
    /// @return lower The lower of the two words read.
    /// @return upper The upper of the two words read.
    function peek2(Pointer pointer) internal pure returns (uint256 lower, uint256 upper) {
        assembly ("memory-safe") {
            lower := mload(sub(pointer, 0x40))
            upper := mload(sub(pointer, 0x20))
        }
    }

    /// Pops the word from the top of the stack.
    ///
    /// Treats the given pointer as a pointer to the top of the stack, so `pop`
    /// reads the word below the pointer. The popped pointer is returned
    /// alongside the read word.
    ///
    /// https://en.wikipedia.org/wiki/Stack_(abstract_data_type)
    ///
    /// @param pointer Pointer to the top of the stack to read below.
    /// @return pointerAfter Pointer after the pop.
    /// @return word The word that was read.
    function pop(Pointer pointer) internal pure returns (Pointer pointerAfter, uint256 word) {
        assembly ("memory-safe") {
            pointerAfter := sub(pointer, 0x20)
            word := mload(pointer)
        }
    }

    /// Pushes a word to the top of the stack.
    ///
    /// Treats the given pointer as a pointer to the top of the stack, so `push`
    /// writes a word at the pointer. The pushed pointer is returned.
    ///
    /// https://en.wikipedia.org/wiki/Stack_(abstract_data_type)
    ///
    /// @param pointer The stack pointer to write at.
    /// @param word The value to write.
    /// @return The stack pointer above where `word` was written to.
    function push(Pointer pointer, uint256 word) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            mstore(pointer, word)
            pointer := add(pointer, 0x20)
        }
        return pointer;
    }

    /// Push 8 words to the top of the stack.
    ///
    /// Same as `push` 8x for 8 words.
    ///
    /// @param pointer The stack pointer to write at.
    /// @param a The first value to write.
    /// @param b The second value to write.
    /// @param c The third value to write.
    /// @param d The fourth value to write.
    /// @param e The fifth value to write.
    /// @param f The sixth value to write.
    /// @param g The seventh value to write.
    /// @param h The eighth value to write.
    /// @return The stack pointer above where `h` was written.
    function push(
        Pointer pointer,
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d,
        uint256 e,
        uint256 f,
        uint256 g,
        uint256 h
    ) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            mstore(pointer, a)
            mstore(add(pointer, 0x20), b)
            mstore(add(pointer, 0x40), c)
            mstore(add(pointer, 0x60), d)
            mstore(add(pointer, 0x80), e)
            mstore(add(pointer, 0xA0), f)
            mstore(add(pointer, 0xC0), g)
            mstore(add(pointer, 0xE0), h)
            pointer := add(pointer, 0x100)
        }
        return pointer;
    }

    /// Returns `length` values from the stack as an array without allocating
    /// new memory. As arrays always start with their length, this requires
    /// writing the length value to the stack below the array values. The value
    /// that is overwritten in the process is also returned so that data is not
    /// lost. For example, imagine a stack `[ A B C D ]` and we list 2 values.
    /// This will write the stack to look like `[ A 2 C D ]` and return both `B`
    /// and a pointer to `2` represented as a `uint256[]`.
    /// The returned array is ONLY valid for as long as the stack DOES NOT move
    /// back into its memory. As soon as the stack moves up again and writes into
    /// the array it will be corrupt. The caller MUST ensure that it does not
    /// read from the returned array after it has been corrupted by subsequent
    /// stack writes.
    /// @param pointer The stack pointer to read the values below into an
    /// array.
    /// @param length The number of values to include in the returned array.
    /// @return head The value that was overwritten with the length.
    /// @return tail The array constructed from the stack memory.
    function list(Pointer pointer, uint256 length) internal pure returns (uint256 head, uint256[] memory tail) {
        assembly ("memory-safe") {
            tail := sub(pointer, add(0x20, mul(length, 0x20)))
            head := mload(tail)
            mstore(tail, length)
        }
    }

    /// Convert two stack pointer values to a single stack index. A stack index
    /// is the distance in 32 byte increments between two stack pointers. The
    /// calculations assumes the two stack pointers are aligned. The caller MUST
    /// ensure the alignment of both values. The calculation is unchecked and MAY
    /// underflow. The caller MUST ensure that the stack top is always above the
    /// stack bottom.
    /// @param stackBottom The lower of the two values.
    /// @param stackTop The higher of the two values.
    /// @return The stack index as 32 byte distance between the top and bottom.
    function toIndex(Pointer stackBottom, Pointer stackTop) internal pure returns (uint256) {
        unchecked {
            return (Pointer.unwrap(stackTop) - Pointer.unwrap(stackBottom)) / 0x20;
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
    /// @param stackTop Pointer to the top of the stack.
    /// @param stackBottom Pointer to the bottom of the stack.
    /// @param sentinel The value to expect as the sentinel. MUST be present in
    /// the stack or `consumeSentinel` will revert. MUST NOT collide with valid
    /// stack items (or be cryptographically improbable to do so).
    /// @param stepSize Number of items to move over in the array per loop
    /// iteration. If the array has a known multiple of items it can be more
    /// efficient to find a sentinel moving in N-item increments rather than
    /// reading every item individually.
    function consumeSentinel(Pointer stackTop, Pointer stackBottom, uint256 sentinel, uint256 stepSize)
        internal
        pure
        returns (Pointer, uint256[] memory)
    {
        uint256[] memory array;
        assembly ("memory-safe") {
            // Underflow is not allowed and pointing at position 0 in memory is
            // corrupt behaviour anyway.
            if iszero(stackBottom) { revert(0, 0) }
            let sentinelLocation := 0
            let length := 0
            let step := mul(stepSize, 0x20)
            for {
                stackTop := sub(stackTop, 0x20)
                let end := sub(stackBottom, 0x20)
            } gt(stackTop, end) {
                stackTop := sub(stackTop, step)
                length := add(length, stepSize)
            } {
                if eq(sentinel, mload(stackTop)) {
                    sentinelLocation := stackTop
                    break
                }
            }
            // Sentinel MUST exist in the stack if consumer expects it to there.
            if iszero(sentinelLocation) { revert(0, 0) }
            mstore(sentinelLocation, length)
            array := sentinelLocation
        }
        return (stackTop, array);
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
