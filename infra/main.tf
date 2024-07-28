resource "azurerm_resource_group" "puc_minas" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "puc_minas" {
  name                = "student-vnet"
  location            = azurerm_resource_group.puc_minas.location
  resource_group_name = azurerm_resource_group.puc_minas.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "puc_minas" {
  name                 = "student-subnet"
  resource_group_name  = azurerm_resource_group.puc_minas.name
  virtual_network_name = azurerm_virtual_network.puc_minas.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "puc_minas" {
  name                = "student-nsg"
  location            = azurerm_resource_group.puc_minas.location
  resource_group_name = azurerm_resource_group.puc_minas.name

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "80"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Check: CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
# Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/azure-policies/azure-general-policies/bc-azure-2-31
resource "azurerm_subnet_network_security_group_association" "puc_minas" {
  subnet_id                 = azurerm_subnet.puc_minas.id
  network_security_group_id = azurerm_network_security_group.puc_minas.id
}

resource "azurerm_public_ip" "puc_minas" {
  name                = "student-pip"
  location            = azurerm_resource_group.puc_minas.location
  resource_group_name = azurerm_resource_group.puc_minas.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_network_interface" "puc_minas" {
  name                = "student-nic"
  location            = azurerm_resource_group.puc_minas.location
  resource_group_name = azurerm_resource_group.puc_minas.name

  ip_configuration {
    name                          = "student-nic-config"
    subnet_id                     = azurerm_subnet.puc_minas.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.puc_minas.id
  }
}

resource "azurerm_network_interface_security_group_association" "puc_minas_fw_vm0" {
  network_interface_id      = azurerm_network_interface.puc_minas.id
  network_security_group_id = azurerm_network_security_group.puc_minas.id
}

resource "azurerm_linux_virtual_machine" "puc_minas" {
  name                = "student-vm"
  computer_name       = "student-vm"
  resource_group_name = azurerm_resource_group.puc_minas.name
  location            = azurerm_resource_group.puc_minas.location
  size                = "Standard_B1s"

  admin_username                  = var.username
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false

  # Check: CKV_AZURE_50: "Ensure Virtual Machine Extensions are not Installed"
  # Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/azure-policies/azure-general-policies/bc-azr-general-14
  allow_extension_operations = false

  network_interface_ids = [
    azurerm_network_interface.puc_minas.id,
  ]

  os_disk {
    name                 = "student-vm-disk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  # discovered by running '$ az vm image list -f Ubuntu --all > images.txt'
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202407250"
  }

  connection {
    host     = azurerm_public_ip.puc_minas.ip_address
    type     = "ssh"
    port     = 22
    password = var.vm_admin_password
    user     = var.username
    agent    = false
    timeout  = "1m"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get -qq install python"]
  }
}