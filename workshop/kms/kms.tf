provider "aws" {
    region = "us-east-2"
}

resource "aws_kms_key" "master" {
    description = "Master Key"
}

resource "aws_kms_alias" "master_alias" {
    name = "alias/master"
    target_key_id = "${aws_kms_key.master.key_id}"
}