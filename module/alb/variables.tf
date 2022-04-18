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

variable "acm_certificate_arn" {
  type        = string
  default     = null
  description = "定義したSSL証明書のarn"
}

variable "acm_certificate" {
  type = any
  default = null
  description = "定義したSSL証明書"
}

locals {
  alb_account_id = "582318560864"
}
