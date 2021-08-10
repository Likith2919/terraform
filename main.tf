provider "aws" {
    access_key = "AKIA3ZHUTQOV6JVLUGUS"
    secret_key = "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"
    region = "us-west-2"
  
}
resource "aws_vpc" "vpc" {
        cidr_block = "10.0.0.0/16"
        enable_dns_hostnames = true
        enable_dns_support = true
        tags = {
            "Name" = "main"
        }
}
resource "aws_subnet" "instance"{
        cidr_block = "10.0.8.0/24"
        vpc_id = aws_vpc.vpc.id
        tags = {
            "Name" = "instance"
        }
}
resource "aws_instance" "ec2_instance" {
        instance_type = "t2.micro"
        ami = "ami-083ac7c7ecf9bb9b0"
        subnet_id = aws_subnet.instance.id
	key_name = "name"
        tags = {
            "Name" = "name"
        }
}
