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
    * @dev The last job id for average temperature
    */
    bytes32 public avgTempJobId;

    /**
    * @dev The last recorded average temperature
    */
    uint256 public avgTemp = 0;

    /**
    * @dev The average temperature
    */    
    uint256 public fee;

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
        bytes32 _avgTempJobId,
        uint256 _fee
    ) internal
    {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        avgTempJobId = _avgTempJobId;
        fee = _fee;
    }
    
    function requestAvgTemp(string memory _from, string memory _to) external {
        Chainlink.Request memory req = buildChainlinkRequest(
            avgTempJobId,
            address(this),
            this.fulfillAvgTemp.selector
        );
        req.add("dateFrom", _from);
        req.add("dateTo", _to);
        req.add("method", "AVG");
        req.add("column", "temp");
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