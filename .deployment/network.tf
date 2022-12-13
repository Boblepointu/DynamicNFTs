########################
#### VPC ###############
########################

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [ data.aws_vpc.main.id ]
  }
}

########################
#### Security group ####
########################

resource "aws_security_group" "ecs-backend" {
  name = "${var.project_name}-ecs-backend-${var.environment}"

  ingress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = [ data.aws_vpc.main.cidr_block ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb-backend" {
  name = "${var.project_name}-lb-backend-${var.environment}"

  ingress {
    description      = "HTTPS for all"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP for all"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

##################################
#### Load balancer backend   #####
##################################

resource "aws_lb" "backend" {
  name               = "${var.project_name}-backend-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.lb-backend.id ]

  subnets            = data.aws_subnets.main.ids
}

resource "aws_lb_listener" "backend-http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "backend-https" {
  load_balancer_arn = aws_lb.backend.arn

  port            = "443"
  protocol        = "HTTPS"
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.backend.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

resource "aws_lb_target_group" "backend" {
  name                 = "${var.project_name}-backend-${var.environment}"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = data.aws_vpc.main.id
  deregistration_delay = 5
  health_check {
    enabled           = true
    healthy_threshold = 2
    interval          = 5
    timeout           = 3
    path              = "/healthcheck"
  }
}