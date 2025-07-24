#!/usr/bin/env python3
"""
Main application module for Final Project JB
Demonstrates core functionality implementation
"""

import json
import os

class ProjectManager:
    def __init__(self, config_path="config/project.json"):
        self.config_path = config_path
        self.config = self.load_config()
    
    def load_config(self):
        """Load project configuration from JSON file"""
        try:
            with open(self.config_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Configuration file {self.config_path} not found")
            return {}
    
    def get_project_info(self):
        """Return basic project information"""
        project = self.config.get('project', {})
        return {
            'name': project.get('name', 'Unknown'),
            'version': project.get('version', '0.0.0'),
            'description': project.get('description', 'No description available')
        }
    
    def list_sections(self):
        """List all project sections"""
        return self.config.get('project', {}).get('sections', [])

def main():
    """Main application entry point"""
    print("=== Final Project JB - Core Functionality ===")
    
    pm = ProjectManager()
    info = pm.get_project_info()
    sections = pm.list_sections()
    
    print(f"Project: {info['name']} v{info['version']}")
    print(f"Description: {info['description']}")
    print(f"Sections: {len(sections)}")
    
    for i, section in enumerate(sections, 1):
        print(f"  {i}. {section}")

if __name__ == "__main__":
    main()
