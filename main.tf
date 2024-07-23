resource "terraform_data" "replacement" {
  input = var.resource_group_name
}

resource "terraform_data" "provisioner" {
  provisioner "local-exec" {
    command = "echo Connect ${var.name} to Azure Arc..."
  }

  provisioner "local-exec" {
    command     = "powershell.exe -ExecutionPolicy Bypass -NoProfile -File ${path.module}/connect.ps1 -userName ${var.local_admin_user} -password \"${var.local_admin_password}\" -authType ${var.authentication_method} -ip ${var.server_ip} -port ${var.winrm_port} -subscription_id ${var.subscription_id} -resource_group_name ${var.resource_group_name} -region ${var.location} -tenant ${var.tenant} -service_principal_id ${var.service_principal_id} -service_principal_secret ${var.service_principal_secret} -expand_c ${var.expand_c}"
    interpreter = ["PowerShell", "-Command"]
  }

  provisioner "local-exec" {
    command = "echo connected ${var.name}"
  }

  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = terraform_data.provisioner.id # TODO: Replace with your azurerm resource name
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = terraform_data.provisioner.id # TODO: Replace this dummy resource azurerm_resource_group.TODO with your module resource
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
