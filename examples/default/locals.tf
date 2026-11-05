locals {
  resource_group_id_parts = try(regex("(?i)^/subscriptions/(?P<subscription_id>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/resourcegroups/(?P<group_name>[\\pL\\p{Nd}_().-]{0,89}[\\pL\\p{Nd}_()-])$", var.resource_group_id), null)
  resource_group_name     = try(local.resource_group_id_parts.group_name, null)
  subscription_id         = try(local.resource_group_id_parts.subscription_id, null)
  server_ports = {
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
}
