// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract DiamondCutFacet is IDiamondCut {
    error NoRollBackAction();
    
    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }

    /// @notice Rollback the last action to the diamond
    function rollback() external override {
        // enforce is contract owner
        LibDiamond.enforceIsContractOwner();
        // LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.RollBackCuts[] storage rollbackCuts = LibDiamond.diamondStorage().rollbackCuts;
        uint256 rollbackCutsLength = rollbackCuts.length;
        if(rollbackCutsLength == 0) {
            revert NoRollBackAction();
        }
        LibDiamond.RollBackCuts memory rollbackCut = rollbackCuts[rollbackCutsLength - 1];
        // remove last rollback action
        rollbackCuts.pop();
        uint256 cutLength = rollbackCut.facetAddress.length;
        IDiamondCut.FacetCut[] memory facetCut = new IDiamondCut.FacetCut[](
            cutLength
        );
        for (uint i = 0; i < cutLength; ++i) {
            bytes4[] memory rollbackSelector = new bytes4[](1);
            rollbackSelector[0] = rollbackCut.functionSelectors[i];

            facetCut[i] = IDiamondCut.FacetCut(
                rollbackCut.facetAddress[i],
                rollbackCut.action,
                rollbackSelector
            );
        }
        LibDiamond.diamondCut(
            facetCut,
            LibDiamond.ROLLBACK_ADDRESS,
            ""
        );
    }
}
