provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "abedra-goto-tfstate"
    key = "vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_vpc" "goto" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "goto_subnet" {
  vpc_id = "${aws_vpc.goto.id}"
  cidr_block = "10.1.0.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_security_group" "bastion_external" {
  name = "bastion_external_security_group"
  description = "Allowed external ports for bastion hosts"
  vpc_id = "${aws_vpc.goto.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "JIRA-1234"
  }
}

resource "aws_security_group" "internal_ssh" {
  name = "bastion_internal_security_group"
  description = "Allow SSH via internal instances"
  vpc_id = "${aws_vpc.goto.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  tags {
    Name = "JIRA-456"
  }
}

resource "aws_instance" "bastion" {
  ami = "ami-25615740"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.goto_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.bastion_external.id}"]
}

resource "aws_security_group" "api_security_group" {
  name = "api_security_group"
  description = "Allowed inbound ports for api"
  vpc_id = "${aws_vpc.goto.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "JIRA-789"
  }
}

resource "aws_security_group" "tls_security_group" {
  name = "tls_security_group"
  description = "Allowed inbound ports for api"
  vpc_id = "${aws_vpc.goto.id}"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "JIRA-91011"
  }
}

data "aws_ami" "image" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2"
    ]
  }
}

resource "aws_instance" "api" {
  ami = "${data.aws_ami.image.id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.goto_subnet.id}"
  vpc_security_group_ids = [
    "${aws_security_group.api_security_group.id}",
    "${aws_security_group.internal_ssh.id}"
  ]
}
