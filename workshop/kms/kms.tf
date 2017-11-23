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

resource "aws_dynamodb_table" "data_encryption_keys" {
    name = "data_encryption_keys"
    read_capacity = 1
    write_capacity = 1
    hash_key = "KeyId"

    attribute {
        name = "KeyId"
        type = "S"
    }
}