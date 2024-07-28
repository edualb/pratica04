tflint {
  required_version = ">= 0.50"
}

config {
  format = "compact"
  force = false
  disabled_by_default = false
}

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}