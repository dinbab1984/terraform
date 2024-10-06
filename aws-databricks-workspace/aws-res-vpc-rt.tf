/* Routing table for private subnet */
resource "aws_route_table" "private_subnet_rt" {
  for_each = var.private_subnets_cidr
  vpc_id   = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-private-route-tbl-${var.aws_region}${each.key}"
  })
  depends_on = [aws_vpc.this]
}

/* Routing table for public subnet */
resource "aws_route_table" "public_subnet_rt" {
  for_each = var.public_subnets_cidr
  vpc_id   = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-public-route-tbl-${var.aws_region}${each.key}"
  })
  depends_on = [aws_vpc.this]
}

/* Routing table for internet gateway */
resource "aws_route_table" "igw_rt" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-igw-rt"
  })
  depends_on = [aws_vpc.this]
}

/* Routing table associations */
resource "aws_route_table_association" "private_rt_association" {
  for_each       = var.private_subnets_cidr
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_subnet_rt[each.key].id
  depends_on     = [aws_subnet.private_subnet, aws_route_table.private_subnet_rt]
}

resource "aws_route_table_association" "public_rt_association" {
  for_each       = var.public_subnets_cidr
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_subnet_rt[each.key].id
  depends_on     = [aws_subnet.public_subnet, aws_route_table.public_subnet_rt]
}

resource "aws_route_table_association" "vpc_igw" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.igw_rt.id
  depends_on     = [aws_internet_gateway.igw, aws_route_table.igw_rt]
}

/* Adding routes to route tables */
resource "aws_route" "private_to_public_nat_gtw" {
  for_each               = var.private_subnets_cidr
  route_table_id         = aws_route_table.private_subnet_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.key].id
  depends_on             = [aws_route_table.private_subnet_rt, aws_nat_gateway.nat_gw]
}

resource "aws_route" "public_nat_gtw_to_igw" {
  for_each               = var.public_subnets_cidr
  route_table_id         = aws_route_table.public_subnet_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.public_subnet_rt, aws_internet_gateway.igw]
}
