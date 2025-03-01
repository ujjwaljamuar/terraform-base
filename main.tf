provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pvt_subnet_1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-south-1a"
}

data "aws_vpc" "default_vpc" {
  default = true
  #   cidr_block = aws_vpc.dev_vpc.cidr_block
  # filter {

  # }
}

resource "aws_subnet" "pub_subnet_1" {
  vpc_id            = data.aws_vpc.default_vpc.id
  cidr_block        = "172.31.48.0/20"
  availability_zone = "ap-south-1b"
}