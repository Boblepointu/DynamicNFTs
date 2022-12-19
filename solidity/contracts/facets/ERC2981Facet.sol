// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./DiamondLoupeSubFacet.sol";
import "./erc721/ownership/ownable.sol";
import "../GenericInheritance.sol";

contract ERC2981Facet is 
    IERC2981,
    GenericInheritance
{
    /**
    * @dev The dispatch contract address
    */
    address payable dispatchContract;

    /**
    * @dev Set dispatch contract
    * @param _dispatchContract The contract where to send the funds, to be able to dispatch them.
    */
    function setDispatchContract(address _dispatchContract) external onlyOwner
    {
        dispatchContract = payable(_dispatchContract);
    }

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    ///  _tokenId - the NFT asset queried for royalty information
    /// @param _salePrice - the sale price of the NFT asset specified by _tokenId
    /// @return receiver - address of who should be sent the royalty payment
    /// @return royaltyAmount - the royalty payment amount for _salePrice
    function royaltyInfo(
        uint256 /*_tokenId*/,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    ){
        uint256 fivePercent = _salePrice / 20;
        return (dispatchContract, fivePercent);
    }

}