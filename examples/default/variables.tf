variable "local_admin_password" {
  type        = string
  description = "The password for the local administrator account."
  sensitive   = true
}

variable "local_admin_user" {
  type        = string
  description = "The username for the local administrator account."
}

variable "location" {
  type        = string
  description = "The Azure region for the existing resource group."
  nullable    = false

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "The location must not be empty."
  }
}

variable "resource_group_id" {
  type        = string
  description = "The resource ID of the existing resource group."
  nullable    = false

  validation {
    condition     = can(regex("(?i)^/subscriptions/(?P<subscription_id>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/resourcegroups/(?P<group_name>[\\pL\\p{Nd}_().-]{0,89}[\\pL\\p{Nd}_()-])$", var.resource_group_id))
    error_message = "The resource_group_id must be a valid Azure resource group ID."
  }
}

variable "service_principal_id" {
  type        = string
  description = "The service principal ID for the Azure account."
}

variable "service_principal_secret" {
  type        = string
  description = "The service principal secret for the Azure account."
  sensitive   = true
}

# Virtual host related variables
variable "virtual_host_ip" {
  type        = string
  description = "The virtual host IP address."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
