// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library LibUint256Matrix {
    /// 2-dimensional analogue of `arrayFrom`. Takes a 1-dimensional array and
    /// coerces it to a 2-dimensional matrix where the first and only item in the
    /// matrix is the 1-dimensional array.
    /// @param a_ The 1-dimensional array to coerce.
    /// @return matrix_ The 2-dimensional matrix containing `a_`.
    function matrixFrom(uint256[] memory a_) internal pure returns (uint256[][] memory matrix_) {
        assembly ("memory-safe") {
            matrix_ := mload(0x40)
            mstore(0x40, add(matrix_, 0x40))
            mstore(matrix_, 1)
            mstore(add(matrix_, 0x20), a_)
        }
    }

    /// 2-dimensional analogue of `arrayFrom`. Takes 1-dimensional arrays and
    /// coerces them to a 2-dimensional matrix where items in the matrix are the
    /// 1-dimensional arrays.
    /// @param a_ First 1-dimensional array to coerce.
    /// @param b_ Second 1-dimensional array to coerce.
    /// @return matrix_ The 2-dimensional matrix containing `a_` and `b_`.
    function matrixFrom(uint256[] memory a_, uint256[] memory b_) internal pure returns (uint256[][] memory matrix_) {
        assembly ("memory-safe") {
            matrix_ := mload(0x40)
            mstore(0x40, add(matrix_, 0x60))
            mstore(matrix_, 2)
            mstore(add(matrix_, 0x20), a_)
            mstore(add(matrix_, 0x40), b_)
        }
        return matrix_;
    }
}
