// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library LibUint256MatrixSlow {
    function matrixFromSlow(uint256[] memory a_) internal pure returns (uint256[][] memory) {
        uint256[][] memory matrix_ = new uint256[][](1);
        matrix_[0] = a_;
        return matrix_;
    }

    function matrixFromSlow(uint256[] memory a_, uint256[] memory b_) internal pure returns (uint256[][] memory) {
        uint256[][] memory matrix_ = new uint256[][](2);
        matrix_[0] = a_;
        matrix_[1] = b_;
        return matrix_;
    }
}
