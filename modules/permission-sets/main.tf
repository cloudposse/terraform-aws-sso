#-----------------------------------------------------------------------------------------------------------------------
# CREATE THE PERMISSION SETS
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "this" {
  for_each         = local.permission_set_map
  name             = each.key
  description      = each.value.description
  instance_arn     = local.sso_instance_arn
  session_duration = each.value.session_duration != "" ? each.value.session_duration : null
  tags             = each.value.tags != "" ? each.value.tags : null
}

#-----------------------------------------------------------------------------------------------------------------------
# ATTACH INLINE POLICIES
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each           = local.inline_policy_attachments_map
  inline_policy      = each.value.policy_set
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps_name].arn
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
# LOCAL VARIABLES AND DATA SOURCES
#-----------------------------------------------------------------------------------------------------------------------
data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn    = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_map  = { for ps in var.permission_sets : ps.name => ps }
  inline_policies_map = { for ps in var.permission_sets : ps.name => ps.inline_policy if length(ps.inline_policy) > 0 }
  managed_policy_map  = { for ps in var.permission_sets : ps.name => ps.policy_attachments if length(ps.policy_attachments) > 0 }
  managed_policy_attachments = flatten([
    for ps_name, policy_list in local.managed_policy_map : [
      for policy in policy_list : {
        policy_set = ps_name
        policy_arn = policy
      }
    ]
  ])

  inline_policy_attachments = flatten([
    for ps_name, policy_list in local.inline_policies_map : [
      for policy in policy_list : {
        policy_set  = policy["policy_set"]
        ps_sub_name = policy["policyname"]
        ps_name     = ps_name
      }
    ]
  ])

  managed_policy_attachments_map = {
    for policy in local.managed_policy_attachments : "${policy.policy_set}.${policy.policy_arn}" => policy
  }
  inline_policy_attachments_map = {
    for policy in local.inline_policy_attachments : "${policy.ps_name}.${policy.ps_sub_name}" => policy
  }
}
