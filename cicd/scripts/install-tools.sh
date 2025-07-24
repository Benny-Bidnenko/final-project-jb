#!/bin/bash

# Install Linting and Security Tools Script
# This script installs real tools for linting and security scanning

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_info "Installing linting and security tools..."

# Install Python tools
print_info "Installing Python linting and security tools..."
pip3 install --user flake8 bandit

# Install ShellCheck
print_info "Installing ShellCheck..."
sudo yum install -y ShellCheck || sudo apt-get install -y shellcheck

# Install Hadolint
print_info "Installing Hadolint..."
wget -O /tmp/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
chmod +x /tmp/hadolint
sudo mv /tmp/hadolint /usr/local/bin/hadolint

# Install Trivy
print_info "Installing Trivy..."
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin

print_success "All tools installed successfully!"
print_info "Installed tools:"
echo "• flake8 --version: $(flake8 --version)"
echo "• bandit --version: $(bandit --version)"
echo "• shellcheck --version: $(shellcheck --version)"
echo "• hadolint --version: $(hadolint --version)"
echo "• trivy --version: $(trivy --version)"
