//create VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

//VPC private subnets
resource "aws_subnet" "private_subnet" {
  for_each               = var.private_subnets_cidr
  vpc_id                 = aws_vpc.this.id
  availability_zone      = each.key
  cidr_block             = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-private-subnet-${each.key}"
  }
  depends_on = [aws_vpc.this]
}
