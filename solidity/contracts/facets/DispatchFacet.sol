// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./DiamondLoupeSubFacet.sol";
import "./erc721/ownership/ownable.sol";
import "../GenericInheritance.sol";

contract DispatchFacet is GenericInheritance
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
        receiverOne = payable(_receiverOne);
        receiverTwo = payable(_receiverTwo);
    }

    event Received(address, uint);

    event Sent(address, uint);

    /**
    * @dev Receive ETH default handler.
    */
    receive() external payable {
        emit Received(msg.sender, msg.value);

        receiverOne.transfer(msg.value/2);
        emit Sent(receiverOne, msg.value/2);

        receiverTwo.transfer(msg.value/2);
        emit Sent(receiverTwo, msg.value/2);
    }
}