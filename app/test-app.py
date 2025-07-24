#!/usr/bin/env python3
"""
Test script for the AWS Resources Dashboard
Tests the application locally before Docker deployment
"""

import os
import sys
import unittest
from unittest.mock import patch, MagicMock

# Add current directory to path for imports
sys.path.insert(0, os.path.dirname(__file__))

class TestAWSApp(unittest.TestCase):
    
    def setUp(self):
        """Set up test environment"""
        os.environ['AWS_ACCESS_KEY_ID'] = 'test-key'
        os.environ['AWS_SECRET_ACCESS_KEY'] = 'test-secret'
    
    def tearDown(self):
        """Clean up test environment"""
        if 'AWS_ACCESS_KEY_ID' in os.environ:
            del os.environ['AWS_ACCESS_KEY_ID']
        if 'AWS_SECRET_ACCESS_KEY' in os.environ:
            del os.environ['AWS_SECRET_ACCESS_KEY']
    
    @patch('boto3.Session')
    def test_app_with_credentials(self, mock_session):
        """Test app behavior with valid credentials"""
        # Mock AWS responses
        mock_ec2_client = MagicMock()
        mock_elb_client = MagicMock()
        
        mock_ec2_client.describe_regions.return_value = {}
        mock_ec2_client.describe_instances.return_value = {
            'Reservations': [{
                'Instances': [{
                    'InstanceId': 'i-12345678',
                    'State': {'Name': 'running'},
                    'InstanceType': 't3.medium',
                    'PublicIpAddress': '1.2.3.4'
                }]
            }]
        }
        mock_ec2_client.describe_vpcs.return_value = {
            'Vpcs': [{
                'VpcId': 'vpc-12345678',
                'CidrBlock': '10.0.0.0/16'
            }]
        }
        mock_elb_client.describe_load_balancers.return_value = {
            'LoadBalancers': []
        }
        mock_ec2_client.describe_images.return_value = {
            'Images': []
        }
        
        mock_session_instance = MagicMock()
        mock_session_instance.client.side_effect = lambda service: {
            'ec2': mock_ec2_client,
            'elbv2': mock_elb_client
        }[service]
        
        mock_session.return_value = mock_session_instance
        
        # Import and test app
        from app import app
        
        with app.test_client() as client:
            response = client.get('/')
            self.assertEqual(response.status_code, 200)
            self.assertIn(b'AWS Resources Dashboard', response.data)
            self.assertIn(b'i-12345678', response.data)
    
    def test_app_without_credentials(self):
        """Test app behavior without credentials"""
        # Remove credentials
        if 'AWS_ACCESS_KEY_ID' in os.environ:
            del os.environ['AWS_ACCESS_KEY_ID']
        if 'AWS_SECRET_ACCESS_KEY' in os.environ:
            del os.environ['AWS_SECRET_ACCESS_KEY']
        
        # Import app (this will trigger the connection error)
        from app import app
        
        with app.test_client() as client:
            response = client.get('/')
            self.assertEqual(response.status_code, 200)
            self.assertIn(b'AWS Connection Error', response.data)
    
    def test_health_endpoint(self):
        """Test health check endpoint"""
        from app import app
        
        with app.test_client() as client:
            response = client.get('/health')
            self.assertEqual(response.status_code, 200)
            self.assertIn(b'status', response.data)

if __name__ == '__main__':
    print("🧪 Testing AWS Resources Dashboard...")
    unittest.main(verbosity=2)
