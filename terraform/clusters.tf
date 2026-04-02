########## AKS Cluster — Dev
resource "azurerm_kubernetes_cluster" "dev" {
  name                = "${var.prefix}-aks-dev-${local.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.prefix}-dev-${local.suffix}"
  kubernetes_version  = var.kubernetes_version
  tags = merge(local.tags, {
    env  = "dev"
    tier = "non-prod"
  })

  default_node_pool {
    name                = "system"
    node_count          = var.dev_node_count
    vm_size             = var.node_vm_size
    os_disk_size_gb     = 30
    temporary_name_for_rotation = "systmp"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }
}

# ACR pull for dev
resource "azurerm_role_assignment" "dev_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.dev.kubelet_identity[0].object_id
}

########## AKS Cluster — Staging
resource "azurerm_kubernetes_cluster" "staging" {
  name                = "${var.prefix}-aks-stg-${local.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.prefix}-stg-${local.suffix}"
  kubernetes_version  = var.kubernetes_version
  tags = merge(local.tags, {
    env  = "staging"
    tier = "non-prod"
  })

  default_node_pool {
    name                = "system"
    node_count          = var.staging_node_count
    vm_size             = var.node_vm_size
    os_disk_size_gb     = 30
    temporary_name_for_rotation = "systmp"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }
}

# ACR pull for staging
resource "azurerm_role_assignment" "staging_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.staging.kubelet_identity[0].object_id
}

########## AKS Cluster — Production
resource "azurerm_kubernetes_cluster" "prod" {
  name                = "${var.prefix}-aks-prod-${local.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.prefix}-prod-${local.suffix}"
  kubernetes_version  = var.kubernetes_version
  tags = merge(local.tags, {
    env  = "prod"
    tier = "production"
  })

  default_node_pool {
    name                = "system"
    node_count          = var.prod_node_count
    vm_size             = var.node_vm_size
    os_disk_size_gb     = 30
    temporary_name_for_rotation = "systmp"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }
}

# ACR pull for prod
resource "azurerm_role_assignment" "prod_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.prod.kubelet_identity[0].object_id
}
