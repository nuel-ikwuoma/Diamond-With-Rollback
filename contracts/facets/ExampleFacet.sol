// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExampleFacet {

    uint256 one = 1;
    uint256 two = 2;

    /// @notice returns item in the first storage slot
    function func1() external pure returns(uint256) {
        return 1;
    }

    /// @notice returns item in the second storage slot
    function func2() external pure returns(uint256) {
        return 2;
    }
}