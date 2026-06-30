package main

import rego.v1

# Minimal unit tests for the conftest policies.
# Run: conftest verify --policy policy/rego

test_deny_public_aks if {
	some msg in deny with input as {"resource_changes": [{
		"address": "module.aks.azurerm_kubernetes_cluster.this",
		"type": "azurerm_kubernetes_cluster",
		"change": {
			"actions": ["create"],
			"after": {"private_cluster_enabled": false},
		},
	}]}
	contains(msg, "private_cluster_enabled")
}

test_allow_private_aks if {
	count(deny) == 0 with input as {"resource_changes": [{
		"address": "module.aks.azurerm_kubernetes_cluster.this",
		"type": "azurerm_kubernetes_cluster",
		"change": {
			"actions": ["create"],
			"after": {
				"private_cluster_enabled": true,
				"local_account_disabled": true,
				"workload_identity_enabled": true,
				"tags": {"environment": "dev"},
			},
		},
	}]}
}

test_deny_acr_admin if {
	some msg in deny with input as {"resource_changes": [{
		"address": "module.acr.azurerm_container_registry.this",
		"type": "azurerm_container_registry",
		"change": {
			"actions": ["create"],
			"after": {"admin_enabled": true, "tags": {"environment": "dev"}},
		},
	}]}
	contains(msg, "admin_enabled")
}
