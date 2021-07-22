variable "account_assignments" {
  type = list(object({
    account_name        = string
    account_id          = string
    permission_set_name = string
    permission_set_arn  = string
    principal_name      = string
    principal_type      = string
  }))
}
