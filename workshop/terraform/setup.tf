provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_s3_bucket" "abedra-yow-tfstate" {
    bucket = "abedra-yow-tfstate"
    acl = "private"
    versioning {
        enabled  = true
    }
}

terraform {
    backend "s3" {
        bucket = "abedra-yow-tfstate"
        key = "setup/terraform.tfstate"
        region = "ap-southeast-2"
    }
}
