// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/interfaces/IExample.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/ExampleFacet.sol";
import "../contracts/Diamond.sol";
import "forge-std/Test.sol";

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    ExampleFacet exampleF;

    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        exampleF = new ExampleFacet();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(exampleF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("ExampleFacet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        // DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function testCallFunction() public {
        uint256 one = IExample(address(diamond)).func1();
        uint256 two = IExample(address(diamond)).func2();
        assertEq(one, 1);
        assertEq(two, 2);
    }

    function testRollBack() public {
        IDiamondCut(address(diamond)).rollback();
        vm.expectRevert("Diamond: Function does not exist");
        IExample(address(diamond)).func1();
        vm.expectRevert("Diamond: Function does not exist");
        IExample(address(diamond)).func2();
    }

    function testLastCut() public {
        for(uint i; i < 3; i++) {
            IDiamondCut(address(diamond)).rollback();
        }

        // 0x0997a2cf is sig for error NoRollBackAction().
        // cut to methods added in Diamond constructor should fail.
        vm.expectRevert(0x0997a2cf);
        IDiamondCut(address(diamond)).rollback();
    }

    function generateSelectors(string memory _facetName)
        internal
        returns (bytes4[] memory selectors)
    {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}

    function rollback() external override {}
}
