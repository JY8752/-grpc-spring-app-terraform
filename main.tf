variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "ap-northeast-1"
}

module "vpc" {
  source = "./module/vpc"
  input  = local.input
}

module "alb" {
  source  = "./module/alb"
  input   = local.input
  subnets = module.vpc.public_subnets
  vpc_id  = module.vpc.vpc_id
}
