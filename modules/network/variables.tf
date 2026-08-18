variable "project_name" {
  type = string
}

variable "env_subfix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cluster_name" {
  description = "Used only for the required kubernetes.io/cluster/<name> subnet tags."
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.public_subnet_cidrs)
    error_message = "private_subnet_cidrs and public_subnet_cidrs must have the same length (one pair per AZ)."
  }
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}
