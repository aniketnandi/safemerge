# LabRole is the only role we have. Read it, never create roles.
data "aws_iam_role" "lab" {
  name = "LabRole"
}

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

resource "aws_security_group" "pentest" {
  name        = "sm-dev-pentest-sg"
  description = "pentest task"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "staging" {
  name        = "sm-dev-staging-sg"
  description = "staging task"
  vpc_id      = data.aws_vpc.default.id
}

# Staging accepts TCP 4000 ONLY from members of pentest-sg
resource "aws_vpc_security_group_ingress_rule" "staging_from_pentest" {
  security_group_id            = aws_security_group.staging.id
  referenced_security_group_id = aws_security_group.pentest.id
  ip_protocol                  = "tcp"
  from_port                    = 4000
  to_port                      = 4000
}

# HTTPS out for ECR image pulls and CloudWatch logs
resource "aws_vpc_security_group_egress_rule" "staging_https" {
  security_group_id = aws_security_group.staging.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "pentest_https" {
  security_group_id = aws_security_group.pentest.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# Pentest may reach staging on 4000 and nothing else internal
resource "aws_vpc_security_group_egress_rule" "pentest_to_staging" {
  security_group_id            = aws_security_group.pentest.id
  referenced_security_group_id = aws_security_group.staging.id
  ip_protocol                  = "tcp"
  from_port                    = 4000
  to_port                      = 4000
}

resource "aws_ecr_repository" "demo_api" {
  name         = "demo-api"
  force_delete = true
}

resource "aws_ecr_repository" "pentest" {
  name         = "safemerge-pentest"
  force_delete = true
}

resource "aws_cloudwatch_log_group" "s0" {
  name              = "/ecs/sm-dev-s0"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "s0" {
  name = "sm-dev-s0"
}

resource "aws_ecs_task_definition" "staging" {
  family                   = "sm-dev-staging-test"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.lab.arn
  task_role_arn            = data.aws_iam_role.lab.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([{
    name         = "staging"
    image        = "${aws_ecr_repository.demo_api.repository_url}:s0-test"
    essential    = true
    portMappings = [{ containerPort = 4000, protocol = "tcp" }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.s0.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "staging"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "pentest" {
  family                   = "sm-dev-pentest-test"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = data.aws_iam_role.lab.arn
  task_role_arn            = data.aws_iam_role.lab.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([{
    name      = "pentest"
    image     = "${aws_ecr_repository.pentest.repository_url}:s0-test"
    essential = true
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.s0.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "pentest"
      }
    }
  }])
}
