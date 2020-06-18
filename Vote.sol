pragma solidity ^0.4.13;

/** 
 * @title Vote
 * @dev Implementation of a voting contract with 4 candidates
 */
 
contract Vote {
    
    uint constant NUM_CANDIDATES = 4;
    
    struct Voter {
        bool isWhiteListed;   // only registered addresses can vote
        bool voted;         // check wheter an address has already voted
    }

    struct Candidate {
        bytes32 name;       // Candidate name
        uint votes;         // Number of votes per candidate
    }
    
    // These variables are stored in the blockchain
    mapping(address => Voter) public voters;    // Map address to stuct Voter to create voters
    address[] public voterAccounts;             // Array to store all voters
    
    Candidate[NUM_CANDIDATES] public candidates;    // variable that keeps record of the candidates
    
    address public manager;     // manager is the creator of the contract
    
    // constructor 
    constructor() public {
        
        // Create de Candidates Names (in the future using string and for loop and concatenating)
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
        
        Voter storage voter = voters[_address];
        voter.isWhiteListed = true;
        
        
    }
    // function voteFor(uint)
    // if msg.value > 0 then ETH send => return
    
    // function endVote() = declare Winner
    
    // function declareWinner()
    
    // function fallback if ETH send
    function() payable public {
        
    }
}
