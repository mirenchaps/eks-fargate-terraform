output "cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}

output "fargate_pod_execution_role_arn" {
  value = aws_iam_role.fargate_pod_execution.arn
}
