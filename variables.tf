variable "rule" {
  description = "describes data collection rule related configuration"
  type        = any
}

variable "endpoints" {
  description = "describes data collection endpoints related configuration"
  type        = any
  default     = {}
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "default tags to be added to the resources"
  type        = map(string)
  default     = {}
}
