// this subnet houses the data plane VPC endpoints
resource "aws_subnet" "subnet_pl_backend" {
  for_each               = var.backend_pl_subnets_cidr
  vpc_id                 = aws_vpc.this.id
  availability_zone      = each.key
  cidr_block             = each.value
  map_public_ip_on_launch = false

  tags = merge(var.tags,{
    Name = "${var.name_prefix}-subnet-pl-backend-${each.key}"
  })
  depends_on = [aws_vpc.this]
}


//Add security group for Backend Private Link 
resource "aws_security_group" "sg_pl_backend" {
  name        = "${var.name_prefix}-sg-pl-backend"
  description =  "Data Plane VPC endpoint security group for Backend Private Link"
  vpc_id      = aws_vpc.this.id
  tags =  merge(var.tags,{
    Name = "${var.name_prefix}-sg-pl-backend"
  })
}

// Add egress rule to Backend Private Link (rest)
resource "aws_vpc_security_group_egress_rule" "sg_egress_rule_backend_rest" {
  security_group_id = aws_security_group.sg_pl_backend.id
  cidr_ipv4   = var.cidr_block
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  tags =  merge(var.tags,{
    Name = "${var.name_prefix}-sg-egress-rule-backend-rest"
  })
  depends_on = [ aws_security_group.sg_pl_backend ]
}

// Add egress rule to Backend Private Link (scc relay)
resource "aws_vpc_security_group_egress_rule" "backend_scc_relay_sg_egress_rule" {
  security_group_id = aws_security_group.sg_pl_backend.id
  cidr_ipv4   = var.cidr_block
  from_port   = 6666
  ip_protocol = "tcp"
  to_port     = 6666
  tags = merge(var.tags,{
    Name = "${var.name_prefix}-sg-egress-rule-backend-scc-relay"
  })
  depends_on = [ aws_security_group.sg_pl_backend ]
}

// Add ingress rule to Backend Private Link (rest)
resource "aws_vpc_security_group_ingress_rule" "sg_ingress_rule_backend_rest" {
  security_group_id = aws_security_group.sg_pl_backend.id
  cidr_ipv4   = var.cidr_block
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  tags = merge(var.tags,{
    Name = "${var.name_prefix}-sg-ingress-rule-backend-rest"
  })
  depends_on = [ aws_security_group.sg_pl_backend ]
}

// Add ingress rule to Backend Private Link (scc relay)
resource "aws_vpc_security_group_ingress_rule" "backend_scc_relay_sg_ingress_rule" {
  security_group_id = aws_security_group.sg_pl_backend.id
  cidr_ipv4   = var.cidr_block
  from_port   = 6666
  ip_protocol = "tcp"
  to_port     = 6666
  tags = merge(var.tags,{
    Name = "${var.name_prefix}-sg-ingress-rule-backend-scc-relay"
  })
  depends_on = [ aws_security_group.sg_pl_backend ]
}

//private links
//rest api
resource "aws_vpc_endpoint" "vpce_backend_rest" {
  vpc_id              = aws_vpc.this.id
  service_name        = var.db_rest_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.sg_pl_backend.id]
  subnet_ids          = [for k,v in var.backend_pl_subnets_cidr : aws_subnet.subnet_pl_backend[k].id]
  private_dns_enabled = true
  tags = merge(var.tags,{
    Name = "${var.name_prefix}-vpce-backend-rest"
  })
  depends_on = [aws_subnet.subnet_pl_backend, aws_security_group.sg_pl_backend]
}

//scc relay
resource "aws_vpc_endpoint" "vpce_backend_scc_relay" {
  vpc_id              = aws_vpc.this.id
  service_name        = var.db_scc_relay_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.sg_pl_backend.id]
  subnet_ids          = [for k,v in var.backend_pl_subnets_cidr : aws_subnet.subnet_pl_backend[k].id]
  private_dns_enabled = true
  tags = merge(var.tags,{
    Name = "${var.name_prefix}-vpce-backend-scc-relay"
  })
  depends_on = [aws_subnet.subnet_pl_backend, aws_security_group.sg_pl_backend]
}

// register backend rest vpc private endpoint in databricks account
resource "databricks_mws_vpc_endpoint" "db_vpce_backend_rest" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.vpce_backend_rest.id
  vpc_endpoint_name   = "${var.name_prefix}-db-vpce-backend-rest"
  region              = var.aws_region
  depends_on          = [aws_vpc_endpoint.vpce_backend_rest]
}

// register scc relay vpc private endpoint in databricks account
resource "databricks_mws_vpc_endpoint" "db_vpce_backend_scc_relay" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.vpce_backend_scc_relay.id
  vpc_endpoint_name   = "${var.name_prefix}-db-vpce-backend-scc-relay"
  region              = var.aws_region
  depends_on          = [aws_vpc_endpoint.vpce_backend_scc_relay]
}

/* Routing table for subnet pl backend */
resource "aws_route_table" "rt_subnet_pl_backend" {
  for_each = var.backend_pl_subnets_cidr
  vpc_id   = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-route-tbl-subnet-pl-backend-${each.key}"
  })
  depends_on = [aws_vpc.this]
}

// Routing table associations - subnet pl subnet
resource "aws_route_table_association" "rta_subnet_pl_backend" {
  for_each  = var.backend_pl_subnets_cidr
  subnet_id = aws_subnet.subnet_pl_backend[each.key].id
  route_table_id = aws_route_table.rt_subnet_pl_backend[each.key].id
  depends_on = [aws_subnet.subnet_pl_backend, aws_route_table.rt_subnet_pl_backend]
}
