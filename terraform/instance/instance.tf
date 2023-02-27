terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-2"
}

data "aws_subnet" "cv_subnet" {
  filter {
    name = "tag:Name"
    values = ["cv_subnet"]
  }
}

data "aws_security_group" "cv_sec_group" {
  filter {
    name = "tag:Name"
    values = ["cv_sec_group"]
  }
}

# data "aws_eip" "cv_eip" {
#   filter {
#     name = "tag:Name"
#     values = ["cv_eip"]
#   }
# }

resource "aws_network_interface" "cv_eni" {
  subnet_id = data.aws_subnet.cv_subnet.id
  security_groups = [data.aws_security_group.cv_sec_group.id]
}

resource "tls_private_key" "cv_pk" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "cv_inst_keypair" {
  key_name = "cv_inst_keypair"
  public_key = tls_private_key.cv_pk.public_key_openssh
}

resource "local_file" "ssh_key" {
    filename = "${aws_key_pair.cv_inst_keypair.key_name}.pem"
    content = tls_private_key.cv_pk.private_key_pem
    file_permission = 400
}

# resource "aws_eip_association" "aws_eip_association" {
#   allocation_id = data.aws_eip.cv_eip.id
#   instance_id = aws_instance.cv_nginx_instance.id
# }

resource "aws_instance" "cv_nginx_instance" {
  ami = "ami-08f0bc76ca5236b20"
  instance_type = "t2.micro"
  key_name = aws_key_pair.cv_inst_keypair.key_name
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.cv_eni.id
  }
}

resource "local_file" "hosts_cfg" {
  content = templatefile("hosts.tpl", 
  {
    cv_static_server_ip = aws_instance.cv_nginx_instance.public_ip
  })
  filename = "../../ansible/inventory"
}