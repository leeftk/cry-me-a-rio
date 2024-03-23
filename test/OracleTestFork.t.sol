// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/AccuWeatherData.sol"; // Adjust the path to your contract
import "forge-std/console.sol";

contract OracleTest is Test {
    AccuWeatherData accuWeatherData;

    function setUp() public {
        // Deploy your contract here
        // Make sure to provide the correct constructor arguments
        accuWeatherData = new AccuWeatherData();
    }

    function testRequestResponse() public {
        // Assuming your contract has a function to make a request and another to read the stored response
        // This example will just call these hypothetical functions

        // Make the request
        accuWeatherData.requestPrecipitationData();

        // Wait for the response to be fulfilled
        // In a real test, you might simulate the passage of time or blocks
        // However, when forking mainnet, you'd typically interact with a mock or use a pre-defined response

        // Fetch and log the response
        uint256 response = accuWeatherData.precipitation();
        emit log_uint(response); // Log the response
        console.log("Precipitation: %d", response); // Log the response
    }
}
