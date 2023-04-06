
resource "aws_identitystore_user" "this" {
  for_each          = var.users
  identity_store_id = local.sso_identity_store_id

  display_name = "${each.value.first_name} ${each.value.last_name}"
  user_name    = each.value.email

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }

  emails {
    value   = each.value.email
    primary = true
  }
}

resource "aws_identitystore_group" "this" {
  for_each          = var.groups
  display_name      = each.value.display_name
  description       = each.value.description
  identity_store_id = local.sso_identity_store_id
}

data "aws_ssoadmin_instances" "this" {}

locals {
  sso_identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}
