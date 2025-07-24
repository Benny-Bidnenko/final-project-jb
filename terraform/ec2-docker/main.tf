# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Get current public IP for security group
data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com"
}

# Get the specified VPC
data "aws_vpc" "existing_vpc" {
  id = var.vpc_id
}

# Get public subnets from the existing VPC
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate an SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/builder_key.pem"
  file_permission = "0600"
}

# Create an AWS key pair using the public key
resource "aws_key_pair" "builder_key" {
  key_name   = "builder-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name        = "builder-ssh-key"
    Environment = var.environment
    Project     = "final-project-jb"
  }
}

# Create Security Group
resource "aws_security_group" "builder_sg" {
  name_prefix = "builder-sg-"
  description = "Security group for builder EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access from current IP
  ingress {
    description = "SSH from current IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.current_ip.response_body)}/32"]
  }

  # HTTP access on port 5001 from current IP
  ingress {
    description = "HTTP on port 5001 from current IP"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.current_ip.response_body)}/32"]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "builder-security-group"
    Environment = var.environment
    Project     = "final-project-jb"
  }
}

# Create the EC2 instance
resource "aws_instance" "builder" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.builder_key.key_name
  vpc_security_group_ids = [aws_security_group.builder_sg.id]
  subnet_id             = data.aws_subnets.public_subnets.ids[0]
  
  # Enable detailed monitoring
  monitoring = true

  # Configure the root block device
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
    
    tags = {
      Name = "builder-root-volume"
    }
  }

  # User data script for automated Docker installation (Option 2 - Bonus)
  user_data = base64encode(templatefile("${path.module}/install_docker.sh", {
    username = "ec2-user"
  }))

  tags = {
    Name        = "builder"
    Environment = var.environment
    Project     = "final-project-jb"
    Purpose     = "Docker Builder Instance"
  }

  # Wait for instance to be ready before proceeding
  provisioner "remote-exec" {
    inline = [
      "echo 'Instance is ready!'",
      "sudo systemctl status docker",
      "docker --version",
      "docker compose version"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.public_ip
      timeout     = "5m"
    }
  }
}
