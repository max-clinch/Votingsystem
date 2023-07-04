const { ethers } = require("hardhat");

async function main() {
  // Deploy Gvote contract
  const GvoteFactory = await ethers.getContractFactory("Gvote");
  const Gvote = await GvoteFactory.deploy();
  await Gvote.deployed();

  console.log("Gvote deployed to:", Gvote.address);

  // Deploy VotingSystem contract
  const votingSystemFactory = await ethers.getContractFactory("VotingSystem");
  const votingSystem = await votingSystemFactory.deploy();
  await votingSystem.deployed();

  console.log("VotingSystem deployed to:", votingSystem.address);

  console.log("Deployment completed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
