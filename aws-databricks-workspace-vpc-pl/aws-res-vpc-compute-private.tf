//VPC private subnets
resource "aws_subnet" "private_subnet" {
  for_each               = var.private_subnets_cidr
  vpc_id                 = aws_vpc.this.id
  availability_zone      = each.key
  cidr_block             = each.value
  map_public_ip_on_launch = false
  
  tags = merge(var.tags,{
    Name = "${var.name_prefix}-private-subnet-${each.key}"
  })
  depends_on = [aws_vpc.this]
}

/* Routing table for private subnet */

resource "aws_route_table" "private_subnet_rt" {
  for_each = var.private_subnets_cidr
  vpc_id   = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-private-route-tbl-${each.key}"
  })
  depends_on = [aws_vpc.this]
}

// Routing table associations - private subnet
resource "aws_route_table_association" "spoke_db_private_rta" {
  for_each  = var.private_subnets_cidr
  subnet_id = aws_subnet.private_subnet[each.key].id
  //count          = length(var.private_subnets_cidr)
  //subnet_id      = element(aws_subnet.db_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_subnet_rt[each.key].id
  depends_on = [aws_subnet.private_subnet, aws_route_table.private_subnet_rt]
}
