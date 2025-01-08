//Create transit gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway for Hub/Spoke"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tgw"
  })
}

//# Attach Spoke VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_spoke" {
  subnet_ids         = [ for k,v in var.private_subnets_cidr : aws_subnet.private_subnet[k].id ]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.this.id
  dns_support        = "enable"

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-tgw-spoke-attach"
    Purpose = "Transit Gateway Attachment - Spoke VPC"
  })
  depends_on = [ aws_ec2_transit_gateway.tgw, aws_vpc.this, aws_subnet.private_subnet ]
}

//Attach Transit / Hub VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_hub" {
  subnet_ids         = [ for k,v in var.nat_subnets_cidr_hub: aws_subnet.nat_subnet_hub[k].id ]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc_hub.id
  dns_support        = "enable"

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-tgw-hub-attach"
    Purpose = "Transit Gateway Attachment - Hub VPC"
  })
  depends_on = [ aws_ec2_transit_gateway.tgw, aws_vpc.vpc_hub, aws_subnet.nat_subnet_hub ]
}


// Create Route for 0.0.0.0/0 (Internet) from Spoke to Hub via Transit Gateway 
resource "aws_ec2_transit_gateway_route" "spoke_to_tgw" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}



// Add route for spoke private subnet to tgw
resource "aws_route" "spoke_private_subnet_to_tgw" {
  for_each               = var.private_subnets_cidr
  route_table_id         = aws_route_table.private_subnet_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_subnet.private_subnet, aws_ec2_transit_gateway.tgw]
}

// Add route for tgw to hub nat subnet

/*
resource "aws_route" "tgw_to_nat_subnet_hub" {
  for_each               = var.nat_subnets_cidr_hub
  route_table_id         = aws_ec2_transit_gateway.tgw.association_default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_hub[each.key].id
  depends_on             = [aws_ec2_transit_gateway.tgw, aws_nat_gateway.nat_gw_hub]
}

resource "aws_route" "tgw_to_nat_subnet_hub" {
  for_each               = var.nat_subnets_cidr_hub
  route_table_id         = aws_route_table.nat_subnet_hub_rt[each.key].id
  destination_cidr_block = var.spoke_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_vpc.spoke_db_vpc, aws_vpc.hub_db_vpc]
}
*/

