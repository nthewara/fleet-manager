variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Primary Azure region"
  type        = string
  default     = "australiaeast"
}

variable "prefix" {
  description = "Naming prefix for all resources"
  type        = string
  default     = "fleetdemo"
}

variable "kubernetes_version" {
  description = "Initial Kubernetes version for fleet member AKS clusters (use older version for upgrade demo)"
  type        = string
  default     = "1.33"
}

variable "node_vm_size" {
  description = "VM size for AKS node pools — use D4s_v3 for faster upgrades"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "monitor_node_vm_size" {
  description = "VM size for monitoring cluster"
  type        = string
  default     = "Standard_D2s_v3"
}
