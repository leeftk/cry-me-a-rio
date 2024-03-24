// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BettingContract} from "../src/BettingContract.sol";
import {AccuWeatherData} from "../src/AccuWeatherData.sol";

contract BettingContractTest is Test {
    BettingContract bettingContract;

    function setUp() public {
        bettingContract =
            new BettingContract(new AccuWeatherData(), block.timestamp + 1 hours, 300); // 3mm
    }

    function testPlaceBet() public {
        // Simulate sending ETH with the transaction
        address bettor = address(0x1);
        vm.deal(bettor, 1 ether); // Provide the bettor with 1 ETH for betting

        vm.startPrank(bettor);
        bettingContract.placeBet{value: 0.00001 ether}({_numYes: 1, _numNo: 0});
        vm.stopPrank();

        // Verify the bet was placed
        assertTrue(bettingContract.numYesFrom(bettor) == 1, "Bettor should have voted.");
    }

    function testFailPlaceBetAfterDeadline() public {
        // Move time forward to simulate betting period has ended
        vm.warp(block.timestamp + 2 hours);

        address bettor = address(0x1);
        vm.deal(bettor, 1 ether); // Provide the bettor with 1 ETH for betting

        vm.startPrank(bettor);
        vm.expectRevert(abi.encodeWithSignature("Betting period has expired."));
        bettingContract.placeBet{value: 0.00001 ether}({_numYes: 1, _numNo: 0}); // This should fail
        vm.stopPrank();
    }

    // Add more tests here...
}
