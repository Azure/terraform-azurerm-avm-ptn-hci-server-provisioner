locals {
  cluster_name        = "${local.site_id}-cl"
  deployment_user     = "${local.site_id}deploy"
  resource_group_name = "${local.site_id}-rg"
  serverPorts = {
    "AzSHOST1" = 15985,
    "AzSHOST2" = 25985
  }
  servers = [
    {
      name        = "AzSHOST1",
      ipv4Address = "192.168.1.12"
    },
    {
      name        = "AzSHOST2",
      ipv4Address = "192.168.1.13"
    }
  ]
  site_id = "iac${var.runnumber}"
}
