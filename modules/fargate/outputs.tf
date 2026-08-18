output "fargate_profile_names" {
  value = [for p in aws_eks_fargate_profile.this : p.fargate_profile_name]
}

output "fargate_profile_arns" {
  value = { for k, p in aws_eks_fargate_profile.this : k => p.arn }
}
