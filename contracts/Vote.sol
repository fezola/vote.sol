// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Voting {
    // Struct to represent a candidate
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    // Mapping to store candidates
    mapping(uint => Candidate) public candidates;
    // Mapping to store if an address has voted
    mapping(address => bool) public voters;
    // Number of candidates
    uint public candidatesCount;
    // Election end time
    uint public electionEndTime;

    // Event to be emitted when a vote is cast
    event VotedEvent(uint indexed candidateId);

    // Constructor to initialize the election end time
    constructor(uint _durationMinutes) {
        electionEndTime = block.timestamp + (_durationMinutes * 1 minutes);
    }

    // Function to add a candidate
    function addCandidate(string memory _name) public {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    // Function to vote for a candidate
    function vote(uint _candidateId) public {
        // Check if the election is still ongoing
        require(block.timestamp < electionEndTime, "Election is over.");
        // Check if the voter has already voted
        require(!voters[msg.sender], "You have already voted.");
        // Check if the candidate is valid
        require(
            _candidateId > 0 && _candidateId <= candidatesCount,
            "Invalid candidate."
        );

        // Record that the voter has voted
        voters[msg.sender] = true;
        // Update the candidate's vote count
        candidates[_candidateId].voteCount++;

        // Emit the voted event
        emit VotedEvent(_candidateId);
    }

    // Function to get the remaining time for the election
    function getRemainingTime() public view returns (uint) {
        if (block.timestamp >= electionEndTime) {
            return 0;
        } else {
            return electionEndTime - block.timestamp;
        }
    }

    // Function to get the result of the election
    function getResult()
        public
        view
        returns (uint winnerId, string memory winnerName, uint winnerVoteCount)
    {
        require(
            block.timestamp >= electionEndTime,
            "Election is still ongoing."
        );

        uint maxVotes = 0;
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = candidates[i].id;
                winnerName = candidates[i].name;
                winnerVoteCount = candidates[i].voteCount;
            }
        }
    }
}
