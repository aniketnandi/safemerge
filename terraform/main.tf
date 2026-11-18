provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = { project = "safemerge", env = var.env, owner = var.owner }
  }
}

locals {
  prefix = "sm-${var.env}"
}

# Learner Lab gives us one role. Everything uses it. Never create IAM roles here.
data "aws_iam_role" "lab" {
  name = "LabRole"
}

data "aws_caller_identity" "me" {}


module "queues" {
  source = "./modules/queues"
  prefix = local.prefix
}
