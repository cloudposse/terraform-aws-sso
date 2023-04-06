variable "member_id" {
  type        = string
  description = "The identifier of the user in AWS SSO"
}

variable "groups_created" {
  type = map(object({
    group_id   = string
    display_name = string}))
  description = "Groups created by the identity-store module"
}

variable "groups_member" {
  type = set(string)
  description = "Groups that each user is a member of"
}