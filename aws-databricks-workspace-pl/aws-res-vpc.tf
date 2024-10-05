module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"
  name    = "${var.name_prefix}-vpc" // var.name_prefix
  cidr    = var.cidr_block //var.cidr_block (/25 for subnets)

  //azs  =  var.availability_zones
  //public_subnets  = [cidrsubnet("10.20.0.0/23", 2, 2), cidrsubnet("10.20.0.0/23", 2, 3)] //var.cidr_block
  //private_subnets = [cidrsubnet("10.20.0.0/23", 2, 0), cidrsubnet("10.20.0.0/23", 2, 1)] //var.cidr_block

  azs             = [for k,v in var.public_subnets_cidr : k]
  public_subnets  = [for k,v in var.public_subnets_cidr : v]
  private_subnets = [for k,v in var.private_subnets_cidr : v]

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  create_igw           = true

  manage_default_security_group = true
  default_security_group_name   = "${var.name_prefix}-sg"

  default_security_group_egress = [{
    cidr_blocks = "0.0.0.0/0"
  }]

  default_security_group_ingress = [{
    description = "Allow all internal TCP and UDP"
    self        = true
  }]
}


