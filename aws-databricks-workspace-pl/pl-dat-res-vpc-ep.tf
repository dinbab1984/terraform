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


//security group for other aws resources
// VPC's Default Security Group
locals {
  sg_egress_ports              = [443, 3306, 2443, 6666]
  sg_ingress_protocol          = ["tcp", "udp"]
  sg_egress_protocol           = ["tcp", "udp"]
}

resource "aws_security_group" "default_sg" {
  name        = "${var.name_prefix}-spoke-vpc-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.this.id
  depends_on  = [aws_vpc.this]
  //Inbound internal traffic between resources in this security group (all ports)
  dynamic "ingress" {
    for_each = local.sg_ingress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }
  //Outbound internal traffic between resources in this security group (all ports)
  dynamic "egress" {
    for_each = local.sg_egress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }
  //Outbound tcp access to 0.0.0.0/0 , ports 443, 3306, 6666
  dynamic "egress" {
    for_each = local.sg_egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.tags
}

resource "aws_vpc_endpoint" "kinesis-streams" {
  vpc_id              = aws_vpc.this.id
  security_group_ids  = [aws_security_group.default_sg.id]
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
  security_group_ids = [aws_security_group.default_sg.id]

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