/* Adding routes to route tables */
resource "aws_route" "private_to_public_nat_gtw" {
  for_each               = var.private_subnets_cidr
  route_table_id         = aws_route_table.private_subnet_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.key].id
  depends_on             = [aws_route_table.private_subnet_rt, aws_nat_gateway.nat_gw]
}

resource "aws_route" "public_nat_gtw_to_igw" {
  for_each               = var.nat_subnets_cidr
  route_table_id         = aws_route_table.nat_subnet_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.nat_subnet_rt, aws_internet_gateway.igw]
}

