provider "aws" {
  region = "us-west-2" # Replace with your desired AWS region
}

resource "aws_vpc" "yggdrasil_vpc_lab" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "yggdrasil_vpc_lab"
  }
}

resource "aws_subnet" "loki_public_subnet_1" {
  vpc_id            = aws_vpc.yggdrasil_vpc_lab.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a" # Replace with your desired AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "loki_public_subnet_1"
  }
}

resource "aws_subnet" "loki_public_subnet_2" {
  vpc_id            = aws_vpc.yggdrasil_vpc_lab.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b" # Replace with your desired AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "loki_public_subnet_2"
  }
}

resource "aws_subnet" "odin_private_subnet_1" {
  vpc_id            = aws_vpc.yggdrasil_vpc_lab.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a" # Replace with your desired AZ
  tags = {
    Name = "odin_private_subnet_1"
  }
}

resource "aws_subnet" "odin_private_subnet_2" {
  vpc_id            = aws_vpc.yggdrasil_vpc_lab.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b" # Replace with your desired AZ
  tags = {
    Name = "odin_private_subnet_2"
  }
}

resource "aws_internet_gateway" "Bifröst" {
  vpc_id = aws_vpc.yggdrasil_vpc_lab.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.yggdrasil_vpc_lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Bifröst
  }
}

resource "aws_route_table_association" "loki_public_subnet_1_association" {
  subnet_id      = aws_subnet.loki_public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "loki_public_subnet_2_association" {
  subnet_id      = aws_subnet.loki_public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id             = aws_vpc.yggdrasil_vpc_lab.id
  service_name       = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = [aws_route_table.public_route_table.id]
  private_dns_enabled = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:*",
        Resource = ["arn:aws:s3:::*/*"]
      }
    ]
  })

  tags = {
    Name = "Asgard-s3-vpc-endpoint"
  }
}
