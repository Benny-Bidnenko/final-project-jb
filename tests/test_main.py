#!/usr/bin/env python3
"""
Unit tests for the main application module
"""

import unittest
import json
import os
import sys
import tempfile

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from main import ProjectManager

class TestProjectManager(unittest.TestCase):
    
    def setUp(self):
        """Set up test fixtures"""
        self.test_config = {
            "project": {
                "name": "Test Project",
                "version": "1.0.0",
                "description": "Test project description",
                "sections": ["section1", "section2", "section3"]
            }
        }
        
        # Create temporary config file
        self.temp_config = tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.json')
        json.dump(self.test_config, self.temp_config)
        self.temp_config.close()
        
        self.pm = ProjectManager(self.temp_config.name)
    
    def tearDown(self):
        """Clean up test fixtures"""
        os.unlink(self.temp_config.name)
    
    def test_load_config(self):
        """Test configuration loading"""
        self.assertEqual(self.pm.config, self.test_config)
    
    def test_get_project_info(self):
        """Test project info retrieval"""
        info = self.pm.get_project_info()
        expected = {
            'name': 'Test Project',
            'version': '1.0.0',
            'description': 'Test project description'
        }
        self.assertEqual(info, expected)
    
    def test_list_sections(self):
        """Test section listing"""
        sections = self.pm.list_sections()
        expected = ["section1", "section2", "section3"]
        self.assertEqual(sections, expected)
    
    def test_missing_config_file(self):
        """Test handling of missing config file"""
        pm = ProjectManager("nonexistent.json")
        self.assertEqual(pm.config, {})
        
        info = pm.get_project_info()
        self.assertEqual(info['name'], 'Unknown')
        self.assertEqual(info['version'], '0.0.0')

if __name__ == '__main__':
    unittest.main()
