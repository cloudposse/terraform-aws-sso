variable "permission_sets" {
  type = list(object({
    name               = string
    description        = optional(string, "")
    relay_state        = optional(string, "")
    session_duration   = optional(string, "PT8H")
    tags               = optional(map(string), {})
    inline_policy      = optional(string, "")
    policy_attachments = optional(list(string), [])
    customer_managed_policy_attachments = optional(list(object({
      name = string
      path = string
    })), [])
  }))

  default = []
}
