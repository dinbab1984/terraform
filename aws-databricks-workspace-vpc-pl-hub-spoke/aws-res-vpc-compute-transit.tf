// Transit Gateway subnet
resource "aws_subnet" "tgw_subnet" {
  for_each = var.tgw_subnets_cidr
  vpc_id   = aws_vpc.this.id
  cidr_block = each.value
  availability_zone = "${var.aws_region}${each.key}"
  map_public_ip_on_launch = true // to be checked
  tags = merge(var.tags, {
    //Name = "${var.name_prefix}-db-nat-public-${element(data.aws_availability_zones.available.names, count.index)}"
    Name = "${var.name_prefix}--tgw-subnet-${var.aws_region}${each.key}"
  })
  depends_on = [aws_vpc.this]
}
