#-----------------------------------------------------------------------------------------------------------------------
# CREATE THE PERMISSION SETS
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "this" {
  for_each         = { for ps in var.permission_sets : ps.name => ps }
  name             = each.key
  description      = each.value.description
  instance_arn     = local.sso_instance_arn
  relay_state      = each.value.relay_state != "" ? each.value.relay_state : null
  session_duration = each.value.session_duration != "" ? each.value.session_duration : null
}

#-----------------------------------------------------------------------------------------------------------------------
# ATTACH INLINE POLICIES
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each           = local.inline_policies
  inline_policy      = each.value
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}

#-----------------------------------------------------------------------------------------------------------------------
# ATTACH MANAGED POLICIES
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for policy in local.managed_policy_attachments : "${policy.policy_set}.${policy.policy_arn}}" => policy
  }
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.policy_set].arn
}

#-----------------------------------------------------------------------------------------------------------------------
# LOCAL VARIABLES AND DATA SOURCES
#-----------------------------------------------------------------------------------------------------------------------
data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn   = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  inline_policies    = { for index, ps in var.permission_sets : ps.name => ps.inline_policy if ps.inline_policy != "" }
  managed_policy_map = { for index, ps in var.permission_sets : ps.name => ps.policy_attachments if length(ps.policy_attachments) > 0 }
  managed_policy_attachments = flatten([
    for ps_name, policy_list in local.managed_policy_map : [
      for policy in policy_list : {
        policy_set = ps_name
        policy_arn = policy
      }
    ]
  ])
}
