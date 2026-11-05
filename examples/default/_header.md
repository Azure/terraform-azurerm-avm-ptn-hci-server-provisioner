# Default example

This registers existing Azure Stack HCI servers with Azure Arc. It requires a real lab; it does not create the servers, virtual host, resource group, or credentials.

## Prerequisites and inputs

Supply all seven required inputs from the approved lab configuration. Keep passwords and secrets out of source control and inject them securely at runtime.

| Input | Terraform environment variable | Required lab value |
| --- | --- | --- |
| `local_admin_password` | `TF_VAR_local_admin_password` | Local administrator password for the existing servers. |
| `local_admin_user` | `TF_VAR_local_admin_user` | Matching local administrator username. |
| `resource_group_id` | `TF_VAR_resource_group_id` | Resource ID of the existing group in the lab subscription. |
| `location` | `TF_VAR_location` | The existing group's Azure region. |
| `service_principal_id` | `TF_VAR_service_principal_id` | Service principal used for Arc registration on the servers. |
| `service_principal_secret` | `TF_VAR_service_principal_secret` | Valid secret for that registration service principal. |
| `virtual_host_ip` | `TF_VAR_virtual_host_ip` | Reachable virtual-host address, or an explicitly supplied empty string for direct-server access. |

`ARM_*` settings authenticate the Terraform providers; they do not populate these inputs or provide the server-registration credentials. The Terraform identity and registration service principal must have the required access to the subscription in the resource group ID and the same tenant. The example derives the subscription and group name from the ID and obtains the tenant from the provider context. It does not look up or verify the group; supply its actual region.

Use the exact case-sensitive environment names above or an uncommitted, securely supplied `terraform.tfvars` file in this example directory. The managed workflow forwards configured keys unchanged.

For the managed PR-check policy plan only, `pre.ps1` supplies missing inputs using a synthetic group ID in the selected subscription, a region, and non-secret provisioner placeholders. Supplied values take precedence. The hook writes only inside the isolated policy stage and does not supply deployment inputs or create a group. CI subscription selection alone does not provision a lab.

Confirm the server inventory and virtual-host port mappings in `locals.tf`. Applying requires a Windows runner with Windows PowerShell and WinRM/CredSSP connectivity to the servers: direct access uses port 5985, while virtual-host access uses the per-server mapped ports. `connect.ps1` performs registration during apply; it is not a policy-check setup hook.
