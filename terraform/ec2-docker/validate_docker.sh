#!/bin/bash

# Docker Validation Script
# Run this script on the EC2 instance to validate Docker installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Docker Installation Validation${NC}"
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

run_test() {
    local test_name="$1"
    local command="$2"
    
    echo -n "Testing $test_name... "
    if eval "$command" > /dev/null 2>&1; then
        print_success "PASSED"
        return 0
    else
        print_error "FAILED"
        return 1
    fi
}

print_header

echo "System Information:"
echo "- OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "- Kernel: $(uname -r)"
echo "- User: $(whoami)"
echo ""

# Test Docker installation
echo "Docker Installation Tests:"
run_test "Docker binary" "which docker"
run_test "Docker version" "docker --version"
run_test "Docker service status" "sudo systemctl is-active docker"
run_test "Docker without sudo" "docker info"

echo ""

# Test Docker Compose installation
echo "Docker Compose Installation Tests:"
run_test "Docker Compose binary" "which docker-compose"
run_test "Docker Compose version" "docker-compose --version"
run_test "Docker Compose plugin" "docker compose version"

echo ""

# Functional tests
echo "Functional Tests:"
run_test "Docker hello-world" "docker run --rm hello-world"
run_test "Docker Alpine test" "docker run --rm alpine:latest echo 'Alpine test successful'"

echo ""

# Docker Compose functional test
echo "Testing Docker Compose functionality..."
cat > docker-compose-test.yml << 'COMPOSE_EOF'
version: '3.8'
services:
  test:
    image: alpine:latest
    command: echo "Docker Compose test successful"
COMPOSE_EOF

if docker-compose -f docker-compose-test.yml up --abort-on-container-exit > /dev/null 2>&1; then
    print_success "Docker Compose functional test PASSED"
else
    print_error "Docker Compose functional test FAILED"
fi

# Cleanup test file
rm -f docker-compose-test.yml

echo ""

# System resources
echo "System Resources:"
echo "- Memory: $(free -h | grep '^Mem:' | awk '{print $2 " total, " $7 " available"}')"
echo "- Disk: $(df -h / | tail -1 | awk '{print $2 " total, " $4 " available"}')"
echo "- CPU: $(nproc) cores"

echo ""

# Docker system info
echo "Docker System Information:"
echo "- Docker version: $(docker --version | cut -d' ' -f3 | tr -d ',')"
echo "- Docker Compose version: $(docker-compose --version | cut -d' ' -f3 | tr -d ',')"
echo "- Storage driver: $(docker info --format '{{.Driver}}')"
echo "- Running containers: $(docker ps -q | wc -l)"
echo "- Total images: $(docker images -q | wc -l)"

print_success "Docker validation completed!"
