#!/bin/bash

# Docker Build Script for Final Project JB
# Usage: ./build.sh [--no-cache] [--tag custom-tag]

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
BUILD_ARGS=""

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Docker Build - Final Project JB${NC}"
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
        --no-cache)
            BUILD_ARGS="$BUILD_ARGS --no-cache"
            print_info "Building without cache"
            shift
            ;;
        --tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--no-cache] [--tag custom-tag]"
            echo "  --no-cache    Build without using cache"
            echo "  --tag TAG     Use custom tag (default: latest)"
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

print_success "Docker is running"

# Build the Docker image
print_info "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
print_info "Build arguments: ${BUILD_ARGS:-none}"

if docker build $BUILD_ARGS -t "${IMAGE_NAME}:${IMAGE_TAG}" .; then
    print_success "Docker image built successfully!"
    
    # Show image information
    echo ""
    print_info "Image Information:"
    docker images "${IMAGE_NAME}:${IMAGE_TAG}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    
    echo ""
    print_info "Image layers:"
    docker history "${IMAGE_NAME}:${IMAGE_TAG}" --no-trunc --format "table {{.CreatedBy}}\t{{.Size}}"
    
    echo ""
    print_success "Build completed! You can now run the container with:"
    echo -e "${YELLOW}  docker run -d -p 5001:5001 --name final-project-app ${IMAGE_NAME}:${IMAGE_TAG}${NC}"
    echo -e "${YELLOW}  Or use: ./run.sh${NC}"
    
else
    print_error "Docker build failed!"
    exit 1
fi
