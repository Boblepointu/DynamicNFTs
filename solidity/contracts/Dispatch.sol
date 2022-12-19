// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./facets/DiamondLoupeSubFacet.sol";
import "./facets/erc721/ownership/ownable.sol";
import "./GenericInheritance.sol";
import { LibDiamond } from  "./libraries/LibDiamond.sol";

contract Dispatch is GenericInheritance
{
    /**
    * @dev The first address to transfer 50% to.
    */
    address payable receiverOne;

    /**
    * @dev The second address to transfer 50% to.
    */
    address payable receiverTwo;

    /**
    * @dev Set dispatch contract
    * @param _receiverOne The first address to transfer 50% to.
    * @param _receiverTwo The second address to transfer 50% to.
    */
    function setReceivers(address _receiverOne, address _receiverTwo) external onlyOwner
    {
        LibDiamond.setReceivers(_receiverOne, _receiverTwo);
    }

    /**
    * @dev Receive ETH default handler.
    */
    receive() external payable {
        emit Received(msg.sender, msg.value);

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.receiverOne.transfer(msg.value/2);
        emit Sent(ds.receiverOne, msg.value/2);

        ds.receiverTwo.transfer(msg.value/2);
        emit Sent(ds.receiverTwo, msg.value/2);
    }
}