variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cluster_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "control_plane_log_types" {
  type = set(string)
}

variable "control_plane_log_group_arn" {
  description = "Not referenced by aws_eks_cluster directly, but declared to make the dependency on the caller-created log group explicit."
  type        = string
}
