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
