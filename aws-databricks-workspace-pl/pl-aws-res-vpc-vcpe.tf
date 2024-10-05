//private links
//rest api
resource "aws_vpc_endpoint" "backend_rest" {
  vpc_id              = module.vpc.vpc_id
  service_name        = var.db_rest_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.pl_subnet.id]
  subnet_ids          = [for k,v in var.pl_subnets_cidr : aws_subnet.pl_subnet[k].id]
  private_dns_enabled = true
  tags = {
    Name = "${var.name_prefix}-be-rest-vpc-endpoint"
  }
  depends_on = [aws_subnet.pl_subnet, aws_security_group.pl_subnet]
}

resource "aws_vpc_endpoint" "relay" {
  vpc_id              = module.vpc.vpc_id
  service_name        = var.db_scc_relay_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.pl_subnet.id]
  subnet_ids          = [for k,v in var.pl_subnets_cidr : aws_subnet.pl_subnet[k].id]
  private_dns_enabled = true
  tags = {
    Name = "${var.name_prefix}-be-relay-vpc-endpoint"
  }
  depends_on = [aws_subnet.pl_subnet, aws_security_group.pl_subnet]
}

resource "databricks_mws_vpc_endpoint" "backend_rest_vpce" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.backend_rest.id
  vpc_endpoint_name   = "${var.name_prefix}-vpc-backend"
  region              = var.aws_region
  depends_on          = [aws_vpc_endpoint.backend_rest]
}

resource "databricks_mws_vpc_endpoint" "relay" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.relay.id
  vpc_endpoint_name   = "${var.name_prefix}-vpc-relay"
  region              = var.aws_region
  depends_on          = [aws_vpc_endpoint.relay]
}

