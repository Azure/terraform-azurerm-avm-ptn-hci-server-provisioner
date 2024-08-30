# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource_id" {
  description = "This is the full output for the resource."
  value       = terraform_data.provisioner.id # TODO: Replace this dummy resource azurerm_resource_group.TODO with your module resource
}

output "server" {
  description = "The arc server object"
  value       = data.azurerm_arc_machine.server
}
