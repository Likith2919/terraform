#Accessing the provider
provider "aws" {
	access_key = "AKIA3ZHUTQOV6JVLUGUS"
	secret_key = "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"
	region = "us-west-2"

}
# Creating the vpc

 resource "aws_vpc" "first" {
     cidr_block = "10.0.0.0/16"
     enable_dns_hostnames = true
     enable_dns_support = true
     tags = {
	"Name" = "test_vpc"
 }
}
# Availability_zones1

data "aws_availability_zone" "first" {
	name = "us-west-2a"
}
# availability_zone2
 data "aws_availability_zone" "second" {
	name = "us-west-2b"
}
# Creating the public subnet

resource "aws_subnet" "pub_sub1" {
	vpc_id = aws_vpc.first.id
	map_public_ip_on_launch = true
        availability_zone_id=  "data.aws_availability_zone.first"
	cidr_block = "10.0.1.0/24"
	tags = {
	 "Name" = "public_subnet1"
 }
}
# Creating the public subnet2
resource "aws_subnet" "pub_sub2" {
        vpc_id = aws_vpc.first.id
        map_public_ip_on_launch = true
        availability_zone = "data.aws_availability_zone.second"
        cidr_block = "10.0.2.0/24"
        tags = {
         "Name" = "public_subnet2"
 }
}

# Creating the internet gateway 
resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.first.id
	tags = {
 	  "Name" = "test_igw"
 }
}
#creating the public route table 

resource "aws_route_table" "example" {
	vpc_id = aws_vpc.first.id
	tags = {
 	  "Name" = "public_rt"
 }
	route {
	  cidr_block = "0.0.0.0/0"
	  gateway_id = aws_internet_gateway.igw.id
 }
}
# route table association

resource "aws_route_table_association" "public1" {
	subnet_id = aws_subnet.pub_sub1.id
	route_table_id = aws_route_table.example.id 
}

# Creating the privateinstance 1

resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.first.id
  map_public_ip_on_launch = false
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "private_1-demo"
  }
}
# Creating the private instanc 2

resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.first.id
  map_public_ip_on_launch = false
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "private_2"
  }
}
# Creating the private instance 3

resource "aws_subnet" "private_3" {
  vpc_id     = aws_vpc.first.id
  map_public_ip_on_launch = false
  cidr_block="10.0.5.0/24"

  tags = {
    Name = "private_3"
  }
}
# Creating the elastic Ip

resource "aws_eip" "nat" {
  vpc      = true
}
# Creating the nat gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pub_sub1.id
  depends_on    = [aws_internet_gateway.igw]
}
# creating the priv rt

 resource "aws_route_table" "pvt" {
	#cidr_block = "0.0.0.0/0"
	vpc_id = aws_vpc.first.id
	#gateway_id = aws_nat_gateway.nat_gw.id
	tags = {
	 "Name" = "NAT-route-table"
 }
	route {
	 cidr_block = "0.0.0.0/0"
	 gateway_id = aws_nat_gateway.nat_gw.id	
 }
}

# Associate route table to private subnet

resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
	depends_on = [
	 aws_subnet.private_1,
	 aws_route_table.pvt,
	]
	subnet_id = aws_subnet.private_1.id
	route_table_id = aws_route_table.pvt.id
}
