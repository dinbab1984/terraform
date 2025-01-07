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
