output "vpc_cni_addon_arn" {
  value = aws_eks_addon.vpc_cni.arn
}

output "kube_proxy_addon_arn" {
  value = aws_eks_addon.kube_proxy.arn
}

output "coredns_addon_arn" {
  value = aws_eks_addon.coredns.arn
}
