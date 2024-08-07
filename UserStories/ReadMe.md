Here is the revised `README.md` with the `Directory Structure` section and references to `requirements.txt` removed:

```markdown
# Scrap Plaintext from DEPCHA

This repository contains a Python script designed to fetch, parse, and process XML data from the GAMS (Geisteswissenschaftliches Asset Management System) platform. The script extracts metadata and content from specified contexts and sub-contexts, converts the content to Markdown format, and saves it to separate files.

## Table of Contents

- [Project Description](#project-description)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Script Explanation](#script-explanation)
  - [Fetching XML Data](#fetching-xml-data)
  - [Parsing XML Data](#parsing-xml-data)
  - [Converting HTML to Markdown](#converting-html-to-markdown)
  - [Processing Each PID](#processing-each-pid)
  - [Saving Markdown Files](#saving-markdown-files)
- [Maintainers](#maintainers)

## Project Description

This project automates the extraction of structured data from the GAMS platform. It processes contexts and sub-contexts, extracts relevant metadata and content, and converts the content into well-structured Markdown files.

## Requirements

- Python 3.x
- `requests` library
- `beautifulsoup4` library
- `lxml` library

## Installation

1. **Clone the repository**:

    ```bash
    git clone https://github.com/your-username/scrap-plaintext-from-depcha.git
    cd scrap-plaintext-from-depcha
    ```

2. **Create and activate a virtual environment (optional but recommended)**:

    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```

3. **Install the required libraries**:

    ```bash
    pip install requests beautifulsoup4 lxml
    ```

## Configuration

No specific configuration is required. Ensure that the URLs in the script match the desired data sources.

## Usage

Run the script using:

```bash
python scrap_plaintext_from_depcha.py
```

### Example

After running the script, you should see output indicating the progress of fetching and processing data. The resulting Markdown files will be saved in the `output_markdowns` directory.

## Script Explanation

### Fetching XML Data

The script starts by fetching the main XML document from the GAMS platform using the provided URL:

```python
main_xml_url = "https://gams.uni-graz.at/archive/risearch?type=tuples&lang=sparql&format=Sparql&query=http%3A%2F%2Ffedora%3A8380%2Farchive%2Fget%2Fcontext%3Adepcha%2FQUERY%2F2023-03-29T10%3A33%3A37.976Z"
main_xml_response = requests.get(main_xml_url)
```

### Parsing XML Data

The XML document is then parsed to extract metadata and `pid` values:

```python
main_root = ET.fromstring(main_xml_response.content)
```

### Converting HTML to Markdown

A helper function converts HTML elements to Markdown format:

```python
def convert_to_markdown(element):
    # Conversion logic here
```

### Processing Each PID

For each `pid`, the script fetches the associated webpage and extracts the content from the `div` with the id `edition`:

```python
def process_pid(pid):
    # Fetch and process content
```

### Saving Markdown Files

The extracted content and metadata are formatted into Markdown and saved to files:

```python
output_directory = "output_markdowns"
# Save logic here
```