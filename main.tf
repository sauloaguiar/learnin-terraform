provider "aws" {
  region = "sa-east-1"
  # never put sensitive data in the configuration file
  # refer to the readme file on how to use it
  # access_key = "value"
  # secret_key = "value"
}

variable "subnet_cidr_block" {
  description = "subnet cidr block"
  // default value will be use if none present on file
  // it will be overwriten if specified by the file
  default = "10.0.50.0/24" 

  // types are usually not required
  // unless we want to enforce the type in the documentation for use
  type = string
}

variable "cidr_blocks" {
  description = "cidr blocks for vpcs and subnets"
  # type = list(string)
  // use when other team members re use configuration files
  type = list(object({cidr_block = string, name = string}))
}


resource "aws_vpc" "development-vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  
  // adding or removing attributes will add/remove them in the aws resource automatically
  tags = {
    Name = var.cidr_blocks[0].name,
    vpc_env= "dev"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  // define to which vpc this subnet should belong
  // each resource has its own object equivalent
  vpc_id = aws_vpc.development-vpc.id
  cidr_block = var.cidr_blocks[1].cidr_block // index is 0 based
  availability_zone = "us-east-1a"
  tags = {
    Name = var.cidr_blocks[0].name
  }
}

// adding new resources to a pre existing resource
data  "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "dev-subnet-2" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = "10.0.10.0/24" // use cidr according to the cidr block from the vpc being used
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-2-default"
  }
}

// these will be printed after the terraform apply execution ends
output "dev-vpc-id" {
  value = aws_vpc.development-vpc.id
}
output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1.id
}