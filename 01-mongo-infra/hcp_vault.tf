provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

data "hcp_hvn" "example" {
  hvn_id = var.hvn_id
}

data "hcp_vault_cluster" "example" {
  cluster_id = var.hcp_vault_cluster_id
}

resource "hcp_vault_cluster_admin_token" "gs" {
  cluster_id = var.hcp_vault_cluster_id
}

resource "hcp_aws_network_peering" "peer" {
  hvn_id          = data.hcp_hvn.example.hvn_id
  peering_id      = "${var.prefix}-peering"
  peer_vpc_id     = aws_vpc.peer.id
  peer_account_id = aws_vpc.peer.owner_id
  peer_vpc_region = data.aws_arn.peer.region
}

resource "hcp_hvn_route" "peer_route" {
  hvn_link         = data.hcp_hvn.example.self_link
  hvn_route_id     = "${var.prefix}-hvn-route"
  destination_cidr = aws_vpc.peer.cidr_block
  target_link      = hcp_aws_network_peering.peer.self_link
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
}