//network configuration
resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${var.name_prefix}-network-configuration"
  security_group_ids = [aws_vpc.this.default_security_group_id]//[aws_security_group.default_sg.id]
  subnet_ids         = [for k, v in var.private_subnets_cidr : aws_subnet.private_subnet[k].id]
  vpc_id             = aws_vpc.this.id
}