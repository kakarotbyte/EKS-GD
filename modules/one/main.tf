data "aws_availability_zones" "available" {}

################################################################################
# VPC
################################################################################
module scenario_one_vpc {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.5.2"
    name = var.cluster_name
    cidr = "10.0.0.0/16"
    azs = data.aws_availability_zones.available.names
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets =  ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "type" = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "type" = "private"
  }

  tags = {
    "test" = "Demo-VPC"
}
}
################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  vpc_id                   = module.scenario_one_vpc.vpc_id
  subnet_ids               = module.scenario_one_vpc.private_subnets
  control_plane_subnet_ids = module.scenario_one_vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m5.large"]
  }
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["m5.large"]
    }
  }
  # aws-auth configmap
  #manage_aws_auth_configmap = false

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

