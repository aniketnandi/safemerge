variable "prefix" {
  type        = string
  description = "Name prefix, for example sm-prod"
}

variable "account_id" {
  type        = string
  description = "AWS account ID, part of the bucket name"
}
