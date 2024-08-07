import requests
from bs4 import BeautifulSoup
import xml.etree.ElementTree as ET

# URL of the XML document
xml_url = "https://gams.uni-graz.at/archive/risearch?type=tuples&lang=sparql&format=Sparql&query=http%3A%2F%2Ffedora%3A8380%2Farchive%2Fget%2Fcontext%3Adepcha.srbas%2FQUERY%2F2023-03-30T07%3A07%3A21.176Z"

# Fetch the XML document
print("Fetching XML document...")
xml_response = requests.get(xml_url)
if xml_response.status_code != 200:
    print(f"Failed to retrieve the XML document. Status code: {xml_response.status_code}")
    exit()
print("XML document fetched successfully.")

# Parse the XML document
print("Parsing XML document...")
root = ET.fromstring(xml_response.content)
print("XML document parsed successfully.")

# Extract the metadata and 'pid' values
namespace = {'ns': 'http://www.w3.org/2001/sw/DataAccess/rf1/result'}
results = root.findall('.//ns:result', namespace)
metadata_dict = {}

for result in results:
    metadata = {
        'container': result.find('ns:container', namespace).text if result.find('ns:container', namespace) is not None else '',
        'cid': result.find('ns:cid', namespace).text if result.find('ns:cid', namespace) is not None else '',
        'pid': result.find('ns:pid', namespace).attrib['uri'].split('/')[-1] if result.find('ns:pid', namespace) is not None else '',
        'ownerId': result.find('ns:ownerId', namespace).text if result.find('ns:ownerId', namespace) is not None else '',
        'createdDate': result.find('ns:createdDate', namespace).text if result.find('ns:createdDate', namespace) is not None else '',
        'lastModifiedDate': result.find('ns:lastModifiedDate', namespace).text if result.find('ns:lastModifiedDate', namespace) is not None else '',
        'title': result.find('ns:title', namespace).text if result.find('ns:title', namespace) is not None else '',
        'identifier': result.find('ns:identifier', namespace).text if result.find('ns:identifier', namespace) is not None else '',
        'creator': result.find('ns:creator', namespace).text if result.find('ns:creator', namespace) is not None else '',
        'subject': result.find('ns:subject', namespace).text if result.find('ns:subject', namespace) is not None else '',
        'publisher': result.find('ns:publisher', namespace).text if result.find('ns:publisher', namespace) is not None else '',
        'contributor': result.find('ns:contributor', namespace).text if result.find('ns:contributor', namespace) is not None else '',
        'date': result.find('ns:date', namespace).text if result.find('ns:date', namespace) is not None else '',
        'description': result.find('ns:description', namespace).text if result.find('ns:description', namespace) is not None else '',
        'coverage': result.find('ns:coverage', namespace).text if result.find('ns:coverage', namespace) is not None else '',
        'language': result.find('ns:language', namespace).text if result.find('ns:language', namespace) is not None else '',
        'source': result.find('ns:source', namespace).text if result.find('ns:source', namespace) is not None else '',
        'rights': result.find('ns:rights', namespace).text if result.find('ns:rights', namespace) is not None else ''
    }
    pid = metadata['pid']
    if pid not in metadata_dict:
        metadata_dict[pid] = []
    metadata_dict[pid].append(metadata)

print(f"Extracted metadata for {len(metadata_dict)} items.")

# Function to convert HTML element to Markdown
def convert_to_markdown(element):
    if element.name == 'h5':
        return f"## {element.get_text()}\n"
    elif element.name == 'p':
        return f"{element.get_text()}\n"
    elif element.name == 'span':
        return f"{element.get_text()}"
    elif element.name == 'div' and 'page' in element.get('class', []):
        return "\n---\n"  # Page break as horizontal rule
    else:
        return element.get_text(separator=' ')

# Fetch and process each page
base_url = "https://gams.uni-graz.at/archive/objects/"
markdown_results = []

for pid, metadata_list in metadata_dict.items():
    print(f"Processing pid: {pid}")
    page_url = f"{base_url}{pid}/methods/sdef:Object/get?"
    print(f"Fetching page: {page_url}")
    page_response = requests.get(page_url)
    
    if page_response.status_code == 200:
        print(f"Page fetched successfully for {pid}.")
        soup = BeautifulSoup(page_response.text, 'html.parser')
        edition_div = soup.find('div', id='edition')
        
        if edition_div:
            print(f"Found 'edition' div for {pid}.")
            markdown_text = ""
            for child in edition_div.descendants:
                if child.name in ['h5', 'p', 'span', 'div']:
                    markdown_text += convert_to_markdown(child)
            
            cleaned_markdown = '\n'.join(line.strip() for line in markdown_text.splitlines() if line.strip())
            metadata_headers = "\n\n".join(
                [
                    f"### {metadata['title']}\n\n"
                    f"**Container:** {metadata['container']}\n\n"
                    f"**PID:** {metadata['pid']}\n\n"
                    f"**Owner ID:** {metadata['ownerId']}\n\n"
                    f"**Created Date:** {metadata['createdDate']}\n\n"
                    f"**Last Modified Date:** {metadata['lastModifiedDate']}\n\n"
                    f"**Identifier:** {metadata['identifier']}\n\n"
                    f"**Creator:** {metadata['creator']}\n\n"
                    f"**Subject:** {metadata['subject']}\n\n"
                    f"**Publisher:** {metadata['publisher']}\n\n"
                    f"**Contributor:** {metadata['contributor']}\n\n"
                    f"**Date:** {metadata['date']}\n\n"
                    f"**Description:** {metadata['description']}\n\n"
                    f"**Coverage:** {metadata['coverage']}\n\n"
                    f"**Language:** {metadata['language']}\n\n"
                    f"**Source:** {metadata['source']}\n\n"
                    f"**Rights:** {metadata['rights']}\n\n"
                    for metadata in metadata_list
                ]
            )
            full_markdown = metadata_headers + cleaned_markdown
            markdown_results.append(full_markdown)
            print(f"Markdown text for {pid}:\n{full_markdown}\n")
        else:
            print(f"No div with id 'edition' found for {pid}.")
    else:
        print(f"Failed to retrieve the webpage for {pid}. Status code: {page_response.status_code}")

# Combine results
final_markdown = "\n\n---\n\n".join(markdown_results)

# Print the combined Markdown
print("Final combined Markdown:\n")
print(final_markdown)
