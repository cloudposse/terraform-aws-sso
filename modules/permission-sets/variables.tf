variable "permission_sets" {
  type = list(object({
    name               = string
    description        = string
    session_duration   = string
    tags               = map(string)
    inline_policy      = list(map(string))
    policy_attachments = list(string)
  }))

  default = []
}
