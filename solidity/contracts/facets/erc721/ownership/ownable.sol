// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../../../libraries/LibDiamond.sol";
import { IERC173 } from "../../../interfaces/IERC173.sol";

/**
 * @dev The contract has an owner address, and provides basic authorization control whitch
 * simplifies the implementation of user permissions. This contract is based on the source code at:
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable is IERC173
{
  /**
   * @dev Error constants.
   */
  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

  /**
   * @dev Current owner address.
   */
  address private _owner;

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner()
  {
    require(msg.sender == _owner, NOT_CURRENT_OWNER);
    _;
  }

  function transferOwnership(address _newOwner) external override {
      require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
      
      if(_owner == address(0)){
        _owner = _newOwner;
        LibDiamond.setContractOwner(_newOwner);
        emit OwnershipTransferred(_owner, _newOwner);
        return;
      }

      require(LibDiamond.contractOwner() == msg.sender, NOT_CURRENT_OWNER);

      LibDiamond.enforceIsContractOwner();

      _owner = _newOwner;
      
      LibDiamond.setContractOwner(_newOwner);

      emit OwnershipTransferred(_owner, _newOwner);
  }

  function owner() external view returns (address) {
      return LibDiamond.contractOwner();
  }
}
