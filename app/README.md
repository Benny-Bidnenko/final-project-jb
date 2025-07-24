# 🚀 AWS Resources Dashboard - Docker Application

## Overview
Multi-stage Docker containerized Python Flask application that displays AWS resources including EC2 instances, VPCs, Load Balancers, and AMIs.

## ✨ Features

### 🔧 **Fixed Application**
- **Complete AWS Resources Dashboard** - Displays EC2, VPCs, ELBs, and AMIs
- **Comprehensive Error Handling** - Graceful handling of missing credentials
- **Beautiful UI** - Styled responsive web interface
- **Production Ready** - Proper logging, health checks, and monitoring

### 🐳 **Docker Features**
- **Multi-stage Dockerfile** with optimized build and runtime stages
- **Security focused** - Non-root user, minimal attack surface
- **Health checks** and monitoring endpoints
- **Environment variable** configuration

## 🎯 Expected Behavior

### Without AWS Credentials (Expected for Assignment):
```
❌ AWS Connection Error: AWS credentials not found. 
Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables.
```
- Shows clear error message with styling
- Displays configuration status
- Explains how to resolve the issue
- Application doesn't crash

### With Valid AWS Credentials:
- ✅ **AWS Connection: Success**
- Displays all EC2 instances in your account
- Shows VPCs with CIDR blocks  
- Lists load balancers (ALB/CLB)
- Shows AMIs owned by the account
- Beautiful responsive dashboard

## 🚀 Quick Start

### Build and Run (Without Credentials)
```bash
./build.sh
./run.sh --detach

# Access the application
curl http://localhost:5001
# Shows expected AWS error message
```

### Run with AWS Credentials
```bash
# Setup credentials interactively
./setup-credentials.sh

# Run with credentials
./run.sh --env-file .env --detach

# Access the application
curl http://localhost:5001
# Shows AWS resources dashboard
```

## 📋 Application Endpoints

- **`/`** - Main AWS resources dashboard
- **`/health`** - Health check endpoint (JSON)

## 🔧 Docker Commands

### Build Image
```bash
# Using script
./build.sh

# Manual
docker build -t final-project-jb:latest .
```

### Run Container
```bash
# Using script (recommended)
./run.sh --detach

# With credentials
./run.sh --env-file .env --detach

# Manual run
docker run -d -p 5001:5001 --name final-project-app final-project-jb:latest
```

### With AWS Credentials
```bash
docker run -d -p 5001:5001 \
  -e AWS_ACCESS_KEY_ID="your-key" \
  -e AWS_SECRET_ACCESS_KEY="your-secret" \
  --name final-project-app \
  final-project-jb:latest
```

## 🧪 Testing

### Health Check
```bash
curl http://localhost:5001/health
```

### Load Testing
```bash
# Test without credentials (should show error)
curl http://localhost:5001/

# Test with credentials (should show resources)
curl -H "Accept: text/html" http://localhost:5001/
```

### Unit Tests
```bash
python3 test-app.py
```

## 📁 File Structure
```
app/
├── Dockerfile              # Multi-stage Docker build
├── app.py                  # Fixed Flask application  
├── requirements.txt        # Python dependencies
├── build.sh               # Build automation
├── run.sh                 # Run automation  
├── setup-credentials.sh    # AWS credentials setup
├── test-app.py            # Unit tests
├── .env.template          # Credential template
├── FIXES_APPLIED.md       # Documentation of fixes
└── README.md              # This file
```

## 🔐 Environment Variables

- **`AWS_ACCESS_KEY_ID`** - AWS access key (required for full functionality)
- **`AWS_SECRET_ACCESS_KEY`** - AWS secret key (required for full functionality)  
- **`ENVIRONMENT`** - Application environment (default: production)

## 🐞 Issues Fixed

The original provided code had several issues:

1. ❌ **Missing API calls** - `vpcs`, `lbs`, `amis` variables were undefined
2. ❌ **No error handling** - Would crash without credentials
3. ❌ **Load balancer compatibility** - Didn't handle ALB vs CLB differences
4. ❌ **Poor user experience** - No styling or helpful error messages

### ✅ All Issues Resolved:
- Complete error handling and graceful degradation
- Proper AWS API calls with all required variables
- Beautiful styled interface for both error and success states
- Production-ready logging and monitoring
- Backward compatibility for different AWS service types

## 🎓 Assignment Compliance

This application meets all assignment requirements:

- ✅ **Multi-stage Dockerfile** - Optimized build process
- ✅ **Requirements.txt** - All Python dependencies listed
- ✅ **AWS environment variables** - Proper credential handling
- ✅ **Port 5001** - Application exposed on correct port
- ✅ **Error display** - Shows expected AWS error when credentials missing
- ✅ **GitHub integration** - Code committed and pushed

## 🚀 Deployment Ready

The application is ready for:
- ✅ **Local development** with Docker
- ✅ **EC2 deployment** via Terraform
- ✅ **Production use** with proper credentials
- ✅ **Monitoring** with health checks
- ✅ **Scaling** with container orchestration

Perfect for demonstrating AWS integration in a containerized environment! 🎉
