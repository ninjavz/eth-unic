pragma solidity ^0.5.10;
// SPDX-License-Identifier: GPL-3.0

/** 
 * UNIC-COMP541
 * Miguel Ramirez
 * U191N0118
 * 
 * @title Vote
 * @dev Implementation of a voting contract with 4 candidates
 * 
 * The contract creator is the manager and only that address can whitelist additional addresses so 
 * that they can vote. Also, only the manager can end the voting process to declare a winner.
 * The Winner needs 60% or more votes to win.
 */
 
contract Vote {
    uint8 constant NUM_CANDIDATES = 4;  // Limits candidates to 256
    
    struct Voter {
        bool isWhiteListed;   // only registered addresses can vote
        bool voted;         // check wheter an address has already voted
    }

    struct Candidate {
        bytes32 name;       // Candidate name
        uint16 votes;       // Number of votes per candidate (limited to 16 bit)
    }
    
    // These variables are stored in the blockchain
    mapping(address => Voter) public electors;    // Map address to stuct Voter to create voters

    Candidate[NUM_CANDIDATES] public candidates;    // variable that keeps record of the candidates
    
    address public manager;     // manager is the creator of the contract
    
    // constructor 
    constructor() public {
        
        // Create de Candidates Names (in the future using string and for loop and concatenating)
        // Set their respective votes to 0
        // Total candidates = 0 to NUM_CANDIDATES-1
        candidates[0].name = "Candidate1";
        candidates[0].votes = 0;
        candidates[1].name = "Candidate2";
        candidates[1].votes = 0;
        candidates[2].name = "Candidate3";
        candidates[2].votes = 0;
        candidates[3].name = "Candidate4";
        candidates[3].votes = 0;
        
        manager = msg.sender;       // only the manager is allowed to add WL addresses
        
    }
    
    // se puede hacer con un modifier
    function whiteList(address _address) public {
        // Check that the contract creator/manager is doing the whitelisting
        require(msg.sender == manager, "Only the managar can whitelist an address to vote!");
        //require((_address[0] == '0') && (_address[1] == 'x'), "Whitelist address is needed!");
        Voter storage voter = electors[_address];
        voter.isWhiteListed = true;
    }
    
    // function voteFor(uint)
    function voteFor(uint8 _selection) public {
        // create voter to update its variables
        Voter storage voter = electors[msg.sender];

        // Is it a valid vote?
        require(_selection>=1 && _selection<=NUM_CANDIDATES, "Voting options are out of range (valid: 1-4).");
        // Is the address whitelisted?
        require(voter.isWhiteListed, "Cannot vote because this address has not been whitelisted by the manager!");
        // Has this address already voted?
        require(!voter.voted, "Unable to vote, already voted!");
        
        // Add votes to a candidate (index has to be corrected with -1)
        candidates[_selection - 1].votes++;
        // mark address so it cannot vote again
        voter.voted = true;
    }
    
    
    // function endVote() = declare Winner
    function endVote() public view returns (bytes32 winnerName_) {
        // count total votes
        uint32 totalVotes = 0;
        uint8 winner = 0;
        
        // Only the manager can end the voting process
        require(msg.sender == manager, "Only the managar can end the voting!");

        for (uint8 i = 0; i < NUM_CANDIDATES; i++) {
            totalVotes = totalVotes + candidates[i].votes;
        }
        
        // Get the index of the candidate with the most votes
        winner = findWinner();

        // Calculate if votes above 60%, if so return that winners name
        if ((candidates[winner].votes * 100 / totalVotes) >= 60) {
            winnerName_ = candidates[winner].name;
        }
        else {
            winnerName_ = "No one wins.";
        }
        
    }
    
    // function findWinner()
    // read through the array and save the position of the highest votes, return that
    function findWinner() internal view returns(uint8 winner_) {
        winner_ = 0;           // same type a NUM_CANDIDATES to avoid overflow
        uint16 highest_vote = 0;
        
        for (uint8 i = 0; i < NUM_CANDIDATES; i++) {
            if (candidates[i].votes > highest_vote) {
                highest_vote = candidates[i].votes;
                winner_ = i;
            }
        }
    }
    
    // fallback function - if ETH send return the amount
    function() external payable {
        address payable wallet = msg.sender;
        wallet.transfer(msg.value);
    }
}
