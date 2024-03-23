// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

contract AccuWeatherData is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    // Define state variables
    uint256 public temperature;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    /**
     * Network: Kovan
     * Oracle: Chainlink Oracle address
     * Job ID: Chainlink Job ID
     * Fee: LINK token amount (in wei) required for the request
     */
    constructor(address _oracle, string memory _jobId, uint256 _fee) {
        setPublicChainlinkToken();
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        fee = _fee; // Typically 0.1 * 10 ** 18 (0.1 LINK)
    }

    // Function to request temperature data from AccuWeather
    function requestTemperatureData(string memory city) public {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to perform the GET request on
        // You need to replace YOUR_API_KEY with your actual AccuWeather API key and specify the city or location
        req.add("get", string(abi.encodePacked("http://dataservice.accuweather.com/currentconditions/v1/", city, "?apikey=kabeZ8hsdQdAzgaihRYXu18GYDTjMScU")));

        // Set the path to find the desired data in the API response
        // This path depends on the AccuWeather API response format
        req.add("path", "0.Temperature.Metric.Value");

        // Sends the request
        sendChainlinkRequestTo(oracle, req, fee);
    }

    // Callback function to receive the response
    function fulfill(bytes32 _requestId, uint256 _temperature) public recordChainlinkFulfillment(_requestId) {
        temperature = _temperature;
    }

    // Helper function to convert string to bytes32
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}
