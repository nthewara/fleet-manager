########## AKS Fleet Manager (with Hub Cluster)
resource "azurerm_kubernetes_fleet_manager" "fleet" {
  name                = "${var.prefix}-fleet-${local.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.tags

  hub_profile {
  }
}

########## Fleet Members
resource "azurerm_kubernetes_fleet_member" "dev" {
  name                  = "member-dev"
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.fleet.id
  kubernetes_cluster_id = azurerm_kubernetes_cluster.dev.id
  group                 = "dev"
}

resource "azurerm_kubernetes_fleet_member" "staging" {
  name                  = "member-staging"
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.fleet.id
  kubernetes_cluster_id = azurerm_kubernetes_cluster.staging.id
  group                 = "staging"
}

resource "azurerm_kubernetes_fleet_member" "prod" {
  name                  = "member-prod"
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.fleet.id
  kubernetes_cluster_id = azurerm_kubernetes_cluster.prod.id
  group                 = "prod"
}

########## Update Strategy
resource "azurerm_kubernetes_fleet_update_strategy" "staged_rollout" {
  name                        = "staged-rollout"
  kubernetes_fleet_manager_id = azurerm_kubernetes_fleet_manager.fleet.id

  stage {
    name = "dev"
    group {
      name = "dev"
    }
    after_stage_wait_in_seconds = 60
  }

  stage {
    name = "staging"
    group {
      name = "staging"
    }
    after_stage_wait_in_seconds = 120
  }

  stage {
    name = "production"
    group {
      name = "prod"
    }
  }
}
