data "terraform_remote_state" "infra" {
  backend = "remote"

  config = {
    organization = var.terraform_org_name
    workspaces = {
      name = var.mongo_infra_workspace_name
    }
  }
}

data "terraform_remote_state" "mongo" {
  backend = "remote"

  config = {
    organization = var.terraform_org_name
    workspaces = {
      name = var.mongo_atlas_workspace_name
    }
  }
}

provider "vault" {
  address = data.terraform_remote_state.infra.outputs.hcp_vault_public_url

  auth_login {
    path      = "auth/userpass/login/${var.vault_username}"
    namespace = "admin"

    parameters = {
      password = "${var.vault_password}"
    }
  }
}

// secret kv v2
resource "vault_mount" "kvv2" {
  path = "secret"
  type = "kv-v2"
}

resource "vault_generic_secret" "atlas" {
  path = "${vault_mount.kvv2.path}/atlas-info"

  data_json = <<EOT
{
  "private_srv": "${data.terraform_remote_state.mongo.outputs.plstring}",
  "public_srv": "${data.terraform_remote_state.mongo.outputs.srv_address}"
}
EOT
}

// transit
resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  description               = "Example description"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "key" {
  backend = vault_mount.transit.path
  name    = "my_key"
}

// vault write -force /sys/leases/revoke-force/atlas
resource "vault_mount" "atlas" {
  path = "atlas"
  type = "database"
}

resource "vault_database_secret_backend_connection" "atlas" {
  backend       = vault_mount.atlas.path
  name          = "atlas"
  allowed_roles = ["dev"]

  mongodbatlas {
    project_id  = data.terraform_remote_state.mongo.outputs.project_id
    public_key  = var.mongodbatlas_public_key
    private_key = var.mongodbatlas_private_key
  }
}

resource "vault_database_secret_backend_role" "dev" {
  depends_on = [
    vault_generic_secret.atlas
  ]
  
  backend = vault_mount.atlas.path
  name    = "dev"
  db_name = vault_database_secret_backend_connection.atlas.name
  creation_statements = [jsonencode(
    {
      database_name = "admin"
      roles = [
        {
          databaseName = "admin",
          roleName     = "readWriteAnyDatabase"
        }
      ]
    }
  )]
}