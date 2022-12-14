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