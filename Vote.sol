pragma solidity ^0.4.13;

/** 
 * @title Vote
 * @dev Implementation of a voting contract with 4 candidates
 */
 
contract Vote {
    
    uint constant NUM_CANDIDATES = 4;
    
    struct Voter {
        bool whitelisted;   // only registered addresses can vote
        bool voted;         // check wheter an address has already voted
        address voter;      // address registered to a voter
    }

    struct Candidates {
        bytes32 name;       // Candidate name
        uint votes;         // Number of votes per candidate
    }
    
    // constructor 
    
    // function whiteList()
    // function voteFor(uint)
    // function declareWinner()
    // function fallback if ETH send

}
