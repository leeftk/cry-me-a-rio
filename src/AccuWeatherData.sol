// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@chainlink/contracts/v0.8/ChainlinkClient.sol";


contract AccuWeatherData is ChainlinkClient {
    event Request(bytes32 indexed requestId, uint256 indexed precipitation);
    using Chainlink for Chainlink.Request;

    uint256 public precipitation;
    uint256 public temperature;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    constructor(address _oracle, string memory _jobId, uint256 _fee) {
        //setPublicChainlinkToken();
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        fee = _fee;
    }

    function requestPrecipitationData() public returns (bytes32 requestId){
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Assuming the API endpoint and the response format, adjust as necessary
        string memory url = "http://dataservice.accuweather.com/currentconditions/v1/455825?apikey=kabeZ8hsdQdAzgaihRYXu18GYDTjMScU&details=true";
        req.add("get", url);
        // Adjust the JSON path to match the structure of the AccuWeather response
        req.add("path", "0.PrecipitationSummary.Precipitation.mm");

        int256 timesAmount = 10 ** 18;
        req.addInt("times", timesAmount);

       return sendChainlinkRequestTo(oracle, req, fee);
         
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