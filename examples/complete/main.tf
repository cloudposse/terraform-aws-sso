module "permission_sets" {
  source = "../../modules/permission-sets"

  permission_sets = [
    {
      name               = "AdministratorAccess",
      description        = "Allow Full Access to the account",
      relay_state        = "",
      session_duration   = "",
      tags               = {},
      inline_policy      = "",
      policy_attachments = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      customer_managed_policy_attachments = [{
        name = aws_iam_policy.S3Access.name
        path = aws_iam_policy.S3Access.path
      }]
    },
    {
      name                                = "S3AdministratorAccess",
      description                         = "Allow Full S3 Admininstrator access to the account",
      relay_state                         = "",
      session_duration                    = "",
      tags                                = {},
      inline_policy                       = data.aws_iam_policy_document.S3Access.json,
      policy_attachments                  = []
      customer_managed_policy_attachments = []
    }
  ]
  context = module.this.context
}

module "sso_account_assignments" {
  source = "../../modules/account-assignments"

  account_assignments = [
    {
      account_id          = "111111111111", # Represents the "production" account
      account_name        = "Account1"
      permission_set_arn  = module.permission_sets.permission_sets["AdministratorAccess"].arn,
      permission_set_name = "AdministratorAccess",
      principal_type      = "GROUP",
      principal_name      = "Administrators"
    },
    {
      account_id          = "111111111111",
      account_name        = "Account1"
      permission_set_arn  = module.permission_sets.permission_sets["S3AdministratorAccess"].arn,
      permission_set_name = "S3AdministratorAccess",
      principal_type      = "GROUP",
      principal_name      = "S3Adminstrators"
    },
    {
      account_id          = "222222222222", # Represents the "Sandbox" account
      account_name        = "account2"
      permission_set_arn  = module.permission_sets.permission_sets["AdministratorAccess"].arn,
      permission_set_name = "AdministratorAccess",
      principal_type      = "GROUP",
      principal_name      = "Developers"
    },
  ]
  context = module.this.context
}

#-----------------------------------------------------------------------------------------------------------------------
# CREATE SOME IAM POLICIES TO ATTACH AS INLINE
#-----------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "S3Access" {
  statement {
    sid = "1"

    actions = ["*"]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

#-----------------------------------------------------------------------------------------------------------------------
# CREATE SOME IAM POLICIES TO ATTACH AS MANAGED
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "S3Access" {
  name   = "S3Access"
  path   = "/"
  policy = data.aws_iam_policy_document.S3Access.json
  tags   = module.this.tags
}
