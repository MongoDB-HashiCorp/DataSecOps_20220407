variable "terraform_org_name" {
  default = "great-stone-biz"
}

variable "mongo_infra_workspace_name" {
  default = "01-mongo-infra"
}

variable "mongo_atlas_workspace_name" {
  default = "02-mongo-atlas"
}

variable "mongodbatlas_public_key" {}
variable "mongodbatlas_private_key" {}

variable "vault_username" {}
variable "vault_password" {}