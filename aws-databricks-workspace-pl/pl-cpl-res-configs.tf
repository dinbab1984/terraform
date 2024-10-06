// this subnet houses the data plane VPC endpoints
resource "aws_subnet" "pl_subnet" {
  for_each               = var.pl_subnets_cidr
  vpc_id                 = aws_vpc.this.id
  availability_zone      = each.key
  cidr_block             = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-pl-subnet-${each.key}"
  }
  depends_on = [aws_vpc.this]
}

//Add security group to pl subnet
resource "aws_security_group" "pl_subnet" {
  name        = "Data Plane VPC endpoint security group"
  description = "Security group shared with relay and workspace endpoints"
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = toset([
      443,
      2443, # FIPS port for CSP
      6666,
    ])

    content {
      description = "Inbound rules"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]
    }
  }

  dynamic "egress" {
    for_each = toset([
      443,
      2443, # FIPS port for CSP
      6666,
    ])

    content {
      description = "Outbound rules"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]
    }
  }

  tags =  {
    Name = "${var.name_prefix}-pl-vpce-sg-rules"
  }
}

//private links
//rest api
resource "aws_vpc_endpoint" "backend_rest" {
  vpc_id              = aws_vpc.this.id
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
  vpc_id              = aws_vpc.this.id
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

