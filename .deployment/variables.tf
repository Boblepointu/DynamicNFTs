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

variable "lb_dns_record_backend" {
  type        = string
  description = "AWS route53 record domain name for ALB"
}

# Network

variable "vpc_id" {
  type        = string
  description = "AWS main vpc id"
}

# ECS Configuration
variable "task_definition_configs" {
  type        = map(any)
  description = "Configuration of ECS backend task"
}

# variable "isinternallb" {
#   type        = bool
#   description = "Is the LB internal or not"
#   default     = true
# }




# variable "list_subnets" {
#   type        = list(string)
#   description = "List of subnet from main vpc"
#   default     = ["subnet-038fe3c675da7ac3a", "subnet-31d73c7d"]
# }

# # SSL
# variable "certificate_arn" {
#   type        = string
#   description = "ssl certificate for front load balancer"
#   default     = "arn:aws:acm:eu-west-2:405310318356:certificate/60ea4d38-f644-4572-bee7-302e9b127593"
# }



# variable "efs_id" {
#   type        = map(any)
#   description = "This is the holder of configuration files"
# }

# variable "cluster_name" {
#   type        = string
#   description = "This is the ECS cluster name"
#   default     = "MyNFT"
# }

# variable "ecs_policy_arn" {
#   type        = string
#   description = "AWS arn of the ecs permissions (Access EFS)"
#   default     = "arn:aws:iam::405310318356:role/ECSTaskRoleForEFS"
# }

