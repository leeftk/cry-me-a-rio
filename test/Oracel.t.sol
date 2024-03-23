// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Test, console} from "forge-std/Test.sol";
import "../src/AccuWeatherData.sol";
import "../src/Mocks/MockChainlinkOracle.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/Vm.sol";

contract AccuWeatherDataTest is Test, IERC20 {
    // Vm vm = Vm(HEVM_ADDRESS);
    AccuWeatherData accuWeatherData;
    MockChainlinkOracle mockOracle;
    IERC20 link = IERC20(0x514910771AF9Ca656af840dff83E8264EcF986CA); // LINK token contract on Ethereum mainnet
    address linkWhale = 0xbc10f2e862ed4502144c7d632a3459f49dfcdb5e;



    function setUp() public {
        mockOracle = new MockChainlinkOracle();
        
        accuWeatherData = new AccuWeatherData();
             // Impersonate the LINK whale
        vm.startPrank(linkWhale);

        // Ensure the whale has enough ETH to pay for gas (optional, if necessary)
        vm.deal(linkWhale, 1 ether);

        // Transfer LINK to your contract
        require(link.transfer(myContract, amount), "LINK transfer failed");

        // Stop impersonating the LINK whale
        vm.stopPrank();
        console.log("made it");
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
