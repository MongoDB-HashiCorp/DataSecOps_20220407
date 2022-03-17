# https://docs.atlas.mongodb.com/tutorial/configure-api-access/organization/create-one-api-key/
# https://docs.mongodb.com/mongodb-vscode/create-cluster-terraform/
# https://www.slideshare.net/mongodb/mongodb-world-2019-terraform-new-worlds-on-mongodb-atlas
# Left Top Org section : gear icon (Settings)
# Click Access Manager on Sidebar
# Right Top : Create  API Key

// data "http" "myip" {
//   url = "https://api.myip.com"

//   request_headers = {
//     Accept = "application/json"
//   }
// }

data "terraform_remote_state" "infra" {
  backend = "remote"

  config = {
    organization = var.terraform_org_name
    workspaces = {
      name = var.mongo_infra_workspace_name
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}

resource "mongodbatlas_project" "test" {
  name   = "${var.prefix}-project"
  org_id = var.org_id
}

resource "mongodbatlas_project_ip_access_list" "test" {
  project_id = mongodbatlas_project.test.id
  cidr_block = var.myip_cidr
  // cidr_block = "${jsondecode(data.http.myip.body).ip}/32"
  comment = "cidr block for tf acc"
}

resource "mongodbatlas_cluster" "mycluster" {
  project_id   = mongodbatlas_project.test.id
  name         = "${var.prefix}-cluster"
  cluster_type = "REPLICASET"

  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.mongo_region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }
  cloud_backup                 = true
  auto_scaling_disk_gb_enabled = true

  # Provider Settings "block"
  provider_name               = "AWS"
  disk_size_gb                = 10
  provider_instance_size_name = "M10"
}

resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = ""
}

resource "mongodbatlas_database_user" "test" {
  username           = var.username
  password           = urlencode(random_password.password.result)
  project_id         = mongodbatlas_project.test.id
  auth_database_name = "admin"

  roles {
    role_name     = "dbAdminAnyDatabase"
    database_name = "admin"
  }

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }

  labels {
    key   = "My Key"
    value = "My Value"
  }

  scopes {
    type = "CLUSTER"
    name = mongodbatlas_cluster.mycluster.name
  }
}

// Private Link
resource "mongodbatlas_privatelink_endpoint" "test" {
  project_id    = mongodbatlas_project.test.id
  provider_name = "AWS"
  region        = var.mongo_region
}

resource "aws_vpc_endpoint" "ptfe_service" {
  vpc_id             = data.terraform_remote_state.infra.outputs.private_link_ids.vpc_id
  service_name       = mongodbatlas_privatelink_endpoint.test.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.terraform_remote_state.infra.outputs.private_link_ids.subnet_ids
  security_group_ids = data.terraform_remote_state.infra.outputs.private_link_ids.security_group_ids
}

resource "mongodbatlas_privatelink_endpoint_service" "test" {
  project_id          = mongodbatlas_privatelink_endpoint.test.project_id
  private_link_id     = mongodbatlas_privatelink_endpoint.test.private_link_id
  endpoint_service_id = aws_vpc_endpoint.ptfe_service.id
  provider_name       = "AWS"
}