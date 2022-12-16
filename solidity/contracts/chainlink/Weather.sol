// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

contract Weather is ChainlinkClient {
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
    function _initChainLinkClient(        
        address _link,
        address _oracle,
        string calldata _serverUrl,
        uint256 _fee
    ) internal
    {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        fee = _fee;
        serverUrl = _serverUrl;
    }

    function requestAvgTemp() public {
        Chainlink.Request memory req = buildChainlinkRequest(
            '7da2702f37fd48e5b1b9a5715e3509b6'
            , address(this)
            , this.fulfillAvgTemp.selector
        );
        req.add('get', serverUrl);
        req.addInt('times', 1);
        sendChainlinkRequest(req, fee);
    }

    function fulfillAvgTemp(
        bytes32 _requestId,
        uint256 _result
    ) external recordChainlinkFulfillment(_requestId) {
        avgTemp = _result;
        emit AvgTemp(_result);
    }
}