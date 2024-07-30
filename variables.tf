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
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the server."
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "server_ip" {
  type        = string
  description = "The IP address of the server."
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

variable "subscription_id" {
  type        = string
  description = "The subscription ID for the Azure account."
}

variable "tenant" {
  type        = string
  description = "The tenant ID for the Azure account."
}

variable "authentication_method" {
  type        = string
  default     = "Default"
  description = "The authentication method for Enter-PSSession."

  validation {
    condition     = can(regex("^(Default|Basic|Negotiate|NegotiateWithImplicitCredential|Credssp|Digest|Kerberos)$", var.authentication_method))
    error_message = "Value of authentication_method should be {Default | Basic | Negotiate | NegotiateWithImplicitCredential | Credssp | Digest | Kerberos}"
  }
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.
DESCRIPTION  
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "expand_c" {
  type        = bool
  default     = false
  description = "Expand C volume as much as possible"
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "winrm_port" {
  type        = number
  default     = 5985
  description = "WinRM port"
}
