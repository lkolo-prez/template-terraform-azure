locals {
  cluster_name = "aks-${var.name}"
  dns_prefix   = coalesce(var.dns_prefix, replace(local.cluster_name, "/[^a-zA-Z0-9-]/", ""))
}

# User-assigned identity for the cluster control plane. Using a UAMI (rather than
# a system-assigned identity) lets callers pre-create role assignments and keeps
# the identity stable across cluster recreation.
resource "azurerm_user_assigned_identity" "cluster" {
  name                = "id-${local.cluster_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = local.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = local.dns_prefix
  kubernetes_version  = var.kubernetes_version
  sku_tier            = "Standard"

  # Private cluster: API server is reachable only over the private network.
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false
  local_account_disabled              = true

  # Azure RBAC + Entra ID integration; no local admin kubeconfig.
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  # Workload Identity (federated) instead of pod-managed identities or secrets.
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 48
  role_based_access_control_enabled = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cluster.id]
  }

  default_node_pool {
    name                        = "system"
    vm_size                     = var.system_node_pool.vm_size
    auto_scaling_enabled        = true
    min_count                   = var.system_node_pool.min_count
    max_count                   = var.system_node_pool.max_count
    os_disk_size_gb             = var.system_node_pool.os_disk_size_gb
    os_disk_type                = "Ephemeral"
    only_critical_addons_enabled = var.system_node_pool.only_critical_addons
    vnet_subnet_id              = var.subnet_id
    zones                       = var.system_node_pool.zones
    max_pods                    = 110
    temporary_name_for_rotation = "systmp"

    upgrade_settings {
      max_surge = "33%"
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = var.network_policy
    network_data_plane  = var.network_policy == "cilium" ? "cilium" : "azure"
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  # Microsoft Defender for Containers.
  microsoft_defender {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  azure_policy_enabled = true

  auto_scaler_profile {
    balance_similar_node_groups = true
    expander                    = "least-waste"
    scale_down_unneeded         = "10m"
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "03:00"
    utc_offset  = "+00:00"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # kubernetes_version drift is managed by the AKS auto-upgrade channel.
      kubernetes_version,
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "diag-${local.cluster_name}"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "guard"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
