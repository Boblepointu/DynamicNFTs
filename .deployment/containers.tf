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
    container_port   = 3000
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
  container_definitions = jsonencode([
    {
      name              = "${var.project_name}-ipfs-${var.environment}"
      image             = "ipfs/go-ipfs"
      cpu               = var.task_definition_configs.ipfs.cpu
      memory            = var.task_definition_configs.ipfs.memory
      memoryReservation = var.task_definition_configs.ipfs.soft_memory_limit
      essential         = true
      # portMappings      = [ ]
      logConfiguration  = {
        logDriver       = "awslogs"
        secretOptions   = null
        options         = {
          awslogs-group         = aws_cloudwatch_log_group.ipfs.name
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