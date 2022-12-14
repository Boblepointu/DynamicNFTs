########################
####     EFS       #####
########################

resource "aws_efs_file_system" "ipfs" {
  creation_token = "${var.project_name}-ipfs-${var.environment}"
  encrypted      = true
}

resource "aws_efs_access_point" "ipfs-0" {
  file_system_id = aws_efs_file_system.ipfs.id
  
  root_directory {
    path = "/ipfs-0"
  }
}

resource "aws_efs_mount_target" "ipfs" {
  for_each = {
    for subnet in data.aws_subnets.main.ids : subnet => {
      id = subnet
    }
  }

  file_system_id = aws_efs_file_system.ipfs.id
  subnet_id      = each.key
}

resource "aws_efs_file_system_policy" "ipfs" {
  file_system_id = aws_efs_file_system.ipfs.id
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{    
        Principal = { AWS = "*" }
        Action    = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Effect    = "Allow"
        Condition = {
            Bool = { "elasticfilesystem:AccessedViaMountTarget": "true" }
        }
        Resource = aws_efs_file_system.ipfs.arn
      }]
  })
}