provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "abedra-workshop-audit" {
    bucket = "abedra-workshop-audit"
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
            "Resource": "arn:aws:s3:::abedra-workshop-audit"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::abedra-workshop-audit/*",
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
    s3_bucket_name                = "${aws_s3_bucket.abedra-workshop-audit.id}"
    s3_key_prefix                 = "audit"
    include_global_service_events = false
}