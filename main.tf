module "vpc" {
  source = "./module/vpc"
  input  = local.input
}

module "alb" {
  source              = "./module/alb"
  input               = local.input
  subnets             = module.vpc.public_subnets
  vpc_id              = module.vpc.vpc_id
  acm_certificate_arn = module.route53.acm_certificate_arn
}

module "route53" {
  source   = "./module/route53"
  input    = local.input
  vpc_id   = module.vpc.vpc_id
  dns_name = module.alb.alb_dns_name
  zone_id  = module.alb.alb_zone_id
}

module "documentdb" {
  source  = "./module/documentdb"
  input   = local.input
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
}

module "ecs" {
  source           = "./module/ecs"
  input            = local.input
  subnets          = module.vpc.private_subnets
  vpc_id           = module.vpc.vpc_id
  vpc_cidr_block   = module.vpc.vpc_cidr_block
  target_group_arn = module.alb.target_group_arn
}
