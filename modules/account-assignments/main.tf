resource "null_resource" "dependency" {
  triggers = {
    dependency_id = join(",", var.identitystore_group_depends_on)
  }
}

data "aws_identitystore_group" "this" {
  # Look up only groups NOT provided via var.group_ids. Groups passed in by
  # the parent module (Terraform-managed + already-resolved IdP groups) skip
  # this data source, avoiding ResourceNotFoundException at plan time when
  # the group is yet to be created.
  for_each          = local.group_list_to_lookup
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.key
    }
  }

  depends_on = [null_resource.dependency]
}

data "aws_identitystore_user" "this" {
  for_each          = local.user_list
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }

  depends_on = [null_resource.dependency]
}

locals {
  assignment_map = {
    for a in var.account_assignments :
    format("%v-%v-%v-%v", a.account, substr(a.principal_type, 0, 1), a.principal_name, a.permission_set_name) => a
  }
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.assignment_map

  instance_arn       = local.sso_instance_arn
  permission_set_arn = each.value.permission_set_arn

  principal_id   = each.value.principal_type == "GROUP" ? local.resolved_group_ids[each.value.principal_name] : data.aws_identitystore_user.this[each.value.principal_name].id
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

  group_list           = toset([for mapping in var.account_assignments : mapping.principal_name if mapping.principal_type == "GROUP"])
  group_list_to_lookup = setsubtract(local.group_list, toset(keys(var.group_ids)))
  user_list            = toset([for mapping in var.account_assignments : mapping.principal_name if mapping.principal_type == "USER"])

  # Group IDs come from two sources, in order of precedence:
  #   1. var.group_ids — passed explicitly by the parent module (skips data lookup)
  #   2. data.aws_identitystore_group.this — fallback for groups not in var.group_ids
  # Merge gives a complete display_name → id map for principal_id resolution.
  resolved_group_ids = merge(
    var.group_ids,
    { for k, v in data.aws_identitystore_group.this : k => v.id },
  )
}

