import os
import logging
from lxml import etree

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s:%(message)s')

# Folder containing XML files
folder_path = '../TEI'  # Update this path to your folder

# TEI namespace and xml namespace
NS_TEI = 'http://www.tei-c.org/ns/1.0'
NS_XML = 'http://www.w3.org/XML/1998/namespace'

# Namespace map with default namespace (no prefix)
NSMAP = {
    None: NS_TEI,  # Default namespace
    'xml': NS_XML
}

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
        elements = root.xpath(xpath_expr)

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

        # Initialize a new taxonomy root element
        new_taxonomy = etree.Element('taxonomy', ana='bk:account', nsmap=NSMAP)

        # Create main categories
        account_holder = etree.SubElement(
            new_taxonomy,
            'category',
            ana='depcha:accountHolder',
            attrib={'{%s}id' % NS_XML: 'aldersbach'}
        )
        cat_desc = etree.SubElement(account_holder, 'catDesc')
        gloss = etree.SubElement(cat_desc, 'gloss')
        gloss.text = 'Aldersbach'

        income_category = etree.SubElement(
            new_taxonomy,
            'category',
            ana='bk:from',
            attrib={'{%s}id' % NS_XML: 'income'}
        )
        cat_desc = etree.SubElement(income_category, 'catDesc')
        gloss = etree.SubElement(cat_desc, 'gloss')
        gloss.text = 'Einnahme'

        expense_category = etree.SubElement(
            new_taxonomy,
            'category',
            ana='bk:to',
            attrib={'{%s}id' % NS_XML: 'expense'}
        )
        cat_desc = etree.SubElement(expense_category, 'catDesc')
        gloss = etree.SubElement(cat_desc, 'gloss')
        gloss.text = 'Ausgaben'

        # Add the 'Other' category
        other_category = etree.SubElement(
            new_taxonomy,
            'category',
            ana='bk:other',
            attrib={'{%s}id' % NS_XML: 'other'}
        )
        cat_desc = etree.SubElement(other_category, 'catDesc')
        gloss = etree.SubElement(cat_desc, 'gloss')
        gloss.text = 'Other'

        # Add income rubrics
        for income_rubric in income_rubrics:
            existing_rubric = income_category.find(
                f".//category[@{{{NS_XML}}}id='{income_rubric}']"
            )
            if existing_rubric is None:
                new_cat = etree.SubElement(
                    income_category,
                    'category',
                    attrib={'{%s}id' % NS_XML: income_rubric}
                )
                cat_desc = etree.SubElement(new_cat, 'catDesc')
                gloss = etree.SubElement(cat_desc, 'gloss')
                gloss.text = income_rubric
                logging.info(f'Added income rubric: {income_rubric}')
            else:
                logging.info(f'Income rubric already exists: {income_rubric}')

        # Add expense rubrics
        for expense_rubric in expense_rubrics:
            existing_rubric = expense_category.find(
                f".//category[@{{{NS_XML}}}id='{expense_rubric}']"
            )
            if existing_rubric is None:
                new_cat = etree.SubElement(
                    expense_category,
                    'category',
                    attrib={'{%s}id' % NS_XML: expense_rubric}
                )
                cat_desc = etree.SubElement(new_cat, 'catDesc')
                gloss = etree.SubElement(cat_desc, 'gloss')
                gloss.text = expense_rubric
                logging.info(f'Added expense rubric: {expense_rubric}')
            else:
                logging.info(f'Expense rubric already exists: {expense_rubric}')

        # Add other rubrics
        for other_rubric in other_rubrics:
            existing_rubric = other_category.find(
                f".//category[@{{{NS_XML}}}id='{other_rubric}']"
            )
            if existing_rubric is None:
                new_cat = etree.SubElement(
                    other_category,
                    'category',
                    attrib={'{%s}id' % NS_XML: other_rubric}
                )
                cat_desc = etree.SubElement(new_cat, 'catDesc')
                gloss = etree.SubElement(cat_desc, 'gloss')
                gloss.text = other_rubric
                logging.info(f'Added other rubric: {other_rubric}')
            else:
                logging.info(f'Other rubric already exists: {other_rubric}')

        # Write the new taxonomy to a new XML file with the modified filename
        output_filename = os.path.splitext(filename)[0] + '-taxonomy.xml'
        output_file_path = os.path.join(folder_path, output_filename)
        with open(output_file_path, 'wb') as f:
            f.write(etree.tostring(new_taxonomy, encoding='UTF-8', xml_declaration=True, pretty_print=True))
        logging.info(f'New taxonomy saved to: {output_filename}')

    except Exception as e:
        logging.error(f'An error occurred while processing {filename}: {e}')
