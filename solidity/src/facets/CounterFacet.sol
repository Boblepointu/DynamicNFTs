// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract CounterFacet {
    uint256 public number;

    function getNumber() public view returns (uint256) {
        return number;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
