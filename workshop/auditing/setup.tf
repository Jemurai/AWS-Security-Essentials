provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "abedra-goto-tfstate"
    key    = "auditing/terraform.tfstate"
    region = "us-east-2"
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = ["${aws_s3_bucket.abedra-goto-audit.arn}"]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.abedra-goto-audit.arn}/audit/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "audit" {
  bucket = "${aws_s3_bucket.abedra-goto-audit.bucket}"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_s3_bucket" "abedra-goto-audit" {
  bucket        = "abedra-goto-audit"
  force_destroy = true
}

resource "aws_cloudtrail" "audit" {
  name                          = "audit"
  s3_bucket_name                = "${aws_s3_bucket.abedra-goto-audit.id}"
  s3_key_prefix                 = "audit"
  include_global_service_events = true
  depends_on                    = ["aws_s3_bucket_policy.audit"]
}

resource "aws_guardduty_detector" "GOTO" {
  enable = true
}
