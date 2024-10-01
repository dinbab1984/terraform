data "azurerm_virtual_network" "this" {
  name                = "${var.name_prefix}-vnet"
  resource_group_name = var.rg_name
}

//vnet private link subnet
resource "azurerm_subnet" "plsubnet" {
  name                                      = "${var.name_prefix}-privatelink"
  resource_group_name                       = var.rg_name
  virtual_network_name                      = data.azurerm_virtual_network.this.name
  address_prefixes                          = [var.pl_subnets_cidr]
  depends_on = [data.azurerm_virtual_network.this]
}