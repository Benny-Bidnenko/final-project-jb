#!/usr/bin/env python3
"""
Flask Application for Final Project JB
Demonstrates Docker containerization with AWS integration
"""

import os
import json
import logging
from datetime import datetime
from flask import Flask, jsonify, render_template_string, request
import boto3
from botocore.exceptions import ClientError, NoCredentialsError
import requests

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)

# Configuration from environment variables
AWS_SECRET_KEY = os.environ.get('AWS_SECRET_KEY', 'not-provided')
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID', 'not-provided')
AWS_DEFAULT_REGION = os.environ.get('AWS_DEFAULT_REGION', 'us-east-1')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'development')

# HTML template for the main page
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Final Project JB - Docker App</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }
        h1 {
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .status-card {
            background: rgba(255, 255, 255, 0.2);
            padding: 20px;
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .status-card h3 {
            margin-top: 0;
            color: #ffeb3b;
            font-size: 1.3em;
        }
        .error {
            background: rgba(244, 67, 54, 0.3);
            border: 1px solid rgba(244, 67, 54, 0.5);
            padding: 15px;
            border-radius: 10px;
            margin: 10px 0;
        }
        .success {
            background: rgba(76, 175, 80, 0.3);
            border: 1px solid rgba(76, 175, 80, 0.5);
            padding: 15px;
            border-radius: 10px;
            margin: 10px 0;
        }
        .info {
            background: rgba(33, 150, 243, 0.3);
            border: 1px solid rgba(33, 150, 243, 0.5);
            padding: 15px;
            border-radius: 10px;
            margin: 10px 0;
        }
        pre {
            background: rgba(0, 0, 0, 0.3);
            padding: 15px;
            border-radius: 8px;
            overflow-x: auto;
            white-space: pre-wrap;
            word-wrap: break-word;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.3);
        }
        .api-links {
            margin: 20px 0;
        }
        .api-links a {
            display: inline-block;
            margin: 5px 10px;
            padding: 10px 20px;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            transition: all 0.3s ease;
        }
        .api-links a:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Final Project JB - Docker Application</h1>
        
        <div class="info">
            <h3>📋 Application Status</h3>
            <p><strong>Environment:</strong> {{ environment }}</p>
            <p><strong>Timestamp:</strong> {{ timestamp }}</p>
            <p><strong>Container:</strong> Running in Docker</p>
            <p><strong>Port:</strong> 5001</p>
        </div>

        <div class="status-grid">
            <div class="status-card">
                <h3>🔐 AWS Configuration</h3>
                <p><strong>Access Key ID:</strong> {{ aws_access_key_status }}</p>
                <p><strong>Secret Key:</strong> {{ aws_secret_key_status }}</p>
                <p><strong>Region:</strong> {{ aws_region }}</p>
                
                {% if aws_error %}
                <div class="error">
                    <h4>❌ AWS Connection Error</h4>
                    <pre>{{ aws_error }}</pre>
                </div>
                {% endif %}
            </div>

            <div class="status-card">
                <h3>🐍 Python Environment</h3>
                <p><strong>Python Version:</strong> {{ python_version }}</p>
                <p><strong>Flask Version:</strong> {{ flask_version }}</p>
                <p><strong>Boto3 Version:</strong> {{ boto3_version }}</p>
            </div>

            <div class="status-card">
                <h3>🌐 Network Information</h3>
                <p><strong>Host:</strong> {{ host_info }}</p>
                <p><strong>User Agent:</strong> {{ user_agent }}</p>
                <p><strong>Request Method:</strong> {{ request.method }}</p>
            </div>

            <div class="status-card">
                <h3>📦 Docker Information</h3>
                <p><strong>Container ID:</strong> {{ container_id }}</p>
                <p><strong>Hostname:</strong> {{ hostname }}</p>
                <p><strong>Working Directory:</strong> {{ working_dir }}</p>
            </div>
        </div>

        <div class="api-links">
            <h3>🔗 API Endpoints</h3>
            <a href="/health">Health Check</a>
            <a href="/aws-test">AWS Test</a>
            <a href="/environment">Environment Info</a>
            <a href="/api/status">JSON Status</a>
        </div>

        <div class="footer">
            <p>🚀 Deployed using Terraform + Docker</p>
            <p>📅 {{ timestamp }}</p>
        </div>
    </div>
</body>
</html>
"""

def get_aws_client_status():
    """Test AWS client connection and return status"""
    try:
        # Try to create an STS client to test credentials
        sts_client = boto3.client(
            'sts',
            aws_access_key_id=AWS_ACCESS_KEY_ID if AWS_ACCESS_KEY_ID != 'not-provided' else None,
            aws_secret_access_key=AWS_SECRET_KEY if AWS_SECRET_KEY != 'not-provided' else None,
            region_name=AWS_DEFAULT_REGION
        )
        
        # Try to get caller identity
        response = sts_client.get_caller_identity()
        return {
            'status': 'success',
            'account': response.get('Account', 'unknown'),
            'user_id': response.get('UserId', 'unknown'),
            'arn': response.get('Arn', 'unknown')
        }
    except NoCredentialsError:
        return {
            'status': 'error',
            'error': 'No AWS credentials found. Please set AWS_ACCESS_KEY_ID and AWS_SECRET_KEY environment variables.'
        }
    except ClientError as e:
        return {
            'status': 'error',
            'error': f'AWS Client Error: {str(e)}'
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': f'Unexpected error: {str(e)}'
        }

@app.route('/')
def home():
    """Main application page"""
    import sys
    import platform
    import socket
    
    # Get AWS status
    aws_status = get_aws_client_status()
    
    # Prepare template variables
    template_vars = {
        'environment': ENVIRONMENT,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC'),
        'aws_access_key_status': 'Configured' if AWS_ACCESS_KEY_ID != 'not-provided' else '❌ Not provided',
        'aws_secret_key_status': 'Configured' if AWS_SECRET_KEY != 'not-provided' else '❌ Not provided',
        'aws_region': AWS_DEFAULT_REGION,
        'aws_error': aws_status.get('error') if aws_status['status'] == 'error' else None,
        'python_version': sys.version,
        'flask_version': getattr(__import__('flask'), '__version__', 'unknown'),
        'boto3_version': getattr(boto3, '__version__', 'unknown'),
        'host_info': request.headers.get('Host', 'unknown'),
        'user_agent': request.headers.get('User-Agent', 'unknown'),
        'container_id': os.environ.get('HOSTNAME', 'not-in-container')[:12],
        'hostname': socket.gethostname(),
        'working_dir': os.getcwd(),
        'request': request
    }
    
    return render_template_string(HTML_TEMPLATE, **template_vars)

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'service': 'final-project-jb-docker-app',
        'version': '1.0.0'
    })

@app.route('/aws-test')
def aws_test():
    """Test AWS connectivity"""
    aws_status = get_aws_client_status()
    return jsonify({
        'aws_test_result': aws_status,
        'timestamp': datetime.now().isoformat(),
        'environment_vars': {
            'AWS_ACCESS_KEY_ID': 'configured' if AWS_ACCESS_KEY_ID != 'not-provided' else 'not-provided',
            'AWS_SECRET_KEY': 'configured' if AWS_SECRET_KEY != 'not-provided' else 'not-provided',
            'AWS_DEFAULT_REGION': AWS_DEFAULT_REGION
        }
    })

@app.route('/environment')
def environment_info():
    """Environment information endpoint"""
    import sys
    import platform
    
    return jsonify({
        'environment': ENVIRONMENT,
        'python_version': sys.version,
        'platform': platform.platform(),
        'hostname': os.environ.get('HOSTNAME', 'unknown'),
        'working_directory': os.getcwd(),
        'environment_variables': {
            key: 'configured' if value != 'not-provided' else 'not-provided'
            for key, value in {
                'AWS_ACCESS_KEY_ID': AWS_ACCESS_KEY_ID,
                'AWS_SECRET_KEY': AWS_SECRET_KEY,
                'AWS_DEFAULT_REGION': AWS_DEFAULT_REGION,
                'ENVIRONMENT': ENVIRONMENT
            }.items()
        },
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/status')
def api_status():
    """Complete status API endpoint"""
    aws_status = get_aws_client_status()
    
    return jsonify({
        'application': {
            'name': 'final-project-jb-docker-app',
            'version': '1.0.0',
            'environment': ENVIRONMENT,
            'status': 'running'
        },
        'aws': aws_status,
        'docker': {
            'container_id': os.environ.get('HOSTNAME', 'not-in-container'),
            'working_directory': os.getcwd()
        },
        'timestamp': datetime.now().isoformat()
    })

@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested resource was not found',
        'status_code': 404,
        'timestamp': datetime.now().isoformat()
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An internal server error occurred',
        'status_code': 500,
        'timestamp': datetime.now().isoformat()
    }), 500

if __name__ == '__main__':
    logger.info(f"Starting Flask application in {ENVIRONMENT} environment")
    logger.info(f"AWS Region: {AWS_DEFAULT_REGION}")
    logger.info(f"AWS Credentials: {'Configured' if AWS_ACCESS_KEY_ID != 'not-provided' else 'Not provided'}")
    
    # Run the Flask application
    app.run(
        host='0.0.0.0',
        port=5001,
        debug=(ENVIRONMENT == 'development')
    )
