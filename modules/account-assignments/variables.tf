variable "account_assignments" {
  type = list(object({
    account             = string
    permission_set_name = string
    permission_set_arn  = string
    principal_name      = string
    principal_type      = string
  }))
}

variable "wait_group_creation" {
  description = "A list of parameters to use for data resources to depend on"
  type        = list(string)
  default     = []
}
