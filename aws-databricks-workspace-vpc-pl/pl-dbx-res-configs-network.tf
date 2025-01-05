//network configuration
resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${var.name_prefix}-network-configuration"
  security_group_ids = [aws_security_group.default_sg.id]
  subnet_ids         = [for k, v in var.private_subnets_cidr : aws_subnet.private_subnet[k].id]
  vpc_id             = aws_vpc.this.id
  vpc_endpoints {
    dataplane_relay = [databricks_mws_vpc_endpoint.db_vpce_backend_scc_relay.vpc_endpoint_id]
    rest_api        = [databricks_mws_vpc_endpoint.db_vpce_backend_rest.vpc_endpoint_id]
  }
}

resource "databricks_mws_private_access_settings" "this" {
  provider                     = databricks.mws
  private_access_settings_name = "Private Access Settings for ${var.name_prefix}"
  region                       = var.aws_region
  public_access_enabled        = true
}