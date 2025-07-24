#!/bin/bash

# Kubernetes Deployment Script for Flask AWS Monitor
# Usage: ./deploy.sh [apply|delete|status|logs]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="default"
APP_NAME="flask-aws-monitor"
MANIFESTS_DIR="../manifests"

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Kubernetes Deployment - Final Project JB${NC}"
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

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if kubectl is installed and configured
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check if we can connect to the cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

deploy_application() {
    print_header
    print_info "Deploying Flask AWS Monitor to Kubernetes..."
    
    # Apply manifests in order
    print_info "Applying ConfigMap and Secret..."
    kubectl apply -f ${MANIFESTS_DIR}/configmap.yaml
    
    print_info "Applying Deployment..."
    kubectl apply -f ${MANIFESTS_DIR}/deployment.yaml
    
    print_info "Applying Services..."
    kubectl apply -f ${MANIFESTS_DIR}/service.yaml
    
    print_info "Applying Network Policy..."
    kubectl apply -f ${MANIFESTS_DIR}/network-policy.yaml
    
    print_info "Applying HPA..."
    kubectl apply -f ${MANIFESTS_DIR}/hpa.yaml
    
    print_info "Applying Ingress (optional)..."
    kubectl apply -f ${MANIFESTS_DIR}/ingress.yaml || print_warning "Ingress not applied (may not have ingress controller)"
    
    print_success "All manifests applied successfully!"
    
    # Wait for deployment to be ready
    print_info "Waiting for deployment to be ready..."
    kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=300s
    
    print_success "Deployment is ready!"
    
    # Show deployment status
    show_status
}

delete_application() {
    print_header
    print_warning "Deleting Flask AWS Monitor from Kubernetes..."
    
    echo "Are you sure you want to delete the application? (yes/no): "
    read -r response
    
    if [[ $response == "yes" ]]; then
        print_info "Deleting all resources..."
        
        kubectl delete -f ${MANIFESTS_DIR}/ingress.yaml || print_warning "Ingress not found"
        kubectl delete -f ${MANIFESTS_DIR}/hpa.yaml || print_warning "HPA not found"
        kubectl delete -f ${MANIFESTS_DIR}/network-policy.yaml || print_warning "NetworkPolicy not found"
        kubectl delete -f ${MANIFESTS_DIR}/service.yaml || print_warning "Services not found"
        kubectl delete -f ${MANIFESTS_DIR}/deployment.yaml || print_warning "Deployment not found"
        kubectl delete -f ${MANIFESTS_DIR}/configmap.yaml || print_warning "ConfigMap/Secret not found"
        
        print_success "Application deleted successfully!"
    else
        print_info "Deletion cancelled"
    fi
}

show_status() {
    print_header
    print_info "Current deployment status:"
    
    echo ""
    print_info "Deployments:"
    kubectl get deployments -l app=${APP_NAME} -n ${NAMESPACE}
    
    echo ""
    print_info "Pods:"
    kubectl get pods -l app=${APP_NAME} -n ${NAMESPACE}
    
    echo ""
    print_info "Services:"
    kubectl get services -l app=${APP_NAME} -n ${NAMESPACE}
    
    echo ""
    print_info "HPA:"
    kubectl get hpa -l app=${APP_NAME} -n ${NAMESPACE}
    
    echo ""
    print_info "Ingress:"
    kubectl get ingress -l app=${APP_NAME} -n ${NAMESPACE}
    
    # Get external access information
    echo ""
    print_info "Access Information:"
    
    # LoadBalancer Service
    LB_IP=$(kubectl get service ${APP_NAME}-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    LB_HOSTNAME=$(kubectl get service ${APP_NAME}-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    
    if [[ -n "$LB_IP" ]]; then
        print_success "LoadBalancer IP: http://$LB_IP"
        print_success "Direct access: http://$LB_IP:5001"
    elif [[ -n "$LB_HOSTNAME" ]]; then
        print_success "LoadBalancer Hostname: http://$LB_HOSTNAME"
        print_success "Direct access: http://$LB_HOSTNAME:5001"
    else
        print_warning "LoadBalancer not ready yet, checking NodePort..."
    fi
    
    # NodePort Service
    NODE_PORT=$(kubectl get service ${APP_NAME}-nodeport -n ${NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "")
    if [[ -n "$NODE_PORT" ]]; then
        NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}' 2>/dev/null || echo "")
        if [[ -n "$NODE_IP" ]]; then
            print_success "NodePort access: http://$NODE_IP:$NODE_PORT"
        else
            print_info "NodePort: $NODE_PORT (use any node IP)"
        fi
    fi
}

show_logs() {
    print_header
    print_info "Showing application logs..."
    
    # Get the first pod
    POD_NAME=$(kubectl get pods -l app=${APP_NAME} -n ${NAMESPACE} -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    
    if [[ -n "$POD_NAME" ]]; then
        print_info "Logs from pod: $POD_NAME"
        kubectl logs -f $POD_NAME -n ${NAMESPACE}
    else
        print_error "No pods found for app: $APP_NAME"
    fi
}

update_secrets() {
    print_header
    print_info "Updating AWS credentials..."
    
    echo -n "Enter AWS Access Key ID: "
    read -r AWS_ACCESS_KEY_ID
    
    echo -n "Enter AWS Secret Access Key: "
    read -s AWS_SECRET_ACCESS_KEY
    echo ""
    
    # Create secret
    kubectl create secret generic aws-credentials \
        --from-literal=aws-access-key-id="$AWS_ACCESS_KEY_ID" \
        --from-literal=aws-secret-access-key="$AWS_SECRET_ACCESS_KEY" \
        --dry-run=client -o yaml | kubectl apply -f -
    
    print_success "AWS credentials updated!"
    print_info "Restarting deployment to pick up new credentials..."
    kubectl rollout restart deployment/${APP_NAME} -n ${NAMESPACE}
}

show_help() {
    print_header
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  apply     - Deploy the application to Kubernetes"
    echo "  delete    - Remove the application from Kubernetes"
    echo "  status    - Show current deployment status"
    echo "  logs      - Show application logs"
    echo "  secrets   - Update AWS credentials"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 apply    # Deploy the application"
    echo "  $0 status   # Check deployment status"
    echo "  $0 logs     # View application logs"
    echo "  $0 delete   # Remove the application"
}

# Main script logic
case "${1:-help}" in
    apply|deploy)
        check_prerequisites
        deploy_application
        ;;
    delete|remove)
        delete_application
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    secrets)
        update_secrets
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
