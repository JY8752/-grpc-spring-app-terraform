variable "aws_access_key" {}
variable "secret_key" {}
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.secret_key
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
