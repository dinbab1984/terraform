// this subnet houses the data plane VPC endpoints
resource "aws_subnet" "pl_subnet" {
  for_each               = var.pl_subnets_cidr
  vpc_id                 = module.vpc.vpc_id
  availability_zone      = each.key
  cidr_block             = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-pl-subnet-${each.key}"
  }
  depends_on = [module.vpc]
}
/*
//route table for pl
resource "aws_route_table" "pl_local_route_tbl" {
  for_each = var.privatelink_subnets_cidr
  vpc_id  = data.aws_vpc.workspace_vpc.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-pl-local-route-tbl-${each.key}"
  })
}

//Associate route table with pl subnet
resource "aws_route_table_association" "dataplane_vpce_rtb" {
  for_each = var.privatelink_subnets_cidr
  subnet_id      = aws_subnet.pl_subnet[each.key].id
  route_table_id = aws_route_table.pl_local_route_tbl[each.key].id
}
*/
//Add security group to pl subnet
resource "aws_security_group" "pl_subnet" {
  name        = "Data Plane VPC endpoint security group"
  description = "Security group shared with relay and workspace endpoints"
  vpc_id      = module.vpc.vpc_id

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
