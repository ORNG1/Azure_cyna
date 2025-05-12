output "resource_group_id" {
  value = azurerm_resource_group.cyna_rg.id
}

output "appgw_public_ip" {
  value = azurerm_public_ip.appgw_ip.ip_address
}
