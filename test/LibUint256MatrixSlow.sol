// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library LibUint256MatrixSlow {
    function matrixFromSlow(uint256[] memory a) internal pure returns (uint256[][] memory) {
        uint256[][] memory matrix = new uint256[][](1);
        matrix[0] = a;
        return matrix;
    }

    function matrixFromSlow(uint256[] memory a, uint256[] memory b) internal pure returns (uint256[][] memory) {
        uint256[][] memory matrix = new uint256[][](2);
        matrix[0] = a;
        matrix[1] = b;
        return matrix;
    }

    function matrixFromSlow(uint256[] memory a, uint256[] memory b, uint256[] memory c)
        internal
        pure
        returns (uint256[][] memory)
    {
        uint256[][] memory matrix = new uint256[][](3);
        matrix[0] = a;
        matrix[1] = b;
        matrix[2] = c;
        return matrix;
    }
}
