#VPC
module "vpc" {
  source = "./module/vpc"
  input  = local.input
}

module "vpc_sg" {
  source      = "./module/sg"
  name        = local.input.app_name
  vpc_id      = module.vpc.vpc_id
  port        = "80"
  cidr_blocks = ["0.0.0.0/0"]
}
