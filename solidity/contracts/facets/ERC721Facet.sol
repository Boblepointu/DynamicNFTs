// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { LibDiamond } from  "../libraries/LibDiamond.sol";
import "./erc721/mocks/nf-token-metadata-enumerable-mock.sol";
import "./DiamondLoupeSubFacet.sol";
import "./erc721/tokens/erc721.sol";
import "./erc721/tokens/erc721-enumerable.sol";
import "../interfaces/IERC165.sol";
import "../interfaces/IERC173.sol";
import "../chainlink/Weather.sol";

contract ERC721Facet is 
    NFTokenMetadataEnumerableMock, 
    DiamondLoupeSubFacet,
    Weather
{
    /**
    * @dev The next tokenId to be minted
    */
    uint256 private nextTokenId = 0;

    /**
    * @dev The tokenUri of the snowflake
    */
    string private snowflakeUri;

    /**
    * @dev The tokenUri of the cloud
    */  
    string private cloudUri;

    /**
    * @dev The tokenUri of the sun
    */      
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
        super._setTokenUri(nextTokenId, snowflakeUri);
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

    /**
    * @dev A distinct URI (RFC 3986) for a given NFT.
    * @param _tokenId Id for which we want uri.
    * @return URI of _tokenId.
    */
    function tokenURI(
        uint256 _tokenId
    )
        external
        override
        view
        validNFToken(_tokenId)
        returns (string memory)
    {
        if(avgTemp <= 0){
            return snowflakeUri;
        }
        else if(avgTemp > 0 && avgTemp <= 2){
            return cloudUri;
        }
   
        return sunUri;
    }

    /**
    * @dev Override initChainLinkClient in Weather contract to control access.
    * @param _link The link contract address.
    * @param _oracle The oracle contract address.
    * @param _serverUrl The HTTP url to get the data.
    * @param _fee The fee dedicated to the task.
    */
    function initChainLinkClient(        
        address _link,
        address _oracle,
        string calldata _serverUrl,
        uint256 _fee
    ) external onlyOwner
    {
        _initChainLinkClient(_link, _oracle, _serverUrl, _fee);
    }

    /**
    * @dev Convert a string to byte32.
    * @param source The string to convert.
    */
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
        return 0x0;
        }

        assembly { // solhint-disable-line no-inline-assembly
        result := mload(add(source, 32))
        }
    }
}