variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Base project name used in resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,62}$", var.project_name))
    error_message = "project_name must use lowercase letters, numbers, and hyphens."
  }
}

variable "env_subfix" {
  description = "Environment suffix appended to resource names (e.g. dev, stage, prod)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,31}$", var.env_subfix))
    error_message = "env_subfix must use lowercase letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Shared tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the control plane (MAJOR.MINOR)."
  type        = string
  default     = "1.33"
}

# --- Networking ---

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (NAT gateways / ALBs only), one per AZ."
  type        = list(string)
  default     = ["10.50.0.0/24", "10.50.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (control plane ENIs + all Fargate pods), one per AZ."
  type        = list(string)
  default     = ["10.50.10.0/24", "10.50.11.0/24"]
}

variable "single_nat_gateway" {
  description = "If true, creates one NAT gateway shared across all AZs (cheaper, less HA). If false, one NAT per AZ."
  type        = bool
  default     = true
}

# --- Cluster endpoint access ---

variable "endpoint_public_access" {
  description = "Whether the EKS API server endpoint is reachable from the public internet."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the EKS API server endpoint is reachable from within the VPC."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public API endpoint, if enabled."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "control_plane_log_types" {
  description = "EKS control-plane log types to enable."
  type        = set(string)
  default     = ["api", "audit", "authenticator"]
}

variable "control_plane_log_retention_days" {
  description = "Retention (days) for the control-plane CloudWatch log group."
  type        = number
  default     = 90
}

# --- Fargate profiles ---

variable "fargate_profiles" {
  description = <<-EOT
    Map of Fargate profile name -> selectors. Every namespace that will run
    pods must have a matching entry here (including kube-system for
    coredns), or those pods will never schedule.
  EOT
  type = map(object({
    selectors = list(object({
      namespace = string
      labels    = optional(map(string), {})
    }))
  }))
  default = {
    kube-system = {
      selectors = [
        { namespace = "kube-system", labels = { "k8s-app" = "kube-dns" } }
      ]
    }
    default = {
      selectors = [
        { namespace = "default", labels = {} }
      ]
    }
  }
}

# --- Add-on versions ---

variable "vpc_cni_version" {
  description = "Version of the vpc-cni addon. Null uses the EKS default for the cluster version."
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy addon. Null uses the EKS default for the cluster version."
  type        = string
  default     = null
}

variable "coredns_version" {
  description = "Version of the coredns addon. Null uses the EKS default for the cluster version."
  type        = string
  default     = null
}
