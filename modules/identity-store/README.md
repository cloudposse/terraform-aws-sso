# AWS SSO Identity Store Module

This module creates SSO Users and Groups in the [AWS SSO Identity Source](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source.html).


## Usage

For example:

```hcl
locals {
  users = {
    User1 = {
      first_name = "Michael",
      last_name  = "Segal",
      email      = "micheal.s@domain.com"
    }
    User2 = {
      first_name = "Lisa",
      last_name  = "Hamilton",
      email      = "lisa.h@domain.com"
    }
  }
  groups = {
    admin = {
      display_name = "Admin",
      description  = "Admin Group"
    }
    dev = {
      display_name = "Dev",
      description  = "Dev Group"
    }
    read-only = {
      display_name = "ReadOnly",
      description  = "Read Only Group"
    }
  }
}

module "identity-store" {
  source = "../terraform-aws-sso/modules/identity-store"
  users  = local.users
  groups = local.groups
}

```
