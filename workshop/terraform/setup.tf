provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "abedra-workshop-tfstate" {
    bucket = "abedra-workshop-tfstate"
    acl = "private"
    versioning {
        enabled  = true
    }
}

terraform {
    backend "s3" {
        bucket = "abedra-workshop-tfstate"
        key = "setup/terraform.tfstate"
        region = "us-east-2"
    }
}