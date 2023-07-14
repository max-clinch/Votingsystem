# Hive Voting system Project

This project demonstrates a basic voting system use case. It comes with a  contract, a test for that contract, and a script that deploys that contract.
Blockchain is a technology that is rapidly gaining momentum in era of industry 4.0. With high security and transparency provisions, it is being widely used in supply chain management systems, healthcare, payments, business, IoT, voting systems, etc. 

Why do we need it? 
Current voting systems like ballot box voting or electronic voting suffer from various security threats such as DDoS attack, polling booth capturing, vote alteration and manipulation, malware attacks, etc, and also require huge amounts of paperwork, human resources, and time. This creates a sense of distrust among existing systems. 
Some of the disadvantages are:
•	Long Queues during elections.
•	Security Breaches like data leaks, vote tampering.
•	Lot of paperwork involved, hence less eco-friendly and time-consuming.
•	Difficult for differently-abled voters to reach polling booth.
•	Cost of expenditure on elections is high.

Solution: 
Using blockchain, voting process can be made more secure, transparent, immutable, and reliable. How? Let’s take an example. 
Suppose you are an eligible voter who goes to polling booth and cast vote using EVM (Electronic Voting Machine). But since it’s a circuitry after all and if someone tampers with microchip, you may never know that did your vote reach to person for whom you voted or was diverted into another candidate’s account? 

Since there’s no tracing back of your vote. But, if you use blockchain- it stores everything as a transaction that will be explained soon below; and hence gives you a receipt of your vote (in a form of a transaction ID) and you can use it to ensure that your vote has been counted securely. 

Now suppose a digital voting system (website/app) has been launched to digitize process and all confidential data is stored on a single admin server/machine, if someone tries to hack it or snoop over it, he/she can change candidate’s vote count- from 2 to 22! You may never know that hacker installs malware or performs clickjacking attacks to steal or negate your vote or simply attacks central server. 

To avoid this, if system is integrated with blockchain- a special property called immutability protects system. Consider SQL, PHP, or any other traditional database systems. You can insert, update, or delete votes. But in a blockchain you can just insert data but cannot update or delete. Hence when you insert something, it stays there forever and no one can manipulate it- Thus name immutable ledger. 

voting systems have been used in recent years but none has completely eliminated these issues as they still require
But Building a blockchain system is not enough. It should be decentralized i.e if one server goes down or something happens on a particular node, other nodes can function normally and do not have to wait for victim node’s recovery. 
So a gist of advantages are listed below:
•	You can vote anytime/anywhere (During Pandemics like COVID-19 where it’s impossible to hold elections physically
•	Secure
•	Immutable
•	Faster
•	Transparent

Let’s visualize process 
It is always interesting to learn things if it’s visually explained. Hence diagram given below explains how the blockchain voting works. 
  

According to above diagram, voter needs to enter his/her credentials in order to vote. All data is then encrypted and stored as a transaction. This transaction is then broadcasted to every node in network, which in turn is then verified. If network approves transaction, it is stored in a block and added to chain. Note that once a block is added into chain, it stays there forever and can’t be updated. Users can now see results and also trace back transaction if they want. 

Since current voting systems don’t suffice to security needs of modern generation, there is a need to build a system that leverages security, convenience, and trust involved in voting process. Hence voting systems make use of Blockchain technology to add an extra layer of security and encourage people to vote from any time, anywhere without any hassle and makes voting process more cost-effective and time-saving.

# CONTRIBUTOR
Suleman Ismaila
Oluwafemi Oluwatoba

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
Gvote deployed to: 0x1Efa25bd75d3e3133B8E0CA985345B934922E13c
VotingSystem deployed to: 0xE54793A58bDFFF6BdAeb715c09238ad047d95B64
Deployment completed!
