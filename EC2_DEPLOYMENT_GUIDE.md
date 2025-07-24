# 🚀 EC2 Docker Deployment Guide - Final Project JB

## Overview
This guide walks you through deploying the Docker containerized Python Flask application on your EC2 "builder" instance.

## Prerequisites
- ✅ Terraform infrastructure deployed (EC2 instance running)
- ✅ SSH access to EC2 instance
- ✅ Docker installed on EC2 (automated via Terraform)
- ✅ GitHub repository with Docker application

## Step-by-Step Deployment

### 1. SSH into the Builder EC2 Instance

```bash
# From your local machine in terraform/ec2-docker directory
terraform output ssh_connection_command

# Example output:
ssh -i builder_key.pem ec2-user@<EC2_PUBLIC_IP>

# Or directly:
ssh -i terraform/ec2-docker/builder_key.pem ec2-user@<EC2_PUBLIC_IP>
```

### 2. Verify Docker Installation on EC2

```bash
# Once connected to EC2 instance
docker --version
docker-compose --version

# Test Docker without sudo (should work)
docker run hello-world

# If permission denied, run:
newgrp docker
# Then try again
```

### 3. Clone the Repository on EC2

```bash
# On EC2 instance
git clone https://github.com/Benny-Bidnenko/final-project-jb.git
cd final-project-jb
```

### 4. Navigate to App Directory and Build Docker Image

```bash
# On EC2 instance
cd app

# Build the Docker image
./build.sh

# Alternative manual build:
docker build -t final-project-jb:latest .
```

### 5. Set Environment Variables (Optional)

```bash
# Create environment file (optional - app handles missing credentials gracefully)
cat > .env << 'ENV_EOF'
ENVIRONMENT=production
AWS_ACCESS_KEY_ID=your-aws-access-key-here
AWS_SECRET_KEY=your-aws-secret-key-here
AWS_DEFAULT_REGION=us-east-1
ENV_EOF

# Make sure to replace with actual values if you have them
```

### 6. Run the Container

```bash
# Option 1: Using the run script (recommended)
./run.sh --detach

# Option 2: Using the run script with environment file
./run.sh --env-file .env --detach

# Option 3: Manual Docker run
docker run -d \
  --name final-project-app \
  -p 5001:5001 \
  -e ENVIRONMENT=production \
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-not-provided} \
  -e AWS_SECRET_KEY=${AWS_SECRET_KEY:-not-provided} \
  -e AWS_DEFAULT_REGION=us-east-1 \
  --restart unless-stopped \
  final-project-jb:latest
```

### 7. Verify Container is Running

```bash
# Check container status
docker ps

# Check application logs
docker logs final-project-app

# Test health endpoint
curl http://localhost:5001/health
```

### 8. Test from Your Local Machine

```bash
# From your local machine (replace with actual EC2 public IP)
curl http://<EC2_PUBLIC_IP>:5001/health

# Or open in browser:
# http://<EC2_PUBLIC_IP>:5001
```

## Expected Application Behavior

### ✅ Successful Deployment
- Application starts and listens on port 5001
- Web interface loads with colorful dashboard
- Health check endpoint returns JSON response
- Container shows as "healthy" in docker ps

### ⚠️ Expected AWS Error (Normal)
The application will show an AWS connection error like:
```
AWS Connection Error: No AWS credentials found. Please set AWS_ACCESS_KEY_ID and AWS_SECRET_KEY environment variables.
```

**This is expected behavior** when AWS credentials are not provided!

## Application Endpoints

- **Main Dashboard**: `http://<EC2_IP>:5001/`
- **Health Check**: `http://<EC2_IP>:5001/health`
- **AWS Test**: `http://<EC2_IP>:5001/aws-test`
- **Environment Info**: `http://<EC2_IP>:5001/environment`
- **API Status**: `http://<EC2_IP>:5001/api/status`

## Troubleshooting

### Container Won't Start
```bash
# Check Docker daemon
sudo systemctl status docker

# Check container logs
docker logs final-project-app

# Rebuild image
docker build --no-cache -t final-project-jb:latest .
```

### Port Access Issues
```bash
# Check if container is listening
docker exec final-project-app netstat -tlnp

# Check security group (from local machine)
# Ensure port 5001 is open for your IP in AWS console
```

### Permission Issues
```bash
# Add user to docker group
sudo usermod -a -G docker ec2-user
newgrp docker

# Or restart SSH session
exit
# SSH back in
```

### View Application Logs
```bash
# Real-time logs
docker logs -f final-project-app

# Last 100 lines
docker logs --tail 100 final-project-app
```

## Container Management

### Stop Container
```bash
docker stop final-project-app
```

### Start Container
```bash
docker start final-project-app
```

### Remove Container
```bash
docker rm -f final-project-app
```

### Update Application
```bash
# Pull latest code
git pull origin dev

# Rebuild and restart
docker stop final-project-app
docker rm final-project-app
./build.sh
./run.sh --detach
```

## Clean Up

### Remove Container and Image
```bash
# Stop and remove container
docker stop final-project-app
docker rm final-project-app

# Remove image
docker rmi final-project-jb:latest

# Clean up unused images
docker system prune -f
```

### Destroy Infrastructure
```bash
# From local machine
cd terraform/ec2-docker
./deploy.sh destroy
```

## Success Criteria ✅

1. **Docker Image Built**: Successfully builds multi-stage image
2. **Container Running**: Shows as "Up" and "healthy" in `docker ps`
3. **Port Accessible**: Application responds on port 5001
4. **Web Interface**: Colorful dashboard loads with system information
5. **AWS Error Displayed**: Shows expected AWS credentials error
6. **Health Check**: `/health` endpoint returns JSON status

## Next Steps

After successful deployment:
- ✅ Code is pushed to GitHub
- ✅ Docker image is built on EC2
- ✅ Container is running on EC2
- ✅ Application is accessible via HTTP on port 5001
- ✅ Expected AWS error is displayed (no fix needed at this stage)

Your Docker deployment is complete! 🎉

## 🔐 AWS Credentials Setup (Updated)

### Method 1: Using the Setup Script (Recommended)

```bash
# On EC2 instance, in the app directory
cd app
./setup-credentials.sh

# Follow the prompts to enter your credentials securely
```

### Method 2: Manual Environment File Creation

```bash
# On EC2 instance
cd app
cp .env.template .env

# Edit the .env file with your actual credentials
nano .env
# or
vi .env

# Replace {{AWS_ACCESS_KEY_ID}} and {{AWS_SECRET_KEY}} with actual values
```

### Method 3: Export Environment Variables

```bash
# Set environment variables (temporary - lost on logout)
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Then run container normally
./run.sh --detach
```

### Method 4: Direct Docker Run with Credentials

```bash
# Run container with credentials directly
docker run -d \
  --name final-project-app \
  -p 5001:5001 \
  -e AWS_ACCESS_KEY_ID="your-access-key" \
  -e AWS_SECRET_KEY="your-secret-key" \
  -e AWS_DEFAULT_REGION="us-east-1" \
  -e ENVIRONMENT="production" \
  --restart unless-stopped \
  final-project-jb:latest
```

### ⚠️ Security Notes

1. **NEVER commit** .env files or credentials to version control
2. **Use secure permissions**: `chmod 600 .env`
3. **Rotate credentials** regularly
4. **Use IAM roles** in production instead of access keys when possible

### Expected Behavior After Setting Credentials

Once credentials are properly configured, the application should:
- ✅ Show "AWS Connection: Success" instead of error
- ✅ Display AWS account information
- ✅ Connect to AWS services without errors
- ✅ Show AWS user/role ARN in the interface

### Testing AWS Connection

```bash
# Test the connection
curl http://<EC2_IP>:5001/aws-test

# Should return success instead of error
```
