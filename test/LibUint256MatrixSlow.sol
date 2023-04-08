// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library LibUint256MatrixSlow {
    function matrixFromSlow(uint256[] memory a_) internal pure returns (uint256[][] memory) {
        uint256[][] memory matrix_ = new uint256[][](1);
        matrix_[0] = a_;
        return matrix_;
    }
}
