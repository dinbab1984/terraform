resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.azure_region
  tags     = local.tags
}

//create vnet
resource "azurerm_virtual_network" "this" {
  name                = "${var.name_prefix}-vnet"
  location            = var.azure_region
  resource_group_name = var.rg_name
  address_space       = [var.cidr_block]
  tags                = local.tags
  depends_on = [azurerm_resource_group.this]
}

//network security group
resource "azurerm_network_security_group" "this" {
  name                = "${var.name_prefix}-nsg"
  location            = var.azure_region
  resource_group_name = var.rg_name
  tags                = local.tags
  depends_on = [azurerm_resource_group.this]
}

/*
//network security rule - allow aad
resource "azurerm_network_security_rule" "aad" {
  name                        = "AllowAAD"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureActiveDirectory"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.this.name
}

//network security rule - allow front
resource "azurerm_network_security_rule" "azfrontdoor" {
  name                        = "AllowAzureFrontDoor"
  priority                    = 201
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureFrontDoor.Frontend"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.this.name
}
*/

//vnet public subnet
resource "azurerm_subnet" "public" {
  name                 = "${var.name_prefix}-public"
  resource_group_name  = var.rg_name
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
}

//vnet public subnet - network security group association
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.this.id
}

variable "private_subnet_endpoints" {
  default = []
}

//vnet private subnet
resource "azurerm_subnet" "private" {
  name                 = "${var.name_prefix}-private"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnets_cidr]

  private_link_service_network_policies_enabled = true
  //private_endpoint_network_policies_enabled = true

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

  service_endpoints = var.private_subnet_endpoints
}

//vnet private subnet - network security group association
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.this.id
}

//vnet private link subnet
resource "azurerm_subnet" "plsubnet" {
  name                                      = "${var.name_prefix}-privatelink"
  resource_group_name                       = var.rg_name
  virtual_network_name                      = azurerm_virtual_network.this.name
  address_prefixes                          = [var.pl_subnets_cidr]
  private_link_service_network_policies_enabled = true
  //private_endpoint_network_policies_enabled = true
}