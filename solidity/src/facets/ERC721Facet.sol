// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { LibDiamond } from  "../libraries/LibDiamond.sol";
import "./erc721/mocks/nf-token-metadata-enumerable-mock.sol";
import "./DiamondLoupeSubFacet.sol";
import "./erc721/tokens/erc721.sol";
import "./erc721/tokens/erc721-enumerable.sol";
import "../interfaces/IERC165.sol";
import "../interfaces/IERC173.sol";

contract ERC721Facet is NFTokenMetadataEnumerableMock, DiamondLoupeSubFacet {
    /**
    * @dev The latest tokenId minted
    */
    uint256 private nextTokenId = 0;
    string private snowflakeUri;
    string private cloudUri;
    string private sunUri;

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
    }

    /**
    * @dev Init differents nft states, to link them to their metadata
    */
    function initStateUris(
        string calldata _snowflakeUri, 
        string calldata _cloudUri, 
        string calldata _sunUri
    ) external onlyOwner
    {
        snowflakeUri = _snowflakeUri;
        cloudUri = _cloudUri;
        sunUri = _sunUri;
    }


    /**
    * @dev Allow the current owner to mint a new weather NFT.
    * @param _to The address that will own the minted NFT.
    */
    function mintWeather(
        address _to
    ) external onlyOwner
    {
        super._mint(_to, nextTokenId);
        super._setTokenUri(nextTokenId, 'ipfs://QmV1yioxmzw9U9YqqmRdkyTTRpNZTDdZ4Ckbk5XYtr8DdK');
        nextTokenId = nextTokenId + 1;
    }

    /**
    * @dev Allow the current owner to mint a new NFT with arbitrary tokenURI.
    * @param _to The address that will own the minted NFT.
    * @param _uri String representing RFC 3986 URI.
    */
    function mint(
        address _to,
        string calldata _uri
    ) external onlyOwner
    {
        super._mint(_to, nextTokenId);
        super._setTokenUri(nextTokenId, _uri);
        nextTokenId = nextTokenId + 1;
    }

    /**
    * @dev Allows the current owner change the name and symbol of the contract.
    * @param _name The new name to set for the contract.
    * @param _symbol The new symbol to set for the contract.
    */
    function setNameAndSymbol(
        string calldata _name,
        string calldata _symbol
    ) external onlyOwner
    {
        nftName = _name;
        nftSymbol = _symbol;
    }
}
