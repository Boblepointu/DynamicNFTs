########################
## User defined vars ####
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
lb_dns_record_backend    = "dynamic-nfts-backend.frenchbtc.fr"

# ECS task definitions. How powerful we want the ECS pods.
task_definition_configs  = {
  frontend = {
    memory            = 512
    cpu               = 256
    soft_memory_limit = 505
  }
  backend = {
    memory            = 512
    cpu               = 256
    soft_memory_limit = 505
  }
  ipfs = {
    memory            = 512
    cpu               = 256
    soft_memory_limit = 505
  }
}