output "project_id" {
  value = mongodbatlas_project.test.id
  sensitive = true
}

locals {
  srv_split = split("/", mongodbatlas_cluster.mycluster.srv_address)
}

output "srv_address" {
  value = nonsensitive("${local.srv_split[0]}//${var.username}:${random_password.password.result}@${local.srv_split[2]}")
}

output "mongo_uri" {
  value = mongodbatlas_cluster.mycluster.mongo_uri
}

output "connection_strings_standard" {
  value = mongodbatlas_cluster.mycluster.connection_strings.0.standard
}

output "plstring" {
  value = mongodbatlas_cluster.mycluster.connection_strings[0].private_endpoint[0].srv_connection_string
}

output "plstring_nslookup" {
  value = "nslookup -type=SRV _mongodb._tcp.${mongodbatlas_cluster.mycluster.connection_strings[0].private_endpoint[0].srv_connection_string}"
}