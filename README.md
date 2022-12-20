# DynamicNFTs

A simple all rounds implementation of dynamic NFTs collection, from infra to front.

## Requirements

- An AWS account (AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY)
- A Route53 zone registered in the AWS account (dns_zone_name)
- A S3 bucket (bucket)
- An Ethereum VM private key (dedicated to the management of these contracts) (PRIVATE_KEY): 
	- with some test ETH (at least 0.15 for Goerli)
	- with some LINK (at least 5-10 for Goerli)
- A RPC URL for the network you will be executing for (RPC_URL)
- The network id for that network (NETWORK_ID)
- The address of the LINK oracle contract / operator on that network (ORACLE_CONTRACT_ADDRESS)
- The address of the LINK token contract on that network (LINK_CONTRACT_ADDRESS)
- The fee needed to run the oracle / operator (testnets, 0.1 LINK (100000000000000000), mainnets, 1 LINK (1000000000000000000)) (LINK_FEE)
- The address of a ERC721 contract, that will allow its holders to mint in advance the token of our contract
- The timestamp to start the sell

## How to operate this repo
### Setting up CI variables

To make the CI work, and for it to do all the job, you need to setup repository action secrets.
The list is following :

- PROJECT_NAME 
  - Whatever you want
- ADMIN_IPFS_LOGIN 
  - Whatever you want
- ADMIN_IPFS_PASSWORD 
  - Whatever you want
- CONTRACT_NAME 
  - Whatever you want
- CONTRACT_SYMBOL
  - Whatever you want
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- LINK_CONTRACT_ADDRESS
  - The ChainLink official token contract address.
- ORACLE_CONTRACT_ADDRESS
  - The ChainLink official oracle contract address.
- LINK_FEE
  - In wei.
- PRIVATE_KEY
  - Without the `0x` at the beginning.
- RPC_URL
  - Preferred a WS one. Truffle won't like any error, and WS lower down the chance to encounter one.
- NETWORK_ID
  - Network id. For goerli, per example, put `5` here.
- SALE_START_TIMESTAMP
  - Timestamp, in second, of when the sale will start.
- EXCLUSIVE_CONTRACT_ADDRESS
  - The contract that make its holders exclusive member on this mint operation.
- DIAMOND_CONTRACT_ADDRESS
  - At first run, before having deployed your contract, set it to 0x00, then, once contracts have been deployed, set it to the actual address of the weather contract (See artifact truffle_output in CI) and relaunch the CI, having setted the ./contract_deployment_switch file to 0).
- WEATHER_CONTRACT_ADDRESS 
  - At first run, before having deployed your contract, set it to 0x00, then, once contracts have been deployed, set it to the actual address of the weather contract (See artifact truffle_output in CI) and relaunch the CI, having setted the ./contract_deployment_switch file to 0).
- SALE_START_TIMESTAMP

### Setting up Terraform variables

Some variables are setted into terraform. You'll find that file @ .deployment/variables.tfvars
Please define :

- region (AWS region to operate)
- vpc_id (The AWS vpc to operate)
- dns_zone_name (must exist in AWS Route53)
- lb_dns_record_frontend (must be a subdomain of dns_zone_name, will be created automatically)
- lb_dns_record_ipfs (must be a subdomain of dns_zone_name, will be created automatically)
- lb_dns_record_ipfs_admin (must be a subdomain of dns_zone_name, will be created automatically)
- lb_dns_record_backend (must be a subdomain of dns_zone_name, will be created automatically)

And, at last, the S3 bucket that will hold the terraform state files, necessary for it to work, you will find it @ .deployment/variables.tf, at the top of the file. Define here "bucket" (must be created beforehand) and "region" which is the AWS region to operate.

## Improvement possible

- Develop the code to upgrade the Diamond through the CI
- Allow multiple IPFS server to run concurrently
- Configure fully Github with protected branches; PR prefill; PR restrictions; Github OWNERFILES
- Two environment, dev and prod (minor adjustement)
- Adding standard-version to manage versions in the package.json in parallel than in the github repository
- Plug the docker image tags in the ECR registry to the repository tag
- Fine grained AWS service account role / policies for all the actions performed by this repository
- Take time to integrate fully ERC721 + extensions implementations into facets / inheritance
- Import the contracts code to etherscan
- ...
