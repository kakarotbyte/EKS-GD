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
      min_size     = 2
      max_size     = 3
      desired_size = 3

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

resource "kubectl_manifest" "eightpods" {
    yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx
  name: nginx
  namespace: default
spec:
  replicas: 10
  selector:
    matchLabels:
      app: nginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
 YAML
 depends_on = [ module.eks]
 }

resource "kubectl_manifest" "RBAC" {
    yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: api-sorver
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
subjects:
- kind: ServiceAccount
  name: api-sorver
  namespace: kube-system
 YAML
 depends_on = [ kubectl_manifest.eightpods,module.eks]
 }

resource "kubectl_manifest" "serviceAccount" {
    yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api-sorver
  namespace: kube-system
 YAML
 depends_on = [ kubectl_manifest.RBAC,module.eks]
 }

resource "kubectl_manifest" "destroyer" {
    yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: api-server
  name: api-server
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-server
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: api-server
    spec:
      containers:
      - image: public.ecr.aws/s0u1v2w0/default-namespace-random-pod-deleter:latest
        name: pod-delete
      serviceAccountName: api-sorver
 YAML
 depends_on = [ kubectl_manifest.serviceAccount,module.eks]
 }