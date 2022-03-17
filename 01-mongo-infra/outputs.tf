output "ssh_private_key" {
  value = nonsensitive(tls_private_key.example.private_key_pem)
}

output "aws_eip_ip" {
  value = aws_eip.test.public_ip
}

output "hcp_vault_public_url" {
  value = data.hcp_vault_cluster.example.vault_public_endpoint_url
}

output "private_link_ids" {
  value = {
    vpc_id             = aws_vpc.peer.id
    subnet_ids         = [aws_subnet.example.id]
    security_group_ids = [aws_security_group.example.id]
  }
}