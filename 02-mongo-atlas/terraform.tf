terraform {
  cloud {
    organization = "great-stone-biz"

    workspaces {
      name = "02-mongo-atlas"
    }
  }
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "= 1.3.0"
    }
  }
}