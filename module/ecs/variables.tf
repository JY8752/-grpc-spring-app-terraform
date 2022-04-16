variable "input" {
  type        = any
  default     = {}
  description = "input values. 'local.input' "
}

variable "subnets" {
  type        = list(string)
  default     = []
  description = "made by vpc module private subnet ids."
}

variable "vpc_cidr_block" {
  type        = string
  default     = ""
  description = "vpcのcidr_block"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "made by vpc module vpc id."
}

variable "target_group_arn" {
  type        = string
  default     = ""
  description = "ALBのターゲットグループarn"
}
