# Data Exfiltration Protection

## Deployment Option 
- VNET & SCC, i.e use azure-databricks-workspace-vnet with following variables/values
    - private_subnet_endpoints = []
    - network_security_group_rules_required =  "NoAzureDatabricksRules"
- Added Private Link (backend & Catalog Data + DBFS storage), i.e. use azure-databricks-workspace-vnet-pl

## Firewall Rules
1. databricks-log-blob-storage - Store Azure Databricks audit and cluster logs (anonymized / masked) for support and troubleshooting (443)
2. databricks-observability-eventhub - To send telemetry information to Control Plane (9093)
3. databricks-system-table-storage - To read system table data (443) 

## Notes
- All traffic is routed according to User Defined Routes (UDR)
- It is not recommended to route the SCC connection through Azure Firewall (avoid the additional hop)
- As with the “Managed tables container”, all other storage containers should be accessed via Private Link
- Use external Metastore with private endpoint
- Control Plane to DBFS uses access connector and it's private
- This architecture can be combined with Databricks Private Link
- It is not recommended to put artifact store behind the firewall. The clusters load DBRs from it, leading to high costs.

### Network Architecture
![alt text](./drawio/architecture.drawio.svg)
