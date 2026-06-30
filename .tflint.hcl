# Root TFLint config.
#
# The CANONICAL, fully-featured TFLint configuration for this repo lives in
# policy/.tflint.hcl (provider-aware azurerm rules, naming, module structure). CI,
# the Taskfile and the pre-commit hook all point at it explicitly:
#
#   tflint --recursive --config "$PWD/policy/.tflint.hcl"
#   task lint
#
# This root file exists only so tools that auto-discover a top-level .tflint.hcl get
# a sane baseline. Keep the real ruleset in policy/.tflint.hcl and prefer running with
# --config policy/.tflint.hcl.
config {
  call_module_type = "all"
  force            = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
