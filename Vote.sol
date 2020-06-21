pragma solidity ^0.5.1;
// SPDX-License-Identifier: MIT

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
 * The timeframe that the voting is permitted is specified by the creator of the contract by 
 * giving only the creator the ability to end the poll (voting) whenever he chooses.
 */
 
contract Vote {
    uint8 constant NUM_CANDIDATES = 4;  // Allowed is 1-9
    
    // Voter structure to keep track of Whitelisted addresses and voting status
    struct Voter {
        bool isWhiteListed;   // only registered addresses can vote
        bool voted;           // check wheter an address has already voted
    }
    
    // Candidates structure to keep track of their respective collected votes
    struct Candidate {
        string name;        // Candidate name
        uint16 votes;       // Number of votes per candidate (limited to 16 bit)
    }
    
    // These variables are stored in the blockchain (state)
    mapping(address => Voter) public electors;    // Map address to stuct Voter to create voters

    Candidate[NUM_CANDIDATES] public candidates;  // variable that keeps record of the candidates
    
    address public manager;     // manager is the creator/owner of the contract
    
    // constructor 
    // Initiates the list of Candidates
    // Sets the manager to the calling address (the creator of the contract)
    constructor() public {
        
        // Create the Candidates Names 
        // Set their respective votes to 0
        require((NUM_CANDIDATES > 0) && (NUM_CANDIDATES < 10), "Too many candidates or no candidates!");  // avoid overflow in the for loop
        
        bytes32 numbers = "123456789";
        
        for (uint8 i = 0; i < NUM_CANDIDATES; i++) {
            candidates[i].name = string(abi.encodePacked("Candidate-", numbers[i]));
            candidates[i].votes = 0;
        }
        
        manager = msg.sender;       // only the manager will be allowed to add WL addresses
    }
    
    // Modifier to check that the caller of the function is the creator/manager of the contract
    modifier onlyManager {
        require(msg.sender == manager, "Only the managar can whitelist an address to vote or end the poll!");
        _;
    }
    
    /**
     * Name: whiteList
     * Input:  address
     * Output: saves an address as whitelisted and able to vote
     */ 
    function whiteList(address _address) public onlyManager {
        Voter storage voter = electors[_address];
        voter.isWhiteListed = true;
    }
    
    /**
     * Name: voteFor
     * Input:  int (as a candidate number)
     * Output: adds the vote to a candidate and invalidates further voting of the caller address
     */ 
    function voteFor(uint8 _selection) public {
        // create voter to update its variables
        Voter storage voter = electors[msg.sender];

        // Is the address whitelisted?
        require(voter.isWhiteListed, "Cannot vote because this address has not been whitelisted by the manager!");
        // Is it a valid vote?
        require(_selection>=1 && _selection<=NUM_CANDIDATES, "Voting options are out of range (valid: 1-4).");
        // Has this address already voted?
        require(!voter.voted, "Unable to vote, already voted!");
        
        // Add votes to a candidate (index has to be corrected with -1)
        candidates[_selection - 1].votes++;
        // mark address so it cannot vote again
        voter.voted = true;
    }
    
    /**
     * Name: endVote
     * Input:  (void)
     * Output: String with Winners Name (or "No one wins." if votes for a candidate not above or equal 60%)
     *         Integer value of votes received by the Winner
     */ 
    function endVote() public view onlyManager returns (string memory winnerName_, uint32 votes_) {
        // count total votes
        uint32 totalVotes = 0;
        uint8 winner = 0;
        
        for (uint8 i = 0; i < NUM_CANDIDATES; i++) {
            totalVotes = totalVotes + candidates[i].votes;
        }
        
        // If nobody votes then there is no winner and avoid division by 0
        if (totalVotes == 0) {
            winnerName_ = "No one wins.";
            votes_ = 0;
        }
        else {
            // Get the index of the candidate with the most votes
            winner = findWinner();

            // Calculate if votes above 60%, if so return that winners name
            if ((candidates[winner].votes * 100 / totalVotes) >= 60) {
                winnerName_ = candidates[winner].name;
                votes_ = candidates[winner].votes;
            }
            else {
                winnerName_ = "No one wins.";
                votes_ = 0;
            }
        }
    }
    
    /**
     * Name: findWinner
     * Input:  (void)
     * Output: index of the winner
     */ 
    // read through the array and save the position of the highest vote, return that index/position
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
    
    /**
     * Name: fallback
     * Input:  (void)
     * Output: returns ETH to sender
     * This fallback returns any amount of ETH send to this contract
     */ 
    function() external payable {
        address payable wallet = msg.sender;
        wallet.transfer(msg.value);
    }
}
