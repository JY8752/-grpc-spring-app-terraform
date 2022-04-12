variable "input" {
  type        = any
  default     = {}
  description = "input values. 'local.input' "
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "made by vpc module vpc id."
}

variable "dns_name" {
  type        = string
  default     = ""
  description = "ALBのDNS名."
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "ALBのゾーンID"
}
