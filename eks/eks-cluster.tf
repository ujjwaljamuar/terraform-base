provider "kubernetes" {
  host                   = data.aws_eks_cluster.eksapp-cluster.endpoint
  token                  = data.aws_eks_cluster.eksapp-cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eksapp-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "eksapp-cluster" {
  name = "eksapp-cluster"
}

data "aws_eks_cluster_auth" "eksapp-cluster" {
  name = "eksapp-cluster"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = "eksapp-cluster"
  cluster_version = "1.31"

  subnet_ids = module.eksapp-vpc.private_subnets
  vpc_id     = module.eksapp-vpc.vpc_id

  tags = {
    "environment" = "development"
    application   = "eks"
  }

  eks_managed_node_groups = {
    t2_small_group = {
      name          = "worker-group-1"
      instance_type = "t2-small"

      min_size     = 3
      max_size     = 5
      desired_size = 3
    }

    t2_medium_group = {
      name          = "worker-group-2"
      instance_type = "t2-medium"

      min_size     = 2
      max_size     = 5
      desired_size = 2
    }
  }
}