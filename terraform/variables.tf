variable "env" {
  type        = string
  description = "prod or dev"
}

variable "owner" {
  type        = string
  description = "Person who owns this deployment"
}

variable "demo_image_tag" {
  type        = string
  default     = "630b539"
  description = "demo-api image tag for the first staging task definition"
}
