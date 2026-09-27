provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "ecommerce" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "ecommerce-vpc" }
}

resource "aws_internet_gateway" "ecommerce" {
  vpc_id = aws_vpc.ecommerce.id
  tags   = { Name = "ecommerce-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ecommerce.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = { Name = "ecommerce-public-subnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecommerce.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecommerce.id
  }

  tags = { Name = "ecommerce-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ecommerce" {
  name        = "ecommerce-sg"
  description = "Frontend public access and internal backend communication"
  vpc_id      = aws_vpc.ecommerce.id

  ingress {
    description = "Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH for verification"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Backend service communication"
    from_port   = 3001
    to_port     = 3004
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ecommerce-sg" }
}

resource "aws_key_pair" "exam" {
  count      = var.ssh_public_key == "" ? 0 : 1
  key_name   = "ecommerce-exam-key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "ecommerce" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ecommerce.id]
  associate_public_ip_address = true
  key_name                    = var.ssh_public_key == "" ? null : aws_key_pair.exam[0].key_name

  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    dockerhub_username = var.dockerhub_username
  })

  user_data_replace_on_change = true

  tags = {
    Name    = "ecommerce-docker-host"
    Project = "HeroX-DevOps-Exam"
  }
}
