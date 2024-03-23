// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/v0.8/VRFConsumerBase.sol";

contract BettingContract is VRFConsumerBase {
    uint256 public constant BASE_ENTRY_FEE = 0.00001 ether;
    uint256 public strikeTimestamp;
    // 1 = no, 2 = yes.
    uint256 public strikeValue;

    address[] public yesVoters;
    address[] public noVoters;
    uint256 public totalNumYes;
    uint256 public totalNumNo;
    mapping(address => uint256) public numYesFrom;
    mapping(address => uint256) public numNoFrom;

    bytes32 internal keyHash;
    uint256 internal fee;

    // Events
    event BetPlaced(address indexed voter, uint256 numYes, uint256 numNo);
    event WinnersPaidOut(
        uint256 strikeValue, uint256 totalPrize, uint256 totalNumCorrectBid, uint256 payoutPerCorrectBid
    );

    /**
     * Constructor
     */
    constructor(address _vrfCoordinator, address _linkToken, bytes32 _keyHash, uint256 _fee, uint256 _strikeTimestamp)
        VRFConsumerBase(_vrfCoordinator, _linkToken)
    {
        keyHash = _keyHash;
        fee = _fee;
        strikeTimestamp = _strikeTimestamp;
    }

    function priceOfBet(uint256 _numYes, uint256 _numNo) public view returns (uint256 costOfYes, uint256 costOfNo) {
        uint256 totalAvgNewNumYes = totalNumYes + (_numYes / 2);
        uint256 totalAvgNewNumNo = totalNumNo + (_numNo / 2);

        // If there's more yes than no, make the yes's more expensive.
        if (totalAvgNewNumYes > totalAvgNewNumNo) {
            costOfYes = BASE_ENTRY_FEE * (totalNumYes - totalNumNo);
            costOfNo = BASE_ENTRY_FEE;
            // If there's more no than yes, make the no's more expensive.
        } else if (totalAvgNewNumNo > totalAvgNewNumYes) {
            costOfNo = BASE_ENTRY_FEE * (totalNumYes - totalNumNo);
            costOfYes = BASE_ENTRY_FEE;
            // Make them the same.
        } else {
            costOfNo = BASE_ENTRY_FEE;
            costOfYes = BASE_ENTRY_FEE;
        }
    }

    /**
     * Function to place a bet.
     */
    function placeBet(uint256 _numYes, uint256 _numNo) external payable {
        require(block.timestamp <= strikeTimestamp, "Betting period has expired.");

        // Basic validation to ensure at least one of _numYes or _numNo is non-zero
        require(_numYes > 0 || _numNo > 0, "Must place a bet on at least one outcome.");

        // Get the cost of the bets.
        (uint256 costOfYes, uint256 costOfNo) = priceOfBet(_numYes, _numNo);

        // Calculate the entry fee based on the multiplier
        uint256 entryFee = (_numYes * costOfYes) + (_numNo * costOfNo);

        require(msg.value == entryFee, "Incorrect value sent.");

        if (_numYes != 0) {
            if (numYesFrom[msg.sender] == 0) {
                yesVoters.push(msg.sender);
            }
            totalNumYes += _numYes;
            numYesFrom[msg.sender] += _numNo;
        }

        if (_numNo != 0) {
            if (numNoFrom[msg.sender] == 0) {
                noVoters.push(msg.sender);
            }
            totalNumNo += _numNo;
            numNoFrom[msg.sender] += _numNo;
        }

        emit BetPlaced(msg.sender, _numYes, _numNo);
    }

    /**
     * Function to request randomness
     */
    function requestResult() external {
        require(block.timestamp > strikeTimestamp, "Betting period has not expired.");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32, /* requestId */ uint256 randomness) internal override {
        require(strikeValue == 0, "Result already declared.");
        // 1 or 2.
        strikeValue = (randomness % 2) + 1;
        payOutWinners();
    }

    /**
     * Function to distribute the Ether to winners
     */
    function payOutWinners() private {
        require(strikeValue == 1 || strikeValue == 2, "Result has not been declared yet.");

        address[] storage winners = strikeValue == 2 ? yesVoters : noVoters;
        require(winners.length > 0, "No winners to pay out.");

        uint256 totalPrize = address(this).balance;
        uint256 totalNumCorrectBid = strikeValue == 2 ? totalNumYes : totalNumNo;
        uint256 payoutPerCorrectBid = totalPrize / totalNumCorrectBid;

        for (uint256 i = 0; i < winners.length; i++) {
            uint256 numCorrectBids = strikeValue == 2 ? numYesFrom[winners[i]] : numNoFrom[winners[i]];
            payable(winners[i]).transfer(payoutPerCorrectBid * numCorrectBids);
        }

        emit WinnersPaidOut(strikeValue, totalPrize, totalNumCorrectBid, payoutPerCorrectBid);
        // Consider resetting the contract state here if you want to allow for another round of betting
    }

    // Consider adding a function to withdraw LINK or unclaimed Ether, accessible by the contract owner for safety.
}
