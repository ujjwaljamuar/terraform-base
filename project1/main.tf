provider "aws" {
  region = var.region
}

variable "region" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avl_zone" {}
variable "env" {}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name : "${var.env}-vpc"
  }
}

resource "aws_subnet" "myapp_subnet_1" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avl_zone

  tags = {
    Name : "${var.env}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name : "${var.env}-igw"
  }
}

/*
resource "aws_default_route_table" "default_rtb" {
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }

  tags = {
    Name : "${var.env}-default-rtb"
  }
}
*/

resource "aws_route_table" "myapp_route_table" {
  vpc_id = aws_vpc.myapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }

  tags = {
    Name : "${var.env}-rtb"
  }
}

resource "aws_route_table_association" "myapp_rtb_assc" {
  subnet_id      = aws_subnet.myapp_subnet_1.id
  route_table_id = aws_route_table.myapp_route_table.id
}