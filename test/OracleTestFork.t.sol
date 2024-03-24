// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/AccuWeatherData.sol";
import "../src/Mocks/MockChainlinkOracle.sol";// Adjust the path to your contract
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@chainlink/contracts/v0.8/shared/interfaces/LinkTokenInterface.sol";


contract OracleTest is Test {
    AccuWeatherData accuWeatherData;
    MockChainlinkOracle mockOracle;
    address linky = 0x779877A7B0D9E8603169DdbD7836e478b4624789; // LINK token contract on Ethereum mainnet
    address linkWhale = 0xBc10f2E862ED4502144c7d632a3459F49DFCDB5e;

    function setUp() public {
            mockOracle = new MockChainlinkOracle();
        
        accuWeatherData = new AccuWeatherData();
             // Impersonate the LINK whale
        vm.startPrank(linkWhale);

        // Ensure the whale has enough ETH to pay for gas (optional, if necessary)
        vm.deal(linkWhale, 1 ether);
        uint amount = 1 ether;
        // Transfer LINK to your contract
        LinkTokenInterface link = LinkTokenInterface(linky);

        
        console.log("made it");
        require(link.transfer(address(accuWeatherData), amount), "LINK transfer failed");
        console.log("made it");
        // Stop impersonating the LINK whale
        vm.stopPrank();
        //find the link balance of the contract
        console.log("Link balance of the contract is %d", link.balanceOf(address(accuWeatherData)));
        
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
