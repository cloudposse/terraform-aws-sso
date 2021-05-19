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
  count = length(var.account_assignments)

  instance_arn       = local.identity_store_arn
  permission_set_arn = var.account_assignments[count.index]["permission_set_arn"]

  principal_id   = var.account_assignments[count.index]["principal_type"] == "GROUP" ? data.aws_identitystore_group.sso[var.account_assignments[count.index]["principal_name"]].id : data.aws_identitystore_user.sso[var.account_assignments[count.index]["principal_name"]].id
  principal_type = var.account_assignments[count.index]["principal_type"]

  target_id   = var.account_assignments[count.index]["account"]
  target_type = "AWS_ACCOUNT"
}


#-----------------------------------------------------------------------------------------------------------------------
# LOCAL VARIABLES AND DATA SOURCES
#-----------------------------------------------------------------------------------------------------------------------
data "aws_ssoadmin_instances" "this" {}

locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  group_list = toset([for mapping in var.account_assignments : mapping.principal_name if mapping.principal_type == "GROUP"])
  user_list  = toset([for mapping in var.account_assignments : mapping.principal_name if mapping.principal_type == "USER"])
}
