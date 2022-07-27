import requests
import json


response_API = requests.get('https://fromthepage.com/iiif/slave-ledger/structured/475253')
respone_text = response_API.text
parse_json = json.loads(respone_text)
data = parse_json['data']

# how to get every single transaction?
# how to get bk:from or bk:to? 

for datafield in data:
    print(datafield)
    print("\n")
