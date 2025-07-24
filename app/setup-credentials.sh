#!/bin/bash

# AWS Credentials Setup Script
# This script helps you securely set up AWS credentials for the Docker application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  AWS Credentials Setup${NC}"
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

echo "This script will help you set up AWS credentials securely."
echo ""

# Check if .env already exists
if [ -f ".env" ]; then
    print_warning ".env file already exists"
    echo "Do you want to overwrite it? (y/N): "
    read -r response
    if [[ ! $response =~ ^[Yy]$ ]]; then
        print_info "Keeping existing .env file"
        exit 0
    fi
fi

# Prompt for credentials
print_info "Please enter your AWS credentials:"
echo ""

echo -n "AWS Access Key ID: "
read -r AWS_ACCESS_KEY_ID

echo -n "AWS Secret Access Key: "
read -s AWS_SECRET_KEY
echo ""

echo -n "AWS Default Region [us-east-1]: "
read -r AWS_DEFAULT_REGION
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}

echo -n "Environment [production]: "
read -r ENVIRONMENT
ENVIRONMENT=${ENVIRONMENT:-production}

# Create .env file
cat > .env << ENV_EOF
# AWS Credentials - NEVER commit this file to version control!
ENVIRONMENT=$ENVIRONMENT
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_KEY=$AWS_SECRET_KEY
AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
ENV_EOF

# Set secure permissions
chmod 600 .env

print_success "AWS credentials configured successfully!"
print_info "Environment file created: .env"
print_warning "Remember: NEVER commit the .env file to version control!"

echo ""
print_info "You can now run the application with:"
echo -e "${YELLOW}  ./run.sh --env-file .env --detach${NC}"
echo ""
print_info "Or test the credentials with:"
echo -e "${YELLOW}  docker run --env-file .env -p 5001:5001 final-project-jb:latest${NC}"
