//create VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags,{
    Name = "${var.name_prefix}-vpc"
  })
}

