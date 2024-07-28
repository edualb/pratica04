output "resource_group_name" {
  value = azurerm_resource_group.puc_minas.name
}

output "public_ip_address" {
  value = azurerm_public_ip.puc_minas[*].ip_address
}

# generate inventory file for Ansible
resource "local_file" "ansbile_inventory" {
  content = templatefile("../os/inventory.template.ini",
    {
      public_ip = azurerm_public_ip.puc_minas.ip_address
    }
  )
  filename = "../os/inventory.ini"
}