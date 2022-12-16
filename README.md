# DynamicNFTs
A simple all rounds implementation of dynamic NFTs collection, from infra to front.

# Requirements
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
	- The fee needed to run the oracle / operator (testnets, 0.1 LINK (100000000000000000), mainnets, 1 LINK (1000000000000000000)) (RPC_URL)

# Setting up CI variables

To make the CI work, and for it to do all the job, you need to setup repository action secrets.
The list is following :
              - PROJECT_NAME = whatever you want
              - ADMIN_IPFS_LOGIN = whatever you want
              - ADMIN_IPFS_PASSWORD = whatever you want
              - CONTRACT_NAME = whatever you want
              - CONTRACT_SYMBOL = whatever you want	      
              - AWS_ACCESS_KEY_ID
              - AWS_SECRET_ACCESS_KEY
              - LINK_CONTRACT_ADDRESS
              - ORACLE_CONTRACT_ADDRESS
              - LINK_FEE
              - PRIVATE_KEY
              - RPC_URL
              - NETWORK_ID

# Setting up Terraform variables

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

# Improvement possible

    - Develop the code to upgrade the Diamond through the CI
    - Allow multiple IPFS server to run concurrently
    - Configure fully Github with protected branches; PR prefill; PR restrictions; Github OWNERFILES
    - Two environment, dev and prod (minor adjustement)
    - Adding standard-version to manage versions in the package.json in parallel than in the github repository
    - Plug the docker image tags in the ECR registry to the repository tag
    - Fine grained AWS service account role / policies for all the actions performed by this repository
    - ...