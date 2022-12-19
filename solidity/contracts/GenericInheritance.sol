// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./facets/erc721/tokens/erc721.sol";
import "./facets/erc721/tokens/erc721-enumerable.sol";
import "./facets/erc721/tokens/erc721-metadata.sol";
import "./interfaces/IERC165.sol";
import "./interfaces/IERC173.sol";
import "./facets/DiamondLoupeSubFacet.sol";
import "./interfaces/IERC2981.sol";
import { LibDiamond } from  "./libraries/LibDiamond.sol";

contract GenericInheritance is DiamondLoupeSubFacet {
    
    event Received(address, uint);

    event Sent(address, uint);

    /**
    * @dev Init supported interfaces
    */
    function initSupportedInterfaces() external onlyOwner
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(ERC721).interfaceId] = true; // ERC721
        ds.supportedInterfaces[type(ERC721Enumerable).interfaceId] = true; // ERC721Enumerable
        ds.supportedInterfaces[type(ERC721Metadata).interfaceId] = true; // ERC721Metadata
        ds.supportedInterfaces[type(IERC165).interfaceId] = true; // ERC165 SupportInterface
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true; // EIP2535 DiamondLoup
        ds.supportedInterfaces[type(IERC173).interfaceId] = true; // ERC173 Ownable
        ds.supportedInterfaces[type(IERC2981).interfaceId] = true; // ERC2981 Royalties
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true; // EIP2535 DiamondLoup
    }

    /**
    * @dev Transfer ownership of the diamond
    */
    function transferOwnership(address _newOwner) external onlyOwner {
        LibDiamond.setContractOwner(_newOwner);
    }

    /**
    * @dev Modifier to restrict access to any function to only the Diamond owner
    */
    modifier onlyOwner()
    {
        require(msg.sender == LibDiamond.contractOwner(), LibDiamond.NOT_CURRENT_OWNER);
        _;
    }
}