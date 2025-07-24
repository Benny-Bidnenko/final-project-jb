# Final Project Structure

This project follows Git Flow branching model:

## Branches
- **main**: Production-ready code
- **dev**: Integration branch for features
- **feature/***: Feature development branches

## Project Sections
Each section will be developed in its own feature branch:

1. Section 1: Project Setup and Configuration
2. Section 2: Core Functionality
3. Section 3: User Interface
4. Section 4: Testing and Documentation
5. Section 5: Deployment and CI/CD

## Git Flow Process
1. All features branch from `dev`
2. Features are merged back to `dev`
3. When ready for release, `dev` is merged to `main` via PR

## Terraform Infrastructure

### EC2 Docker Setup
- **Location**: `terraform/ec2-docker/`
- **Purpose**: Provision AWS EC2 instance with Docker pre-installed
- **Instance**: Named "builder" using specified VPC `vpc-044604d0bfb707142`

### Features
- ✅ Automated SSH key generation and management
- ✅ Security group with restricted access (SSH + HTTP 5001)
- ✅ Docker and Docker Compose auto-installation
- ✅ Comprehensive documentation and validation scripts
- ✅ Easy deployment with helper scripts

### Quick Commands
```bash
# Deploy infrastructure
cd terraform/ec2-docker
./deploy.sh init && ./deploy.sh plan && ./deploy.sh apply

# Connect to instance
terraform output -raw ssh_connection_command | bash

# Validate Docker installation (on EC2)
./validate_docker.sh

# Cleanup
./deploy.sh destroy
```
