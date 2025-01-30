<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-ptn-hci-server-provisioner

Module to provision azure stack hci server.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_role_assignment.machine_role_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [terraform_data.provisioner](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [terraform_data.replacement](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [azurerm_arc_machine.server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/arc_machine) (data source)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_local_admin_password"></a> [local\_admin\_password](#input\_local\_admin\_password)

Description: The password for the local administrator account.

Type: `string`

### <a name="input_local_admin_user"></a> [local\_admin\_user](#input\_local\_admin\_user)

Description: The username for the local administrator account.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the server.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

### <a name="input_server_ip"></a> [server\_ip](#input\_server\_ip)

Description: The IP address of the server.

Type: `string`

### <a name="input_service_principal_id"></a> [service\_principal\_id](#input\_service\_principal\_id)

Description: The service principal ID for the Azure account.

Type: `string`

### <a name="input_service_principal_secret"></a> [service\_principal\_secret](#input\_service\_principal\_secret)

Description: The service principal secret for the Azure account.

Type: `string`

### <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id)

Description: The subscription ID for the Azure account.

Type: `string`

### <a name="input_tenant"></a> [tenant](#input\_tenant)

Description: The tenant ID for the Azure account.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_authentication_method"></a> [authentication\_method](#input\_authentication\_method)

Description: The authentication method for Enter-PSSession.

Type: `string`

Default: `"Default"`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_expand_c"></a> [expand\_c](#input\_expand\_c)

Description: Expand C volume as much as possible

Type: `bool`

Default: `false`

### <a name="input_winrm_port"></a> [winrm\_port](#input\_winrm\_port)

Description: WinRM port

Type: `number`

Default: `5985`

## Outputs

The following outputs are exported:

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: This is the full output for the resource.

### <a name="output_server"></a> [server](#output\_server)

Description: The arc server object

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->