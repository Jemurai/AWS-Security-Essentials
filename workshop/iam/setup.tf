provider "aws" {
  region = "us-east-2"
}

terraform {
    backend "s3" {
        bucket = "abedra-goto-tfstate"
        key = "iam/terraform.tfstate"
        region = "us-east-2"
    }
}

resource "aws_iam_user" "audit" {
  name = "audit"
}

resource "aws_iam_user" "goto" {
  name = "goto"
}

variable "read_only_users" {
  type = "list"
  description = "Users that are allowed to assume ReadOnly rights"
  default = [
    "audit"
  ]
}

variable "admin_users" {
  type = "list"
  description = "Users that are allowed to assume full Admin rights"
  default = [
    "goto"
  ]
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "read_only" {
  name = "read_only"
  description = "ReadOnly Access"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Effect": "Allow",
            "Sid": "",
            "Condition": {
                "Bool": {
                    "aws:MultifactorAuthPresent": "true"
                }
            }
        }
    ]
}
    EOF
}

resource "aws_iam_role" "admin" {
  name = "admin"
  description = "Administrator Access"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Effect": "Allow",
            "Sid": "",
            "Condition": {
                "Bool": {
                    "aws:MultifactorAuthPresent": "true"
                }
            }
        }
    ]
}
    EOF
}

resource "aws_iam_policy" "assume_read_only" {
  name = "assume_read_only"
  description = "Ability to assume the read_only role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "${aws_iam_role.read_only.arn}"
  }
}
EOF
}

resource "aws_iam_policy" "assume_admin" {
  name = "assume_admin"
  description = "Ability to assume the admin role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "${aws_iam_role.admin.arn}"
  }
}
EOF
}

resource "aws_iam_policy_attachment" "read_only_policy_attachment" {
  name = "read_only_policy_attachment"
  roles = ["${aws_iam_role.read_only.name}"]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "admin_policy_attachment" {
  name = "admin_policy_attachment"
  roles = ["${aws_iam_role.admin.name}"]
  # groups = ["${aws_iam_group.admins.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_policy_attachment" "assume_read_only_policy_attachment" {
  name = "assume_read_only_policy_attachment"
  users = "${var.read_only_users}"
  policy_arn = "${aws_iam_policy.assume_read_only.arn}"
}

resource "aws_iam_policy_attachment" "assume_admin_policy_attachment" {
  name = "assume_admin_policy_attachment"
  users = "${var.admin_users}"
  policy_arn = "${aws_iam_policy.assume_admin.arn}"
}
