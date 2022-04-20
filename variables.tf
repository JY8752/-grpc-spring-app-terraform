//入力変数をローカルの変数にまとめる
locals {
  input = {
    app_name       = var.app_name,
    domain         = var.domain,
    docdb_username = var.docdb_username
  }
}

variable "app_name" {
  type        = string
  default     = null
  description = "application name"
}

variable "domain" {
  type        = string
  default     = null
  description = "外部で取得したドメイン名"
}

variable "docdb_username" {
  type        = string
  default     = ""
  description = "documentDBに指定するユーザー名"
}
