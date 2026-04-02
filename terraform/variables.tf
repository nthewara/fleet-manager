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
  description = "Initial Kubernetes version for AKS clusters"
  type        = string
  default     = "1.30"
}

variable "dev_node_count" {
  description = "Node count for dev cluster"
  type        = number
  default     = 1
}

variable "staging_node_count" {
  description = "Node count for staging cluster"
  type        = number
  default     = 1
}

variable "prod_node_count" {
  description = "Node count for production cluster"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size for AKS node pools"
  type        = string
  default     = "Standard_B2ms"
}
