pipeline {
    agent any

    environment {
        // Docker Hub Configuration
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'your-dockerhub-username/final-project-jb'
        IMAGE_TAG = "${BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${DOCKER_IMAGE}:${IMAGE_TAG}"
        
        // Repository Configuration
        REPO_URL = 'https://github.com/Benny-Bidnenko/final-project-jb.git'
        REPO_BRANCH = 'dev'
        
        // Project Paths
        PROJECT_HOME = "${WORKSPACE}"
        APP_DIR = "${WORKSPACE}/app"
        
        // AWS Configuration (if needed)
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Clone Repository') {
            steps {
                echo "🔄 Cloning repository from ${REPO_URL} (branch: ${REPO_BRANCH})"
                git branch: "${REPO_BRANCH}", url: "${REPO_URL}"
                
                script {
                    // Display repository information
                    sh '''
                        echo "Repository cloned successfully!"
                        echo "Current directory: $(pwd)"
                        echo "Repository contents:"
                        ls -la
                        echo "App directory contents:"
                        ls -la app/
                    '''
                }
            }
        }

        stage('Parallel Quality Checks') {
            parallel {
                stage('Linting') {
                    steps {
                        echo "🔍 Starting Linting Phase..."
                        script {
                            dir("${APP_DIR}") {
                                // Python Linting with Flake8
                                echo "Running Flake8 for Python linting..."
                                sh '''
                                    echo "=== FLAKE8 PYTHON LINTING ==="
                                    echo "Checking Python code quality in app.py..."
                                    # Mock command - replace with real implementation for bonus
                                    echo "flake8 app.py --max-line-length=88 --ignore=E203,W503"
                                    echo "✅ Flake8 linting completed successfully"
                                '''
                            }
                            
                            // Shell Script Linting with ShellCheck
                            echo "Running ShellCheck for shell script linting..."
                            sh '''
                                echo "=== SHELLCHECK BASH LINTING ==="
                                echo "Checking shell scripts..."
                                # Mock command - replace with real implementation for bonus
                                echo "shellcheck build.sh run.sh setup-credentials.sh"
                                echo "✅ ShellCheck linting completed successfully"
                            '''
                            
                            // Dockerfile Linting with Hadolint
                            dir("${APP_DIR}") {
                                echo "Running Hadolint for Dockerfile linting..."
                                sh '''
                                    echo "=== HADOLINT DOCKERFILE LINTING ==="
                                    echo "Checking Dockerfile best practices..."
                                    # Mock command - replace with real implementation for bonus
                                    echo "hadolint Dockerfile"
                                    echo "✅ Hadolint Dockerfile linting completed successfully"
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
                
                stage('Security Scanning') {
                    steps {
                        echo "🔒 Starting Security Scanning Phase..."
                        script {
                            dir("${APP_DIR}") {
                                // Python Security Scanning with Bandit
                                echo "Running Bandit for Python security scanning..."
                                sh '''
                                    echo "=== BANDIT PYTHON SECURITY SCAN ==="
                                    echo "Scanning Python code for security vulnerabilities..."
                                    # Mock command - replace with real implementation for bonus
                                    echo "bandit -r app.py -f json -o bandit-report.json"
                                    echo "✅ Bandit security scanning completed successfully"
                                '''
                            }
                            
                            // Container Security Scanning with Trivy
                            echo "Running Trivy for filesystem and dependency scanning..."
                            sh '''
                                echo "=== TRIVY SECURITY SCAN ==="
                                echo "Scanning filesystem and dependencies for vulnerabilities..."
                                # Mock command - replace with real implementation for bonus
                                echo "trivy fs . --format json --output trivy-report.json"
                                echo "✅ Trivy filesystem scanning completed successfully"
                            '''
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
                        echo "🧪 Starting Unit Testing Phase..."
                        script {
                            dir("${APP_DIR}") {
                                echo "Running Python unit tests..."
                                sh '''
                                    echo "=== PYTHON UNIT TESTS ==="
                                    echo "Running application unit tests..."
                                    # Mock command - replace with real implementation for bonus
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
                echo "🐳 Building Docker image: ${FULL_IMAGE_NAME}"
                script {
                    dir("${APP_DIR}") {
                        // Build the Docker image
                        sh '''
                            echo "Building Docker image with multi-stage build..."
                            echo "Image name: $FULL_IMAGE_NAME"
                            docker build -t $FULL_IMAGE_NAME .
                            docker tag $FULL_IMAGE_NAME $DOCKER_IMAGE:latest
                            
                            echo "Docker image built successfully!"
                            docker images | grep $DOCKER_IMAGE
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
                echo "🧪 Testing Docker image functionality..."
                script {
                    sh '''
                        echo "=== DOCKER IMAGE TESTING ==="
                        echo "Starting container for testing..."
                        
                        # Run container in detached mode
                        docker run -d --name test-container -p 5001:5001 $FULL_IMAGE_NAME
                        
                        # Wait for container to start
                        sleep 10
                        
                        # Test health endpoint
                        echo "Testing application health endpoint..."
                        curl -f http://localhost:5001/health || exit 1
                        
                        echo "✅ Docker image test completed successfully"
                        
                        # Clean up test container
                        docker stop test-container
                        docker rm test-container
                    '''
                }
            }
            post {
                always {
                    echo "🧹 Cleaning up test containers..."
                    sh '''
                        docker stop test-container || true
                        docker rm test-container || true
                    '''
                }
            }
        }
        
        stage('Security Scan Docker Image') {
            steps {
                echo "🔒 Scanning Docker image for vulnerabilities..."
                script {
                    sh '''
                        echo "=== DOCKER IMAGE SECURITY SCAN ==="
                        echo "Scanning Docker image with Trivy..."
                        # Mock command - replace with real implementation for bonus
                        echo "trivy image $FULL_IMAGE_NAME --format json --output docker-scan-report.json"
                        echo "✅ Docker image security scan completed"
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "📤 Pushing Docker image to Docker Hub..."
                script {
                    // Login and push to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        sh '''
                            echo "Pushing image: $FULL_IMAGE_NAME"
                            docker push $FULL_IMAGE_NAME
                            
                            echo "Pushing latest tag: $DOCKER_IMAGE:latest"
                            docker push $DOCKER_IMAGE:latest
                            
                            echo "✅ Images pushed successfully to Docker Hub!"
                        '''
                    }
                }
            }
            post {
                success {
                    echo "✅ Docker images pushed successfully to Docker Hub"
                    echo "🎉 Image available at: https://hub.docker.com/r/${DOCKER_IMAGE}"
                }
                failure {
                    echo "❌ Failed to push Docker images to Docker Hub"
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
                    docker rmi $DOCKER_IMAGE:latest || true
                    echo "Local cleanup completed"
                '''
            }
            cleanWs()
        }
        success {
            echo """
            🎉 =================================== 🎉
            ✅ PIPELINE COMPLETED SUCCESSFULLY! ✅
            🎉 =================================== 🎉
            
            📊 Pipeline Summary:
            • Repository: ${REPO_URL}
            • Branch: ${REPO_BRANCH}
            • Build: #${BUILD_NUMBER}
            • Docker Image: ${FULL_IMAGE_NAME}
            • Docker Hub: https://hub.docker.com/r/${DOCKER_IMAGE}
            
            🚀 Next Steps:
            • Verify image on Docker Hub
            • Deploy to staging/production
            • Run integration tests
            """
        }
        failure {
            echo """
            ❌ ============================= ❌
            💥 PIPELINE FAILED! 💥
            ❌ ============================= ❌
            
            Please check the logs above for error details.
            Common issues:
            • Docker Hub credentials
            • Docker daemon connectivity
            • Code quality issues
            • Security vulnerabilities
            """
        }
    }
}
