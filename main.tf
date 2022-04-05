module "vpc" {
  source = "./module/vpc"
  input  = local.input
}

module "alb" {
  source  = "./module/alb"
  input   = local.input
  subnets = module.vpc.public_subnets
}
