// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import {BettingContract} from "src/BettingContract.sol";
import {AccuWeatherData} from "src/AccuWeatherData.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        new BettingContract(new AccuWeatherData(), block.timestamp + 3 days, 300); // 3mm
        vm.stopBroadcast();
    }
}
