variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "public_subnet_count" {
  description = "Number of public subnets."
  type        = number
  default     = 2
}

variable "blue_app_version" {
  description = "Version of the docker image"
  type        = string
  default     = "v1"
}

variable "enable_blue_env" {
  description = "Enable blue environment"
  type        = bool
  default     = false
}

variable "blue_instance_count" {
  description = "Number of instances in blue environment"
  type        = number
  default     = 2
}
