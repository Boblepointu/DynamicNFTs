#########################################
#### Aurora cluster for chainlink #######
#########################################

# module "pg-cluster" {
#   source  = "terraform-aws-modules/rds-aurora/aws"

#   name           = "${var.project_name}-pg-${var.environment}"
#   engine         = "aurora-postgresql"
#   engine_version = "13.7"
#   instance_class = "db.t3.medium"
#   instances = {
#     1 = {
#       instance_class      = "db.t3.medium"
#       publicly_accessible = true
#     }
#   }

#   database_name = "chainlink"

#   vpc_id  = data.aws_vpc.main.id
#   subnets = data.aws_subnets.main.ids

#   create_db_subnet_group = true
#   create_security_group  = true

#   allowed_security_groups = [ aws_security_group.rds.id ]
#   allowed_cidr_blocks     = [ data.aws_vpc.main.cidr_block ]

#   storage_encrypted   = true
#   apply_immediately   = true
#   skip_final_snapshot = true
  
#   iam_database_authentication_enabled = true
#   master_password = var.db_password
#   monitoring_interval = 10

#   create_db_parameter_group      = true
#   db_parameter_group_name        = "${var.project_name}-pg-${var.environment}"
#   db_parameter_group_family      = "aurora-postgresql13"

#   create_db_cluster_parameter_group = true
#   db_cluster_parameter_group_name = "${var.project_name}-pg-${var.environment}"
#   db_cluster_parameter_group_family = "aurora-postgresql13"

#   enabled_cloudwatch_logs_exports = [ "postgresql" ]
# }