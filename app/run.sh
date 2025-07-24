#!/bin/bash

# Docker Run Script for Final Project JB
# Usage: ./run.sh [--env-file .env] [--detach] [--remove]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
IMAGE_NAME="final-project-jb"
IMAGE_TAG="latest"
CONTAINER_NAME="final-project-app"
PORT="5001"
ENV_FILE=""
DETACH=""
REMOVE_EXISTING=""

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Docker Run - Final Project JB${NC}"
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

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --detach|-d)
            DETACH="-d"
            shift
            ;;
        --remove|-r)
            REMOVE_EXISTING="yes"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--env-file FILE] [--detach] [--remove]"
            echo "  --env-file FILE   Use environment file"
            echo "  --detach, -d      Run in detached mode"
            echo "  --remove, -r      Remove existing container if exists"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_header

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running or not accessible"
    exit 1
fi

# Check if image exists
if ! docker images "${IMAGE_NAME}:${IMAGE_TAG}" | grep -q "${IMAGE_NAME}"; then
    print_error "Docker image ${IMAGE_NAME}:${IMAGE_TAG} not found"
    print_info "Please build the image first: ./build.sh"
    exit 1
fi

# Remove existing container if requested
if [ "$REMOVE_EXISTING" = "yes" ]; then
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_info "Removing existing container: ${CONTAINER_NAME}"
        docker rm -f "${CONTAINER_NAME}" || true
    fi
fi

# Stop existing container if running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    print_warning "Container ${CONTAINER_NAME} is already running"
    print_info "Stopping existing container..."
    docker stop "${CONTAINER_NAME}"
    docker rm "${CONTAINER_NAME}"
fi

# Prepare environment variables
ENV_ARGS=""
if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
    ENV_ARGS="--env-file $ENV_FILE"
    print_info "Using environment file: $ENV_FILE"
else
    # Set default environment variables
    ENV_ARGS="-e ENVIRONMENT=development"
    ENV_ARGS="$ENV_ARGS -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-not-provided}"
    ENV_ARGS="$ENV_ARGS -e AWS_SECRET_KEY=${AWS_SECRET_KEY:-not-provided}"
    ENV_ARGS="$ENV_ARGS -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}"
    print_warning "No environment file specified, using defaults"
fi

# Run the container
print_info "Starting container: ${CONTAINER_NAME}"
print_info "Port mapping: ${PORT}:5001"
print_info "Mode: $([ -n "$DETACH" ] && echo "detached" || echo "interactive")"

# Construct and execute docker run command
DOCKER_CMD="docker run $DETACH --name $CONTAINER_NAME -p $PORT:5001 $ENV_ARGS --restart unless-stopped $IMAGE_NAME:$IMAGE_TAG"

print_info "Executing: $DOCKER_CMD"

if eval $DOCKER_CMD; then
    if [ -n "$DETACH" ]; then
        print_success "Container started successfully in detached mode!"
        echo ""
        print_info "Container status:"
        docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        print_info "Access the application at: http://localhost:$PORT"
        print_info "View logs with: docker logs -f $CONTAINER_NAME"
        print_info "Stop container with: docker stop $CONTAINER_NAME"
    else
        print_success "Container started in interactive mode"
    fi
else
    print_error "Failed to start container"
    exit 1
fi
