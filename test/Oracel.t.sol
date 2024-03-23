// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Test, console} from "forge-std/Test.sol";
import "../src/Oracle.sol";
import "../src/Mocks/MockChainlinkOracle.sol";
import "forge-std/Vm.sol";

contract AccuWeatherDataTest is Test {
    // Vm vm = Vm(HEVM_ADDRESS);
    AccuWeatherData accuWeatherData;
    MockChainlinkOracle mockOracle;

    function setUp() public {
        mockOracle = new MockChainlinkOracle();
        
        accuWeatherData = new AccuWeatherData(address(mockOracle), "jobId", 0.1 ether);
    }

    function testPrecipitationDataFetch() public {
        // Trigger the request
        accuWeatherData.requestPrecipitationData();

        // Simulate the oracle response
        bytes32 requestId = 0x0; // Simplified for example. In reality, capture the requestId from the emitted event.
        uint256 mockedPrecipitation = 5; // Example precipitation value in mm
        mockOracle.fulfillPrecipitationRequest(requestId, mockedPrecipitation, address(accuWeatherData));

        // Verify the precipitation was updated correctly
        assertEq(accuWeatherData.precipitation(), mockedPrecipitation);
    }
}
