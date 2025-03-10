provider "aws" {
  region = "ap-south-1"
}

variable "dev_vpc_cidr" {
  description = "dev vpc cidr range"
  default = "10.0.0.0/16"
  type = string // bool, string, number, list(string), list(object({cidr=string,name:string}))
}

variable "pvt_subnet_1_cidr" {
  description = "private subnet cidr range"
}

variable "pub_subnet_1_cidr" {
  description = "public subnet cidr range"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = var.dev_vpc_cidr
}

resource "aws_subnet" "pvt_subnet_1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.pvt_subnet_1_cidr
  availability_zone = "ap-south-1a"
}

// we use data to retrieve information of existing resources
data "aws_vpc" "default_vpc" {
  default = true
  #   cidr_block = aws_vpc.dev_vpc.cidr_block
  # filter {

  # }
}

resource "aws_subnet" "pub_subnet_1" {
  vpc_id            = data.aws_vpc.default_vpc.id
  cidr_block        = var.pub_subnet_1_cidr
  availability_zone = "ap-south-1b"
}

output "dev_vpc_id" {
  value = aws_vpc.dev_vpc.id
}