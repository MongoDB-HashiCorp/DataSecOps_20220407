terraform {
  cloud {
    organization = "great-stone-biz"

    workspaces {
      name = "03-mongo-vault"
    }
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "= 3.3.1"
    }
  }
}