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
