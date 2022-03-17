variable "terraform_org_name" {
  default = "great-stone-biz"
}

variable "mongo_infra_workspace_name" {
  default = "01-mongo-infra"
}

variable "mongodbatlas_public_key" {}
variable "mongodbatlas_private_key" {}

variable "org_id" {}

variable "aws_region" {
  default = "ap-northeast-2"
}
variable "mongo_region" {
  default = "AP_NORTHEAST_2"
}

variable "default_tags" {
  default = {}
}

variable "prefix" {
  default = "gs"
}

variable "username" {
  default = "tf-user"
}

variable "myip_cidr" {
  default = "14.39.92.145/32"
}