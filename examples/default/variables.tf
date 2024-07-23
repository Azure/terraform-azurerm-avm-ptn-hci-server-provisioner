variable "local_admin_password" {
  type        = string
  description = "The password for the local administrator account."
}

variable "local_admin_user" {
  type        = string
  description = "The username for the local administrator account."
}

variable "runnumber" {
  type        = string
  description = "The run number"
}

variable "service_principal_id" {
  type        = string
  description = "The service principal ID for the Azure account."
}

variable "service_principal_secret" {
  type        = string
  description = "The service principal secret for the Azure account."
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID for the Azure account."
}

# Virtual host related variables
variable "virtual_host_ip" {
  type        = string
  description = "The virtual host IP address."
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

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
