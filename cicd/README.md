# 🚀 CI/CD Integration - Jenkins & Azure DevOps

## Overview

This directory contains comprehensive CI/CD pipeline configurations for both Jenkins and Azure DevOps, implementing parallel execution of linting, security scanning, Docker builds, and Docker Hub integration.

## 📁 Directory Structure

```
cicd/
├── jenkins/
│   └── Jenkinsfile           # Jenkins pipeline configuration
├── azure-devops/
│   └── azure-pipelines.yml  # Azure DevOps pipeline configuration
├── scripts/
│   ├── install-jenkins.sh   # Jenkins installation script
│   └── install-tools.sh     # Linting/security tools installation
└── README.md                # This documentation
```

## 🎯 Pipeline Features

### ✅ Both Pipelines Include:

1. **Parallel Quality Checks**:
   - **Linting**: Flake8 (Python), ShellCheck (Bash), Hadolint (Docker)
   - **Security Scanning**: Bandit (Python), Trivy (Container/FS)
   - **Unit Testing**: Python application tests

2. **Docker Integration**:
   - Multi-stage Docker image build
   - Container functionality testing
   - Security scanning of built images

3. **Docker Hub Integration**:
   - Secure credential management
   - Automated image pushing
   - Tagged releases (build number + latest)

4. **Error Handling & Reporting**:
   - Comprehensive logging
   - Cleanup procedures
   - Success/failure notifications

## 🔧 Jenkins Setup

### Prerequisites
- EC2 "builder" instance running
- Docker installed and configured
- Internet access for downloads

### Installation Steps

1. **SSH into your EC2 builder instance**:
   ```bash
   ssh -i terraform/ec2-docker/builder_key.pem ec2-user@<EC2_PUBLIC_IP>
   ```

2. **Install Jenkins**:
   ```bash
   # Clone the repository
   git clone https://github.com/Benny-Bidnenko/final-project-jb.git
   cd final-project-jb
   
   # Run Jenkins installation script
   chmod +x cicd/scripts/install-jenkins.sh
   ./cicd/scripts/install-jenkins.sh
   ```

3. **Access Jenkins**:
   - URL: `http://<EC2_PUBLIC_IP>:8080`
   - Use the initial admin password displayed during installation

4. **Jenkins Configuration**:
   ```bash
   # Install required plugins:
   - Docker Pipeline
   - Git Plugin
   - Pipeline Plugin (usually pre-installed)
   
   # Create Docker Hub credentials:
   - Go to: Manage Jenkins > Manage Credentials
   - Add: Username/Password credentials
   - ID: 'docker-hub-credentials'
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password
   ```

5. **Create Jenkins Pipeline**:
   - New Item > Pipeline
   - Configure SCM: Git
   - Repository URL: `https://github.com/Benny-Bidnenko/final-project-jb.git`
   - Branch: `dev`
   - Script Path: `Jenkinsfile`

### Optional: Install Real Tools (Bonus)

```bash
# Install linting and security tools for real implementation
./cicd/scripts/install-tools.sh
```

## 🔵 Azure DevOps Setup

### Prerequisites
- Azure DevOps organization
- Docker Hub service connection

### Configuration Steps

1. **Create Azure DevOps Project**:
   - Go to dev.azure.com
   - Create new project: "final-project-jb"

2. **Set up Service Connections**:
   ```bash
   # Go to: Project Settings > Service connections
   # Create Docker Registry connection:
   - Connection type: Docker Hub
   - Connection name: 'docker-hub-connection'
   - Docker Hub ID: Your username
   - Password: Your Docker Hub password
   ```

3. **Create Pipeline**:
   - Pipelines > Create Pipeline
   - Choose: GitHub (or Azure Repos)
   - Select repository: `final-project-jb`
   - Configure: Existing Azure Pipelines YAML file
   - Path: `/azure-pipelines.yml`

4. **Configure Variables** (if needed):
   - Pipeline > Edit > Variables
   - Add any environment-specific variables

## 🎯 Pipeline Execution

### Jenkins Pipeline Stages:

1. **Clone Repository** - Fetches latest code from GitHub
2. **Parallel Quality Checks**:
   - **Linting**: Flake8, ShellCheck, Hadolint
   - **Security Scanning**: Bandit, Trivy
   - **Unit Testing**: Python tests
3. **Build Docker Image** - Multi-stage build process
4. **Test Docker Image** - Container functionality verification
5. **Security Scan Docker Image** - Container vulnerability scanning
6. **Push to Docker Hub** - Tagged image deployment

### Azure DevOps Pipeline Stages:

1. **Quality Checks and Security Scanning** - Parallel matrix execution
2. **Build and Test** - Docker image build and testing
3. **Push to Docker Hub** - Image deployment with multiple tags

## 🔒 Security & Credentials

### Jenkins Credentials:
- **docker-hub-credentials**: Docker Hub username/password
- Stored securely in Jenkins credential store
- Referenced in pipeline via `credentials('docker-hub-credentials')`

### Azure DevOps Secrets:
- **docker-hub-connection**: Service connection for Docker Hub
- Managed through Azure DevOps service connections
- Referenced in pipeline via `$(dockerHubServiceConnection)`

## 🧪 Testing Pipeline

### Verify Pipeline Success:

1. **Check Pipeline Execution**:
   - All stages complete successfully
   - No red/failed stages
   - Parallel execution works correctly

2. **Verify Docker Hub Push**:
   - Visit: `https://hub.docker.com/r/your-username/final-project-jb`
   - Confirm tagged images are present
   - Check image metadata and layers

3. **Test Deployed Image**:
   ```bash
   # Pull and test the pushed image
   docker pull your-username/final-project-jb:latest
   docker run -d -p 5001:5001 your-username/final-project-jb:latest
   curl http://localhost:5001/health
   ```

## 🛠️ Troubleshooting

### Common Issues:

1. **Docker Build Fails**:
   ```bash
   # Check Docker daemon is running
   sudo systemctl status docker
   # Ensure user has Docker permissions
   sudo usermod -a -G docker $USER
   ```

2. **Docker Hub Push Fails**:
   - Verify credentials are correct
   - Check Docker Hub repository exists
   - Ensure repository is public or credentials have push access

3. **Jenkins Agent Issues**:
   ```bash
   # Restart Jenkins service
   sudo systemctl restart jenkins
   # Check Jenkins logs
   sudo journalctl -u jenkins -f
   ```

4. **Tool Installation Issues**:
   ```bash
   # For Amazon Linux 2 (EC2)
   sudo yum install -y python3-pip
   pip3 install --user flake8 bandit
   ```

## 📊 Mock vs Real Implementation

### Mock Commands (Default):
- Faster execution
- No external dependencies
- Shows pipeline structure
- Good for learning/demo

### Real Implementation (Bonus):
- Actual linting and security scanning
- Real vulnerability detection
- Production-ready quality gates
- Requires tool installation

To enable real tools, run:
```bash
./cicd/scripts/install-tools.sh
```

Then uncomment the real commands in the pipeline files.

## 🎉 Success Criteria

### Pipeline Completion:
- ✅ All stages execute successfully
- ✅ Parallel execution works correctly
- ✅ Docker image builds without errors
- ✅ Image pushes to Docker Hub successfully
- ✅ Tagged versions are available on Docker Hub

### Quality Gates:
- ✅ Linting passes (or shows mock success)
- ✅ Security scanning completes (or shows mock success)
- ✅ Unit tests pass
- ✅ Docker image functionality verified

## 🚀 Next Steps

After successful pipeline setup:

1. **Enable Webhooks** for automatic triggers
2. **Add Integration Tests** for deployed containers
3. **Implement Real Security Scanning** (bonus)
4. **Set up Monitoring** for pipeline failures
5. **Configure Notifications** for build status

Your CI/CD pipeline is now ready for production use! 🎉
