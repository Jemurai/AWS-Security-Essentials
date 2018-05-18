provider "aws" {
    region = "us-east-2"
}

terraform {
    backend "s3" {
        bucket = "abedra-tfstate"
        key = "kms/terraform.tfstate"
        region = "us-east-2"
    }
}

resource "aws_kms_key" "workshop" {
    description = "Workshop Key"
}

resource "aws_kms_alias" "master_alias" {
    name = "alias/workshop"
    target_key_id = "${aws_kms_key.workshop.key_id}"
}

resource "aws_dynamodb_table" "workshop_encryption_keys" {
    name = "workshop_encryption_keys"
    read_capacity = 1
    write_capacity = 1
    hash_key = "KeyId"

    attribute {
        name = "KeyId"
        type = "S"
    }
}
