// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@chainlink/contracts/v0.8/ChainlinkClient.sol";
import "forge-std/console.sol";

contract AccuWeatherData is ChainlinkClient {
    event Request(bytes32 indexed requestId, uint256 indexed precipitation);

    using Chainlink for Chainlink.Request;

    bytes32 private jobId;
    uint256 private fee;
    uint256 public precipitation;

    //only the contract owner should be able to tweet
    address payable owner;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    constructor() {
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    function requestPrecipitationData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Assuming the API endpoint and the response format, adjust as necessary
        string memory url = "http://dataservice.accuweather.com/currentconditions/v1/45449?apikey=kabeZ8hsdQdAzgaihRYXu18GYDTjMScU&details=true";
        console.log("1");
        req.add("get", url);
        // Adjust the JSON path to match the structure of the AccuWeather response
        req.add("path", "0.PrecipitationSummary.Past24Hours.Metric.Value");

        
        int256 timesAmount = 1000;
        req.addInt("times", timesAmount);

       return sendChainlinkRequest(req, fee);
   
         
    }

    function fulfill(bytes32 _requestId, uint256 _precipitation) public {
        emit Request(_requestId, _precipitation);
        precipitation = _precipitation;
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
}
