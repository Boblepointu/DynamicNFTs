terraform {
  backend "s3" {
    bucket = "frenchbtc-terraform-state-files"
    region = "eu-west-3"
  }
}

variable "region" {
  type = string
  description = "AWS region"
}

variable "environment" {
  type = string
  description = "Environment (prod / preprod / staging / dev ...)"
}

variable "project_name" {
  type = string
  description = "Project name"
}

# Route 53

variable "dns_zone_name" {
  type        = string
  description = "Domain name"
}

variable "lb_dns_record_frontend" {
  type        = string
  description = "AWS route53 record domain name for ALB"
}

variable "lb_dns_record_ipfs" {
  type        = string
  description = "AWS route53 record domain name for ALB"
}

variable "lb_dns_record_ipfs_admin" {
  type        = string
  description = "AWS route53 record domain name for ALB"
}

variable "lb_dns_record_backend" {
  type        = string
  description = "AWS route53 record domain name for ALB"
}

# variable "lb_dns_record_chainlink" {
#   type        = string
#   description = "AWS route53 record domain name for ALB"
# }

# Network

variable "vpc_id" {
  type        = string
  description = "AWS main vpc id"
}

# ECS Configuration

variable "task_definition_configs" {
  type        = map(any)
  description = "Configuration of ECS frontend task"
}

# IPFS Configuration
variable "ipfs_login" {
  type        = string
  description = "The login to access IPFS admin port"
}
variable "ipfs_password" {
  type        = string
  description = "The password to access IPFS admin port"
}

# Chain Configuration
variable "private_key" {
  type        = string
  description = "The private key to operate the smart contract"
}

variable "rpc_url" {
  type        = string
  description = "The RPC to connect to"
}

variable "weather_contract_address" {
  type        = string
  description = "The weather contract address"
}

variable "link_fee" {
  type        = string
  description = "The link fee to ask oracle"
}

variable "link_contract_address" {
  type        = string
  description = "The address of the ERC20 link contract"
}

variable "diamond_contract_address" {
  type        = string
  description = "The address of the diamond contract"
}

variable "exclusive_contract_address" {
  type        = string
  description = "The address of the exclusive contract, to be able to mint in advance nfts"
}

variable "network_id" {
  type        = string
  description = "The network id to operate"
}

variable "sale_start_timestamp" {
  type        = string
  description = "The timestamp at which the sale start"
}