########################
#### ECS cluster #######
########################

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster-${var.environment}"
}

output "aws_ecs_cluster-main-name" {
  value = aws_ecs_cluster.main.name
}

########################
#### ECR ressource #####
########################

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "aws_ecr_repository-frontend-name" {
  value = aws_ecr_repository.frontend.name
}

resource "aws_ecr_repository" "ipfs" {
  name                 = "${var.project_name}-ipfs-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "aws_ecr_repository-ipfs-name" {
  value = aws_ecr_repository.ipfs.name
}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "aws_ecr_repository-backend-name" {
  value = aws_ecr_repository.backend.name
}

########################
#### Log groups ########
########################

resource "aws_cloudwatch_log_group" "frontend" {
  name = "/ecs/${var.project_name}-frontend-${var.environment}"
}

resource "aws_cloudwatch_log_group" "ipfs" {
  name = "/ecs/${var.project_name}-ipfs-${var.environment}"
}

resource "aws_cloudwatch_log_group" "backend" {
  name = "/ecs/${var.project_name}-backend-${var.environment}"
}

########################
#### ECS services ######
########################

resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend-${var.environment}"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 5

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "${var.project_name}-frontend-${var.environment}"
    container_port   = 3000
  }

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    assign_public_ip = true
    security_groups  = [ aws_security_group.ecs-frontend.id ]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  depends_on = [
    aws_lb_listener.frontend-https
  ]
}

output "aws_ecs_service-frontend-name" {
  value = "${var.project_name}-frontend-${var.environment}"
}

resource "aws_ecs_service" "ipfs" {
  name            = "${var.project_name}-ipfs-${var.environment}"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.ipfs.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 5

  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = aws_lb_target_group.ipfs.arn
    container_name   = "${var.project_name}-ipfs-${var.environment}"
    container_port   = 3000
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ipfs-admin.arn
    container_name   = "${var.project_name}-ipfs-${var.environment}"
    container_port   = 3001
  }

  network_configuration {
    subnets          = data.aws_subnets.main.ids# [ data.aws_subnets.main.ids[2] ]
    assign_public_ip = true
    security_groups  = [ aws_security_group.ecs-ipfs.id ] #["sg-0f20dfc3b8d6d814b"]#[ aws_security_group.ecs-ipfs.id ]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  depends_on = [
    aws_lb_listener.ipfs-https,
    aws_lb_listener.ipfs-admin-https
  ]
}

output "aws_ecs_service-ipfs-name" {
  value = "${var.project_name}-ipfs-${var.environment}"
}

resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend-${var.environment}"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 5

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "${var.project_name}-backend-${var.environment}"
    container_port   = 3000
  }

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    assign_public_ip = true
    security_groups  = [ aws_security_group.ecs-backend.id ]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  depends_on = [
    aws_lb_listener.backend-https
  ]
}

output "aws_ecs_service-backend-name" {
  value = "${var.project_name}-backend-${var.environment}"
}

#####################################
#### ECS roles and policies #########
#####################################

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IPFS task
resource "aws_iam_policy" "ipfs-secrets" {
  name   = "${var.project_name}-ipfs-secrets-${var.environment}"
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.ipfs-login.arn
        },{
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.ipfs-password.arn
        },{
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Effect   = "Allow",
          Resource = "*"
        },{
          Action = [
            "elasticfilesystem:ClientMount",
            "elasticfilesystem:ClientWrite"
          ],
          Effect    = "Allow",
          Resource  = "*"        
        }
      ]
  })  
}

resource "aws_iam_policy" "backend-secrets" {
  name   = "${var.project_name}-backend-${var.environment}"
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Effect   = "Allow"
          Resource = aws_secretsmanager_secret.private-key.arn
        },{
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
  })  
}

resource "aws_iam_role" "ecs_ipfs_tasks_execution_role" {
  name               = "${var.project_name}-ipfs-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_ipfs_tasks_secrets" {
  role       = aws_iam_role.ecs_ipfs_tasks_execution_role.name
  policy_arn = aws_iam_policy.ipfs-secrets.arn
}

# Frontend task
resource "aws_iam_role" "ecs_frontend_tasks_execution_role" {
  name               = "${var.project_name}-frontend-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_frontend_tasks_default" {
  role       = aws_iam_role.ecs_frontend_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Backend task
resource "aws_iam_role" "ecs_backend_tasks_execution_role" {
  name               = "${var.project_name}-backend-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_backend_tasks_default" {
  role       = aws_iam_role.ecs_backend_tasks_execution_role.name
  policy_arn = aws_iam_policy.backend-secrets.arn
}

# Chainlink task
# resource "aws_iam_role" "ecs_chainlink_tasks_execution_role" {
#   name               = "${var.project_name}-chainlink-${var.environment}"
#   assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
# }

# resource "aws_iam_role_policy_attachment" "ecs_chainlink_tasks_default" {
#   role       = aws_iam_role.ecs_chainlink_tasks_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }


########################
#### ECS tasks #########
########################

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend-${var.environment}"
  requires_compatibilities = [ "FARGATE" ]
  network_mode             = "awsvpc"
  cpu                      = var.task_definition_configs.frontend.cpu
  memory                   = var.task_definition_configs.frontend.memory
  execution_role_arn       = aws_iam_role.ecs_frontend_tasks_execution_role.arn
  container_definitions = jsonencode([
    {
      name              = "${var.project_name}-frontend-${var.environment}"
      image             = "rebelthor/sleep"
      cpu               = var.task_definition_configs.frontend.cpu
      memory            = var.task_definition_configs.frontend.memory
      memoryReservation = var.task_definition_configs.frontend.soft_memory_limit
      essential         = true
      portMappings      = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "WEATHER_CONTRACT_ADDRESS"
          value = var.weather_contract_address
        },
        {
          name  = "DIAMOND_CONTRACT_ADDRESS"
          value = var.diamond_contract_address
        },
        {
          name  = "EXCLUSIVE_CONTRACT_ADDRESS"
          value = var.exclusive_contract_address
        },
        {
          name  = "BACKEND_HOST"
          value = var.lb_dns_record_backend
        },
        {
          name  = "NETWORK_ID"
          value = var.network_id
        }
      ]

      logConfiguration  = {
        logDriver       = "awslogs"
        secretOptions   = null
        options         = {
          awslogs-group         = aws_cloudwatch_log_group.frontend.name
          awslogs-region        = data.aws_region.main.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
  }
}

output "aws_ecs_task_definition-frontend-name" {
  value = aws_ecs_task_definition.frontend.family
}

resource "aws_ecs_task_definition" "ipfs" {
  family                   = "${var.project_name}-ipfs-${var.environment}"
  requires_compatibilities = [ "FARGATE" ]
  network_mode             = "awsvpc"
  cpu                      = var.task_definition_configs.ipfs.cpu
  memory                   = var.task_definition_configs.ipfs.memory
  execution_role_arn       = aws_iam_role.ecs_ipfs_tasks_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_ipfs_tasks_execution_role.arn
  container_definitions = jsonencode([
    {
      name              = "${var.project_name}-ipfs-${var.environment}"
      image             = "rebelthor/sleep"
      cpu               = var.task_definition_configs.ipfs.cpu
      memory            = var.task_definition_configs.ipfs.memory
      memoryReservation = var.task_definition_configs.ipfs.soft_memory_limit
      essential         = true
      portMappings      = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        },
        {
          containerPort = 3001
          hostPort      = 3001
          protocol      = "tcp"
        },
        {
          containerPort = 4001
          hostPort      = 4001
          protocol      = "udp"
        }        
      ]
      logConfiguration  = {
        logDriver       = "awslogs"
        secretOptions   = null
        options         = {
          awslogs-group         = aws_cloudwatch_log_group.ipfs.name
          awslogs-region        = data.aws_region.main.name
          awslogs-stream-prefix = "ecs"
        }
      }
      mountPoints = [
        {
          readOnly        = null,
          containerPath   = "/root/.ipfs",
          sourceVolume    = "ipfs-storage"
        }
      ]
      secrets = [
        {
          name      = "LOGIN",
          valueFrom = aws_secretsmanager_secret.ipfs-login.arn
        },
        {
          name      = "PASSWORD",
          valueFrom = aws_secretsmanager_secret.ipfs-password.arn
        }
      ]           
    }
  ])

  volume {
    name = "ipfs-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.ipfs.id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.ipfs-0.id
        iam             = "ENABLED"
      }
    }
  }

  runtime_platform {
    operating_system_family = "LINUX"
  }
}

output "aws_ecs_task_definition-ipfs-name" {
  value = aws_ecs_task_definition.ipfs.family
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend-${var.environment}"
  requires_compatibilities = [ "FARGATE" ]
  network_mode             = "awsvpc"
  cpu                      = var.task_definition_configs.backend.cpu
  memory                   = var.task_definition_configs.backend.memory
  execution_role_arn       = aws_iam_role.ecs_backend_tasks_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_backend_tasks_execution_role.arn
  container_definitions = jsonencode([
    {
      name              = "${var.project_name}-backend-${var.environment}"
      image             = "rebelthor/sleep"
      cpu               = var.task_definition_configs.backend.cpu
      memory            = var.task_definition_configs.backend.memory
      memoryReservation = var.task_definition_configs.backend.soft_memory_limit
      essential         = true
      portMappings      = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }       
      ]
      logConfiguration  = {
        logDriver       = "awslogs"
        secretOptions   = null
        options         = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = data.aws_region.main.name
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        {
          name  = "WEATHER_CONTRACT_ADDRESS"
          value = var.weather_contract_address
        },
        {
          name  = "RPC_URL"
          value = var.rpc_url
        },
        {
          name  = "LINK_FEE"
          value = var.link_fee
        },
        {
          name  = "LINK_CONTRACT_ADDRESS"
          value = var.link_contract_address
        },
        {
          name  = "DIAMOND_CONTRACT_ADDRESS"
          value = var.diamond_contract_address
        },
        {
          name  = "EXCLUSIVE_CONTRACT_ADDRESS"
          value = var.exclusive_contract_address
        }
      ]
      secrets = [
        {
          name      = "PRIVATE_KEY"
          valueFrom = aws_secretsmanager_secret.private-key.arn
        }
      ]           
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
  }
}

output "aws_ecs_task_definition-backend-name" {
  value = aws_ecs_task_definition.backend.family
}