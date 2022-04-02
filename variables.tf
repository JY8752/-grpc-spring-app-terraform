//入力変数をローカルの変数にまとめる
locals {
  input = {
    app_name = var.app_name
  }
}

variable "app_name" {
  type        = string
  default     = null
  description = "application name"
}
