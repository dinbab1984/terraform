resource "aws_default_network_acl" "default" {
default_network_acl_id = aws_vpc.this.default_network_acl_id

# Ingress rule to allow all inbound traffic
ingress {
  rule_no    = 100
  protocol   = "-1"  # -1 means all protocols
  action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}

/*
// the below gives error message : Failed network validation checks network configurtion
// error_type networkAcl error_message Network Acl ID acl- restricts inbound traffic subnets
# Ingress rule to allow all traffic to the workspace VPC CIDR for internal traffic
ingress {
  rule_no    = 100
  protocol   = "-1"  # -1 means all protocols
  action     = "allow"
  cidr_block = aws_vpc.this.cidr_block
  from_port  = 0
  to_port    = 0
}

# Ingress rule to allow TCP access to 0.0.0.0/0 for ports such as 443 , 6666
dynamic "ingress" {
  for_each = var.vpc_network_acl_ports
  content {
    protocol   = "tcp"
    rule_no    = 101 + index(var.vpc_network_acl_ports, ingress.value)
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = ingress.value
    to_port    = ingress.value
    }
  }
*/

# Egress rule to allow all traffic to the workspace VPC CIDR for internal traffic
egress {
  rule_no    = 100
  protocol   = "-1"  # -1 means all protocols
  action     = "allow"
  cidr_block = aws_vpc.this.cidr_block
  from_port  = 0
  to_port    = 0
}

# Egress rule to allow TCP access to 0.0.0.0/0 for ports such as 443 , 6666
dynamic "egress" {
  for_each = var.vpc_network_acl_ports
  content {
    protocol   = "tcp"
    rule_no    = 101 + index(var.vpc_network_acl_ports, egress.value)
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = egress.value
    to_port    = egress.value
    }
  }

  tags =  merge(var.tags,{
    Name = "${var.name_prefix}-vpc-default-net-acl"
  })
  
  depends_on = [ aws_vpc.this ]
}

