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
    * @dev Exclusive contract pass
    */
    address private exclusiveContract;


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
    * @dev Set exclusive contract address.
    */
    function setExclusiveContract(
        address _exclusiveContract
    ) external onlyOwner
    {
        exclusiveContract = _exclusiveContract;
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
    * @dev Allow anyone owning a specific NFT in another collection to mint 
    * @param _to The address that will own the minted NFT.
    * @param _uri String representing RFC 3986 URI.
    */
    function payableExclusiveMint(
        uint256 _exclusiveTokenId,
        address _to
    ) external payable
    {
        require(ERC721(exclusiveContract).ownerOf(_exclusiveTokenId) == msg.sender, 'You do not own the required NFT to mint in exclusive mode. Wait 20min to buy some of this collection.');
        require(msg.value == 500000000000000, 'You did not send enough eth to mint ! Price is 0.0005ETH');
        require(this.totalSupply() <= 15, 'No luck ! This collection has already been fully minted !');

        payable(this).transfer(msg.value);

        super._mint(_to, nextTokenId);
        super._setTokenUri(nextTokenId, snowflakeUri);
        nextTokenId = nextTokenId + 1;
    }

    /**
    * @dev Allow anyone to mint 
    * @param _to The address that will own the minted NFT.
    * @param _uri String representing RFC 3986 URI.
    */
    function payableExclusiveMint(
        uint256 _exclusiveTokenId,
        address _to
    ) external payable
    {
        require(msg.value == 1000000000000000, 'You did not send enough eth to mint ! Price is 0.001ETH');
        require(this.totalSupply() <= 15, 'No luck ! This collection has already been fully minted !');

        payable(this).transfer(msg.value);

        super._mint(_to, nextTokenId);
        super._setTokenUri(nextTokenId, snowflakeUri);
        nextTokenId = nextTokenId + 1;
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