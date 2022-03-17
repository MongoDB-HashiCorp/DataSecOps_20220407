provider "aws" {
  region = var.region

  default_tags {
    tags = var.default_tags
  }
}

resource "aws_vpc" "peer" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.peer.id
}

resource "aws_eip" "example" {
  vpc = true
}

resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.peer.id
  cidr_block              = "172.31.10.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.example.id
}

resource "aws_default_route_table" "example" {
  default_route_table_id = aws_vpc.peer.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  route {
    cidr_block                = data.hcp_hvn.example.cidr_block
    vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  }
}

resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_default_route_table.example.id
}

resource "aws_default_network_acl" "example" {
  default_network_acl_id = aws_vpc.peer.default_network_acl_id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}


data "aws_arn" "peer" {
  arn = aws_vpc.peer.arn
}

data "aws_availability_zones" "available" {
  state = "available"
}

// data "http" "myip" {
//   url = "https://api.myip.com"

//   request_headers = {
//     Accept = "application/json"
//   }
// }

resource "aws_security_group" "example" {
  vpc_id = aws_vpc.peer.id
  name   = "${var.prefix}-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myip_cidr]
    // cidr_blocks = ["${jsondecode(data.http.myip.body).ip}/32"]
  }

  // egress {
  //   from_port   = 0
  //   to_port     = 0
  //   protocol    = "-1"
  //   cidr_blocks = ["0.0.0.0/0"]
  // }

  egress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = [data.hcp_hvn.example.cidr_block]
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key_pem" {
  content         = tls_private_key.example.private_key_pem
  filename        = ".ssh/id_rsa"
  file_permission = "0600"
}

resource "aws_key_pair" "example" {
  key_name   = "${var.prefix}-key-pair"
  public_key = tls_private_key.example.public_key_openssh
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_eip" "test" {
  vpc      = true
  instance = aws_instance.test.id
}

resource "aws_instance" "test" {
  subnet_id     = aws_subnet.example.id
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "m5.large"
  key_name      = aws_key_pair.example.key_name
  vpc_security_group_ids = [
    aws_security_group.example.id
  ]
}

// resource "aws_kms_key" "example" {
//   description             = "MongoDB KMS key"
//   deletion_window_in_days = 10
// }