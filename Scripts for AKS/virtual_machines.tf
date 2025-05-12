resource "azurerm_linux_virtual_machine" "k8s_node" {
  count               = 3
  name                = "k8s-node-${count.index + 1}"
  resource_group_name = azurerm_resource_group.cyna_rg.name
  location            = azurerm_resource_group.cyna_rg.location
  size                = "Standard_B1s"
  admin_username      = "cynaadmin"

  network_interface_ids = [azurerm_network_interface.k8s_nic[count.index].id]

  admin_ssh_key {
    username   = "cynaadmin"
    public_key = tls_private_key.cyna_ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}