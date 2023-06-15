#-----------------------------------------------------------------------------------------------------------------------
# LOCAL VARIABLES
#-----------------------------------------------------------------------------------------------------------------------

locals {
  sso_instance_arn    = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_map  = { for ps in var.permission_sets : ps.name => ps }
  inline_policies_map = { for ps in var.permission_sets : ps.name => ps.inline_policy if ps.inline_policy != "" }
  managed_policy_map  = { for ps in var.permission_sets : ps.name => ps.policy_attachments if length(ps.policy_attachments) > 0 }
  managed_policy_attachments = flatten([
    for ps_name, policy_list in local.managed_policy_map : [
      for policy in policy_list : {
        policy_set = ps_name
        policy_arn = policy
      }
    ]
  ])
  managed_policy_attachments_map = {
    for policy in local.managed_policy_attachments : "${policy.policy_set}.${policy.policy_arn}" => policy
  }
  customer_managed_policy_map = { for ps in var.permission_sets : ps.name => ps.customer_managed_policy_attachments if length(ps.customer_managed_policy_attachments) > 0 }
  customer_managed_policy_attachments = flatten([
    for ps_name, policy_list in local.customer_managed_policy_map : [
      for policy in policy_list : {
        policy_set  = ps_name
        policy_name = policy.name
        policy_path = policy.path
      }
    ]
  ])
  customer_managed_policy_attachments_map = {
    for policy in local.customer_managed_policy_attachments : "${policy.policy_set}.${policy.policy_path}${policy.policy_name}" => policy
  }
  assignment_map    = {
    for a in var.account_assignments :
    format("%v-%v-%v-%v", a.account, substr(a.principal_type, 0, 1), a.principal_name, a.permission_set_name) => a
  }
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_list        = toset([for mapping in var.account_assignments : mapping.principal_name if mapping.principal_type == "GROUP"])
  user_list         = toset([for mapping in var.account_assignments : mapping.principal_name if mapping.principal_type == "USER"])
}

#-----------------------------------------------------------------------------------------------------------------------
# DATA SOURCES
#-----------------------------------------------------------------------------------------------------------------------

data "aws_ssoadmin_instances" "this" {}

data "aws_identitystore_user" "this" {
  for_each          = local.user_list
  identity_store_id = local.identity_store_id

  filter {
    attribute_path  = "UserName"
    attribute_value = each.key
  }

  depends_on = [null_resource.dependency]
}

data "aws_identitystore_group" "this" {
  for_each          = local.group_list
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.key
    }
  }

  depends_on = [null_resource.dependency]
}

#-----------------------------------------------------------------------------------------------------------------------
# CREATE THE PERMISSION SETS
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "this" {
  for_each         = local.permission_set_map
  name             = each.key
  description      = each.value.description
  instance_arn     = local.sso_instance_arn
  relay_state      = each.value.relay_state != "" ? each.value.relay_state : null
  session_duration = each.value.session_duration != "" ? each.value.session_duration : null
  tags             = each.value.tags != "" ? each.value.tags : null
}

#-----------------------------------------------------------------------------------------------------------------------
# ATTACH INLINE POLICIES
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each           = local.inline_policies_map
  inline_policy      = each.value
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}

#-----------------------------------------------------------------------------------------------------------------------
# ATTACH MANAGED POLICIES
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = local.managed_policy_attachments_map
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.policy_set].arn
}

#-----------------------------------------------------------------------------------------------------------------------
# ATTACH CUSTOMER MANAGED POLICIES
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  for_each           = local.customer_managed_policy_attachments_map
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.policy_set].arn
  customer_managed_policy_reference {
    name = each.value.policy_name
    path = each.value.policy_path
  }
}

#-----------------------------------------------------------------------------------------------------------------------
# ACCOUNT ASSIGMENTS
#-----------------------------------------------------------------------------------------------------------------------

resource "null_resource" "dependency" {
  triggers = {
    dependency_id = join(",", var.identitystore_group_depends_on)
  }
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.assignment_map

  instance_arn       = local.sso_instance_arn
  permission_set_arn = each.value.permission_set_arn

  principal_id   = each.value.principal_type == "GROUP" ? data.aws_identitystore_group.this[each.value.principal_name].id : data.aws_identitystore_user.this[each.value.principal_name].id
  principal_type = each.value.principal_type

  target_id   = each.value.account
  target_type = "AWS_ACCOUNT"
}

