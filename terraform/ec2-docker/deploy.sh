#!/bin/bash

# Terraform EC2 Docker Deployment Script
# Usage: ./deploy.sh [init|plan|apply|destroy|output]

set -e

TERRAFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$TERRAFORM_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Terraform EC2 Docker Infrastructure${NC}"
    echo -e "${BLUE}================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if AWS CLI is configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured or credentials are invalid."
        echo "Please run: aws configure"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

terraform_init() {
    print_header
    echo "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized successfully"
}

terraform_plan() {
    print_header
    echo "Creating Terraform plan..."
    terraform plan -out=tfplan
    print_success "Terraform plan created successfully"
    echo ""
    print_warning "Review the plan above before applying!"
}

terraform_apply() {
    print_header
    echo "Applying Terraform configuration..."
    
    if [ -f "tfplan" ]; then
        terraform apply tfplan
        rm -f tfplan
    else
        terraform apply
    fi
    
    print_success "Infrastructure deployed successfully!"
    echo ""
    echo "Getting connection information..."
    terraform output ssh_connection_command
}

terraform_destroy() {
    print_header
    print_warning "This will destroy all infrastructure!"
    echo "Are you sure you want to continue? (yes/no)"
    read -r response
    
    if [ "$response" = "yes" ]; then
        terraform destroy
        print_success "Infrastructure destroyed successfully"
    else
        echo "Destroy cancelled"
    fi
}

show_outputs() {
    print_header
    echo "Current infrastructure outputs:"
    terraform output
}

show_help() {
    print_header
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  init     - Initialize Terraform"
    echo "  plan     - Create and show Terraform plan"
    echo "  apply    - Apply Terraform configuration"
    echo "  destroy  - Destroy infrastructure"
    echo "  output   - Show Terraform outputs"
    echo "  help     - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 init && $0 plan && $0 apply"
    echo "  $0 output"
    echo "  $0 destroy"
}

# Main script logic
case "${1:-help}" in
    init)
        check_prerequisites
        terraform_init
        ;;
    plan)
        check_prerequisites
        terraform_plan
        ;;
    apply)
        check_prerequisites
        terraform_apply
        ;;
    destroy)
        terraform_destroy
        ;;
    output)
        show_outputs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
