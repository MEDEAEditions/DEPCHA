import os
import logging
from lxml import etree

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s:%(message)s')

# Folder containing XML files
folder_path = '/TEI'  # Update this path to your folder

# TEI namespace
NSMAP = {'tei': 'http://www.tei-c.org/ns/1.0'}

# Get list of XML files in the folder
xml_files = [f for f in os.listdir(folder_path) if f.endswith('.xml')]

for filename in xml_files:
    file_path = os.path.join(folder_path, filename)
    logging.info(f'Processing file: {filename}')

    try:
        # Parse the XML file
        tree = etree.parse(file_path)
        root = tree.getroot()

        # Find all elements with @ana containing "bk:rubric"
        xpath_expr = ".//*[@ana[contains(., 'bk:rubric')]]"
        elements = root.xpath(xpath_expr, namespaces=NSMAP)

        logging.info(f'Found {len(elements)} elements with @ana containing "bk:rubric"')

        # Extract the non-"bk:rubric" values from @ana
        rubrics = []
        for elem in elements:
            ana_value = elem.get('ana')
            ana_values = ana_value.split()
            for val in ana_values:
                if val != 'bk:rubric':
                    rubrics.append(val)

        logging.info(f'Extracted rubrics: {rubrics}')

        # Categorize rubrics
        income_rubrics = []
        expense_rubrics = []
        other_rubrics = []

        for rubric in rubrics:
            # Remove leading '#' if present
            rubric_name = rubric.lstrip('#')

            if rubric_name.startswith('Einnahmen_'):
                income_rubrics.append(rubric_name)
            elif rubric_name.startswith('Ausgaben_'):
                expense_rubrics.append(rubric_name)
            else:
                other_rubrics.append(rubric_name)

        logging.info(f'Income rubrics: {income_rubrics}')
        logging.info(f'Expense rubrics: {expense_rubrics}')
        logging.info(f'Other rubrics: {other_rubrics}')

        # Modify the taxonomy structure
        # Find the taxonomy element with ana="bk:account"
        taxonomy = root.find(".//tei:taxonomy[@ana='bk:account']", namespaces=NSMAP)
        if taxonomy is None:
            logging.warning('No taxonomy element with ana="bk:account" found')
            continue

        # Find the income and expense categories
        income_category = taxonomy.find(".//tei:category[@xml:id='income'][@ana='bk:from']", namespaces=NSMAP)
        expense_category = taxonomy.find(".//tei:category[@xml:id='expense'][@ana='bk:to']", namespaces=NSMAP)

        if income_category is None:
            logging.warning('No income category found')
        else:
            # Add income rubrics
            for income_rubric in income_rubrics:
                existing_rubric = income_category.find(f".//tei:category[@xml:id='{income_rubric}']", namespaces=NSMAP)
                if existing_rubric is None:
                    new_cat = etree.SubElement(income_category, '{http://www.tei-c.org/ns/1.0}category', attrib={'xml:id': income_rubric})
                    cat_desc = etree.SubElement(new_cat, '{http://www.tei-c.org/ns/1.0}catDesc')
                    gloss = etree.SubElement(cat_desc, '{http://www.tei-c.org/ns/1.0}gloss')
                    gloss.text = income_rubric
                    logging.info(f'Added income rubric: {income_rubric}')
                else:
                    logging.info(f'Income rubric already exists: {income_rubric}')

        if expense_category is None:
            logging.warning('No expense category found')
        else:
            # Add expense rubrics
            for expense_rubric in expense_rubrics:
                existing_rubric = expense_category.find(f".//tei:category[@xml:id='{expense_rubric}']", namespaces=NSMAP)
                if existing_rubric is None:
                    new_cat = etree.SubElement(expense_category, '{http://www.tei-c.org/ns/1.0}category', attrib={'xml:id': expense_rubric})
                    cat_desc = etree.SubElement(new_cat, '{http://www.tei-c.org/ns/1.0}catDesc')
                    gloss = etree.SubElement(cat_desc, '{http://www.tei-c.org/ns/1.0}gloss')
                    gloss.text = expense_rubric
                    logging.info(f'Added expense rubric: {expense_rubric}')
                else:
                    logging.info(f'Expense rubric already exists: {expense_rubric}')

        # Save the modified XML back to the file
        tree.write(file_path, encoding='UTF-8', xml_declaration=True, pretty_print=True)
        logging.info(f'Modified file saved: {filename}')

    except Exception as e:
        logging.error(f'An error occurred while processing {filename}: {e}')
