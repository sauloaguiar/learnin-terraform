provider "aws" {
  region = "us-east-1"
  # never put sensitive data in the configuration file
  # refer to the readme file on how to use it
  #access_key = ""
  #secret_key = ""
}
variable "vpc_cidr_blocks" {}
variable "subnet_cidr_blocks" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}

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
    Name = "${var.env_prefix}-internet-gateway"
  }
}

resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

resource "aws_route_table_association" "route-table-association-subnet" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp-security-group" {
  name = "myapp-security-group"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
      cidr_blocks = [ var.my_ip ]
      from_port = 22
      protocol = "tcp"
      to_port = 22
    }
  ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 8080
      protocol = "tcp"
      to_port = 8080
    }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    prefix_list_ids = []
    protocol = "-1"
    to_port = 0
  } 

  tags = {
    Name = "${var.env_prefix}-security-group"
  }
  
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

resource "aws_instance" "myapp-server" {
  # instance configuration (required fields)
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  # networking configuration (let's put this instance within our vpc)
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [ aws_default_security_group.default-sg.id ]
  availability_zone = var.avail_zone

  # 
  associate_public_ip_address = true
}