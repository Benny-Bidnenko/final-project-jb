# API Documentation

## ProjectManager Class

### Constructor
```python
ProjectManager(config_path="config/project.json")
```

Initializes a new ProjectManager instance.

**Parameters:**
- `config_path` (str): Path to the project configuration file

### Methods

#### load_config()
Loads project configuration from the specified JSON file.

**Returns:** dict - Configuration data

#### get_project_info()
Returns basic project information.

**Returns:** dict with keys:
- `name` (str): Project name
- `version` (str): Project version
- `description` (str): Project description

#### list_sections()
Lists all project sections defined in the configuration.

**Returns:** list - List of section names

## Usage Example

```python
from main import ProjectManager

# Initialize project manager
pm = ProjectManager()

# Get project information
info = pm.get_project_info()
print(f"Project: {info['name']} v{info['version']}")

# List sections
sections = pm.list_sections()
for section in sections:
    print(f"- {section}")
```

## Testing

Run tests with:
```bash
python -m pytest tests/
# or
python tests/test_main.py
```
