// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./erc721/mocks/nf-token-metadata-enumerable-mock.sol";
import "./DiamondLoupeSubFacet.sol";

import "../chainlink/Weather.sol";
import "../interfaces/IERC721.sol";
import "../GenericInheritance.sol";

contract ERC721Facet is 
    NFTokenMetadataEnumerableMock,
    GenericInheritance
{
    /**
    * @dev The weather contract address
    */
    address weatherContract;

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
    * @dev The contractUri
    */
    string private contractUri;

    /**
    * @dev Init differents nft states, to link them to their metadata.
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
    * @dev Init weather contract address.
    */
    function setWeatherContract(
        address _weatherContract
    ) external onlyOwner
    {
        weatherContract = _weatherContract;
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
    * @dev Allows the current owner change the name and symbol of the contract.
    * @param _contractUri The contract metadata URI.
    */
    function setContractUri(
        string calldata _contractUri
    ) external onlyOwner
    {
        contractUri = _contractUri;
    }    

    /**
    * @dev A distinct URI for the contract (https://docs.opensea.io/docs/contract-level-metadata).
    * @return URI of the contract.
    */
    function contractURI() public view returns (string memory) {
        return contractUri;
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
        uint256 avgTemp = Weather(weatherContract).getAvgTemp();
        if(avgTemp <= 1000){
            return snowflakeUri;
        }
        else if(avgTemp > 1000 && avgTemp <= 1002){
            return cloudUri;
        }
   
        return sunUri;
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