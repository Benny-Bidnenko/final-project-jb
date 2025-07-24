# 🐳 Docker Python Flask Application

## Overview
Multi-stage Docker containerized Python Flask application with AWS integration for Final Project JB.

## Features
- **Multi-stage Dockerfile** with optimized build and runtime stages
- **Python Flask** web application with modern UI
- **AWS SDK integration** with boto3
- **Environment variable** configuration
- **Health checks** and monitoring endpoints
- **Non-root user** for security
- **Comprehensive logging** and error handling

## Quick Start

### Build the Image
```bash
./build.sh
```

### Run the Container
```bash
./run.sh --detach
```

### Access the Application
- Web UI: http://localhost:5001
- Health Check: http://localhost:5001/health
- AWS Test: http://localhost:5001/aws-test

## Docker Commands

### Manual Build
```bash
docker build -t final-project-jb:latest .
```

### Manual Run
```bash
docker run -d -p 5001:5001 --name final-project-app final-project-jb:latest
```

### With Environment Variables
```bash
docker run -d -p 5001:5001 \
  -e AWS_ACCESS_KEY_ID=your-key \
  -e AWS_SECRET_KEY=your-secret \
  -e AWS_DEFAULT_REGION=us-east-1 \
  --name final-project-app \
  final-project-jb:latest
```

## Development

### Using Docker Compose
```bash
docker-compose up -d
```

### View Logs
```bash
docker logs -f final-project-app
```

### Stop Container
```bash
docker stop final-project-app
```

## File Structure
```
app/
├── Dockerfile              # Multi-stage Docker build
├── app.py                  # Main Flask application
├── requirements.txt        # Python dependencies
├── docker-compose.yml      # Development setup
├── .dockerignore          # Docker build exclusions
├── build.sh               # Build automation script
├── run.sh                 # Run automation script
└── README.md              # This file
```

## Environment Variables
- `AWS_ACCESS_KEY_ID` - AWS access key (optional)
- `AWS_SECRET_KEY` - AWS secret key (optional)
- `AWS_DEFAULT_REGION` - AWS region (default: us-east-1)
- `ENVIRONMENT` - Application environment (default: production)

## Endpoints
- `/` - Main dashboard with system information
- `/health` - Health check endpoint
- `/aws-test` - AWS connectivity test
- `/environment` - Environment information
- `/api/status` - Complete JSON status

## Expected Behavior
The application will show an AWS connection error when credentials are not provided - this is expected and normal behavior for the assignment.

## Container Features
- **Multi-stage build** reduces final image size
- **Non-root user** improves security
- **Health check** for container monitoring
- **Proper signal handling** for graceful shutdown
- **Volume support** for development
