variable "prefix" {
  default = "gs"
}

variable "username" {
  default = "tf-user"
}

variable "region" {
  default = "ap-northeast-2"
}

variable "default_tags" {
  default = {}
}

variable "myip_cidr" {
  default = "14.39.92.145/32"
}

variable "hvn_id" {
  default = "hvn"
}

variable "hcp_client_id" {}
variable "hcp_client_secret" {}
variable "hcp_vault_cluster_id" {}