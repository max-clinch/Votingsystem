// Sources flattened with hardhat v2.16.1 https://hardhat.org
// SPDX-License-Identifier: MIT 

// File contracts/Gvote.sol

pragma solidity ^0.8.0;

contract Gvote {
    struct Session {
        address owner;
        bool approved;
        bool start;
        bool end;
        uint256 candidateCount; // Added variable
        mapping(uint256 => address) candidates;
        mapping(address => bool) isCandidate;
        mapping(address => bool) isVoter;
        mapping(uint256 => uint256) candidateVotes;
        mapping(address => uint256) voterChoice;
    }

    mapping(uint256 => Session) public sessions;
    uint256 public sessionCount;

    event VoteCast(address indexed voter, uint256 sessionId, uint256 candidateIndex);
    event SessionCreated(uint256 sessionId, address owner);

    modifier onlySessionOwner(uint256 _sessionId) {
        require(msg.sender == sessions[_sessionId].owner, "Only the session owner can access this function.");
        _;
    }

    modifier onlyApprovedSession(uint256 _sessionId) {
        require(sessions[_sessionId].approved, "Only approved sessions can access this function.");
        _;
    }

    function createSession() public {
        Session storage newSession = sessions[sessionCount];
        newSession.owner = msg.sender;
        newSession.approved = false;
        sessionCount++;

        emit SessionCreated(sessionCount - 1, msg.sender);
    }

    function registerAsCandidate(uint256 _sessionId) public {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");
        require(!session.start && !session.end, "Session has already started or ended.");
        require(!session.isCandidate[msg.sender], "Already registered as a candidate.");

        session.candidates[sessionCount] = msg.sender;
        session.isCandidate[msg.sender] = true;
    }

    function registerAsVoter(uint256 _sessionId) public {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");
        require(!session.start && !session.end, "Session has already started or ended.");
        require(!session.isVoter[msg.sender], "Already registered as a voter.");

        session.isVoter[msg.sender] = true;
    }

    function startSession(uint256 _sessionId) public onlySessionOwner(_sessionId) {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");
        require(!session.start && !session.end, "Session has already started or ended.");

        session.start = true;
    }

    function endSession(uint256 _sessionId) public onlySessionOwner(_sessionId) {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");
        require(session.start && !session.end, "Session has not started yet or already ended.");

        session.end = true;
    }

    function approveSession(uint256 _sessionId) public onlySessionOwner(_sessionId) {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");
        require(!session.start && !session.end, "Session has already started or ended.");

        session.approved = true;
    }

    function vote(uint256 _sessionId, uint256 _candidateIndex) public onlyApprovedSession(_sessionId) {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");
        require(session.start && !session.end, "Session has not started yet or already ended.");
        require(session.isVoter[msg.sender], "Not registered as a voter.");
        require(!session.isCandidate[msg.sender], "Cannot vote as a candidate.");
        require(_candidateIndex < sessionCount, "Invalid candidate index.");
        require(session.voterChoice[msg.sender] == 0, "Already voted.");

        session.candidateVotes[_candidateIndex]++;
        session.voterChoice[msg.sender] = _candidateIndex;

        emit VoteCast(msg.sender, _sessionId, _candidateIndex);
    }

    function getCandidateVotes(uint256 _sessionId, uint256 _candidateIndex) public view onlyApprovedSession(_sessionId) returns (uint256) {
        Session storage session = sessions[_sessionId];
        require(_candidateIndex < sessionCount, "Invalid candidate index.");

        return session.candidateVotes[_candidateIndex];
    }

    function getVoterChoice(uint256 _sessionId, address _voter) public view onlyApprovedSession(_sessionId) returns (uint256) {
        Session storage session = sessions[_sessionId];
        require(session.isVoter[_voter], "Not registered as a voter.");

        return session.voterChoice[_voter];
    }

    function getSessionCandidateCount(uint256 _sessionId) public view returns (uint256) {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");

        return sessionCount;
    }

    function getSessionVoterCount(uint256 _sessionId) public view returns (uint256) {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");

        return sessionCount;
    }

    function getSessionStatus(uint256 _sessionId) public view returns (bool, bool) {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");

        return (session.start, session.end);
    }

    function getSessionApprovalStatus(uint256 _sessionId) public view returns (bool) {
        Session storage session = sessions[_sessionId];
        require(session.owner != address(0), "Invalid session ID.");

        return session.approved;
    }
    
    function getWinner(uint256 _sessionId) public view onlyApprovedSession(_sessionId) returns (address) {
        Session storage session = sessions[_sessionId];
        require(session.start && session.end, "Session has not ended yet.");
        
        uint256 winnerIndex;
        uint256 maxVotes;
        for (uint256 i = 0; i < session.candidateCount; i++) {
            if (session.candidateVotes[i] > maxVotes) {
                maxVotes = session.candidateVotes[i];
                winnerIndex = i;
            }
        }
        
        return session.candidates[winnerIndex];
    }
}


// File contracts/VotingSystem.sol


pragma solidity ^0.8.0;

contract VotingSystem {
    address public admin;
    uint256 public candidateCount;
    uint256 public voterCount;
    bool public start;
    bool public end;

    struct Candidate {
        string name;
        string party;
        uint256 voteCount;
    }

    mapping(uint256 => Candidate) public candidates;
    mapping(address => bool) public hasVoted;
    mapping(address => bool) public isRegistered;
    mapping(uint256 => mapping(address => bool)) public votedForCandidate;
    address[] private voterAddresses;

    event VoteCast(address indexed voter, uint256 candidateIndex);
    event SessionCreated(uint256 sessionId, address owner);

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
}
