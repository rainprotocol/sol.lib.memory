// SPDX-License-Identifier: CAL
pragma solidity ^0.8.16;

library LibUint256ArraySlow {
    function arrayFromSlow(uint256 a_) internal pure returns (uint256[] memory) {
        uint256[] memory array_ = new uint256[](1);
        array_[0] = a_;
        return array_;
    }

    function arrayFromSlow(uint256 a_, uint256 b_) internal pure returns (uint256[] memory) {
        uint256[] memory array_ = new uint256[](2);
        array_[0] = a_;
        array_[1] = b_;
        return array_;
    }

    function arrayFromSlow(uint256 a_, uint256 b_, uint256 c_) internal pure returns (uint256[] memory) {
        uint256[] memory array_ = new uint256[](3);
        array_[0] = a_;
        array_[1] = b_;
        array_[2] = c_;
        return array_;
    }

    function arrayFromSlow(uint256 a_, uint256 b_, uint256 c_, uint256 d_) internal pure returns (uint256[] memory) {
        uint256[] memory array_ = new uint256[](4);
        array_[0] = a_;
        array_[1] = b_;
        array_[2] = c_;
        array_[3] = d_;
        return array_;
    }

    function arrayFromSlow(uint256 a_, uint256 b_, uint256 c_, uint256 d_, uint256 e_)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array_ = new uint256[](5);
        array_[0] = a_;
        array_[1] = b_;
        array_[2] = c_;
        array_[3] = d_;
        array_[4] = e_;
        return array_;
    }

    function arrayFromSlow(uint256 a_, uint256 b_, uint256 c_, uint256 d_, uint256 e_, uint256 f_)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array_ = new uint256[](6);
        array_[0] = a_;
        array_[1] = b_;
        array_[2] = c_;
        array_[3] = d_;
        array_[4] = e_;
        array_[5] = f_;
        return array_;
    }

    function arrayFromSlow(uint256 a_, uint256[] memory tail_) internal pure returns (uint256[] memory) {
        uint256[] memory array_ = new uint256[](tail_.length + 1);
        array_[0] = a_;
        for (uint256 i_ = 0; i_ < tail_.length; i_++) {
            array_[i_ + 1] = tail_[i_];
        }
        return array_;
    }

    function arrayFromSlow(uint256 a_, uint256 b_, uint256[] memory tail_) internal pure returns (uint256[] memory) {
        uint256[] memory array_ = new uint256[](tail_.length + 2);
        array_[0] = a_;
        array_[1] = b_;
        for (uint256 i_ = 0; i_ < tail_.length; i_++) {
            array_[i_ + 2] = tail_[i_];
        }
        return array_;
    }

    function matrixFromSlow(uint256[] memory a_) internal pure returns (uint256[][] memory) {
        uint256[][] memory matrix_ = new uint256[][](1);
        matrix_[0] = a_;
        return matrix_;
    }
}
