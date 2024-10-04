resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.spoke_db_vpc.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [ for k,v in var.spoke_private_subnets_cidr : aws_route_table.spoke_db_private_rt[k].id]
  tags = {
    Name = "${var.name_prefix}-spoke-s3-vpc-endpoint"
  }
  depends_on = [aws_vpc.spoke_db_vpc, aws_route_table.spoke_db_private_rt]
}

resource "aws_vpc_endpoint" "kinesis-streams" {
  vpc_id          = aws_vpc.spoke_db_vpc.id
  security_group_ids = [aws_security_group.spoke_default_sg.id]
  service_name    = "com.amazonaws.${var.aws_region}.kinesis-streams"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids          = [ for k,v in var.spoke_private_subnets_cidr : aws_subnet.spoke_db_private_subnet[k].id ]
  tags = {
    Name = "${var.name_prefix}-spoke-kinesis-vpc-endpoint"
  }
  depends_on = [aws_vpc.spoke_db_vpc, aws_subnet.spoke_db_private_subnet]
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id = aws_vpc.spoke_db_vpc.id
  security_group_ids = [aws_security_group.spoke_default_sg.id]

  endpoints = {
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = [for k, v in var.spoke_private_subnets_cidr : aws_subnet.spoke_db_private_subnet[k].id]
      tags = {
        Name = "${var.name_prefix}-spoke-sts-vpc-endpoint"
      }
    },
  }
  tags = var.tags
}


//private links
//rest api
resource "aws_vpc_endpoint" "backend_rest" {
  vpc_id              = aws_vpc.spoke_db_vpc.id
  service_name        = var.db_rest_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.spoke_default_sg.id]
  subnet_ids          = [for k,v in var.spoke_private_subnets_cidr : aws_subnet.spoke_db_private_subnet[k].id]
  private_dns_enabled = true
  depends_on          = [aws_subnet.spoke_db_private_subnet]
  tags = {
    Name = "${var.name_prefix}-spoke-be-rest-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "relay" {
  vpc_id              = aws_vpc.spoke_db_vpc.id
  service_name        = var.db_scc_relay_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.spoke_default_sg.id]
  subnet_ids          = [for k,v in var.spoke_private_subnets_cidr : aws_subnet.spoke_db_private_subnet[k].id]
  private_dns_enabled = true
  depends_on          = [aws_subnet.spoke_db_private_subnet]
  tags = {
    Name = "${var.name_prefix}-spoke-be-relay-vpc-endpoint"
  }
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