// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Test, console} from "forge-std/Test.sol";
import "../src/AccuWeatherData.sol";
import "../src/Mocks/MockChainlinkOracle.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/Vm.sol";

contract AccuWeatherDataTest is Test{
    // Vm vm = Vm(HEVM_ADDRESS);
    AccuWeatherData accuWeatherData;
    MockChainlinkOracle mockOracle;
    IERC20 link = IERC20(0x514910771AF9Ca656af840dff83E8264EcF986CA); // LINK token contract on Ethereum mainnet
    address linkWhale = 0xBc10f2E862ED4502144c7d632a3459F49DFCDB5e;



    function setUp() public {
        mockOracle = new MockChainlinkOracle();
        
        accuWeatherData = new AccuWeatherData();
    

    }

    function testPrecipitationDataFetch() public {

        // Simulate the oracle response
        bytes32 requestId = 0x0; // Simplified for example. In reality, capture the requestId from the emitted event.
        uint256 mockedPrecipitation = 5; // Example precipitation value in mm
        mockOracle.fulfillPrecipitationRequest(requestId, address(accuWeatherData));
        accuWeatherData.fulfill(requestId, mockedPrecipitation);

        // Verify the precipitation was updated correctly
        assertEq(accuWeatherData.precipitation(), mockedPrecipitation);
    }
}
