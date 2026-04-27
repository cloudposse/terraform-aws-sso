variable "account_assignments" {
  type = list(object({
    account             = string
    permission_set_name = string
    permission_set_arn  = string
    principal_name      = string
    principal_type      = string
  }))

  description = "Account assignments"
}

variable "identitystore_group_depends_on" {
  description = "A list of parameters to use for data resources to depend on. This is a workaround to avoid module depends_on as that will recreate the module resources in many unexpected situations"
  type        = list(string)
  default     = []
}

variable "group_ids" {
  description = <<-EOT
    Map of group display name to Identity Store group ID. When provided, the
    submodule resolves GROUP principals from this map directly instead of
    using a data source. This avoids a `ResourceNotFoundException` at plan
    time when an `account_assignments` entry references a Terraform-managed
    group that has not yet been created.

    Pass a merged map of all manual + IdP group IDs from the parent module.
    Any principal_name in `account_assignments` that is missing from this map
    falls back to the data source lookup, preserving the previous behavior.
    EOT
  type        = map(string)
  default     = {}
}
