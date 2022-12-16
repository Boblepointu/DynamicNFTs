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
# variable "db_password" {
#   type        = string
#   description = "The password to access pg database"
# }