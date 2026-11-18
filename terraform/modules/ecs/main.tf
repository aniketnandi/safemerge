# --- Network: the default VPC and its default public subnets (looked up, not created) ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_region" "current" {}

# --- Security groups (design from Aniket's S0-4 test) ---
resource "aws_security_group" "staging" {
  name        = "${var.prefix}-staging-sg"
  description = "Staging app: port 4000 only from the pentest task"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "pentest" {
  name        = "${var.prefix}-pentest-sg"
  description = "Pentest task: no inbound, outbound only to staging and AWS"
  vpc_id      = data.aws_vpc.default.id
}

# The only way into staging: TCP 4000 from the pentest security group
resource "aws_vpc_security_group_ingress_rule" "staging_from_pentest" {
  security_group_id            = aws_security_group.staging.id
  referenced_security_group_id = aws_security_group.pentest.id
  ip_protocol                  = "tcp"
  from_port                    = 4000
  to_port                      = 4000
  description                  = "App port, from the pentest task only"
}

resource "aws_vpc_security_group_egress_rule" "staging_https_out" {
  security_group_id = aws_security_group.staging.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "ECR image pulls and CloudWatch logs"
}

resource "aws_vpc_security_group_egress_rule" "pentest_to_staging" {
  security_group_id            = aws_security_group.pentest.id
  referenced_security_group_id = aws_security_group.staging.id
  ip_protocol                  = "tcp"
  from_port                    = 4000
  to_port                      = 4000
  description                  = "Pentest traffic to staging"
}

resource "aws_vpc_security_group_egress_rule" "pentest_https_out" {
  security_group_id = aws_security_group.pentest.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "ECR, CloudWatch logs, S3, DynamoDB"
}

# --- ECS cluster and logs ---
resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
}

resource "aws_cloudwatch_log_group" "staging" {
  name              = "/${var.prefix}/staging"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "pentest" {
  name              = "/${var.prefix}/pentest"
  retention_in_days = 14
}

# --- Staging task definition ---
# The deploy gate registers a new revision for each new image.
resource "aws_ecs_task_definition" "staging" {
  family                   = "${var.prefix}-staging"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.lab_role_arn
  task_role_arn            = var.lab_role_arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([{
    name         = "staging"
    image        = var.demo_image
    essential    = true
    portMappings = [{ containerPort = 4000, protocol = "tcp" }]

    # ECS marks the task HEALTHY once /health answers. The deploy gate waits for this.
    healthCheck = {
      command     = ["CMD-SHELL", "wget -q -O- http://localhost:4000/health || exit 1"]
      interval    = 10
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.staging.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "staging"
      }
    }
  }])
}

# --- Pentest task definition (created only once a pentest image is set) ---
# The deploy gate passes TARGET_URL as an override when it runs this task.
resource "aws_ecs_task_definition" "pentest" {
  count = var.pentest_image == "" ? 0 : 1

  family                   = "${var.prefix}-pentest"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = var.lab_role_arn
  task_role_arn            = var.lab_role_arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([{
    name      = "pentest"
    image     = var.pentest_image
    essential = true

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.pentest.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "pentest"
      }
    }
  }])
}
