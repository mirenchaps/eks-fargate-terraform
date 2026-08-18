# Root wiring: network -> iam -> cluster -> fargate profiles -> addons.
#
# Everything runs on Fargate: there are no EC2 worker nodes, launch
# templates, or managed node groups anywhere in this configuration.

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "control_plane" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.control_plane_log_retention_days

  tags = var.tags
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  env_subfix   = var.env_subfix
  tags         = var.tags

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  cluster_name         = var.cluster_name
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  env_subfix   = var.env_subfix
  tags         = var.tags
}

module "cluster" {
  source = "./modules/cluster"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  tags               = var.tags

  cluster_role_arn = module.iam.cluster_role_arn

  # Fargate-only clusters still require subnet_ids for the control plane
  # ENIs; both private and public are included so the endpoint access
  # options below can be honored, but Fargate profiles themselves will
  # only ever reference the private subnets (see modules/fargate).
  subnet_ids = concat(module.network.private_subnet_ids, module.network.public_subnet_ids)

  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access
  public_access_cidrs     = var.public_access_cidrs

  control_plane_log_types     = var.control_plane_log_types
  control_plane_log_group_arn = aws_cloudwatch_log_group.control_plane.arn

  depends_on = [aws_cloudwatch_log_group.control_plane]
}

module "fargate" {
  source = "./modules/fargate"

  cluster_name           = module.cluster.cluster_name
  pod_execution_role_arn = module.iam.fargate_pod_execution_role_arn
  private_subnet_ids     = module.network.private_subnet_ids
  fargate_profiles       = var.fargate_profiles
  tags                   = var.tags

  depends_on = [module.cluster]
}

module "addons" {
  source = "./modules/addons"

  cluster_name       = module.cluster.cluster_name
  vpc_cni_version    = var.vpc_cni_version
  kube_proxy_version = var.kube_proxy_version
  coredns_version    = var.coredns_version
  tags               = var.tags

  # CoreDNS must be able to schedule onto Fargate before the addon is
  # applied, otherwise it will sit Pending indefinitely.
  depends_on = [module.fargate]
}
