# Install Terraform on Ubuntu

## Method 1: Official HashiCorp Repository (Recommended)

```bash
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update
sudo apt install terraform
```

## Method 2: Direct Download

```bash
# Download latest Terraform
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip

# Install unzip if needed
sudo apt install unzip

# Extract and install
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform --version
```

## Method 3: Snap (Simplest)

```bash
sudo snap install terraform
```

## Verify Installation

```bash
terraform --version
which terraform
```

You should see output like:
```
Terraform v1.7.0
on linux_amd64
```

## Next Steps

After installing Terraform:

```bash
# Navigate to terraform directory
cd terraform/ec2-docker

# Initialize Terraform
terraform init

# Check if AWS CLI is configured
aws sts get-caller-identity

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```
