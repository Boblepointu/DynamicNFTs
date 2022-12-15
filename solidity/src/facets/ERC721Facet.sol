// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { LibDiamond } from  "../libraries/LibDiamond.sol";
import "./erc721/mocks/nf-token-metadata-enumerable-mock.sol";
import "./DiamondLoupeSubFacet.sol";

contract ERC721Facet is NFTokenMetadataEnumerableMock, DiamondLoupeSubFacet {
    /**
    * @dev The latest tokenId minted
    */
    uint256 private nextTokenId = 0;

    function lol() public pure returns (string memory) {
        return 'LOL';
    }

    function lollol() public pure returns (string memory) {
        return 'LOL';
    }

    /**
    * @dev Init supported interfaces
    */
    function initSupportedInterfaces() external onlyOwner
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[0x80ac58cd] = true; // ERC721
        ds.supportedInterfaces[0x780e9d63] = true; // ERC721Enumerable
        ds.supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
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
