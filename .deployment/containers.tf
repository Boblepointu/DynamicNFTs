########################
#### ECS cluster #######
########################

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster-${var.environment}"
}

########################
#### ECR ressource #####
########################

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend-${var.environment}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "aws_ecr_repository-frontend-name" {
  value = aws_ecr_repository.frontend.name
}

resource "aws_ecr_repository" "ipfs" {
  name                 = "${var.project_name}-ipfs-${var.environment}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "aws_ecr_repository-ipfs-name" {
  value = aws_ecr_repository.ipfs.name
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

resource "aws_ecs_service" "ipfs" {
  name            = "${var.project_name}-ipfs-${var.environment}"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.ipfs.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 5

  load_balancer {
    target_group_arn = aws_lb_target_group.ipfs.arn
    container_name   = "${var.project_name}-ipfs-${var.environment}"
    container_port   = 5001
  }

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    assign_public_ip = true
    security_groups  = [ aws_security_group.ecs-ipfs.id ]
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
    aws_lb_listener.ipfs-https
  ]
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

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "ecs-task-execution-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################
#### ECS tasks #########
########################

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend-${var.environment}"
  requires_compatibilities = [ "FARGATE" ]
  network_mode             = "awsvpc"
  cpu                      = var.task_definition_configs.frontend.cpu
  memory                   = var.task_definition_configs.frontend.memory
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
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

resource "aws_ecs_task_definition" "ipfs" {
  family                   = "${var.project_name}-ipfs-${var.environment}"
  requires_compatibilities = [ "FARGATE" ]
  network_mode             = "awsvpc"
  cpu                      = var.task_definition_configs.ipfs.cpu
  memory                   = var.task_definition_configs.ipfs.memory
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_tasks_execution_role.arn
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
          containerPort = 80
          hostPort      = 80
        },
        {
          containerPort = 4001
          hostPort      = 4001
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
      root_directory          = "/"
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