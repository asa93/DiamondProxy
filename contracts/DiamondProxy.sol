pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract DiamondProxy is Ownable {
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }
    Facet[] facets;
    mapping(bytes4 => address) selectorTofacet;

    constructor() Ownable() {}

    /**
     * @dev Add new facet = implementation
     *
     */
    function addFacet(Facet memory _facet) external onlyOwner {
        //todo: need to check for duplicates
        facets.push(_facet);
    }

    function facet(uint256 _index) public view returns (Facet memory) {
        return facets[_index];
    }

    /**
     * @dev Allocate selector to a facet. selector = first 4 bytes of hash of function
     *
     */
    function addSelector(bytes4 selector, address _facet) external onlyOwner {
        selectorTofacet[selector] = _facet;
    }

    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal {
        // get facet from function selector
        address _facet = selectorTofacet[msg.sig];

        require(_facet != address(0), "selector does not match any facet");
        // Execute external function from facet using delegatecall and return any value.

        _delegate(_facet);
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal {}
}
