output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "fleet_name" {
  value = azurerm_kubernetes_fleet_manager.fleet.name
}

output "fleet_id" {
  value = azurerm_kubernetes_fleet_manager.fleet.id
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "dev_cluster_name" {
  value = azurerm_kubernetes_cluster.dev.name
}

output "staging_cluster_name" {
  value = azurerm_kubernetes_cluster.staging.name
}

output "prod_cluster_name" {
  value = azurerm_kubernetes_cluster.prod.name
}

output "dev_cluster_id" {
  value = azurerm_kubernetes_cluster.dev.id
}

output "staging_cluster_id" {
  value = azurerm_kubernetes_cluster.staging.id
}

output "prod_cluster_id" {
  value = azurerm_kubernetes_cluster.prod.id
}
