const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VotingSystem", function () {
  let votingSystem;
  let admin;
  let voter1;
  let voter2;
  let candidate1;
  let candidate2;

  beforeEach(async () => {
    const VotingSystem = await ethers.getContractFactory("VotingSystem");
    [admin, voter1, voter2] = await ethers.getSigners();

    votingSystem = await VotingSystem.deploy();
    await votingSystem.deployed();

    await votingSystem.connect(admin).addCandidate("Candidate 1", "Party 1");
    await votingSystem.connect(admin).addCandidate("Candidate 2", "Party 2");

    const candidatesCount = await votingSystem.getCandidateCount();

    candidate1 = await votingSystem.getCandidate(candidatesCount - 2);
    candidate2 = await votingSystem.getCandidate(candidatesCount - 1);
  });

  it("should add candidates", async function () {
    expect(candidate1.name).to.equal("Candidate 1");
    expect(candidate1.party).to.equal("Party 1");
    expect(candidate1.voteCount).to.equal(0);

    expect(candidate2.name).to.equal("Candidate 2");
    expect(candidate2.party).to.equal("Party 2");
    expect(candidate2.voteCount).to.equal(0);
  });

  it("should start and end the election", async function () {
    await votingSystem.connect(admin).startElection();
    expect(await votingSystem.start()).to.equal(true);

    await votingSystem.connect(admin).endElection();
    expect(await votingSystem.end()).to.equal(true);
  });

  it("should register voters", async function () {
    await votingSystem.connect(admin).startElection();

    await votingSystem.connect(voter1).registerVoter();
    expect(await votingSystem.getVoterStatus(voter1.address)).to.equal(true);

    await votingSystem.connect(voter2).registerVoter();
    expect(await votingSystem.getVoterStatus(voter2.address)).to.equal(true);
  });

  it("should allow registered voters to cast their vote", async function () {
    await votingSystem.connect(admin).startElection();

    await votingSystem.connect(voter1).registerVoter();

    await votingSystem.connect(voter1).vote(0);
    const candidate1VoteCount = (await votingSystem.getCandidate(0)).voteCount;
    expect(candidate1VoteCount).to.equal(1);

    const voter1HasVoted = await votingSystem.hasVoted(voter1.address);
    expect(voter1HasVoted).to.equal(true);

    await expect(votingSystem.connect(voter1).vote(0)).to.be.revertedWith("Already voted.");
  });

  it("should get the winning candidate", async function () {
    await votingSystem.connect(admin).startElection();

    await votingSystem.connect(voter1).registerVoter();
    await votingSystem.connect(voter2).registerVoter();

    await votingSystem.connect(voter1).vote(0);
    await votingSystem.connect(voter2).vote(0);

    const [winnerName, winnerParty, winnerVoteCount] = await votingSystem.getWinningCandidate();
    expect(winnerName).to.equal("Candidate 1");
    expect(winnerParty).to.equal("Party 1");
    expect(winnerVoteCount).to.equal(2);
  });

  it("should create a ballot", async function () {
    await votingSystem.connect(admin).createBallot("Ballot 1", [0, 1], 1626182400, 1626186000);

    const ballot = await votingSystem.ballots(0);
    expect(ballot.name).to.equal("Ballot 1");
    expect(ballot.candidateIds.length).to.equal(2);
    expect(ballot.candidateIds[0]).to.equal(0);
    expect(ballot.candidateIds[1]).to.equal(1);
    expect(ballot.startTime).to.equal(1626182400);
    expect(ballot.endTime).to.equal(1626186000);
  });
});
