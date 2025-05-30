variable "account_assignments" {
  type = list(object({
    account_name        = string // has to be determined value before terraform apply
    account_id          = string // can be determined later
    permission_set_name = string // has to be determined value before terraform apply
    permission_set_arn  = string // can be determined later
    principal_name      = string // has to be determined value before terraform apply
    principal_type      = string // has to be determined value before terraform apply
  }))
}

variable "identitystore_group_depends_on" {
  description = "A list of parameters to use for data resources to depend on. This is a workaround to avoid module depends_on as that will recreate the module resources in many unexpected situations"
  type        = list(string)
  default     = []
}
