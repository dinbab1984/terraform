//VPC subnets for NAT Gateway
resource "aws_subnet" "nat_subnet" {
  for_each               = var.nat_subnets_cidr
  vpc_id                 = aws_vpc.this.id
  availability_zone      = each.key
  cidr_block             = each.value
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-subnet-${each.key}"
  })
  depends_on = [aws_vpc.this]
}

//Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  for_each = var.nat_subnets_cidr
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip-${var.aws_region}${each.key}"
  })
}

// NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  for_each = var.nat_subnets_cidr
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id = aws_subnet.nat_subnet[each.key].id
  depends_on    = [aws_eip.nat_eip, aws_subnet.nat_subnet]
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gw-${var.aws_region}${each.key}"
  })
}

/* Routing table for NAT subnet */
resource "aws_route_table" "nat_subnet_rt" {
  for_each = var.nat_subnets_cidr
  vpc_id   = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-route-tbl-${each.key}"
  })
  depends_on = [aws_vpc.this]
}

resource "aws_route_table_association" "nat_rt_association" {
  for_each       = var.nat_subnets_cidr
  subnet_id      = aws_subnet.nat_subnet[each.key].id
  route_table_id = aws_route_table.nat_subnet_rt[each.key].id
  depends_on     = [aws_subnet.nat_subnet, aws_route_table.nat_subnet_rt]
}

/* Adding routes to route tables */
//get ip adddress of metastore
data "dns_a_record_set" "metastore" {
  host = var.metastorefqdn
}

locals {
   private_subnet_rt_metastoreip = flatten([
    for addrs in data.dns_a_record_set.metastore.addrs : [
      for region_az, cidr in var.private_subnets_cidr : {
        metastoreip = addrs
        region_az   = region_az
      }
    ]
  ])
}

/*
output "private_subnet_rt_metastoreip" {
  value = local.private_subnet_rt_metastoreip
  
}
*/

resource "aws_route" "private_to_public_nat_gtw" {
  for_each               = { for k, v in local.private_subnet_rt_metastoreip : k => v }
  route_table_id         =  aws_route_table.private_subnet_rt[each.value.region_az].id
  destination_cidr_block = "${each.value.metastoreip}/32"
  //destination_cidr_block = "3.255.48.43/32"
  //destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.value.region_az].id
  depends_on             = [aws_route_table.private_subnet_rt, aws_nat_gateway.nat_gw]
}


resource "aws_route" "public_nat_gtw_to_igw" {
  for_each               = { for k, v in local.private_subnet_rt_metastoreip : k => v }
  route_table_id         =  aws_route_table.nat_subnet_rt[each.value.region_az].id
  destination_cidr_block = "${each.value.metastoreip}/32"
  //destination_cidr_block = "3.255.48.43/32" 
  //destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.nat_subnet_rt, aws_internet_gateway.igw]
}
