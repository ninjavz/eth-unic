pragma solidity ^0.4.13;
// SPDX-License-Identifier: GPL-3.0

/** 
 * @title Vote
 * @dev Implementation of a voting contract with 4 candidates
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
    address[] public voterAccounts;             // Array to store all voters
    
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
    
    function whiteList(address _address) public {
        // Check that the contract creator is doing the whitelisting
        require(msg.sender == manager, "Only the managar can whitelist an address to vote!");
        
        Voter storage voter = electors[_address];
        voter.isWhiteListed = true;
        
        voterAccounts.push(_address);
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
        
        // Add votes to a candidate
        candidates[_selection - 1].votes++;
        // mark address so it cannot vote again
        voter.voted = true;
    }
    
    
    // function endVote() = declare Winner
    function endVote() public returns (bytes32) {
        // count total votes
        uint32 totalVotes = 0;
        
        for (uint8 i = 0; i < NUM_CANDIDATES; i++) {
            totalVotes = totalVotes + candidates[i].votes;
        }
        
        // Sort Candidates according to votes (low to high)
        sortCandidates(0);
        
        // Winner is the last item of the sorted Array
        // Check if Winner has 60% or more votes
        return candidates[NUM_CANDIDATES].name;
    }
    
    // function declareWinner()
    function sortCandidates(uint8 _position) internal {
        bytes32 temp_name;
        uint16 temp_votes = 0;
        
        // Break recursion if end of list 
        if (_position == (NUM_CANDIDATES - 1)) {
            return;
        }
        
        if (candidates[_position].votes > candidates[_position + 1].votes) {
            temp_name = candidates[_position + 1].name;
            temp_votes = candidates[_position + 1].votes;
            
            // Swap positions in list/Array
            candidates[_position + 1].name = candidates[_position].name;
            candidates[_position + 1].votes = candidates[_position].votes;
            candidates[_position].name = temp_name;
            candidates[_position].votes = temp_votes;
        }
        else {
            sortCandidates(_position + 1);
        }
    }
    
    // function fallback if ETH send
    function() external payable {
        
    }
}
