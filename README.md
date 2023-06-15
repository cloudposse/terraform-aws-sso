# AWS SSO Permission Sets Module

This module creates a collection of [AWS SSO permission sets](https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html). A permission set is a collection of administrator-defined policies that AWS SSO uses to determine a user's effective permissions to access a given AWS account. Permission sets can contain either AWS managed policies or custom policies that are stored in AWS SSO. Policies are essentially documents that act as containers for one or more permission statements. These statements represent individual access controls (allow or deny) for various tasks that determine what tasks users can or cannot perform within the AWS account.

Permission sets are stored in AWS SSO and are only used for AWS accounts. They are not used to manage access to cloud applications. Permission sets ultimately get created as IAM roles in a given AWS account, with trust policies that allow users to assume the role through AWS SSO.

## Usage

```hcl
module "sso" {
  source = "https://github.com/nimbux911/terraform-aws-sso.git?ref=main"

  permission_sets = [
    {
      name               = "SSO_PS_ADMINISTRATOR",
      description        = "Allow Full Access to the account",
      relay_state        = "",
      session_duration   = "PT12H",
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

account_assignments = [
    {
        account = "111111111111",
        permission_set_arn = module.sso.permission_sets["SSO_PS_ADMINISTRATOR_STAGE"].arn,
        permission_set_name = "Administrators",
        principal_type = "GROUP",
        principal_name = "Administrators"
    },
    {
        account = "111111111111",
        permission_set_arn = "arn:aws:sso:::permissionSet/ssoins-0000000000000000/ps-955c264e8f20fea3",
        permission_set_name = "Developers",
        principal_type = "GROUP",
        principal_name = "Developers"
    },
    {
        account = "222222222222",
        permission_set_arn = "arn:aws:sso:::permissionSet/ssoins-0000000000000000/ps-31d20e5987f0ce66",
        permission_set_name = "Developers",
        principal_type = "GROUP",
        principal_name = "Developers"
    },
  ]
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

resource "aws_iam_policy" "S3Access" {
  name   = "S3Access"
  path   = "/"
  policy = data.aws_iam_policy_document.S3Access.json
  tags   = module.this.tags
}
```
