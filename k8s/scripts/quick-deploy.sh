#!/bin/bash

# Quick Kubernetes Deployment Script - One Command Deploy
# Usage: ./quick-deploy.sh your-dockerhub-username

set -e

USERNAME=${1:-your-dockerhub-username}
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}🚀 Quick Deploy - Final Project JB${NC}"
echo -e "${BLUE}====================================${NC}"

# Update image name in deployment
echo -e "${BLUE}📝 Updating Docker image name...${NC}"
sed -i "s/your-dockerhub-username/$USERNAME/g" ../manifests/deployment.yaml

# Deploy everything
echo -e "${BLUE}🚀 Deploying to Kubernetes...${NC}"
kubectl apply -f ../manifests/

# Wait for deployment
echo -e "${BLUE}⏳ Waiting for deployment...${NC}"
kubectl rollout status deployment/flask-aws-monitor --timeout=300s

# Show status
echo -e "${GREEN}✅ Deployment complete!${NC}"
kubectl get all -l app=flask-aws-monitor

echo ""
echo -e "${GREEN}🌐 Access your application:${NC}"

# Get LoadBalancer info
LB_IP=$(kubectl get service flask-aws-monitor-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
LB_HOSTNAME=$(kubectl get service flask-aws-monitor-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [[ -n "$LB_IP" ]]; then
    echo -e "${GREEN}LoadBalancer: http://$LB_IP${NC}"
elif [[ -n "$LB_HOSTNAME" ]]; then
    echo -e "${GREEN}LoadBalancer: http://$LB_HOSTNAME${NC}"
fi

# Get NodePort info
NODE_PORT=$(kubectl get service flask-aws-monitor-nodeport -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30001")
echo -e "${GREEN}NodePort: <NODE_IP>:$NODE_PORT${NC}"

echo ""
echo -e "${BLUE}📊 Monitor with: kubectl get pods -l app=flask-aws-monitor -w${NC}"
