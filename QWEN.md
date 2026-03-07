# Scriptorium Project Overview

## Project Type
This is a documentation and content management repository that contains:
1. A collection of HTML-based documents and infographics on AI development frameworks
2. A Python script for generating Confluence space content reports

## Directory Structure
- `/docs` - Contains HTML documents and infographics on AI development topics
- `/manage-spaces` - Contains a Python script for Confluence content analysis

## Key Components

### Documentation Portal (`/docs`)
A self-contained HTML-based documentation portal with:
- `index.html` - Main entry point that dynamically lists available documents
- `manifest.json` - Lists all available HTML documents
- Multiple HTML documents on AI development frameworks and methodologies
- A color palette converter tool (`paletteConverter.html`)

The documentation uses Tailwind CSS for styling and Chart.js for data visualizations. The portal is designed to be hosted statically and fetches document lists from the manifest file.

### Confluence Management (`/manage-spaces`)
A Python script (`confluence_space_report.py`) that:
- Connects to Confluence REST API
- Fetches all content from a specified space
- Classifies content by age (YTD, 1 year, 2 years, etc.)
- Identifies content created by deprecated accounts
- Generates an HTML report grouped by content age and account status

## Technologies Used
- HTML/CSS/JavaScript for documentation
- Tailwind CSS framework
- Chart.js for data visualizations
- Python for Confluence API integration
- Jinja2 for HTML templating
- Requests library for HTTP requests

## Development Conventions
- Uses standard Python project structure with a comprehensive .gitignore
- HTML documents follow a consistent styling approach with a defined color palette
- Python script follows standard conventions with configuration sections, helper functions, and main logic
- All content is released under the Unlicense (public domain)

## Building and Running

### Documentation Portal
The documentation portal is static HTML and can be served directly:
```bash
# Serve locally with any HTTP server
python -m http.server 8000 --directory docs
# Then open http://localhost:8000
```

### Confluence Report Generator
To run the Confluence report generator:
```bash
# Install dependencies
pip install requests jinja2

# Run the script (requires Confluence API credentials)
python manage-spaces/confluence_space_report.py [SPACE_KEY]
```

Note: The script requires Confluence API credentials (email and API token) to be configured in the script before running.

## License
This project is released into the public domain under the Unlicense. All content can be freely used, modified, and distributed for any purpose.