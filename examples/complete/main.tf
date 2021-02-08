module "permission_sets" {
  source = "../../modules/permission-sets"

  permission_sets = [
    {
      name               = "One",
      description        = "This is One description",
      relay_state        = "",
      session_duration   = "",
      tags               = {},
      inline_policy      = data.aws_iam_policy_document.FullAccess.json,
      policy_attachments = []
    },
    { name               = "Two",
      description        = "This is Two description",
      relay_state        = "",
      session_duration   = "",
      tags               = {},
      inline_policy      = "",
      policy_attachments = ["arn:aws:iam::aws:policy/AdministratorAccess", "arn:aws:iam::aws:policy/AlexaForBusinessFullAccess"]
    },
    { name               = "Three",
      description        = "This is Three description",
      relay_state        = "",
      session_duration   = "",
      tags               = {},
      inline_policy      = data.aws_iam_policy_document.S3Access.json,
      policy_attachments = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  ]
  context = module.this.context
}

module "sso_account_assignments" {
  source = "../../modules/account-assignments"

  account_assignments = [
    { account = "226010001608", permission_set_arn = module.permission_sets.permission_sets["Two"].arn, principal_type = "GROUP", principal_name = "MattCalhounReadOnly" },
    { account = "226010001608", permission_set_arn = module.permission_sets.permission_sets["Three"].arn, principal_type = "GROUP", principal_name = "MattCalhounAdmin" },
    { account = "626770839906", permission_set_arn = module.permission_sets.permission_sets["One"].arn, principal_type = "GROUP", principal_name = "MattCalhounAdmin" },
    { account = "626770839906", permission_set_arn = module.permission_sets.permission_sets["One"].arn, principal_type = "USER", principal_name = "matt@cloudposse.com" }
  ]
}

#-----------------------------------------------------------------------------------------------------------------------
# CREATE SOME IAM POLCIES TO ATTACH AS INLINE
#-----------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "FullAccess" {
  statement {
    sid = "1"

    actions = [
      "*",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "S3Access" {
  statement {
    sid = "1"

    actions = ["*"]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

# output "test" {
#   value = module.permission_sets.test
# }

# output "test2" {
#   value = module.sso_account_assignments.assignments
# }
