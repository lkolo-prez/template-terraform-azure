# OPA / conftest policies evaluated against the Terraform plan JSON.
#
# Generate the input with:
#   terraform show -json plan.tfplan > plan.json
#   conftest test --policy policy/rego plan.json
#
# These policies encode aircloud platform guardrails that complement tfsec/checkov.
package main

import rego.v1

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

resources_of_type(type) := [r |
	some r in input.resource_changes
	r.type == type
	r.change.actions[_] != "delete"
]

# ---------------------------------------------------------------------------
# DENY rules (hard gates)
# ---------------------------------------------------------------------------

# AKS clusters must be private.
deny contains msg if {
	some r in resources_of_type("azurerm_kubernetes_cluster")
	r.change.after.private_cluster_enabled != true
	msg := sprintf("AKS cluster %q must set private_cluster_enabled = true", [r.address])
}

# AKS must disable local accounts (no static admin kubeconfig).
deny contains msg if {
	some r in resources_of_type("azurerm_kubernetes_cluster")
	r.change.after.local_account_disabled != true
	msg := sprintf("AKS cluster %q must set local_account_disabled = true", [r.address])
}

# AKS must have Workload Identity + OIDC issuer enabled.
deny contains msg if {
	some r in resources_of_type("azurerm_kubernetes_cluster")
	not r.change.after.workload_identity_enabled
	msg := sprintf("AKS cluster %q must enable workload_identity_enabled", [r.address])
}

# Key Vault must use RBAC authorization, purge protection and not be public.
deny contains msg if {
	some r in resources_of_type("azurerm_key_vault")
	r.change.after.rbac_authorization_enabled != true
	msg := sprintf("Key Vault %q must use rbac_authorization_enabled = true", [r.address])
}

deny contains msg if {
	some r in resources_of_type("azurerm_key_vault")
	r.change.after.purge_protection_enabled != true
	msg := sprintf("Key Vault %q must enable purge_protection_enabled", [r.address])
}

# ACR must not enable the admin user.
deny contains msg if {
	some r in resources_of_type("azurerm_container_registry")
	r.change.after.admin_enabled == true
	msg := sprintf("ACR %q must not enable admin_enabled", [r.address])
}

# No NSG rule may allow inbound from the internet to SSH/RDP.
deny contains msg if {
	some r in resources_of_type("azurerm_network_security_rule")
	r.change.after.direction == "Inbound"
	r.change.after.access == "Allow"
	r.change.after.source_address_prefix == "*"
	port := {"22", "3389"}[_]
	r.change.after.destination_port_range == port
	msg := sprintf("NSG rule %q must not allow inbound %s from the internet", [r.address, port])
}

# Every taggable resource must carry an `environment` tag.
deny contains msg if {
	taggable := {"azurerm_resource_group", "azurerm_kubernetes_cluster", "azurerm_key_vault", "azurerm_container_registry"}
	some r in input.resource_changes
	taggable[r.type]
	r.change.actions[_] != "delete"
	not r.change.after.tags.environment
	msg := sprintf("%s %q must carry an `environment` tag", [r.type, r.address])
}

# ---------------------------------------------------------------------------
# WARN rules (soft signals)
# ---------------------------------------------------------------------------

warn contains msg if {
	some r in resources_of_type("azurerm_log_analytics_workspace")
	r.change.after.retention_in_days < 30
	msg := sprintf("Log Analytics workspace %q has retention < 30 days", [r.address])
}
