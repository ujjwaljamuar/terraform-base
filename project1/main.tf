provider "aws" {
  region = var.region
}

variable "region" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avl_zone" {}
variable "env" {}
variable "my_ip_addr" {}
variable "instance_type" {}
variable "pub_key_location" {}

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

resource "aws_security_group" "myapp_sg" {
  name   = "myapp-sg"
  vpc_id = aws_vpc.myapp_vpc.id

  ingress {
    # for ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_addr]
  }

  ingress {
    # for nginx
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name : "${var.env}-myapp-sg"
  }
}

data "aws_ami" "latest_amazon_linux_image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

/*
output "aws_ami" {
  value = data.aws_ami.latest_amazon_linux_image
}
*/

resource "aws_key_pair" "myapp_kp" {
  key_name   = "myapp-kp"
  public_key = file(var.pub_key_location)
}

resource "aws_instance" "myapp_ec2" {
  ami           = data.aws_ami.latest_amazon_linux_image.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.myapp_subnet_1.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone      = var.avl_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.myapp_kp.key_name

  tags = {
    Name : "${var.env}-myapp-ec2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.myapp_ec2.public_ip
}