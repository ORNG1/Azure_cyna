output "resource_group_id" {
  value = azurerm_resource_group.cyna_rg.id
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.cyna_aks.kube_config_raw
  sensitive = true
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.cyna_aks.name
}
