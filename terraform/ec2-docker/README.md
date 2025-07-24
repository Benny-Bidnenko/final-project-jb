# Terraform EC2 Docker Infrastructure

This Terraform configuration provisions an EC2 instance named "builder" with Docker and Docker Compose pre-installed.

## Architecture Overview

- **EC2 Instance**: `t3.medium` Amazon Linux 2 instance named "builder"
- **VPC**: Uses existing VPC `vpc-044604d0bfb707142`
- **Security**: SSH and HTTP (port 5001) access restricted to your current IP
- **Docker**: Automatically installed via user-data script
- **SSH Keys**: Generated automatically with secure key management

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (>= 1.0)
3. **Internet connection** for downloading Docker and getting your public IP

## Quick Start

1. **Clone and navigate to the terraform directory**:
   ```bash
   cd terraform/ec2-docker
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

5. **Get the SSH connection command**:
   ```bash
   terraform output ssh_connection_command
   ```

## Configuration Files

- `main.tf` - Main Terraform configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `install_docker.sh` - Docker installation script
- `terraform.tfvars.example` - Example variables file

## Customization

Copy `terraform.tfvars.example` to `terraform.tfvars` and modify as needed:

```bash
cp terraform.tfvars.example terraform.tfvars
```

## Security Features

### Security Group Rules
- **SSH (22)**: Access from your current public IP only
- **HTTP (5001)**: Access from your current public IP only
- **Outbound**: All traffic allowed for updates and downloads

### SSH Key Management
- RSA 4096-bit key pair generated automatically
- Private key saved locally with proper permissions (0600)
- Public key deployed to EC2 instance

## Outputs

After successful deployment, you'll get:

- **EC2 Public IP**: For direct access
- **SSH Connection Command**: Ready-to-use SSH command
- **Security Group ID**: For reference
- **SSH Key Path**: Location of private key file

## Docker Installation

The instance comes with:
- **Docker**: Latest version from AWS repositories
- **Docker Compose**: Latest version as standalone binary
- **Docker Compose Plugin**: For `docker compose` command syntax

### Verification Commands

Once connected via SSH, verify the installation:

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version
docker compose version

# Test Docker (run without sudo)
docker run hello-world

# Check Docker service status
sudo systemctl status docker
```

## Manual Installation Alternative

If you prefer manual installation, SSH into the instance and run:

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and back in for group changes to take effect
```

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **SSH Connection Refused**:
   - Wait 2-3 minutes for instance to fully boot
   - Verify your current IP matches the security group

2. **Docker Permission Denied**:
   - Log out and back in after first connection
   - Or run: `newgrp docker`

3. **Terraform Apply Fails**:
   - Check AWS credentials: `aws sts get-caller-identity`
   - Verify region and VPC ID

### Getting Help

Check the logs:
```bash
# On EC2 instance
sudo cat /var/log/user-data.log
sudo cat /var/log/cloud-init-output.log
```

## Cost Considerations

- **t3.medium**: ~$0.0416/hour (~$30/month if running 24/7)
- **EBS Storage**: 20GB gp3 ~$1.60/month
- **Data Transfer**: Minimal for development use

Remember to destroy resources when not in use to avoid unnecessary charges.
