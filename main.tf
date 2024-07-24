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

