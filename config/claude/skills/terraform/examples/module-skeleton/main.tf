# Minimal Terraform module skeleton
# Copy and adapt for new modules

terraform {
  required_version = ">= 1.0"
}

variable "name" {
  description = "Resource name prefix"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# TODO: Add resources here

output "id" {
  description = "Primary resource ID"
  value       = null # TODO: Replace with actual resource ID
}
