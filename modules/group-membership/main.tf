resource "aws_identitystore_group_membership" "this" {
  for_each          = var.groups_member
  identity_store_id = local.sso_identity_store_id
  group_id          = [for group in var.groups_created : group.group_id if group.display_name == each.value][0]
  member_id         = var.member_id
}

data "aws_ssoadmin_instances" "this" {}

locals {
  sso_identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}