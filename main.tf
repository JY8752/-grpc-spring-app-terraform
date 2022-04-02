#VPC
module "vpc" {
  source = "./module/vpc"
  input  = local.input
}
