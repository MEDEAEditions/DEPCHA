#import csv
from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.namespace import DCTERMS, RDF, RDFS, SKOS, XSD
import re
import pandas as pd
import json
import hashlib
import glob
import re
from locale import atof, setlocale, LC_NUMERIC
import math
from datetime import datetime, date
import numpy as np
import dateutil.parser

# https://stackoverflow.com/questions/6633523/how-can-i-convert-a-string-with-dot-and-comma-into-a-float-in-python
# . and , in float numbers depending on default locale
setlocale(LC_NUMERIC, '') 


########################################################################################
# VARIABLES
count_transactions = 0
count_totals = 0
count_transfers = 0
count_moneys = 0
count_commodities = 0
count_services = 0
count_rights = 0
count_EconomicUnits = 0

########################################################################################
# FUNCTIONS

########################################################################################
# substring before " ("; remove ", " and  " " so its a valid URI
def normalizeStringforURI(string):
     if(str(name).count(",") <= 1):
        if(" (" in string):
            return ((string.split(" (")[0]).replace(", ", "")).replace(" ", "")  
        else:
            return (string.replace(", ", "")).replace(" ", "")  
     else:
            return "anonym"

########################################################################################
# 
def normalizeStringforJSON(string):
    string = string.replace('"', '\\"')
    string = " ".join(string.split())
    return string 
        
########################################################################################
# creates a bk:Money and add bk:unit (uri) and bk:quantity (literal)
# param: getBKMoney(URIRef(), double, string)
# <bk:Transfer> <bk:transfers> <bk:Money rdf:about="https://gams.uni-graz.at/o:depcha.gwfp.3#T220M1">
def get_Money(Measurable_Money, bk_quantity, bk_unit_index, Transfer): 
    try:
        if(pd.notnull(bk_quantity)):
            output_graph.add((Measurable_Money, RDF.type,  BK.Money))
            output_graph.add((Transfer, BK.transfers, Measurable_Money))
            global count_moneys
            count_moneys += 1
            # <bk:quantity>
            # make some string operators to fix ","  and whitspaces to make valid floats
            output_graph.add((Measurable_Money, BK.quantity, Literal(float(str(bk_quantity).replace(' ','').replace(',','.')))))
            for currency in config_data["BK_CURRENCY"]["currency"]:
                if(currency.get("id") == bk_unit_index):
                    bk_unit = currency.get("unit")        
            output_graph.add((Measurable_Money, BK.unit, URIRef(BASE_URL + CONTEXT + "#" + bk_unit) ))
            
            if(pd.notnull(row["bk_when"]) and pd.notnull(row["bk_debit_credit"])):
                try:
                    normalized_date = dateutil.parser.parse(row["bk_when"], default=datetime(1000, 1, 1))
                    if(normalized_date.date().year != 1000):
                        year = normalized_date.date().strftime("%Y")
                        
                        # select the income_db|expense_db via year as key and depending on bk:debit|bk:credit 
                        # add {bk_unit : bk_quantity} to the list; from this list the sum for every year can be calculated
                        debitOrCredit = row['bk_debit_credit']
                        if re.search('debit', debitOrCredit, re.IGNORECASE):
                            income_db[year].append({bk_unit : bk_quantity} )
                        elif re.search('credit', debitOrCredit, re.IGNORECASE):
                            expense_db[year].append({bk_unit : bk_quantity} )
                        else:
                            False
            #Debug_DebitCreditEmptyCell += 1     
                except:
                    print(f"Exception: failed to add money and unit to key YYYY-MM: {bk_quantity} {bk_unit}")
    except:
        print(f"Exception: no valid number in BK_MONEY: Currencies must not contain commas, spaces, or characters: {bk_quantity}")
    # <bk:unit>  https://gams.uni-graz.at/context:depcha.gwfp#pence
                                                    
########################################################################################
# this function add bk:entry, gams:isMemberOfCollection to the output_graph
# param: URIRef() of the bk:Transaction
def getBKCoreElements(Class):
    # replace " with ' as the JSON output in DEPCHA has problems with it; replace "VT" in CSV with " "
    # in the csv are VT (vertical tabs; \u000B) String newString = oldString.replace('\u000B', ' ');
    
    if('bk_entry' in df.columns):
        # " --> ' ;  tab --> " "  ; newline --> " ", vertical tabs; \u000B --> " "; normalize whitespaces with strip
        normalizedEntry = row["bk_entry"].replace('"',"'").replace('\n', ' ').replace('\t', ' ').replace('\u000B', ' ').strip()
        output_graph.add((Class, BK.entry, Literal(normalizedEntry) )) 
    output_graph.add((Class, GAMS.isMemberOfCollection, URIRef(BASE_URL + CONTEXT) )) 
    output_graph.add((Class, GAMS.isPartOf, URIRef(BASE_URL + PID) )) 


########################################################################################
# creats <bk:debit> or <bk:credit> marking a transfer as debit or credit; contains string that identifies transfer as debit or credit in the source
# todo: bk_debit column, bk:credit column
def getCreditOrDebit(Transfer):
    if(pd.notnull(row["bk_debit_credit"])):
        debitOrCredit = row['bk_debit_credit']
        if re.search('debit', debitOrCredit, re.IGNORECASE):
            output_graph.add((Transfer, BK.debit,  Literal(debitOrCredit) ))
        elif re.search('credit', debitOrCredit, re.IGNORECASE):
            output_graph.add((Transfer, BK.credit,  Literal(debitOrCredit) ))
        else:
            False
            #Debug_DebitCreditEmptyCell += 1

########################################################################################
'''
def createTransferOfMoney(Transaction_URI, Transaction):
    #<bk:Transfer> <bk:transfers> <bk:Money>
    if('bk_money' in df.columns):
        if(pd.notnull(row["bk_money"])):
            # selects all coumns bk_money, bk_money1 ... it is assumed that the first bk_money is the main currency
            monetaryValues = row.filter(like='bk_money')
            # <bk:Transfer>
            Transfer = URIRef(Transaction_URI + "TM")
            output_graph.add((Transaction, BK.consistsOf,  Transfer))
            output_graph.add((Transfer, RDF.type, BK.Transfer))
            global count_transfers
            count_transfers = count_transfers + 1
            
            ### for all cells with content in columns name bk_money
            for count, bk_quantity in enumerate(monetaryValues):
                global count_moneys
                count_moneys = count_moneys + 1
                get_Money(URIRef(Transaction_URI + "M" + str(count)), bk_quantity, str(count), Transfer)

            ### <bk:debit>, <bk:credit>
            getCreditOrDebit(Transfer) 
            ##################
            ### bk:from, bk:to
            getFromOrTo(Transfer)
'''               
########################################################################################
#
# 
def getFromOrTo(Transfer):
    if(pd.notnull(row["bk_economic_unit"])):
        #EconomicUnit_URI = BASE_URL + PID + str(normalized_name)
        EconomicUnit_URI = BASE_URL + PID + normalizeStringforURI(row["bk_economic_unit"])
        EconomicUnit = URIRef(EconomicUnit_URI)
        # check the already graph pattern if the current transfer has bk:debit or bk:credit
        # if bk:debit than Washington is getting money
        # A debit entry in an account represents a transfer of value to that account
        if (Transfer, BK.debit, None) in output_graph:
            output_graph.add((Transfer, BK.to, BK_MAIN_ECONOMIC_UNIT_URI))
            output_graph.add((Transfer, BK_from_property, EconomicUnit)) 
        # if bk:credit than Washington is spending money
        # and a credit entry represents a transfer from the account.
        elif (Transfer, BK.credit, None) in output_graph:
            output_graph.add((Transfer, BK.to,  EconomicUnit))
            output_graph.add((Transfer, BK_from_property, BK_MAIN_ECONOMIC_UNIT_URI ))  
        else:
            False
            #Debug_FromToEmpty += 1
    
########################################################################################
# returns conversion according to main currency depending on conversion info in confic file
#  * checks is quantitiy is 0 or invalid or transforms "2,5" to valid float "2.5"
def convert_Money_to_MainCurrency(quantity, unit):
    
    # TODO: skip second currency for now: add a second bk:IncomeStmt with its bk:unit and bk:
    # !!!
    if(unit == "pound" or unit == "shilling" or unit == "pence"):
        BK_MAIN_CURRENCY = config_data["BK_CURRENCY"]["currency"][0]
        # catch if quantity is not castable as float --> return 0
        converted_quantity = ""
        try:
            converted_quantity = quantity.replace(" ", "")
            if("," in converted_quantity):
                converted_quantity = converted_quantity.replace(",", ".")
                
            # catch if quantity = 0
            if(float(converted_quantity) > 0):
                for currency in config_data["BK_CURRENCY"]["currency"]:
                    if(unit == currency["unit"]):
                        try:
                            # $BaseUnit / 20; $BaseUnit / 240
                            conversionDivisor = (currency["conversion"]["formular"]).split("/ ", 1)[1]
                            return float(converted_quantity) / float(conversionDivisor)
                        except:
                            #print(f"Exception: {currency['unit']}")
                            return float(converted_quantity)
            else:
                return 0.0
        except:
            #print(f"Exception: invalid quantitiy '{converted_quantity}' in converting to main currency")
            return 0.0
    else:
        return 0.0
########################################################################################
#
#     
def add_Quantity_To_Sum(sum_, quantity, ConversionValue):
    try:
        sum_ += atof(quantity)/ConversionValue
        return sum_
    except:
        print("Exception: Not a valid number in add_Quantity_To_Sum function")


########################################################################################
# This function checks which kind of measurable is going to be created.
# case 1: there is a BK_WHAT and BK_QUANTITY
# case 2: there is a BK_MONEY
# case 3: there is a BK_COMMODITY|BK_SERVICE
def createTransferOfMeasurable(Transaction_URI, Transaction):
    # <bk:Transfer rdf:about="https://gams.uni-graz.at/o:depcha.gwfp.3#T891TM">
    Transfer = URIRef(Transaction_URI + "TM")
    output_graph.add((Transaction, BK.consistsOf,  Transfer))
    output_graph.add((Transfer, RDF.type, BK.Transfer))
    
    global count_transfers
    count_transfers = count_transfers + 1    
    
    # case 1: there is a BK_WHAT and BK_QUANTITY
    if('bk_what' in df.columns and 'bk_quantity' in df.columns):
        # selects all columns bk_what
        all_bk_what = row.filter(like='bk_what')
        # create a bk:Measurable with a bk:quantity
        for count, bk_what in enumerate(all_bk_what):
            Measurable = URIRef(Transaction_URI + "M" + str(count))
            output_graph.add((Measurable, RDF.type, BK.Measurable))
            output_graph.add((Transfer, BK.transfers, Measurable))
            output_graph.add((Measurable, BK.what, Literal(str(row["bk_what"]))))
            if(pd.notnull(row["bk_quantity"])):
                output_graph.add((Measurable, BK.quantity, Literal(row["bk_quantity"])))
          
    # case 2: there is a BK_MONE   
    # removed this "and pd.notnull(row["bk_money"]" ist that a problem? 
    if('bk_money' in df.columns):
        # selects all columns bk_money, bk_money1 ... it is assumed that the first bk_money is the main currency
        monetaryValues = row.filter(like='bk_money')
        # <bk:Transfer>
        #Transfer = URIRef(Transaction_URI + "TM")
        #output_graph.add((Transaction, BK.consistsOf,  Transfer))
        #output_graph.add((Transfer, RDF.type, BK.Transfer))

        ### for all cells with content in columns name bk_money
        for count, bk_quantity in enumerate(monetaryValues):
            get_Money(URIRef(Transaction_URI + "M" + str(count)), bk_quantity, str(count), Transfer)

        ### <bk:debit>, <bk:credit>
        getCreditOrDebit(Transfer) 
        ##################
        ### bk:from, bk:to
        getFromOrTo(Transfer)  

########################################################################################















########################################################################################
### MAIN
########################################################################################
# VARIABLES
Debug_CountEmptyRow = 0
Debug_DebitCreditEmptyCell = 0
Debug_FromToEmpty = 0
Debug_missedTotal = 0
Debug_CurrencyInformation = "BK_CURRENCY: check"
Debug_Count_No_BK_ENTRY = 0

# this programm iterate over all .json (=confic files) in a folder --> getting info like filename of the.csv
# the .csv is loaded and every row is mapped to a RDF-Serialization pf a bk:Transaction.

folder = "gwfp"
file_extension = ".json"
# csvToRDF_config__Ledger_C
config_json_filename = "csvToRDF_config__Ledger_minimal"

###
# get all JSON confic files in a folder
# for a single file: 
#all_JSON_filenames = [i for i in glob.glob(f"{folder}/{config_json_filename}{file_extension}")]
all_JSON_filenames = [i for i in glob.glob(f"{folder}/*{file_extension}")]
########################################################################################
for json_file in all_JSON_filenames:
    # open confic file
    with open(json_file) as json_config_file:
        config_data = json.load(json_config_file)

    df = pd.read_csv(open(folder + "/" + config_data["FILENAME"], encoding="utf8"))
    
    # normalize all colum names to bk_entry etc. [for JSON query result in DEPCHA needed!]
    df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_').str.replace('(', '').str.replace(')', '')


    ##############################
    ### define variables for RDF graph
    BK = Namespace("https://gams.uni-graz.at/o:depcha.bookkeeping#")
    GAMS = Namespace("https://gams.uni-graz.at/o:gams-ontology#") 
    OM = Namespace("http://www.ontology-of-units-of-measure.org/resource/om-2/")
    VOID = Namespace("http://rdfs.org/ns/void#")
    FOAF = Namespace("http://xmlns.com/foaf/spec/")
    DCTERMS = Namespace("http://purl.org/dc/terms/")
    DEPCHA = Namespace("https://gams.uni-graz.at/o:depcha.ontology#")
    BASE_URL = "https://gams.uni-graz.at/"
    DC = Namespace("http://purl.org/dc/elements/1.1/")
    
    # make a graph
    output_graph = Graph()
    # define namespace in output file
    output_graph.bind("bk", BK)
    output_graph.bind("gams", GAMS)
    output_graph.bind("om", OM)
    output_graph.bind("void", VOID)
    output_graph.bind("foaf", FOAF)
    output_graph.bind("dcterms", DCTERMS)
    output_graph.bind("dc", DC)
    output_graph.bind("depcha", DEPCHA)

    #############################
    ### load data from confic file
    CONTEXT = config_data["CONTEXT"]
    PID = config_data["PID"]
    BK_MAIN_ECONOMIC_UNIT_LABEL = config_data["BK_MAIN_ECONOMIC_UNIT_LABEL"]
    BK_MAIN_ECONOMIC_UNIT_URI = URIRef(BASE_URL + CONTEXT + "#" + config_data["BK_MAIN_ECONOMIC_UNIT_ID"])
    # the first currency ist the main currency
    BK_MAIN_CURRENCY = config_data["BK_CURRENCY"]["currency"][0]

    # from is reserved term in python
    BK_from_property = URIRef("https://gams.uni-graz.at/o:depcha.bookkeeping#from")

    #
    count_transactions = 0
    count_totals = 0
    count_transfers = 0
    count_moneys = 0
    count_commodities = 0
    count_services = 0
    count_economic_units = 0

    ########################################################################################
    ### https://www.w3.org/TR/void/
    ########################################################################################
    VOID_Dataset = URIRef(BASE_URL + PID)
    output_graph.add((VOID_Dataset, RDF.type, VOID.Dataset ))
    # foaf
    output_graph.add((VOID_Dataset, FOAF.homepage, URIRef(BASE_URL + PID)))
    # generated
    output_graph.add((VOID_Dataset, DCTERMS.modified, Literal(date.today())))
    # void 
    output_graph.add((VOID_Dataset, VOID.feature, URIRef("http://www.w3.org/ns/formats/RDF_XML")))
    output_graph.add((VOID_Dataset, VOID.dataDump, URIRef(BASE_URL + PID  + "/ONTOLOGY")))
    output_graph.add((VOID_Dataset, VOID.vocabulary, URIRef("https://gams.uni-graz.at/o:depcha.bookkeeping#")))
    output_graph.add((VOID_Dataset, VOID.vocabulary, URIRef("https://gams.uni-graz.at/o:gams-ontology#")))
    output_graph.add((VOID_Dataset, VOID.vocabulary, URIRef("http://xmlns.com/foaf/spec/")))
    output_graph.add((VOID_Dataset, VOID.vocabulary, URIRef("http://purl.org/dc/terms/")))
    output_graph.add((VOID_Dataset, VOID.vocabulary, URIRef("http://www.ontology-of-units-of-measure.org/resource/om-2/")))
    output_graph.add((VOID_Dataset, VOID.triples, Literal(0)))
    if(config_data["DEPCHA_DATASET_DC_METADATA"]):
        output_graph.add((VOID_Dataset, DC.title, Literal( config_data["DEPCHA_DATASET_DC_METADATA"]["title"] )))
        output_graph.add((VOID_Dataset, DC.creator, Literal( config_data["DEPCHA_DATASET_DC_METADATA"]["creator"] ) ))
        output_graph.add((VOID_Dataset, DC.date, Literal( config_data["DEPCHA_DATASET_DC_METADATA"]["date"] ) ))
        output_graph.add((VOID_Dataset, DC.contributor, Literal( config_data["DEPCHA_DATASET_DC_METADATA"]["contributor"] ) ))
        output_graph.add((VOID_Dataset, DC.language, Literal( config_data["DEPCHA_DATASET_DC_METADATA"]["language"] ) ))
        output_graph.add((VOID_Dataset, DC.source, Literal( config_data["DEPCHA_DATASET_DC_METADATA"]["source"] ) ))
        output_graph.add((VOID_Dataset, DC.subject, Literal( config_data["DEPCHA_DATASET_DC_METADATA"]["subject"] ) ))
        # static metadata
        output_graph.add((VOID_Dataset, DC.relation, Literal( "Digital Edition Publishing Cooperative for Historical Accounts" ) ))
        output_graph.add((VOID_Dataset, DC.relation, Literal( "http://gams.uni-graz.at/depcha" ) ))
        output_graph.add((VOID_Dataset, DC.publisher, Literal( "Institute Centre for Information Modelling, University of Graz" ) ))
        output_graph.add((VOID_Dataset, DC.rights, Literal( "Creative Commons BY 4.0" ) ))
        output_graph.add((VOID_Dataset, DC.rights, Literal( "https://creativecommons.org/licenses/by/4.0" ) ))
        #output_graph.add((VOID_Dataset, DC.format, Literal( "rdf+xml" ) ))

        
    ########################################################################################
    ### Distinct bk:EconomicUnit
    ########################################################################################
    # * if a bk_EconomicUnit column exists create a distinct set of <bk:EconomicUnit>
    # * therwise make a distinct list of all entries in the BK_FROM and BK:TO column   
    
    # todo bk:Group, bk:Individual
    if(BK_MAIN_ECONOMIC_UNIT_URI):
        output_graph.add((BK_MAIN_ECONOMIC_UNIT_URI, RDF.type,  BK.EconomicUnit))
        output_graph.add((BK_MAIN_ECONOMIC_UNIT_URI , RDFS.label,  Literal(normalizeStringforJSON(BK_MAIN_ECONOMIC_UNIT_LABEL)) ))
        count_economic_units += 1
    
      
    if('bk_economic_unit' in df.columns):
        print("in column")
        for name in df.bk_economic_unit.unique():
            # normalize for URI
            if(type(name)==str):
                normalized_name = normalizeStringforURI(name)
                EconomicUnit_URI = BASE_URL + PID + str(normalized_name)
                EconomicUnit = URIRef(EconomicUnit_URI)
                output_graph.add((EconomicUnit, RDF.type,  BK.EconomicUnit))
                output_graph.add((EconomicUnit , RDFS.label,  Literal(normalizeStringforJSON(name)) ))
                count_economic_units += 1
        print("Log: distinct bk_EconomicUnit ... check") 
    elif('bk_to' in df.columns or 'bk_from' in df.columns):
        print("yes")
    else:
        print("Log: was not able to create distinct BK.EconomicUnit")    

    
    # bk:EconomicUnit
    # multiple names in column, seperator from forename and surname is the same as seperator from names
    # hack: if 1 or less , than its just on name or cash or orgName
         
    ########################################################################################
    ### data structure which contains sums for income/expense fpr each year
    income_db = {}
    expense_db = {}
    
    ########################################################################################
    ### Distinct dates
    ########################################################################################
    # define a set with all dates from bk_when column
    #  * 10 March 1772 --> 1772-03-10
    #  * March 1772 --> 1772-03-01
    #  * 1772 --> 1772-01-01
    #  * skip empty cells; catch invalid dates; make 1000-01-01 default and skip it  
    #  * fill  income_db|expense_db with they years as key 
    dates = set()
    for date_string in df.bk_when:
        if(pd.notnull(date_string)):
            try:
                normalized_date = dateutil.parser.parse(date_string, default=datetime(1000, 1, 1))
                if(normalized_date.date().year != 1000):
                    #dates.add(normalized_date.date().strftime("%Y-%m"))
                    year = normalized_date.date().strftime("%Y")
                    dates.add(year)
                    income_db[year] = []
                    expense_db[year] = []
            except:
                print(f"Exception: invalid date {date_string}")            
    print("Log: Distinct dates ... check")
                
    ########################################################################################
    ### <bk:Transaction>
    ########################################################################################   
    # iterate over all rows; every row is a bk:Transaction or bk:Total 
    for index, row in df.iterrows():
        
        ### TODO: row with "Carried to" or "[Total]" or "Amount brought over" must be exluded or explicitly defined
        # a bk_Transaction is not a "[Total]" and has a date
        if('bk_entry' in df.columns):
            try:
                if ( pd.notnull(row["bk_entry"]) and not "[Total]" in str(row["bk_entry"]) and
                    (not "Carried to" in row["bk_entry"]) and (not "Amount brought over" in row["bk_entry"])):
                    ### <bk:Transaction>
                    Transaction_URI = BASE_URL + PID + "#T" + str(index)
                    Transaction = URIRef(Transaction_URI)
                    output_graph.add((Transaction, RDF.type,  BK.Transaction))
                    # count
                    count_transactions = count_transactions + 1
                    ### <bk:entry>, <gams:isMemberOfCollection>
                    getBKCoreElements(Transaction)
                    ### <bk:Transfer> <bk:Money>
                    createTransferOfMeasurable(Transaction_URI, Transaction)
                    #ToDo
                    ### bk:Transfer of Commodity
                    #if(pd.notnull(row.get["bk_commodity"])):
                    #    print("todo")
                        
                    ### bk:Transfer of Service
                    #if(pd.notnull(row["bk_service"])):
                    #    print("todo")
                    
                #########################################
                # GWFP: [Total] in bk:entry marks bk:Total, Todo optional row.BK_TOTAL ?
                elif ("[Total]" in str(row["bk_entry"])):  
                    ### <bk:Total>
                    Total_URI = BASE_URL + PID + "#To" + str(index)
                    Total = URIRef(Total_URI)
                    output_graph.add((Total, RDF.type,  BK.Total))
                    # count
                    count_totals = count_totals + 1
                    
                    ### <bk:entry>, <gams:isMemberOfCollection>
                    getBKCoreElements(Total)
                    ### <bk:Transfer> <bk:Money>
                    createTransferOfMeasurable(Total_URI, Total)
                    
                #########################################
                else:
                    Debug_CountEmptyRow += 1         
                    #print("Log: bk:Transactions|bk:Total ... check")
            except:
                Debug_Count_No_BK_ENTRY += 1 
                #print(f"Exception: No BK_ENTRY.")
                    
        #########################################   
        # there is only a BK_ID and not BK_ENTRY to identify a transaction
        # BK_ID is part of the URI
        if('bk_id' in df.columns):
            ### <bk:Transaction>
            Transaction_URI = BASE_URL + PID + "#T" + str(row["bk_id"])
            Transaction = URIRef(Transaction_URI)
            output_graph.add((Transaction, RDF.type,  BK.Transaction))
            # count
            count_transactions = count_transactions + 1
            ### <bk:entry>, <gams:isMemberOfCollection>
            getBKCoreElements(Transaction)
            createTransferOfMeasurable(Transaction_URI, Transaction)
    
    
        ### <bk:when>
        # try to parse string with dateutil and get YYYY-MM-DD
        if('bk_when' in df.columns):
            if(pd.notnull(row["bk_when"])):
                try:
                    # if more than two words try to parse the %Y-%m-%d - date
                    if(len(row['bk_when'].split()) > 2):
                        normalized_date = dateutil.parser.parse(row['bk_when'], ignoretz=True).strftime('%Y-%m-%d')
                    else:
                        normalized_date = dateutil.parser.parse(row['bk_when'], ignoretz=True).strftime('%Y-%m')
                    output_graph.add((Transaction, BK.when, Literal(normalized_date) ))
                except:
                    print(f"Error: Found invalid date {row['bk_when']} in row {index}")     
    
    #print(income_db)   
    #print("########")
    #print(expense_db)


    ########################################################################################
    ### <bk:Dataset>
    ########################################################################################
    DEPCHA_Dataset_URI = BASE_URL + PID + "#Dataset"
    DEPCHA_Dataset = URIRef(DEPCHA_Dataset_URI)
    output_graph.add((DEPCHA_Dataset, RDF.type,  DEPCHA.Dataset))
    output_graph.add((DEPCHA_Dataset, GAMS.isMemberOfCollection,  URIRef(BASE_URL + CONTEXT) ))
    output_graph.add((DEPCHA_Dataset, GAMS.isPartOf, URIRef(BASE_URL + PID) )) 

    output_graph.add((DEPCHA_Dataset, DEPCHA.isMainEconomicUnit,  URIRef(BK_MAIN_ECONOMIC_UNIT_URI) ))
    output_graph.add((DEPCHA_Dataset, DEPCHA.numberOfTransactions, Literal(count_transactions)))
    output_graph.add((DEPCHA_Dataset, DEPCHA.numberOfEconomicUnits, Literal(count_economic_units)))
    count_economic_goods = count_commodities + count_services + count_rights
    output_graph.add((DEPCHA_Dataset, DEPCHA.numberOfEconomicGoods, Literal(count_economic_goods)))
    output_graph.add((DEPCHA_Dataset, DEPCHA.numberOfServices, Literal(count_services)))
    output_graph.add((DEPCHA_Dataset, DEPCHA.numberOfCommodities, Literal(count_commodities)))
    output_graph.add((DEPCHA_Dataset, DEPCHA.numberOfRights, Literal(count_rights)))
    output_graph.add((DEPCHA_Dataset, DEPCHA.numberOfTotals, Literal(count_totals)))

    # units and currencies
    output_graph.add((DEPCHA_Dataset, DEPCHA.isMainCurrency, URIRef(BASE_URL + CONTEXT + "#" + BK_MAIN_CURRENCY["unit"]) ))
    for currency in config_data["BK_CURRENCY"]["currency"]:
        output_graph.add((DEPCHA_Dataset, DEPCHA.currency, URIRef(BASE_URL + CONTEXT + "#" + BK_MAIN_CURRENCY["unit"]) ))


    # create a bk:Dataset for every year
    # it contains info about the sum of all expense and income          
    for year in dates:
        # <bk:Dataset rdf:about="https://gams.uni-graz.at/o:depcha.gwfp.3#1771">
        depcha_Aggregation_URI = BASE_URL + PID + "#" + year
        Aggregation = URIRef(depcha_Aggregation_URI)
        output_graph.add((Aggregation, RDF.type,  DEPCHA.Aggregation))
        output_graph.add((DEPCHA_Dataset, DEPCHA.aggregates, Aggregation))
        # <bk:date>1771</bk:date>
        output_graph.add((Aggregation, BK.when, Literal(year) ))
        output_graph.add((Aggregation, BK.unit, Literal(BK_MAIN_CURRENCY['unit']) ))

        # income / debit
        revenue_sum = 0
        for money in income_db[year]:
            unit = list(money)[0]
            quantity = money.get(unit)
            # return converted money according to predefined main currency (confic file)
            revenue_sum += convert_Money_to_MainCurrency(quantity, unit) 
        output_graph.add((Aggregation, BK.debit, Literal(float(revenue_sum)) ))

        # expense / credit
        expenditure_sum = 0
        for money in expense_db[year]:
            unit = list(money)[0]
            quantity = money.get(unit)
            expenditure_sum += convert_Money_to_MainCurrency(quantity, unit) 
        output_graph.add((Aggregation, BK.credit, Literal(float(expenditure_sum)) ))

    ########################################################################################
    ### Currency <om:Unit rdf:about="https://gams.uni-graz.at/context:depcha.gwfp#pound">
    ########################################################################################
    ### currency info in confic file
    if(config_data["BK_CURRENCY"]):
        # the first mentioned currency is the main currency all other are mapepd to
        #BK_MAIN_CURRENCY = config_data["BK_CURRENCY"]["currency"][0]
        # <bk:Unit rdf:about="https://gams.uni-graz.at/context:depcha.gwfp#shilling">
        for currency in config_data["BK_CURRENCY"]["currency"]:
            BK_Unit = URIRef(BASE_URL + CONTEXT + "#" + currency["unit"])
            output_graph.add((BK_Unit, RDF.type, BK.Unit ))
            output_graph.add((BK_Unit, RDFS.label, Literal(normalizeStringforJSON(currency["unit"])) ))
            # add to depcha:Dataset the unit
            output_graph.add((DEPCHA_Dataset, DEPCHA.currency, BK_Unit ))
            if(currency.get("conversion", False)):
                BK_Conversion = URIRef(BASE_URL + CONTEXT + "#" + currency["unit"] + "Conversion")
                output_graph.add((BK_Conversion, RDF.type, BK.Conversion ))
                output_graph.add((BK_Conversion, BK.convertsFrom, BK_Unit ))
                toCurrency = URIRef(BASE_URL + CONTEXT + "#" + currency["conversion"]["convertsTo"])
                output_graph.add((BK_Conversion, BK.convertsTo,  toCurrency))
                output_graph.add((BK_Conversion, BK.formula, Literal(normalizeStringforJSON(currency["conversion"]["formula"]))))
                #BaseUnit = URIRef(BASE_URL + CONTEXT + "#" + currency["conversion"]["hasBaseUnit"])
                #output_graph.add((BK_Unit, OM.hasBaseUnit, BaseUnit ))
                # Todo find om:proeprty for conversion: ConversionStmt with value and operator in property ?
                #output_graph.add((BK_Unit, BK.conversionFormular, Literal(currency["conversion"]["formular"]) ))  
        print("Log: BK_CURRENCY ... check") 
    ###  currency info in csv
    # if bk_currency is in the spreadsheet?
    # case 1: bk_currency column with multiple values in it like: pound, shilling, cents
    # case 2: for each bk:currency a column and every cell is filled up with the same value 
    elif('bk_currency' in df.columns):
        print("ToDo bk_currency")
    else:
        Debug_CurrencyInformation = "Error 'BK_CURRENCY' missing: no Information about currency in spreadsheet or in confic file"
        print("Log: BK_CURRENCY ... failed")   



    ########################################################################################
    ### DEBUGGING
    print("################## DATASET:")
    #print(DataSets)
    print("################## Distinct bk:EconomicUnit:")
    #print(DistinctEconomicUnit)
    print("################## Columns:")
    #print(df.columns.values)
    print("################## Log:")
    print(f"Log: Processed the following config files: {all_JSON_filenames}")
    print(f"Log: skipped {str(Debug_CountEmptyRow)} rows with empty bk:entry")
    print(f"Log: no bk:debit or bk:credit found for {str(Debug_DebitCreditEmptyCell)} bk:entry")
    print(f"Log: was not able to identify bk:from or bk:to for {str(Debug_FromToEmpty)} bk:entry")
    print(f"Log: missed {str(Debug_missedTotal)} bk:Total")
    #print(Debug_CurrencyInformation)
    print(f"The BK_MAIN_CURRENCY is {BK_MAIN_CURRENCY}") 
    print(f"Log: {count_transactions} bk:Transaction created")
    print(f"Log: {count_totals} bk:Total created")
    print(f"Log: {count_transfers} bk:Transfer created")
    print(f"Log: {count_moneys} bk:Money created")
    print(f"Log: {count_commodities} bk:Commodity created")
    print(f"Log: {count_services} bk:Service created")
    print(f"Log: {count_rights} bk:Right created")
    print(f"Log: {count_EconomicUnits} bk:EconomicUnit created")
    print(f"Log: {Debug_Count_No_BK_ENTRY} no valid bk:entry in row.")    
        
    ########################################################################################
    ### OUTPUT file .xml
    ########################################################################################
    output_graph.serialize(destination = config_data["OUTPUT-FILE-NAME"] + '.xml', format="pretty-xml")

### 
print(f"new file: {config_data['OUTPUT-FILE-NAME']}.xml")     