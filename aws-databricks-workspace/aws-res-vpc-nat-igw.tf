//VPC public subnets for NAT Gateway
resource "aws_subnet" "public_subnet" {
  for_each               = var.public_subnets_cidr
  vpc_id                 = aws_vpc.this.id
  availability_zone      = each.key
  cidr_block             = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-public-subnet-${each.key}"
  }
  depends_on = [aws_vpc.this]
}

// Internet gateway for the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-igw"
  })
  depends_on = [aws_vpc.this]
}

//Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  for_each = var.public_subnets_cidr
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-nat-eip-${var.aws_region}${each.key}"
  })
}

// NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  for_each = var.public_subnets_cidr
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id = aws_subnet.public_subnet[each.key].id
  depends_on    = [aws_eip.nat_eip, aws_subnet.public_subnet]
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-nat-gw-${var.aws_region}${each.key}"
  })
}

