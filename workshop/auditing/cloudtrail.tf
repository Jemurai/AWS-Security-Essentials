provider "aws" {
    region = "ap-southeast-2"
}

terraform {
    backend "s3" {
        bucket = "abedra-yow-tfstate"
        key = "auditing/terraform.tfstate"
        region = "ap-southeast-2"
    }
}

resource "aws_s3_bucket" "abedra-yow-audit" {
    bucket = "abedra-yow-audit"
    force_destroy = true

    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::abedra-yow-audit"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::abedra-yow-audit/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_cloudtrail" "audit" {
    name                          = "audit"
    s3_bucket_name                = "${aws_s3_bucket.abedra-yow-audit.id}"
    s3_key_prefix                 = "audit"
    include_global_service_events = false
}