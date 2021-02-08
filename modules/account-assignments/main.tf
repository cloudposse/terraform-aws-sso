data "aws_identitystore_group" "this" {
  for_each          = local.group_list
  identity_store_id = local.identity_store_id

  filter {
    attribute_path  = "DisplayName"
    attribute_value = each.key
  }
}

data "aws_identitystore_user" "this" {
  for_each          = local.user_list
  identity_store_id = local.identity_store_id

  filter {
    attribute_path  = "UserName"
    attribute_value = each.key
  }
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = { for i, v in var.account_assignments : i => v }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = each.value.permission_set_arn

  principal_id   = each.value.principal_type == "GROUP" ? data.aws_identitystore_group.this[each.value.principal_name].id : data.aws_identitystore_user.this[each.value.principal_name].id
  principal_type = each.value.principal_type

  target_id   = each.value.account
  target_type = "AWS_ACCOUNT"
}



#-----------------------------------------------------------------------------------------------------------------------
# LOCAL VARIABLES AND DATA SOURCES
#-----------------------------------------------------------------------------------------------------------------------
data "aws_ssoadmin_instances" "this" {}
locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  group_list = toset(values({ for index, mapping in var.account_assignments : index => mapping.principal_name if mapping.principal_type == "GROUP" }))
  user_list  = toset(values({ for index, mapping in var.account_assignments : index => mapping.principal_name if mapping.principal_type == "USER" }))
}

output "assignments" {
  value = aws_ssoadmin_account_assignment.this
}

