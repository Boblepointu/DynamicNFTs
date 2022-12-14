########################
## Aws defined vars ####
########################

# Global AWS account.
# Select the AWS region and AWS VPC id.
region                   = "eu-west-3"
vpc_id                   = "vpc-052bc5d16953c7e7b"

# Custom dns
# The dns zone must be preregistered and domain name NS records pointed to AWS NS.
dns_zone_name            = "frenchbtc.fr."
lb_dns_record_frontend   = "dynamic-nfts.frenchbtc.fr"
lb_dns_record_ipfs       = "dynamic-nfts-gateway.frenchbtc.fr"
lb_dns_record_ipfs_admin = "dynamic-nfts-gateway-admin.frenchbtc.fr"

########################
## User defined vars ###
########################

# Custom env name, can be anything. AWS resources name will include that.
environment              = "prod"
# Custom project name, can be anything. AWS resources name will include that.
project_name             = "dynamic-nfts"
# ECS task definitions. How powerful we want the ECS pods.
task_definition_configs  = {
  frontend = {
    memory            = 1024
    cpu               = 512
    soft_memory_limit = 1000
  }
  ipfs = {
    memory            = 4096
    cpu               = 2048
    soft_memory_limit = 4050
  }
}
# The login/password to access admin port on the IPFS ECS task
ipfs_login               = "admin"
ipfs_password            = "123123abcabc***"