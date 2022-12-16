########################
#### ECS secrets #######
########################

resource "aws_secretsmanager_secret" "ipfs-login" {
  name                    = "${var.project_name}-ipfs-login-${var.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ipfs-login" {
  secret_id     = aws_secretsmanager_secret.ipfs-login.id
  secret_string = var.ipfs_login
}

resource "aws_secretsmanager_secret" "ipfs-password" {
  name                    = "${var.project_name}-ipfs-password-${var.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ipfs-password" {
  secret_id     = aws_secretsmanager_secret.ipfs-password.id
  secret_string = var.ipfs_password
}

# resource "aws_secretsmanager_secret" "chainlink-database-url" {
#   name                    = "${var.project_name}-chainlink-database-url-${var.environment}"
#   recovery_window_in_days = 0
# }

# resource "aws_secretsmanager_secret_version" "chainlink-database-url" {
#   secret_id     = aws_secretsmanager_secret.chainlink-database-url.id
#   secret_string = "postgresql://${module.pg-cluster.cluster_master_username}:${module.pg-cluster.cluster_master_password}@${module.pg-cluster.cluster_endpoint}:${module.pg-cluster.cluster_port}/${module.pg-cluster.cluster_database_name}"
# }