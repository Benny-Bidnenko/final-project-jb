#!/usr/bin/env python3
"""
AWS Resources Dashboard
Flask Application for Final Project JB - Fixed Version
"""

import os
import boto3
from flask import Flask, render_template_string
from botocore.exceptions import ClientError, NoCredentialsError
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Fetch AWS credentials from environment variables
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY") 
REGION = "us-east-1"

# Initialize Boto3 clients with error handling
try:
    session = boto3.Session(
        aws_access_key_id=AWS_ACCESS_KEY,
        aws_secret_access_key=AWS_SECRET_KEY,
        region_name=REGION
    )
    ec2_client = session.client("ec2")
    elb_client = session.client("elbv2")
    
    # Test connection
    ec2_client.describe_regions(RegionNames=[REGION])
    logger.info("AWS connection established successfully")
    aws_connection_error = None
    
except NoCredentialsError:
    logger.error("AWS credentials not found")
    aws_connection_error = "AWS credentials not found. Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables."
    ec2_client = None
    elb_client = None
    
except ClientError as e:
    logger.error(f"AWS client error: {e}")
    aws_connection_error = f"AWS Client Error: {str(e)}"
    ec2_client = None
    elb_client = None
    
except Exception as e:
    logger.error(f"Unexpected AWS error: {e}")
    aws_connection_error = f"Unexpected AWS error: {str(e)}"
    ec2_client = None
    elb_client = None

@app.route("/")
def home():
    # If there's an AWS connection error, show it
    if aws_connection_error:
        error_template = """
        <html>
        <head>
            <title>AWS Resources - Error</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    margin: 40px;
                    background-color: #f5f5f5;
                }
                .error-container {
                    background-color: #fff;
                    border: 1px solid #ddd;
                    border-radius: 8px;
                    padding: 30px;
                    max-width: 800px;
                    margin: 0 auto;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }
                .error {
                    background-color: #fee;
                    border: 1px solid #fcc;
                    border-radius: 4px;
                    padding: 20px;
                    margin: 20px 0;
                    color: #c33;
                }
                h1 {
                    color: #333;
                    border-bottom: 2px solid #007cba;
                    padding-bottom: 10px;
                }
                .info {
                    background-color: #e7f3ff;
                    border: 1px solid #b3d9ff;
                    border-radius: 4px;
                    padding: 15px;
                    margin: 20px 0;
                    color: #0056b3;
                }
            </style>
        </head>
        <body>
            <div class="error-container">
                <h1>🚀 Final Project JB - AWS Resources Dashboard</h1>
                
                <div class="error">
                    <h3>❌ AWS Connection Error</h3>
                    <p><strong>Error:</strong> {{ error_message }}</p>
                </div>
                
                <div class="info">
                    <h3>📋 Expected Behavior</h3>
                    <p>This error is <strong>expected</strong> when AWS credentials are not properly configured.</p>
                    <p>To fix this issue, you need to:</p>
                    <ul>
                        <li>Set the <code>AWS_ACCESS_KEY_ID</code> environment variable</li>
                        <li>Set the <code>AWS_SECRET_ACCESS_KEY</code> environment variable</li>
                        <li>Ensure the credentials have the necessary permissions</li>
                    </ul>
                </div>
                
                <div class="info">
                    <h3>🔧 Configuration Status</h3>
                    <p><strong>AWS_ACCESS_KEY_ID:</strong> {{ 'Configured' if aws_key else 'Not provided' }}</p>
                    <p><strong>AWS_SECRET_ACCESS_KEY:</strong> {{ 'Configured' if aws_secret else 'Not provided' }}</p>
                    <p><strong>AWS_REGION:</strong> {{ region }}</p>
                </div>
                
                <div class="info">
                    <h3>🐳 Container Information</h3>
                    <p><strong>Application:</strong> Running in Docker container</p>
                    <p><strong>Port:</strong> 5001</p>
                    <p><strong>Environment:</strong> {{ environment }}</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return render_template_string(
            error_template,
            error_message=aws_connection_error,
            aws_key=bool(AWS_ACCESS_KEY),
            aws_secret=bool(AWS_SECRET_KEY),
            region=REGION,
            environment=os.getenv('ENVIRONMENT', 'production')
        )
    
    # If AWS connection is working, fetch and display resources
    try:
        # Fetch EC2 instances
        logger.info("Fetching EC2 instances...")
        instances = ec2_client.describe_instances()
        instance_data = []
        for reservation in instances["Reservations"]:
            for instance in reservation["Instances"]:
                instance_data.append({
                    "ID": instance["InstanceId"],
                    "State": instance["State"]["Name"],
                    "Type": instance["InstanceType"],
                    "Public IP": instance.get("PublicIpAddress", "N/A")
                })
        
        # Fetch VPCs - FIX: Actually call describe_vpcs
        logger.info("Fetching VPCs...")
        vpcs = ec2_client.describe_vpcs()
        vpc_data = [{"VPC ID": vpc["VpcId"], "CIDR": vpc["CidrBlock"]} for vpc in vpcs["Vpcs"]]
        
        # Fetch Load Balancers - FIX: Actually call describe_load_balancers
        logger.info("Fetching Load Balancers...")
        try:
            lbs = elb_client.describe_load_balancers()
            lb_data = [{"LB Name": lb["LoadBalancerName"], "DNS Name": lb["DNSName"]} for lb in lbs["LoadBalancers"]]
        except KeyError:
            # Handle case where LoadBalancerName might not exist (ALB vs CLB)
            lbs = elb_client.describe_load_balancers()
            lb_data = []
            for lb in lbs["LoadBalancers"]:
                lb_data.append({
                    "LB Name": lb.get("LoadBalancerName", lb.get("LoadBalancerArn", "N/A").split("/")[-1]),
                    "DNS Name": lb["DNSName"]
                })
        except Exception as e:
            logger.warning(f"Error fetching load balancers: {e}")
            lb_data = [{"LB Name": "Error fetching LBs", "DNS Name": str(e)}]
        
        # Fetch AMIs - FIX: Actually call describe_images
        logger.info("Fetching AMIs...")
        try:
            amis = ec2_client.describe_images(Owners=['self'])  # Only owned by the account
            ami_data = [{"AMI ID": ami["ImageId"], "Name": ami.get("Name", "N/A")} for ami in amis["Images"]]
            
            # If no owned AMIs, show recent Amazon Linux AMIs as example
            if not ami_data:
                logger.info("No owned AMIs found, fetching recent Amazon Linux AMIs...")
                amis = ec2_client.describe_images(
                    Owners=['amazon'],
                    Filters=[
                        {'Name': 'name', 'Values': ['amzn2-ami-hvm-*']},
                        {'Name': 'state', 'Values': ['available']},
                        {'Name': 'architecture', 'Values': ['x86_64']}
                    ],
                    MaxResults=5
                )
                ami_data = [{"AMI ID": ami["ImageId"], "Name": ami.get("Name", "N/A")} for ami in amis["Images"]]
                
        except Exception as e:
            logger.warning(f"Error fetching AMIs: {e}")
            ami_data = [{"AMI ID": "Error fetching AMIs", "Name": str(e)}]
        
        logger.info(f"Found {len(instance_data)} instances, {len(vpc_data)} VPCs, {len(lb_data)} load balancers, {len(ami_data)} AMIs")
        
    except Exception as e:
        logger.error(f"Error fetching AWS resources: {e}")
        return f"<h1>Error fetching AWS resources:</h1><p>{str(e)}</p>"
    
    # Render the result in a properly styled table
    html_template = """
    <html>
    <head>
        <title>AWS Resources Dashboard</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
                background-color: #f5f5f5;
            }
            .container {
                background-color: white;
                border-radius: 8px;
                padding: 20px;
                margin: 20px 0;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            h1 {
                color: #333;
                border-bottom: 3px solid #007cba;
                padding-bottom: 10px;
            }
            h2 {
                color: #555;
                border-bottom: 2px solid #28a745;
                padding-bottom: 5px;
                margin-top: 30px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin: 15px 0;
            }
            th, td {
                border: 1px solid #ddd;
                padding: 12px;
                text-align: left;
            }
            th {
                background-color: #007cba;
                color: white;
                font-weight: bold;
            }
            tr:nth-child(even) {
                background-color: #f8f9fa;
            }
            tr:hover {
                background-color: #e8f4f8;
            }
            .status {
                background-color: #d4edda;
                border: 1px solid #c3e6cb;
                border-radius: 4px;
                padding: 10px;
                margin: 10px 0;
                color: #155724;
            }
            .empty-state {
                text-align: center;
                color: #666;
                font-style: italic;
                padding: 20px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Final Project JB - AWS Resources Dashboard</h1>
            
            <div class="status">
                <strong>✅ AWS Connection:</strong> Successfully connected to AWS in region {{ region }}
            </div>
            
            <h2>🖥️ EC2 Instances ({{ instance_count }})</h2>
            {% if instance_data %}
            <table>
                <tr><th>Instance ID</th><th>State</th><th>Type</th><th>Public IP</th></tr>
                {% for instance in instance_data %}
                <tr>
                    <td>{{ instance['ID'] }}</td>
                    <td>{{ instance['State'] }}</td>
                    <td>{{ instance['Type'] }}</td>
                    <td>{{ instance['Public IP'] }}</td>
                </tr>
                {% endfor %}
            </table>
            {% else %}
            <div class="empty-state">No EC2 instances found in this region.</div>
            {% endif %}
            
            <h2>🌐 VPCs ({{ vpc_count }})</h2>
            {% if vpc_data %}
            <table>
                <tr><th>VPC ID</th><th>CIDR Block</th></tr>
                {% for vpc in vpc_data %}
                <tr>
                    <td>{{ vpc['VPC ID'] }}</td>
                    <td>{{ vpc['CIDR'] }}</td>
                </tr>
                {% endfor %}
            </table>
            {% else %}
            <div class="empty-state">No VPCs found in this region.</div>
            {% endif %}
            
            <h2>⚖️ Load Balancers ({{ lb_count }})</h2>
            {% if lb_data %}
            <table>
                <tr><th>Load Balancer Name</th><th>DNS Name</th></tr>
                {% for lb in lb_data %}
                <tr>
                    <td>{{ lb['LB Name'] }}</td>
                    <td>{{ lb['DNS Name'] }}</td>
                </tr>
                {% endfor %}
            </table>
            {% else %}
            <div class="empty-state">No load balancers found in this region.</div>
            {% endif %}
            
            <h2>💿 AMIs ({{ ami_count }})</h2>
            {% if ami_data %}
            <table>
                <tr><th>AMI ID</th><th>Name</th></tr>
                {% for ami in ami_data %}
                <tr>
                    <td>{{ ami['AMI ID'] }}</td>
                    <td>{{ ami['Name'] }}</td>
                </tr>
                {% endfor %}
            </table>
            {% else %}
            <div class="empty-state">No AMIs found.</div>
            {% endif %}
            
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; text-align: center;">
                <p>🐳 Running in Docker container | 📅 Deployed with Terraform | ⚡ Powered by Flask</p>
            </div>
        </div>
    </body>
    </html>
    """
    
    return render_template_string(
        html_template,
        instance_data=instance_data,
        vpc_data=vpc_data,
        lb_data=lb_data,
        ami_data=ami_data,
        region=REGION,
        instance_count=len(instance_data),
        vpc_count=len(vpc_data),
        lb_count=len(lb_data),
        ami_count=len(ami_data)
    )

@app.route("/health")
def health_check():
    """Health check endpoint"""
    return {
        'status': 'healthy',
        'service': 'aws-resources-dashboard',
        'version': '1.0.0',
        'aws_connection': 'ok' if not aws_connection_error else 'error'
    }

if __name__ == "__main__":
    logger.info(f"Starting AWS Resources Dashboard in region {REGION}")
    logger.info(f"AWS Connection Status: {'Connected' if not aws_connection_error else 'Error'}")
    app.run(host="0.0.0.0", port=5001, debug=True)
