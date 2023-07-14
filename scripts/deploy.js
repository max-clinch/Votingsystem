//const { ethers } = require("hardhat");
//
//async function main() {
//  // Deploy Gvote contract
//  const GvoteFactory = await ethers.getContractFactory("Gvote");
//  const Gvote = await GvoteFactory.deploy();
//  await Gvote.deployed();
//
//  console.log("Gvote deployed to:", Gvote.address);
//
//  // Deploy VotingSystem contract
//  const votingSystemFactory = await ethers.getContractFactory("VotingSystem");
//  const votingSystem = await votingSystemFactory.deploy();
//  await votingSystem.deployed();
//
//  console.log("VotingSystem deployed to:", votingSystem.address);
//
//  console.log("Deployment completed!");
//}
//
//main()
//  .then(() => process.exit(0))
//  .catch((error) => {
//    console.error(error);
//    process.exit(1);
//});
//

const { ethers } = require("hardhat");

async function main() {
  // Deploy Gvote contract
  const GvoteFactory = await ethers.getContractFactory("Gvote");
  const GvoteBytecode = GvoteFactory.bytecode;
  const GvoteContract = new ethers.ContractFactory(GvoteFactory.interface, GvoteBytecode);
  const Gvote = await GvoteContract.deploy();
  await Gvote.deployed();

  console.log("Gvote deployed to:", Gvote.address);

  // Deploy VotingSystem contract with the same address as Gvote
  const votingSystemFactory = await ethers.getContractFactory("VotingSystem");
  const VotingSystemBytecode = votingSystemFactory.bytecode;
  const VotingSystemContract = new ethers.ContractFactory(votingSystemFactory.interface, VotingSystemBytecode);
  const votingSystem = await VotingSystemContract.deploy();
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
