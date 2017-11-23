provider "aws" {
    region = "us-east-2"
}

resource "aws_vpc" "workshop" {
    cidr_block = "10.1.0.0/16"

    tags {
        Name = "main"
    }
}

resource "aws_subnet" "workshop_subnet" {
    vpc_id = "${aws_vpc.workshop.id}"
    cidr_block = "10.1.0.0/24"
    availability_zone = "us-east-2"
    
    tags {
        Name = "main"
    }
}

resource "aws_security_group" "api_security_group" {
    name = "api_security_group"
    description = "Allowed inbound ports for api"
    vpc_id = "${aws_vpc.workshop.id}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "main_api"
    }
}

resource "aws_security_group" "bastion_external_security_group" {
    name = "bastion_external_security_group"
    description = "Allowed external ports for bastion hosts"
    vpc_id = "${aws_vpc.workshop.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "main_bastion"
    }
}

resource "aws_security_group" "bastion_internal_security_group" {
    name = "bastion_internal_security_group"
    description = "Allow SSH via bastion hosts for internal instances"
    vpc_id = "${aws_vpc.workshop.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "SSH"
        cidr_blocks = ["10.1.0.2/32"]
    }
}

resource "aws_instance" "bastion" {
    ami = "xxx"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.bastion_external_security_group.id}"]

    tags {
        Name = "bastion"
    }
}

resource "aws_instance" "api" {
    ami = "xxx"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.api_security_group.id}", "${aws_security_group.bastion_internal_security_group.id}"]

    tags {
        Name = "api"
    }
}