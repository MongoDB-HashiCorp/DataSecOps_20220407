terraform {
  cloud {
    organization = "great-stone-biz"

    workspaces {
      name = "01-mongo-infra"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 2.1.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.23.0"
    }
  }
}