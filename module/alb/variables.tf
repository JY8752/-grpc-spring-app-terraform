variable "input" {
  type        = any
  default     = {}
  description = "input values. 'local.input' "
}

variable "subnets" {
  type        = list(string)
  default     = []
  description = "made by vpc module public subnet ids."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "made by vpc module vpc id."
}
