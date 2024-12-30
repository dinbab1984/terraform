//Public IP for firewall
resource "azurerm_public_ip" "fwpublicip" {
  name                = "hubfirewallpublicip"
  location            = azurerm_resource_group.hubrg.location
  resource_group_name = azurerm_resource_group.hubrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = var.tags
  depends_on = [ azurerm_resource_group.hubrg ]
}

//firewall policy
resource "azurerm_firewall_policy" "hubfw_policy" {
  name                     = "hubfw-policy"
  resource_group_name      = azurerm_resource_group.hubrg.name
  location                 = azurerm_resource_group.hubrg.location
  sku                      = "Standard"
  threat_intelligence_mode = "Alert"
  dns {
    proxy_enabled = true
  }
  tags = var.tags
  depends_on = [ azurerm_resource_group.hubrg ]
}

//Firewall rule - 2. Telemetry (Azure EventHub)
resource "azurerm_firewall_policy_rule_collection_group" "net_policy_rule_collection_group" {
  name               = "ADBtNetworkRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.hubfw_policy.id
  priority           = 200
  network_rule_collection {
    name     = "adbtelemetryfqdn"
    action   = "Allow"
    priority = 200
    rule {
      name                  = "databricks-telemetry"
      source_addresses      = [for k,v in data.azurerm_subnet.ws_subnets : data.azurerm_subnet.ws_subnets[k].address_prefixes[0]]
      destination_fqdns     = var.telemetryfqdns
      destination_ports     = ["9093"]
      protocols             = ["TCP"]
    }
  }
  depends_on = [ azurerm_firewall_policy.hubfw_policy , data.azurerm_subnet.ws_subnets ]
}

//Firewall rules - 1. Log Store (Azure Blob) & 3. System Table Store(Azure ADLS)
resource "azurerm_firewall_policy_rule_collection_group" "app_policy_rule_collection_group" {
  name               = "ADBApplicationtRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.hubfw_policy.id
  priority           = 300
  application_rule_collection {
    name     = "ADBApplicationRuleCollection"
    action   = "Allow"
    priority = 500
    rule {
      name = "databricks-log-store"
      source_addresses = [for k,v in data.azurerm_subnet.ws_subnets : data.azurerm_subnet.ws_subnets[k].address_prefixes[0]]
      destination_fqdns = var.logstorefqdns
      protocols {
        port = "443"
        type = "Https"
      }
    }
    rule {
      name = "databricks-system-table-store"
      source_addresses = [for k,v in data.azurerm_subnet.ws_subnets : data.azurerm_subnet.ws_subnets[k].address_prefixes[0]]
      destination_fqdns = var.systemtablestorefqdns
      protocols {
        port = "443"
        type = "Https"
      }
    }
  }
  depends_on = [ azurerm_firewall_policy.hubfw_policy,data.azurerm_subnet.ws_subnets ]
}

//Firewall resource
resource "azurerm_firewall" "hubfw" {
  name                = "hubfirewall"
  location            = azurerm_resource_group.hubrg.location
  resource_group_name = azurerm_resource_group.hubrg.name
  //dns_proxy_enabled   = true //for firewall network rule with fqdns destination
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "hubfw-configuration"
    subnet_id            = azurerm_subnet.hubfw.id
    public_ip_address_id = azurerm_public_ip.fwpublicip.id
  }
  firewall_policy_id = azurerm_firewall_policy.hubfw_policy.id
  tags = var.tags
  depends_on = [ azurerm_public_ip.fwpublicip, azurerm_firewall_policy.hubfw_policy ]
}

/*
//Firewall rules - 1. Log Store (Azure Blob)
resource "azurerm_firewall_application_rule_collection" "adblogstorefqdn" {
  name                = "adblogstorefqdn"
  azure_firewall_name = azurerm_firewall.hubfw.name
  resource_group_name = azurerm_resource_group.hubrg.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "databricks-log-store"

    source_addresses = [for k,v in data.azurerm_subnet.ws_subnets : data.azurerm_subnet.ws_subnets[k].address_prefixes[0] ]

    target_fqdns = var.logstorefqdns

    protocol {
      port = "443"
      type = "Https"
    }
  }
  depends_on = [ azurerm_firewall.hubfw , data.azurerm_subnet.ws_subnets ]
}


//Firewall rule - 2. Telemetry (Azure EventHub)
resource "azurerm_firewall_network_rule_collection" "adbtelemetryfqdn" {
  name                = "adbtelemetryfqdn"
  azure_firewall_name = azurerm_firewall.hubfw.name
  resource_group_name = azurerm_resource_group.hubrg.name
  priority            = 201
  action              = "Allow"

  rule {
    name = "databricks-telemetry"

    source_addresses = [for k,v in data.azurerm_subnet.ws_subnets : data.azurerm_subnet.ws_subnets[k].address_prefixes[0]]

    destination_fqdns = var.telemetryfqdns

    destination_ports = ["9093"]

    protocols = [
      "TCP"
    ]
  }
  depends_on = [ azurerm_firewall.hubfw , data.azurerm_subnet.ws_subnets ]
}

//Firewall rule - 3. System Table Store(Azure ADLS)
resource "azurerm_firewall_application_rule_collection" "adbsystemstablestorefqdn" {
  name                = "adbsystemstablestorefqdn"
  azure_firewall_name = azurerm_firewall.hubfw.name
  resource_group_name = azurerm_resource_group.hubrg.name
  priority            = 202
  action              = "Allow"

  rule {
    name = "databricks-system-table-store"

    source_addresses = [for k,v in data.azurerm_subnet.ws_subnets : data.azurerm_subnet.ws_subnets[k].address_prefixes[0]]

    target_fqdns = var.systemtablestorefqdns

    protocol {
      port = "443"
      type = "Https"
    }
  }
  depends_on = [ azurerm_firewall.hubfw, data.azurerm_subnet.ws_subnets ]
}

*/

/*

//Firewall rules - 4. metastore
resource "azurerm_firewall_network_rule_collection" "adbfnetwork" {
  name                = "adbcontrolplanenetwork"
  azure_firewall_name = azurerm_firewall.hubfw.name
  resource_group_name = azurerm_resource_group.hubrg.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "databricks-metastore"

    source_addresses = [
      join(", ", azurerm_subnet.public.address_prefixes),
      join(", ", azurerm_subnet.private.address_prefixes),
    ]

    destination_ports = [
      "3306",
    ]

    destination_addresses = [
      var.metastoreips
    ]

    protocols = [
      "TCP",
    ]
  }
}
*/