# resource "null_resource" "ssh_connection" {
#   depends_on = [azurerm_linux_virtual_machine.puc_minas]

#   connection {
#     host     = azurerm_public_ip.puc_minas.ip_address
#     type     = "ssh"
#     port     = 22
#     password = var.vm_admin_password
#     user     = var.username
#     agent    = false
#     timeout  = "1m"
#   }

#   provisioner "remote-exec" {
#     inline = ["sudo apt-get -qq install python"]
#   }
# }