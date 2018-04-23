provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "abedra-goto-tfstate"
    key    = "iam/terraform.tfstate"
    region = "us-east-2"
  }
}

# resource "aws_iam_account_password_policy" "approved" {
#   minimum_password_length        = 8
#   require_lowercase_characters   = true
#   require_numbers                = true
#   require_uppercase_characters   = true
#   require_symbols                = true
#   allow_users_to_change_password = true
# }

resource "aws_iam_user" "audit" {
  name = "audit"
}

resource "aws_iam_user" "goto" {
  name = "goto"
}

variable "read_only_users" {
  type        = "list"
  description = "Users that are allowed to assume ReadOnly rights"

  default = [
    "audit",
  ]
}

variable "admin_users" {
  type        = "list"
  description = "Users that are allowed to assume full Admin rights"

  default = [
    "goto",
  ]
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "read_only" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "read_only" {
  name               = "read_only"
  description        = "ReadOnly Access"
  assume_role_policy = "${data.aws_iam_policy_document.read_only.json}"
}

data "aws_iam_policy_document" "admin" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    effect = "Allow"

    condition {
      test     = "Bool"
      variable = "aws:MultifactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "admin" {
  name               = "admin"
  description        = "Administrator Access"
  assume_role_policy = "${data.aws_iam_policy_document.admin.json}"
}

data "aws_iam_policy_document" "assume_read_only" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["${aws_iam_role.read_only.arn}"]
  }
}

resource "aws_iam_policy" "assume_read_only" {
  name        = "assume_read_only"
  description = "Ability to assume the read_only role"

  policy = "${data.aws_iam_policy_document.assume_read_only.json}"
}

data "aws_iam_policy_document" "assume_admin" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["${aws_iam_role.admin.arn}"]
  }
}

resource "aws_iam_policy" "assume_admin" {
  name        = "assume_admin"
  description = "Ability to assume the admin role"

  policy = "${data.aws_iam_policy_document.assume_admin.json}"
}

resource "aws_iam_group" "admins" {
  name = "admins"
}

resource "aws_iam_group_membership" "admin_group_membership" {
  name  = "admin_group_membership"
  users = "${var.admin_users}"
  group = "${aws_iam_group.admins.name}"
}

resource "aws_iam_policy_attachment" "read_only_policy_attachment" {
  name       = "read_only_policy_attachment"
  roles      = ["${aws_iam_role.read_only.name}"]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "admin_policy_attachment" {
  name       = "admin_policy_attachment"
  roles      = ["${aws_iam_role.admin.name}"]
  groups     = ["${aws_iam_group.admins.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_policy_attachment" "assume_read_only_policy_attachment" {
  name       = "assume_read_only_policy_attachment"
  users      = "${var.read_only_users}"
  policy_arn = "${aws_iam_policy.assume_read_only.arn}"
}

resource "aws_iam_policy_attachment" "assume_admin_policy_attachment" {
  name       = "assume_admin_policy_attachment"
  users      = "${var.admin_users}"
  policy_arn = "${aws_iam_policy.assume_admin.arn}"
}
