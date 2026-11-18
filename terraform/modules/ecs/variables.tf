variable "prefix" {
  type        = string
  description = "Name prefix, for example sm-prod"
}

variable "lab_role_arn" {
  type        = string
  description = "LabRole ARN, used as both task role and execution role"
}

variable "demo_image" {
  type        = string
  description = "Full image URI for the staging app, for example <registry>/demo-api:630b539"
}

variable "pentest_image" {
  type        = string
  default     = ""
  description = "Full image URI for the pentest task. Leave empty until the pentest image exists."
}
