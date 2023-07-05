variable "account_assignments" {
  type = list(object({
    account             = string
    permission_set_name = string
    permission_set_arn  = optional(string, "")
    principal_name      = string
    principal_type      = optional(string, "GROUP")
  }))
}

variable "identitystore_group_depends_on" {
  description = "A list of parameters to use for data resources to depend on. This is a workaround to avoid module depends_on as that will recreate the module resources in many unexpected situations"
  type        = list(string)
  default     = []
}

variable "permission_sets" {
  type = map
}