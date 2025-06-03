variable "resource_group_name" {
  type        = string
  description = "Nom du resource group"
  default     = "Cyna-RG"
}

variable "location" {
  type        = string
  description = "Région Azure"
  default     = "West Europe"
}
