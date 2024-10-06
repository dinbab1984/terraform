/* Routing table for private subnet */
resource "aws_route_table" "private_subnet_rt" {
  for_each = var.private_subnets_cidr
  vpc_id   = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-private-route-tbl-${var.aws_region}${each.key}"
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

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.this.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [ for k,v in var.private_subnets_cidr : aws_route_table.private_subnet_rt[k].id]
  tags = {
    Name = "${var.name_prefix}-s3-vpc-endpoint"
  }
  depends_on = [aws_vpc.this, aws_route_table.private_subnet_rt]
}

resource "aws_vpc_endpoint" "kinesis-streams" {
  vpc_id              = aws_vpc.this.id
  security_group_ids  = [aws_vpc.this.default_security_group_id]
  service_name        = "com.amazonaws.${var.aws_region}.kinesis-streams"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [ for k,v in var.private_subnets_cidr : aws_subnet.private_subnet[k].id ]
  tags = {
    Name = "${var.name_prefix}-kinesis-vpc-endpoint"
  }
  depends_on = [aws_vpc.this, aws_subnet.private_subnet]
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id = aws_vpc.this.id
  security_group_ids = [aws_vpc.this.default_security_group_id]

  endpoints = {
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = [for k, v in var.private_subnets_cidr : aws_subnet.private_subnet[k].id]
      tags = {
        Name = "${var.name_prefix}-sts-vpc-endpoint"
      }
    },
  }
  tags = var.tags
}