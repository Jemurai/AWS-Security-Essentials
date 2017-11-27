provider "aws" {
    region = "ap-southeast-2"
}

terraform {
    backend "s3" {
        bucket = "abedra-yow-tfstate"
        key = "kms/terraform.tfstate"
        region = "ap-southeast-2"
    }
}

resource "aws_kms_key" "yow" {
    description = "Yow Key"
}

resource "aws_kms_alias" "master_alias" {
    name = "alias/yow"
    target_key_id = "${aws_kms_key.yow.key_id}"
}

resource "aws_dynamodb_table" "yow_encryption_keys" {
    name = "yow_encryption_keys"
    read_capacity = 1
    write_capacity = 1
    hash_key = "KeyId"

    attribute {
        name = "KeyId"
        type = "S"
    }
}