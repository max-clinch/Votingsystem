
// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "./Gvote.sol";

contract VotingSystem {
    // State variables
    address public admin;
    uint256 public candidateCount;
    uint256 public voterCount;
    bool public start;
    bool public end;
    uint256 public ballotCount;

    struct Candidate {
        string name;
        string party;
        uint256 voteCount;
    }

    struct Ballot {
        uint256 id;
        string name;
        uint256[] candidateIds;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(uint256 => Candidate) public candidates;
    mapping(address => bool) public hasVoted;
    mapping(address => bool) public isRegistered;
    mapping(uint256 => mapping(address => bool)) public votedForCandidate;
    address[] private voterAddresses;
    mapping(uint256 => Ballot) public ballots;

    // Events
    event VoteCast(address indexed voter, uint256 candidateIndex);
    event SessionCreated(uint256 sessionId, address owner);
    event BallotCreated(uint256 ballotId, string name);

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can access this function.");
        _;
    }

    modifier securityGuard() {
        require(msg.sender == admin || isRegistered[msg.sender], "Only the admin or registered voters can access this function.");
        _;
    }

    constructor() {
        admin = msg.sender;
        candidateCount = 0;
        voterCount = 0;
        start = false;
        end = false;
        ballotCount = 0;
    }

    function addCandidate(string memory _name, string memory _party) public onlyAdmin {
        require(!start, "Election has already started.");
        require(!end, "Election has already ended.");

        candidates[candidateCount] = Candidate(_name, _party, 0);
        candidateCount++;
    }

    function startElection() public onlyAdmin {
        require(candidateCount > 0, "No candidates added yet.");
        require(!start, "Election has already started.");
        require(!end, "Election has already ended.");

        start = true;
    }

    function endElection() public onlyAdmin {
        require(start, "Election has not started yet.");
        require(!end, "Election has already ended.");

        end = true;
    }

    function registerVoter() public {
        require(start, "Election has not started yet.");
        require(!end, "Election has already ended.");
        require(!isRegistered[msg.sender], "Already registered.");

        isRegistered[msg.sender] = true;
        voterAddresses.push(msg.sender);
        voterCount++;
    }

    function vote(uint256 _candidateIndex) public securityGuard {
        require(start, "Election has not started yet.");
        require(!end, "Election has already ended.");
        require(isRegistered[msg.sender], "Not registered as a voter.");
        require(!hasVoted[msg.sender], "Already voted.");
        require(_candidateIndex < candidateCount, "Invalid candidate index.");
        require(!votedForCandidate[_candidateIndex][msg.sender], "Already voted for this candidate.");

        candidates[_candidateIndex].voteCount++;
        hasVoted[msg.sender] = true;
        votedForCandidate[_candidateIndex][msg.sender] = true;

        emit VoteCast(msg.sender, _candidateIndex);
    }

    function getCandidate(uint256 _candidateIndex) public view returns (string memory, string memory, uint256) {
        require(_candidateIndex < candidateCount, "Invalid candidate index.");

        Candidate memory candidate = candidates[_candidateIndex];
        return (candidate.name, candidate.party, candidate.voteCount);
    }

    function getCandidateCount() public view returns (uint256) {
        return candidateCount;
    }

    function getVoterCount() public view returns (uint256) {
        return voterCount;
    }

    function getVoterStatus(address _voter) public view returns (bool) {
        return isRegistered[_voter];
    }

    function getWinningCandidate() public view returns (string memory, string memory, uint256) {
        require(end, "Election has not ended yet.");

        uint256 maxVoteCount = 0;
        uint256 winningCandidateIndex;

        for (uint256 i = 0; i < candidateCount; i++) {
            if (candidates[i].voteCount > maxVoteCount) {
                maxVoteCount = candidates[i].voteCount;
                winningCandidateIndex = i;
            }
        }

        Candidate memory winner = candidates[winningCandidateIndex];
        return (winner.name, winner.party, winner.voteCount);
    }

    function createBallot(
        string memory _name,
        uint256[] memory _candidateIds,
        uint256 _startTime,
        uint256 _endTime
    ) public onlyAdmin {
        require(!start, "Election has already started.");
        require(!end, "Election has already ended.");
        require(_candidateIds.length > 0, "At least one candidate must be included.");
        require(_startTime < _endTime, "Invalid ballot period.");

        ballots[ballotCount] = Ballot(ballotCount, _name, _candidateIds, _startTime, _endTime);
        ballotCount++;

        emit BallotCreated(ballotCount - 1, _name);
    }
}
