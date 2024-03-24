// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import {BettingContract} from "src/BettingContract.sol";
import {AccuWeatherData} from "src/AccuWeatherData.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        new BettingContract(new AccuWeatherData(), block.timestamp + 3 days, 300, 0x9C382eEC918e14F4943912F07661D1de286c79ad); // 3mm
        vm.stopBroadcast();
    }
}
