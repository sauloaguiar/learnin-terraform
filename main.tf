provider "aws" {
  region = "us-east-1"
  # never put sensitive data in the configuration file
  # refer to the readme file on how to use it
}


resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_blocks
  
  // adding or removing attributes will add/remove them in the aws resource automatically
  tags = {
    Name = "${var.env_prefix}-vpc",
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_blocks = var.subnet_cidr_blocks
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  image_name = var.image_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id
  avail_zone = var.avail_zone
}