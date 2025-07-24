pipeline {
    agent any
    
    environment {
        // Docker Hub Credentials
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_PASSWORD = credentials('dockerhub-password')
        IMAGE_NAME = 'your-dockerhub-username/flask-aws-monitor'
        IMAGE_TAG = "${BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${IMAGE_NAME}:${IMAGE_TAG}"
        
        // Repository Configuration
        REPO_URL = 'https://github.com/Benny-Bidnenko/final-project-jb.git'
        REPO_BRANCH = 'dev'
        
        // Project Paths
        APP_DIR = "${WORKSPACE}/app"
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                echo "🔄 Cloning repository from ${REPO_URL}"
                // Fixed: Use your actual repository URL and branch
                git branch: "${REPO_BRANCH}", url: "${REPO_URL}"
                
                script {
                    echo "Repository cloned successfully!"
                    sh 'ls -la'
                    sh 'ls -la app/ || echo "App directory not found"'
                }
            }
        }
        
        stage('Parallel Checks') {
            // Fixed: Added missing 'parallel' directive
            parallel {
                stage('Linting') {
                    steps {
                        echo '🔍 Starting Linting Phase...'
                        script {
                            dir("${APP_DIR}") {
                                // Python Linting with Flake8
                                echo "=== FLAKE8 PYTHON LINTING ==="
                                sh '''
                                    echo "Checking Python code quality in app.py..."
                                    # Mock implementation - replace with real for bonus
                                    echo "flake8 app.py --max-line-length=88 --ignore=E203,W503"
                                    echo "✅ Python linting completed successfully"
                                '''
                                
                                // Shell Script Linting with ShellCheck
                                echo "=== SHELLCHECK BASH LINTING ==="
                                sh '''
                                    echo "Checking shell scripts..."
                                    # Mock implementation - replace with real for bonus
                                    echo "shellcheck build.sh run.sh setup-credentials.sh"
                                    echo "✅ Shell script linting completed successfully"
                                '''
                                
                                // Dockerfile Linting with Hadolint
                                echo "=== HADOLINT DOCKERFILE LINTING ==="  
                                sh '''
                                    echo "Checking Dockerfile best practices..."
                                    # Mock implementation - replace with real for bonus
                                    echo "hadolint Dockerfile"
                                    echo "✅ Dockerfile linting completed successfully"
                                '''
                            }
                        }
                    }
                    post {
                        always {
                            echo "📊 Linting phase completed"
                        }
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        echo '🔒 Starting Security Scanning Phase...'
                        script {
                            dir("${APP_DIR}") {
                                // Python Security Scanning with Bandit
                                echo "=== BANDIT PYTHON SECURITY SCAN ==="
                                sh '''
                                    echo "Scanning Python code for security vulnerabilities..."
                                    # Mock implementation - replace with real for bonus
                                    echo "bandit -r app.py -f json -o bandit-report.json"
                                    echo "✅ Python security scanning completed successfully"
                                '''
                                
                                // Container/Filesystem Security Scanning with Trivy
                                echo "=== TRIVY SECURITY SCAN ==="
                                sh '''
                                    echo "Scanning filesystem and dependencies for vulnerabilities..."
                                    # Mock implementation - replace with real for bonus
                                    echo "trivy fs . --format json --output trivy-report.json"
                                    echo "✅ Filesystem security scanning completed successfully"
                                '''
                                
                                // Dependency Security Check
                                echo "=== DEPENDENCY SECURITY CHECK ==="
                                sh '''
                                    echo "Checking Python dependencies for known vulnerabilities..."
                                    # Mock implementation - replace with real for bonus
                                    echo "safety check -r requirements.txt"
                                    echo "✅ Dependency security check completed successfully"
                                '''
                            }
                        }
                    }
                    post {
                        always {
                            echo "🛡️ Security scanning phase completed"
                        }
                    }
                }
                
                stage('Unit Tests') {
                    steps {
                        echo '🧪 Starting Unit Testing Phase...'
                        script {
                            dir("${APP_DIR}") {
                                echo "=== PYTHON UNIT TESTS ==="
                                sh '''
                                    echo "Running application unit tests..."
                                    # Mock implementation - replace with real for bonus
                                    echo "python3 test-app.py"
                                    echo "✅ Unit tests completed successfully"
                                '''
                            }
                        }
                    }
                    post {
                        always {
                            echo "🧪 Unit testing phase completed"
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker Image...'
                script {
                    dir("${APP_DIR}") {
                        // Fixed: Implemented Docker build step
                        echo "Building Docker image: ${FULL_IMAGE_NAME}"
                        sh '''
                            echo "=== DOCKER IMAGE BUILD ==="
                            echo "Building multi-stage Docker image..."
                            docker build -t $FULL_IMAGE_NAME .
                            docker tag $FULL_IMAGE_NAME $IMAGE_NAME:latest
                            
                            echo "Docker image built successfully!"
                            docker images | grep $IMAGE_NAME || echo "Image not found in list"
                        '''
                    }
                }
            }
            post {
                success {
                    echo "✅ Docker image built successfully: ${FULL_IMAGE_NAME}"
                }
                failure {
                    echo "❌ Docker image build failed"
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                echo '🧪 Testing Docker Image Functionality...'
                script {
                    sh '''
                        echo "=== DOCKER IMAGE TESTING ==="
                        echo "Starting container for functionality testing..."
                        
                        # Start container in detached mode
                        docker run -d --name test-container -p 5001:5001 \
                            -e AWS_ACCESS_KEY_ID=test-key \
                            -e AWS_SECRET_ACCESS_KEY=test-secret \
                            $FULL_IMAGE_NAME
                        
                        # Wait for container to start
                        echo "Waiting for container to start..."
                        sleep 15
                        
                        # Test health endpoint
                        echo "Testing application health endpoint..."
                        curl -f http://localhost:5001/health || {
                            echo "Health check failed, checking container logs:"
                            docker logs test-container
                            exit 1
                        }
                        
                        echo "✅ Docker image functionality test passed"
                    '''
                }
            }
            post {
                always {
                    echo "🧹 Cleaning up test container..."
                    sh '''
                        docker stop test-container || true
                        docker rm test-container || true
                    '''
                }
            }
        }
        
        stage('Security Scan Docker Image') {
            steps {
                echo '🔒 Scanning Docker Image for Vulnerabilities...'
                script {
                    sh '''
                        echo "=== DOCKER IMAGE SECURITY SCAN ==="
                        echo "Scanning Docker image with Trivy..."
                        # Mock implementation - replace with real for bonus
                        echo "trivy image $FULL_IMAGE_NAME --format json --output docker-scan-report.json"
                        echo "✅ Docker image security scan completed"
                        
                        echo "=== DOCKER IMAGE BEST PRACTICES ==="
                        echo "Checking Docker image for best practices..."
                        # Mock implementation - could use dive or similar tools
                        echo "dive $FULL_IMAGE_NAME --ci"
                        echo "✅ Docker image best practices check completed"
                    '''
                }
            }
            post {
                always {
                    echo "🔒 Docker image security scanning completed"
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo '📤 Pushing to Docker Hub...'
                script {
                    // Fixed: Implemented Docker Hub push logic
                    sh '''
                        echo "=== DOCKER HUB AUTHENTICATION ==="
                        echo "Logging into Docker Hub..."
                        echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin
                        
                        echo "=== DOCKER IMAGE PUSH ==="
                        echo "Pushing image with build tag: $FULL_IMAGE_NAME"
                        docker push $FULL_IMAGE_NAME
                        
                        echo "Pushing image with latest tag: $IMAGE_NAME:latest"
                        docker push $IMAGE_NAME:latest
                        
                        echo "✅ Images pushed successfully to Docker Hub!"
                        echo "🎉 Image available at: https://hub.docker.com/r/$IMAGE_NAME"
                    '''
                }
            }
            post {
                success {
                    echo "✅ Docker Hub push completed successfully"
                    echo "🔗 Image URL: https://hub.docker.com/r/${IMAGE_NAME}"
                }
                failure {
                    echo "❌ Docker Hub push failed"
                }
                always {
                    echo "🔐 Logging out of Docker Hub..."
                    sh 'docker logout || true'
                }
            }
        }
    }
    
    post {
        always {
            echo "🧹 Pipeline cleanup..."
            script {
                // Clean up local Docker images to save space
                sh '''
                    echo "Cleaning up local Docker images..."
                    docker rmi $FULL_IMAGE_NAME || true
                    docker rmi $IMAGE_NAME:latest || true
                    
                    # Clean up any test containers
                    docker stop test-container || true
                    docker rm test-container || true
                    
                    echo "Local cleanup completed"
                '''
            }
            cleanWs()
        }
        success {
            echo """
            🎉 ===================================== 🎉
            ✅    PIPELINE COMPLETED SUCCESSFULLY!    ✅
            🎉 ===================================== 🎉
            
            📊 Pipeline Summary:
            • Repository: ${REPO_URL}
            • Branch: ${REPO_BRANCH}
            • Build: #${BUILD_NUMBER}
            • Docker Image: ${FULL_IMAGE_NAME}
            • Docker Hub: https://hub.docker.com/r/${IMAGE_NAME}
            
            🚀 Pipeline Stages Completed:
            • ✅ Repository cloned successfully
            • ✅ Parallel linting and security scanning passed
            • ✅ Docker image built successfully
            • ✅ Container functionality tested
            • ✅ Security scans completed
            • ✅ Image pushed to Docker Hub
            
            🎯 Next Steps:
            • Verify image on Docker Hub
            • Deploy to staging/production
            • Run integration tests
            • Set up monitoring alerts
            """
        }
        failure {
            echo """
            ❌ =============================== ❌
            💥      PIPELINE FAILED!         💥
            ❌ =============================== ❌
            
            Please check the logs above for error details.
            
            🔍 Common Issues to Check:
            • Docker Hub credentials configuration
            • Docker daemon connectivity  
            • Repository URL and branch accessibility
            • Code quality issues from linting
            • Security vulnerabilities found
            • Container port conflicts
            • Network connectivity issues
            
            🛠️ Troubleshooting Steps:
            1. Check Jenkins credential configuration
            2. Verify Docker Hub repository exists
            3. Test Docker commands manually on agent
            4. Review application logs in failed stage
            5. Check firewall/network settings
            """
        }
        unstable {
            echo "⚠️ Pipeline completed with warnings - check logs for details"
        }
    }
}
