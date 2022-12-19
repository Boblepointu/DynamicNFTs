// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

contract Weather is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    /**
    * @dev The last recorded average temperature
    */
    uint256 public avgTemp = 0;

    /**
    * @dev The average temperature
    */    
    uint256 public fee;

    /**
    * @dev The average temperature
    */    
    string public serverUrl;

    /**
    * @dev The event to emit each time a temperature is recovered
    */
    event AvgTemp(uint256 _result);

    /**
    * @dev Init chainlink client
    */
    constructor(
        address _link,
        address _oracle,
        uint256 _fee
    ) ConfirmedOwner(msg.sender)
    {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        fee = _fee;
    }

    function setServerUrl(string calldata _serverUrl) public onlyOwner{
        serverUrl = _serverUrl;
    }

    function setAvgTemp(uint256 _avgTmp) public onlyOwner{
        avgTemp = _avgTmp;
    }

    function getAvgTemp() public returns(uint256){
        return avgTemp;
    }

    function requestAvgTemp() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            'ca98366cc7314957b8c012c72f05aeeb'
            , address(this)
            , this.fulfillAvgTemp.selector
        );
        req.add('get', serverUrl);
        req.add("path", "avgTemp");
        req.addInt('times', 1);
        return sendChainlinkRequest(req, fee);
    }

    function fulfillAvgTemp(
        bytes32 _requestId,
        uint256 _result
    ) public recordChainlinkFulfillment(_requestId) {
        avgTemp = _result;
        emit AvgTemp(_result);
    }
}