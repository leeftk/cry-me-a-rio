// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../AccuWeatherData.sol";

contract MockChainlinkOracle {
    
    function fulfillPrecipitationRequest(bytes32 _requestId, uint256 _precipitation, address _contract) public {
        // Simulate calling the fulfill function on the AccuWeatherData contract

        AccuWeatherData(_contract).fulfill(_requestId, _precipitation);
    }
}
