variable "name" {
  type        = string
  default     = ""
  description = "this is security_group name. e.x.) 'security-group-name' "
}
variable "vpc_id" {
  type        = string
  default     = ""
  description = "this is vpc_id."
}
variable "port" {
  type        = string
  default     = ""
  description = "this is ingress port number."
}
variable "cidr_blocks" {
  type        = list(string)
  default     = []
  description = "this is ingress cidr_blocks."
}
