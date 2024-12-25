# Network Access

## Deployment Option - VNet Injection + SCC (Secure Cluster Connectivity)

### User to Control Plane
- the workspace URL is publicly accessible

### VNet to Control Plane
- deploy Databricks in the customer's VNet
- the VNet and subnets created in advance
- cluster VMs receive only Private IPs
- traffic is now outbound (the cluster VMs connect to the Control Plane)
- Back-end Private Link (for the connection between VNet and Control plane)


#### IP address ranges of Azure Databricks
##### Necessary IP ranges (subnets) for VNet injection
- VNet					            /16 - /24	(e.g. /20)
    -   Host (”public-subnet”)		up to /26	(e.g. /21)
    -   Container (”private-subnet”)	up to /26	(e.g. /21)
    -   Public IP (for non-NPIP)		    Azure IP range
- Notes: 
    -   Private CIDR range size = Public CIDR range size 
    -   Azure reserves 5 addresses for internal purposes, e.g. in a /20 VNet with /21 subnets the largest possible cluster would have one driver and maximal 2043 workers
    -   Even for “No Public IP” workspaces the host network is called “public-subnet” in the Azure Portal, however, it is a private IP range
    -   For network infrastructure nodes e.g. for Private Link separate subnets are needed. Consider to use smaller subnets than half of the VPC side (e.g. cidr - 2) 
    -   container subnet” is also referred to as “private subnet” and  “host subnet” as “public subnet”. Since the terms “private” and “public” are misleading, “container” and “host” are preferred
#### Recommended VNet setup
- Being prepared for network security setups like Private Link
    -   It is possible to configure a network setup for Databricks with subnet size of Vnet CIDR - 1, e.g. VNet = /16, subnets = /17. This maximizes the possible cluster size, however there is no space in the VNet left for configuring more secure setups
    -   It is recommended to use VNet CIDR - 2 for the subnets, e.g. VNet = /16, subnets = /18
    -   Given this configuration, other subnets can be created in the VNet, e.g. to hold private endpoints for a private link configuration

### VNet to Storage
- uses Private Link for data traffic between cluster VMs and the storage accounts
- can reach very high costs


### Communication in an SCC workspace 
- Setup : VNet injection with SCC
- Secure Cluster Connectivity reverses the call direction via the SCC Relay and removes Public IPs from the Compute Plane. 
- Calls from Compute Plane to the Control Plane via Private Link
- Create a subnet for the private endpoints (do not define any NSG rules for a subnet that contains private endpoints)
- On Azure, Log / Telemetry / system tables store and Artifact Store currently cannot be put behind a PE (technical limitations)
- DBFS and customer data should be accessed via standard Private Link setups (Azure specific, not part of Databricks Private Link). Same holds for all other cloud services
- Control Plane to DBFS uses access connector and it is private
- DNS change for the Customer VNet: Route traffic to the private endpoint for the Web App 
- Users access Databricks over the Public Internet
- Do NOT use DBFS as a storage layer (e.g. no access control) but rather use storage accounts with Unity Catalog access control for all customer tables, volumes, …


### Network Architecture
![alt text](./drawio/architecture.drawio.svg)
