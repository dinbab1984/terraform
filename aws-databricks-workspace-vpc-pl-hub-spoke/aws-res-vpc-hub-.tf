//create VPC Hub
resource "aws_vpc" "vpc_hub" {
  cidr_block           = var.cidr_block_hub
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags,{
    Name = "${var.name_prefix}-vpc-hub"
  })
}

