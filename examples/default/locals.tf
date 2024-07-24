locals {
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
