// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library LibUint256Matrix {
    /// 2-dimensional analogue of `arrayFrom`. Takes a 1-dimensional array and
    /// coerces it to a 2-dimensional matrix where the first and only item in the
    /// matrix is the 1-dimensional array.
    /// @param a The 1-dimensional array to include in the matrix.
    /// @return matrix The 2-dimensional matrix containing `a`.
    function matrixFrom(uint256[] memory a) internal pure returns (uint256[][] memory matrix) {
        assembly ("memory-safe") {
            matrix := mload(0x40)
            mstore(0x40, add(matrix, 0x40))
            mstore(matrix, 1)
            mstore(add(matrix, 0x20), a)
        }
    }

    /// 2-dimensional analogue of `arrayFrom`. Takes 1-dimensional arrays and
    /// coerces them to a 2-dimensional matrix where items in the matrix are the
    /// 1-dimensional arrays.
    /// @param a The 1-dimensional array to include in the matrix.
    /// @param b Second 1-dimensional array to include in the matrix.
    /// @return matrix The 2-dimensional matrix containing `a` and `b`.
    function matrixFrom(uint256[] memory a, uint256[] memory b) internal pure returns (uint256[][] memory matrix) {
        assembly ("memory-safe") {
            matrix := mload(0x40)
            mstore(0x40, add(matrix, 0x60))
            mstore(matrix, 2)
            mstore(add(matrix, 0x20), a)
            mstore(add(matrix, 0x40), b)
        }
        return matrix;
    }

    /// 2-dimensional analogue of `arrayFrom`. Takes 1-dimensional arrays and
    /// coerces them to a 2-dimensional matrix where items in the matrix are the
    /// 1-dimensional arrays.
    /// @param a The 1-dimensional array to include in the matrix.
    /// @param b Second 1-dimensional array to include in the matrix.
    /// @param c Third 1-dimensional array to include in the matrix.
    /// @return matrix The 2-dimensional matrix containing `a`, `b` and `c`.
    function matrixFrom(uint256[] memory a, uint256[] memory b, uint256[] memory c)
        internal
        pure
        returns (uint256[][] memory matrix)
    {
        assembly ("memory-safe") {
            matrix := mload(0x40)
            mstore(0x40, add(matrix, 0x80))
            mstore(matrix, 3)
            mstore(add(matrix, 0x20), a)
            mstore(add(matrix, 0x40), b)
            mstore(add(matrix, 0x60), c)
        }
        return matrix;
    }
}
