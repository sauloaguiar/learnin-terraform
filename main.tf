provider "aws" {
  region = "us-east-1"
  # never put sensitive data in the configuration file
  # refer to the readme file on how to use it
  #access_key = "AKIAQKXWVPUTOANFBR6S"
  #secret_key = "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"
}
variable "vpc_cidr_blocks" {}
variable "subnet_cidr_blocks" {}

variable "avail_zone" {}

variable "env_prefix" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_blocks
  
  // adding or removing attributes will add/remove them in the aws resource automatically
  tags = {
    Name = "${var.env_prefix}-vpc",
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  // define to which vpc this subnet should belong
  // each resource has its own object equivalent
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_blocks
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1",
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix} internet gateway"
  }
}

resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.env_prefix} route table"
  }
}

resource "aws_route_table_association" "route-table-association-subnet" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}