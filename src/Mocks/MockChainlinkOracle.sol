// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../AccuWeatherData.sol";

    
contract MockChainlinkOracle {
    
    function fulfillPrecipitationRequest(bytes32 _requestId, address _contract) public {
        uint256 pseudoRandomValue = block.number % 2; // Alternates between 0 and 1
        AccuWeatherData(_contract).fulfill(_requestId, pseudoRandomValue);
    }
}

    

