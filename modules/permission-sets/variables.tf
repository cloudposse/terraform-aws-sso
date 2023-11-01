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
      path = optional(string, "/")
    }))
  }))

  default = []
  validation {
    error_message = "Customer managed policy attachment path cannot be empty"
    condition     = !anytrue([for ps in var.permission_sets : anytrue([for p in ps.customer_managed_policy_attachments : p.path == ""])])
  }
}
