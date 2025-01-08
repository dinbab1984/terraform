//VPC subnets for NAT Gateway
resource "aws_subnet" "nat_subnet_hub" {
  for_each               = var.nat_subnets_cidr_hub
  vpc_id                 = aws_vpc.vpc_hub.id
  availability_zone      = each.key
  cidr_block             = each.value
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-subnet-hub-${each.key}"
  })
  depends_on = [aws_vpc.vpc_hub]
}

//Elastic IP for NAT
resource "aws_eip" "nat_eip_hub" {
  for_each = var.nat_subnets_cidr_hub
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip-hub-${var.aws_region}${each.key}"
  })
}

// NAT Gateway
resource "aws_nat_gateway" "nat_gw_hub" {
  for_each = var.nat_subnets_cidr_hub
  allocation_id = aws_eip.nat_eip_hub[each.key].id
  subnet_id = aws_subnet.nat_subnet_hub[each.key].id
  depends_on    = [aws_eip.nat_eip_hub, aws_subnet.nat_subnet_hub]
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gw-hub-${var.aws_region}${each.key}"
  })
}

/* Routing table for NAT subnet */
resource "aws_route_table" "nat_subnet_hub_rt" {
  for_each = var.nat_subnets_cidr_hub
  vpc_id   = aws_vpc.vpc_hub.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-hub-route-tbl-${each.key}"
  })
  depends_on = [aws_vpc.vpc_hub]
}

resource "aws_route_table_association" "nat_rt_association" {
  for_each       = var.nat_subnets_cidr_hub
  subnet_id      = aws_subnet.nat_subnet_hub[each.key].id
  route_table_id = aws_route_table.nat_subnet_hub_rt[each.key].id
  depends_on     = [aws_subnet.nat_subnet_hub, aws_route_table.nat_subnet_hub_rt]
}