output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.cluster.cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = module.cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster."
  value       = module.cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data for the cluster."
  value       = module.cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by the cluster and Fargate profiles."
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs (NAT/ALB only)."
  value       = module.network.public_subnet_ids
}

output "cluster_role_arn" {
  description = "IAM role ARN assumed by the EKS control plane."
  value       = module.iam.cluster_role_arn
}

output "fargate_pod_execution_role_arn" {
  description = "IAM role ARN assumed by Fargate pod executions."
  value       = module.iam.fargate_pod_execution_role_arn
}

output "fargate_profile_names" {
  description = "Names of the created Fargate profiles."
  value       = module.fargate.fargate_profile_names
}

output "configure_kubectl" {
  description = "Command to configure kubectl for this cluster."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.cluster.cluster_name}"
}
