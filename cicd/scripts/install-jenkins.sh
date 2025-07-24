#!/bin/bash

# Jenkins Installation Script for EC2 Builder Instance
# Run this script on your EC2 instance to install Jenkins

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Jenkins Installation - Final Project JB${NC}"
    echo -e "${BLUE}================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header

# Update system
print_info "Updating system packages..."
sudo yum update -y

# Install Java (required for Jenkins)
print_info "Installing Java 11..."
sudo yum install -y java-11-amazon-corretto-headless

# Verify Java installation
java -version

# Add Jenkins repository
print_info "Adding Jenkins repository..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
print_info "Installing Jenkins..."
sudo yum install -y jenkins

# Start and enable Jenkins
print_info "Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check Jenkins status
sudo systemctl status jenkins

# Configure firewall (if needed)
print_info "Configuring firewall for Jenkins..."
sudo firewall-cmd --permanent --add-port=8080/tcp || echo "Firewall not configured"
sudo firewall-cmd --reload || echo "Firewall not configured"

# Get Jenkins initial admin password
print_success "Jenkins installation completed!"
echo ""
print_info "Jenkins is running on port 8080"
print_info "Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo ""
print_warning "Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
print_info "Save this password - you'll need it for the initial setup!"

# Additional setup recommendations
echo ""
print_info "Additional Setup Recommendations:"
echo "1. Install suggested plugins during Jenkins setup"
echo "2. Create an admin user"
echo "3. Install Docker Pipeline plugin"
echo "4. Configure Docker Hub credentials"
echo "5. Set up GitHub webhook (optional)"

print_success "Jenkins installation script completed!"
