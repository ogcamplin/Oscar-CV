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

resource "aws_vpc" "cv_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "cv_vpc"
  }
}

resource "aws_subnet" "cv_subnet" {
  vpc_id = aws_vpc.cv_vpc.id
  cidr_block = aws_vpc.cv_vpc.cidr_block # same cidr as vpc
  map_public_ip_on_launch = true

  tags = {
    Name = "cv_subnet"
  }
}

resource "aws_internet_gateway" "cv_igw" {
  vpc_id = aws_vpc.cv_vpc.id
}

resource "aws_route_table" "cv_route_table" {
  vpc_id = aws_vpc.cv_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cv_igw.id
  }
} 

# resource "aws_eip" "cv_eip" {
#   vpc = true

#   tags = {
#     Name = "cv_eip"
#   }
# }

resource "aws_route_table_association" "cv_rta_subnet" {
  subnet_id = aws_subnet.cv_subnet.id
  route_table_id = aws_route_table.cv_route_table.id
}

resource "aws_security_group" "cv_sec_group" {
  name = "cv_sec_group"
  vpc_id = aws_vpc.cv_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    from_port = 22
    to_port = 22
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    from_port = 80
    to_port = 80
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    from_port = 443
    to_port = 443
  }

  # ingress {
  #   cidr_blocks = ["0.0.0.0/0"]
  #   protocol = "tcp"
  #   from_port = 53
  #   to_port = 53
  # }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "icmp"
    from_port = 0
    to_port = 8
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "cv_sec_group"
  }
}

resource "aws_network_acl" "cv_nacl" {
  vpc_id = aws_vpc.cv_vpc.id
  subnet_ids = [aws_subnet.cv_subnet.id]
  
  ingress {
    rule_no = 1
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  ingress {
    rule_no = 2
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  ingress {
    rule_no = 3
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  # ingress {
  #   rule_no = 4
  #   from_port = 53
  #   to_port = 53
  #   protocol = "tcp"
  #   cidr_block = "0.0.0.0/0"
  #   action = "allow"
  # }

  ingress {
    rule_no = 5
    from_port = 0
    to_port = 8
    protocol = "icmp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  ingress {
    rule_no = 6
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  # egress rules

  egress {
    rule_no = 1
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  egress {
    rule_no = 2
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  egress {
    rule_no = 3
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }

  # egress {
  #   rule_no = 4
  #   from_port = 53
  #   to_port = 53
  #   protocol = "tcp"
  #   cidr_block = "0.0.0.0/0"
  #   action = "allow"
  # }

  egress {
    rule_no = 5
    from_port = 0
    to_port = 8
    protocol = "icmp"
    cidr_block = "0.0.0.0/0"
    action = "allow"
  }
}

