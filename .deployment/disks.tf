########################
####     EFS       #####
########################

resource "aws_efs_file_system" "ipfs" {
  creation_token = "${var.project_name}-ipfs-${var.environment}"
}

resource "aws_efs_access_point" "ipfs-0" {
  file_system_id = aws_efs_file_system.ipfs.id
  
  root_directory {
    path = "/ipfs-0"
  }
}