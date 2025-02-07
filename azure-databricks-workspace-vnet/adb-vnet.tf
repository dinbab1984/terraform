resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.azure_region
  tags     = var.tags
}

//create vnet
resource "azurerm_virtual_network" "this" {
  name                = "${var.name_prefix}-vnet"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.cidr_block]
  tags                = var.tags
  depends_on = [azurerm_resource_group.this]
}

//network security group
resource "azurerm_network_security_group" "this" {
  name                = "${var.name_prefix}-nsg"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
  depends_on = [azurerm_resource_group.this]
}

//vnet public subnet
resource "azurerm_subnet" "public" {
  name                 = "${var.name_prefix}-public"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnets_cidr]

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
  depends_on = [azurerm_virtual_network.this]
  service_endpoints = var.private_subnet_endpoints
}

//vnet public subnet - network security group association
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.this.id
  depends_on = [azurerm_subnet.public, azurerm_network_security_group.this]
}

//vnet private subnet
resource "azurerm_subnet" "private" {
  name                 = "${var.name_prefix}-private"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnets_cidr]
  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
  depends_on = [azurerm_virtual_network.this]
  service_endpoints = var.private_subnet_endpoints
}

//vnet private subnet - network security group association
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.this.id
  depends_on = [azurerm_subnet.private , azurerm_network_security_group.this]
}
