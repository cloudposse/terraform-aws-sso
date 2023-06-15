variable "permission_sets" {
  type = list(object({
    name               = string
    description        = string
    relay_state        = string
    session_duration   = string
    tags               = map(string)
    inline_policy      = string
    policy_attachments = list(string)
    customer_managed_policy_attachments = list(object({
      name = string
      path = string
    }))
  }))

  default = []
}

variable "account_assignments" {
  type = list(object({
    account             = string
    permission_set_name = string
    permission_set_arn  = string
    principal_name      = string
    principal_type      = string
  }))
}

variable "identitystore_group_depends_on" {
  description = "A list of parameters to use for data resources to depend on. This is a workaround to avoid module depends_on as that will recreate the module resources in many unexpected situations"
  type        = list(string)
  default     = []
}
