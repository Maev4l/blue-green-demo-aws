variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "enable_bastion" {
  description = "Enable Bastion"
  type        = bool
  default     = false
}

variable "public_subnet_count" {
  description = "Number of public subnets."
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets."
  type        = number
  default     = 2
}

variable "blue_app_version" {
  description = "Version of the docker image for blue instances"
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

variable "green_app_version" {
  description = "Version of the docker image for green instances"
  type        = string
  default     = "v2"
}

variable "enable_green_env" {
  description = "Enable green environment"
  type        = bool
  default     = false
}

variable "green_instance_count" {
  description = "Number of instances in green environment"
  type        = number
  default     = 2
}

variable "traffic_distribution" {
  description = "Levels of traffic distribution"
  type        = string
  default     = "even"
}
