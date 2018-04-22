provider "aws" {
    region = "us-east-2"
}

terraform {
    backend "s3" {
        bucket = "abedra-goto-tfstate"
        key = "kms/terraform.tfstate"
        region = "us-east-2"
    }
}

resource "aws_kms_key" "goto" {
    description = "GOTO Key"
}

resource "aws_kms_alias" "master_alias" {
    name = "alias/goto"
    target_key_id = "${aws_kms_key.goto.key_id}"
}

resource "aws_dynamodb_table" "goto_encryption_keys" {
    name = "goto_encryption_keys"
    read_capacity = 1
    write_capacity = 1
    hash_key = "KeyId"

    attribute {
        name = "KeyId"
        type = "S"
    }
}
