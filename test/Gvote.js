const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Gvote", function () {
  let Gvote;
  let gv;
  let owner;
  let voter1;
  let voter2;
  let candidate1;
  let candidate2;

  beforeEach(async () => {
    Gvote = await ethers.getContractFactory("Gvote");
    [owner, voter1, voter2] = await ethers.getSigners();

    gv = await Gvote.deploy();
    await gv.deployed();

    await gv.createSession();
    const sessionCount = await gv.sessionCount();

    await gv.connect(owner).registerAsCandidate(sessionCount - 1);
    await gv.connect(voter1).registerAsVoter(sessionCount - 1);
    await gv.connect(voter2).registerAsVoter(sessionCount - 1);

    candidate1 = await gv.sessions(sessionCount - 1, 0);
    candidate2 = await gv.sessions(sessionCount - 1, 1);
  });

  it("should create a session", async function () {
    const sessionCount = await gv.sessionCount();
    expect(sessionCount).to.equal(1);
  });

  it("should register candidates", async function () {
    expect(candidate1).to.equal(owner.address);
  });

  it("should register voters", async function () {
    expect(await gv.sessions(0).isVoter[voter1.address]).to.equal(true);
    expect(await gv.sessions(0).isVoter[voter2.address]).to.equal(true);
  });

  it("should start and end a session", async function () {
    await gv.connect(owner).startSession(0);
    expect(await gv.sessions(0).start).to.equal(true);

    await gv.connect(owner).endSession(0);
    expect(await gv.sessions(0).end).to.equal(true);
  });

  it("should approve a session", async function () {
    await gv.connect(owner).approveSession(0);
    expect(await gv.sessions(0).approved).to.equal(true);
  });

  it("should vote for a candidate", async function () {
    await gv.connect(owner).approveSession(0);
    await gv.connect(voter1).vote(0, 0);

    const candidateVotes = await gv.getCandidateVotes(0, 0);
    expect(candidateVotes).to.equal(1);

    const voterChoice = await gv.getVoterChoice(0, voter1.address);
    expect(voterChoice).to.equal(0);

    await expect(gv.connect(voter1).vote(0, 0)).to.be.revertedWith("Already voted.");
  });

  it("should get the candidate votes", async function () {
    await gv.connect(owner).approveSession(0);
    await gv.connect(voter1).vote(0, 0);
    await gv.connect(voter2).vote(0, 0);

    const candidateVotes = await gv.getCandidateVotes(0, 0);
    expect(candidateVotes).to.equal(2);
  });

  it("should get the voter choice", async function () {
    await gv.connect(owner).approveSession(0);
    await gv.connect(voter1).vote(0, 1);

    const voterChoice = await gv.getVoterChoice(0, voter1.address);
    expect(voterChoice).to.equal(1);
  });

  it("should get the session candidate count", async function () {
    const sessionCandidateCount = await gv.getSessionCandidateCount(0);
    expect(sessionCandidateCount).to.equal(2);
  });

  it("should get the session voter count", async function () {
    const sessionVoterCount = await gv.getSessionVoterCount(0);
    expect(sessionVoterCount).to.equal(2);
  });

  it("should get the session status", async function () {
    await gv.connect(owner).startSession(0);
    await gv.connect(owner).endSession(0);

    const [start, end] = await gv.getSessionStatus(0);
    expect(start).to.equal(true);
    expect(end).to.equal(true);
  });

  it("should get the session approval status", async function () {
    await gv.connect(owner).approveSession(0);
    const approvalStatus = await gv.getSessionApprovalStatus(0);
    expect(approvalStatus).to.equal(true);
  });

  it("should get the winner", async function () {
    await gv.connect(owner).approveSession(0);
    await gv.connect(voter1).vote(0, 0);
    await gv.connect(voter2).vote(0, 1);

    const winner = await gv.getWinner(0);
    expect(winner).to.equal(voter2.address);
  });
});
