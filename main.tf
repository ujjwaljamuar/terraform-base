provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "dev_subnet_1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-south-1b"
}