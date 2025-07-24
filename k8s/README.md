# 🚀 Kubernetes Deployment - Final Project JB

## Overview

This directory contains comprehensive Kubernetes manifests to deploy the Flask AWS Monitor application to a Kubernetes cluster with production-ready configurations.

## 📁 Directory Structure

```
k8s/
├── manifests/
│   ├── deployment.yaml       # Main application deployment
│   ├── service.yaml          # Services (LoadBalancer, NodePort, ClusterIP)
│   ├── configmap.yaml        # Configuration and secrets
│   ├── ingress.yaml          # Ingress controller configuration
│   ├── hpa.yaml              # Horizontal Pod Autoscaler
│   └── network-policy.yaml   # Network security policy
├── scripts/
│   ├── deploy.sh             # Comprehensive deployment script
│   └── quick-deploy.sh       # One-command deployment
└── README.md                 # This documentation
```

## 🎯 Assignment Requirements - Complete Implementation

### ✅ 1. Kubernetes Manifests Created:
- **Deployment YAML** using your pushed Docker image ✅
- **Service YAML** to expose the application ✅
- **Additional production manifests** for complete setup ✅

### ✅ 2. Ready for Remote K8s Cluster Deployment:
- All manifests configured for external deployment ✅
- Multiple service types for different access methods ✅
- Production-ready security and scaling configurations ✅

### ✅ 3. Browser Access Validation:
- LoadBalancer service for external access ✅
- NodePort service as backup access method ✅
- Ingress configuration for domain-based access ✅

## 🛠️ Deployment Options

### Option 1: Quick Deployment (Recommended)

```bash
# Navigate to k8s scripts directory
cd k8s/scripts

# Deploy with your Docker Hub username
./quick-deploy.sh your-dockerhub-username

# Check status
kubectl get all -l app=flask-aws-monitor
```

### Option 2: Comprehensive Deployment

```bash
# Navigate to k8s scripts directory
cd k8s/scripts

# Full deployment with monitoring
./deploy.sh apply

# Check deployment status
./deploy.sh status

# View logs
./deploy.sh logs
```

### Option 3: Manual Deployment

```bash
# Update image name in deployment.yaml first
# Change: your-dockerhub-username/flask-aws-monitor:latest
# To: your-actual-username/flask-aws-monitor:latest

# Apply manifests
kubectl apply -f k8s/manifests/

# Check deployment
kubectl get all -l app=flask-aws-monitor
```

## 🔧 Pre-Deployment Setup

### 1. Update Docker Image Name

**In `k8s/manifests/deployment.yaml`, line 29:**
```yaml
# Change this line:
image: your-dockerhub-username/flask-aws-monitor:latest
# To:
image: your-actual-dockerhub-username/flask-aws-monitor:latest
```

### 2. Update AWS Credentials (Optional)

**Method A: Use the deployment script**
```bash
cd k8s/scripts
./deploy.sh secrets
```

**Method B: Manual secret creation**
```bash
kubectl create secret generic aws-credentials \
  --from-literal=aws-access-key-id="YOUR_ACCESS_KEY" \
  --from-literal=aws-secret-access-key="YOUR_SECRET_KEY"
```

**Method C: Edit the base64 values in configmap.yaml**
```bash
# Encode your credentials
echo -n "your-access-key" | base64
echo -n "your-secret-key" | base64

# Update the values in k8s/manifests/configmap.yaml
```

## 🌐 Accessing Your Application

After deployment, you can access your application through multiple methods:

### Method 1: LoadBalancer (Recommended)
```bash
# Get LoadBalancer IP/Hostname
kubectl get service flask-aws-monitor-service

# Access via browser
http://<EXTERNAL-IP>         # Port 80
http://<EXTERNAL-IP>:5001    # Direct port
```

### Method 2: NodePort
```bash
# Get NodePort
kubectl get service flask-aws-monitor-nodeport

# Access via browser (use any node IP)
http://<NODE-IP>:30001
```

### Method 3: Port Forward (Development)
```bash
# Forward local port to pod
kubectl port-forward service/flask-aws-monitor-clusterip 8080:5001

# Access via browser
http://localhost:8080
```

### Method 4: Ingress (if ingress controller installed)
```bash
# Add to /etc/hosts
echo "<INGRESS-IP> flask-aws-monitor.local" | sudo tee -a /etc/hosts

# Access via browser
http://flask-aws-monitor.local
```

## 📊 Monitoring and Management

### Check Deployment Status
```bash
# All resources
kubectl get all -l app=flask-aws-monitor

# Detailed pod information
kubectl describe pods -l app=flask-aws-monitor

# Real-time pod monitoring
kubectl get pods -l app=flask-aws-monitor -w
```

### View Application Logs
```bash
# All pods logs
kubectl logs -l app=flask-aws-monitor

# Specific pod logs
kubectl logs <pod-name> -f

# Previous container logs
kubectl logs <pod-name> --previous
```

### Scaling the Application
```bash
# Manual scaling
kubectl scale deployment flask-aws-monitor --replicas=5

# Check HPA status
kubectl get hpa flask-aws-monitor-hpa

# HPA events
kubectl describe hpa flask-aws-monitor-hpa
```

## 🔒 Security Features

### Network Policy
- Restricts pod-to-pod communication
- Allows necessary ingress on port 5001
- Permits all egress for AWS API calls

### Pod Security
- Runs as non-root user (UID 1001)
- Drops all capabilities
- Read-only root filesystem where possible
- Security context with fsGroup

### Secrets Management
- AWS credentials stored in Kubernetes secrets
- Environment variables populated from secrets
- Base64 encoded sensitive data

## 🚀 Production Features

### High Availability
- **3 replicas** by default for redundancy
- **Pod anti-affinity** to spread across nodes
- **Rolling update strategy** for zero-downtime deployments

### Health Checks
- **Liveness probe** on `/health` endpoint
- **Readiness probe** for traffic routing
- **Proper timeouts and thresholds**

### Auto-scaling
- **Horizontal Pod Autoscaler** (2-10 replicas)
- **CPU and memory-based scaling**
- **Smart scaling policies** to prevent flapping

### Resource Management
- **Resource requests** for scheduling
- **Resource limits** to prevent overuse
- **Quality of Service** guarantees

## 🧪 Validation Steps

### 1. Verify Deployment
```bash
# Check all pods are running
kubectl get pods -l app=flask-aws-monitor

# Expected output: 3 pods in Running state
NAME                                READY   STATUS    RESTARTS   AGE
flask-aws-monitor-xxx-yyy          1/1     Running   0          2m
flask-aws-monitor-xxx-zzz          1/1     Running   0          2m
flask-aws-monitor-xxx-aaa          1/1     Running   0          2m
```

### 2. Test Health Endpoint
```bash
# Port forward for testing
kubectl port-forward service/flask-aws-monitor-clusterip 8080:5001 &

# Test health endpoint
curl http://localhost:8080/health

# Expected output:
{
  "status": "healthy",
  "service": "aws-resources-dashboard",
  "version": "1.0.0",
  "aws_connection": "error"  # Expected without real AWS credentials
}
```

### 3. Validate Browser Access
1. **Get external access URL** from LoadBalancer or NodePort
2. **Open browser** and navigate to the URL
3. **Verify application loads** with the Flask AWS Monitor interface
4. **Check AWS error message** is displayed (expected behavior)

### 4. Test Scaling
```bash
# Trigger scaling by generating load
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

# Inside the container:
while true; do wget -q -O- http://flask-aws-monitor-clusterip:5001; done

# In another terminal, watch HPA:
kubectl get hpa flask-aws-monitor-hpa -w
```

## 🛠️ Troubleshooting

### Common Issues

**1. Image Pull Errors**
```bash
# Check if image exists and is accessible
docker pull your-username/flask-aws-monitor:latest

# Verify image name in deployment.yaml matches your Docker Hub
kubectl describe pod <pod-name>
```

**2. Pod CrashLoopBackOff**
```bash
# Check pod logs
kubectl logs <pod-name>

# Check previous container logs
kubectl logs <pod-name> --previous

# Describe pod for events
kubectl describe pod <pod-name>
```

**3. Service Not Accessible**
```bash
# Check service endpoints
kubectl get endpoints flask-aws-monitor-service

# Verify service selector matches pod labels
kubectl get pods --show-labels -l app=flask-aws-monitor
```

**4. LoadBalancer Pending**
```bash
# Check if cluster supports LoadBalancer
kubectl get nodes -o wide

# Use NodePort as alternative
kubectl get service flask-aws-monitor-nodeport
```

**5. Health Check Failures**
```bash
# Test health endpoint directly
kubectl exec -it <pod-name> -- curl localhost:5001/health

# Check probe configuration
kubectl describe pod <pod-name>
```

## 🗑️ Cleanup

### Remove Application
```bash
# Using deployment script
cd k8s/scripts
./deploy.sh delete

# Manual cleanup
kubectl delete -f k8s/manifests/

# Verify cleanup
kubectl get all -l app=flask-aws-monitor
```

## 🎯 Success Criteria

### ✅ Deployment Success:
- [ ] All pods are in Running state
- [ ] Services have external endpoints
- [ ] Health checks are passing
- [ ] HPA is active and monitoring

### ✅ Browser Access:
- [ ] Application loads in browser
- [ ] AWS error message is displayed (expected)
- [ ] Health endpoint returns JSON response
- [ ] UI is responsive and functional

### ✅ Production Ready:
- [ ] Multiple replicas running
- [ ] Auto-scaling configured
- [ ] Security policies applied
- [ ] Monitoring and logging working

## 🎉 Assignment Complete!

Your Flask AWS Monitor application is now:
- ✅ **Deployed to Kubernetes** with production manifests
- ✅ **Accessible via browser** through LoadBalancer/NodePort
- ✅ **Highly available** with multiple replicas
- ✅ **Auto-scaling** based on resource usage
- ✅ **Secure** with network policies and pod security
- ✅ **Monitored** with health checks and logging

**Next Steps**: Access your application, take screenshots for validation, and enjoy your fully deployed Kubernetes application! 🚀

## 📚 Additional Resources

- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **kubectl Cheat Sheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- **Health Check Best Practices**: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
- **HPA Documentation**: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
