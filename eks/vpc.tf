variable "eksapp_cidr_block" {}
variable "eksapp_public_subnets_cidr_block" {}
variable "eksapp_private_subnet_cidr_block" {}
variable "eks_app_region" {}

provider "aws" {
  region = var.eks_app_region
}

data "aws_availability_zones" "eks-app-azs" {

}

module "eksapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "eksapp-vpc"
  cidr = var.eksapp_cidr_block

  private_subnets = var.eksapp_private_subnet_cidr_block
  public_subnets  = var.eksapp_public_subnets_cidr_block

  azs = data.aws_availability_zones.eks-app-azs.names
}