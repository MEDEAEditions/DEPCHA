#import csv
from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.namespace import DCTERMS, RDF, RDFS, SKOS, XSD
import re
import pandas as pd
import json
import hashlib
import glob
from locale import atof, setlocale, LC_NUMERIC
import math

# https://stackoverflow.com/questions/6633523/how-can-i-convert-a-string-with-dot-and-comma-into-a-float-in-python
# . and , in float numbers depending on default locale
setlocale(LC_NUMERIC, '') 

########################################################################################
# VARIABLES
Debug_CountEmptyRow = 0;
Debug_DebitCreditEmptyRow = 0;
Debug_missedTotal = 0;
Debug_CurrencyInformation = "BK_CURRENCY: check"

########################################################################################
# FUNCTIONS
   
# check is a key exists in a dict
def checkKey(dict, key):  
    if key in dict.keys(): 
        return True
    else: 
        return False 


########################################################################################
# input: csv
# defines an empty dict with years as keys and a nested dict with income (bk:debit) and expense (bk:credit) set 0
# {'1790': {'income': '0', 'expense':'0'}, '1791': {'income': '0', 'expense':'0'}, ...} 
def getYearsforDataSet(df):
    for count, row in enumerate(df):
        row = dict(row)
        yearRegex = re.compile('([1-3][0-9]{3})') 
        Years = yearRegex.search(row["BK_WHEN"])
        if(Years != None):
            DataSets.update( {Years.group(): {'income': '0', 'expense':'0'}} )
       
            
########################################################################################
# creates a bk:Money and add bk:unit (uri) and bk:quantity (literal)
# param: getBKMoney(URIRef(), double, string)
# <bk:Transfer> <bk:transfers> <bk:Money rdf:about="https://gams.uni-graz.at/o:depcha.gwfp.3#T220M1">
def get_Money(Measurable_Money, bk_quantity, bk_unit_index, Transfer):
    if (pd.notnull(bk_quantity)):
        output_graph.add((Measurable_Money, RDF.type,  BK.Money))
        output_graph.add((Transfer, BK.transfers, Measurable_Money))
        # <bk:quantity>
        output_graph.add((Measurable_Money, BK.quantity, Literal(str(bk_quantity))))
        # <bk:unit>  https://gams.uni-graz.at/context:depcha.gwfp#pence
        for currency in config_data["BK_CURRENCY"]["currency"]:
            if(currency.get("id") == bk_unit_index):
                bk_unit = currency.get("unit")        
        output_graph.add((Measurable_Money, BK.unit, URIRef(baseURL + CONTEXT + "#" + bk_unit) ))
        
########################################################################################
def create_Transfer_of_Money(Transaction_URI, Transaction):
    #<bk:Transfer> <bk:transfers> <bk:Money>
    if(pd.notnull(row["bk_money"])):
        # selects all coumns bk_money, bk_money1 ... it is assumed that the first bk_money is the main currency
        monetaryValues = row.filter(like='bk_money')
        # <bk:Transfer>
        Transfer = URIRef(Transaction_URI + "T" + str(index))
        output_graph.add((Transaction, BK.consistsOf,  Transfer))
        output_graph.add((Transfer, RDF.type, BK.Transfer))
        ### for all cells with content in columns name bk_money
        for count, bk_quantity in enumerate(monetaryValues):
            get_Money(URIRef(Transaction_URI + "M" + str(count)), bk_quantity, str(count), Transfer)
                        
                          
        
########################################################################################
# this function add bk:entry, gams:isMemberOfCollection to the output_graph
# param: URIRef() of the bk:Transaction
def getBKCoreElements(Class):
    output_graph.add((Class, BK.entry, Literal(row["bk_entry"].replace('"',"'")) )) 
    output_graph.add((Class, GAMS.isMemberOfCollection,  URIRef(baseURL + CONTEXT) )) 
    output_graph.add((Transaction, BK.entry,  Literal(row["bk_entry"].replace('"',"'")) ))  


########################################################################################
########################################################################################
#### MAIN
# this programm iterate over all .json (=confic files) in a folder. it gets the needed infomration from 
# this file including the filename of the.csv
# the .csv is loaded and for every row is mapped to a RDF-Serialization  a bk:Transaction is created 

folder = "gwfp"
file_extension = ".json"

# get all JSON confic files in a folder
# for a single file: 
all_JSON_filenames = [i for i in glob.glob(f"{folder}/csvToRDF_config__Ledger_C{file_extension}")]
#all_JSON_filenames = [i for i in glob.glob(f"{folder}/*{file_extension}")]
########################################################################################
for json_file in all_JSON_filenames:
    # open confic file
    with open(json_file) as json_config_file:
        config_data = json.load(json_config_file)

    df = pd.read_csv(open(folder + "/" + config_data["FILENAME"], encoding="utf8"))
    
    # normalize all colum names to bk_entry etc. [for JSON query result in DEPCHA needed!]
    df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_').str.replace('(', '').str.replace(')', '')

    #############################
    ### load data from confic file
    CONTEXT = config_data["CONTEXT"]
    PID = config_data["PID"]

    ##############################
    ### define variables for RDF graph
    BK = Namespace("https://gams.uni-graz.at/o:depcha.bookkeeping#")
    GAMS = Namespace("https://gams.uni-graz.at/o:gams-ontology#") 
    OM = Namespace("http://www.ontology-of-units-of-measure.org/resource/om-2/")
    baseURL = "https://gams.uni-graz.at/"
    # make a graph
    output_graph = Graph()
    # define namespace in output file
    output_graph.bind("bk", BK)
    output_graph.bind("gams", GAMS)
    output_graph.bind("om", OM)

    # from is reserved term in python
    #bk_from = URIRef("https://gams.uni-graz.at/o:depcha.bookkeeping#from")


    ########################################################################################
    ### Currency <om:Unit rdf:about="https://gams.uni-graz.at/context:depcha.gwfp#pound">
    if(config_data["BK_CURRENCY"]):
        # the first mentioned currency is the main currency all other are mapepd to
        BK_MAIN_CURRENCY = config_data["BK_CURRENCY"]["currency"][0]
        # <om:Unit rdf:about="https://gams.uni-graz.at/context:depcha.gwfp#shilling"> <om:hasBaseUnit>, <rdfs:label>, <bk:conversionFormular> (?)
        for currency in config_data["BK_CURRENCY"]["currency"]:
            OM_Unit = URIRef(baseURL + CONTEXT + "#" + currency["unit"])
            output_graph.add((OM_Unit, RDF.type, OM.Unit ))
            output_graph.add((OM_Unit, RDFS.label, Literal(currency["unit"]) ))
            if(currency.get("conversion", False)):
                BaseUnit = URIRef(baseURL + CONTEXT + "#" + currency["conversion"]["hasBaseUnit"])
                output_graph.add((OM_Unit, OM.hasBaseUnit, BaseUnit ))
                # Todo find om:proeprty for conversion: ConversionStmt with value and operator in property ?
                output_graph.add((OM_Unit, BK.conversionFormular, Literal(currency["conversion"]["formular"]) ))     
    #########################################
        # if bk_currency is in the spreadsheet?
        # case 1: bk_currency column with multiple values in it like: pound, shilling, cents
        # case 2: for each bk:currency a column and every cell is filled up with the same value 
    elif('bk_currency' in df.columns):
        print("ToDo bk_currency")
    ######################################### 
    else:
        Debug_CurrencyInformation = "Error 'BK_CURRENCY' missing: no Information about currency in spreadsheet or in confic file"
        
        
    ########################################################################################
    ### BETWEEN 
    # if a BK_BETWEEN column exists create a distinct set of <bk:Between>
    for name in df.bk_between.unique():
        # normalize for URI
        if(type(name)==str):
            if(str(name).count(",") <= 1):
                normalized_name = (str(name).replace(", ", "")).replace(" ", "") 
            else:
                normalized_name = "anonym"
            Between_URI = baseURL + PID + "#B." + str(normalized_name)
            Between = URIRef(Between_URI)
            output_graph.add((Between, RDF.type,  BK.Between))
            output_graph.add((Between , BK.name,  Literal(name) ))
    '''
    if(pd.notnull(row["bk_between"])):
        # normalize for URI
        if(str(row["bk_between"]).count(",") <= 1):
            bk_Between = str(row['bk_between'].replace(", ", "")).replace(" ", "") 
        else:
            bk_Between = "anonym"
      
        #if(row['BK_BETWEEN'] != ''):
        #    output_graph.add((From, BK.name,  Literal(row['BK_BETWEEN']) ))
        #else:
        #    output_graph.add((From, BK.name,  Literal('anon') ))
    else:
        print("bk between is not a a singl column in the spreadsheet")
    # FROM with name, status and profession 
    #output_graph.add((From, RDF.type,  BK.Between))
    #if(checkKey(row, 'BK_NAME_FROM')):
    #    output_graph.add((From, BK.name,  Literal(row['BK_NAME_FROM']) ))
    '''
   


    # bk:Between
    # multiple names in column, seperator from forename and surname is the same as seperator from names
    # hack: if 1 or less , than its just on name or cash or orgName
   
        
        
    ########################################################################################
    # iterate over all rows; every row is a bk:Transaction or bk:Total 
    # (itertuples does not support coulmns with same name like bk_money.1, bk_money.2 etc. ?)
    for index, row in df.iterrows():
    
        #########################################
        ### <bk:Transaction>
        if (pd.notnull(row["bk_entry"]) and not "[Total]" in str(row["bk_entry"])):
            
            ###
            Transaction_URI = baseURL + PID + "#T" + str(index)
            Transaction = URIRef(Transaction_URI)
            output_graph.add((Transaction, RDF.type,  BK.Transaction))
            ### 
            getBKCoreElements(Transaction)
            ###
            create_Transfer_of_Money(Transaction_URI, Transaction)
                 
            ### bk:when
            # <bk:Transaction> <bk:when> "YYYY-MM-DD" or "YYYY-MM" or "YYYY" 
            if(pd.notnull(row["bk_when"])):
                output_graph.add((Transaction, BK.when,  Literal(row['bk_when']) ))
            
        
            #ToDo
            
            ### bk:Transfer of Commodity
            #if(pd.notnull(row.get["bk_commodity"])):
            #    print("todo")
                
            ### bk:Transfer of Service
            #if(pd.notnull(row["bk_service"])):
            #    print("todo")
            
            
        #########################################
        ### <bk:Total>
        # GWFP: [Total] in bk:entry marks bk:Total, Todo optional row.BK_TOTAL ?
        elif ("[Total]" in str(row["bk_entry"])):  
            ###
            Total_URI = baseURL + PID + "#To" + str(index)
            Total = URIRef(Total_URI)
            output_graph.add((Total, RDF.type,  BK.Total))
            ###
            getBKCoreElements(Total)
            ###
            create_Transfer_of_Money(Total_URI, Total)
            
        #########################################
        else:
            Debug_CountEmptyRow += 1
        #########################################
        
        ### VARIABLES
        # bk:entry
        # normalization why?     #normalizedEntry = " ".join(df['BK_ENTRY'][row].split())    
        #bk_source = str(df['BK_SOURCE'][row])
        # bk_entry = str(df['BK_ENTRY'][row])
        #bk_debit_credit = str(df['BK_DEBIT_CREDIT'][row])

    ########################################################################################
    ### output file .xml
    output_graph.serialize(destination= config_data["OUTPUT-FILE-NAME"] + '.xml', format="pretty-xml")
    
""" 
# bk:DataSets
DataSets = dict()
# updates dates to DataSets <https://gams.uni-graz.at/o:depcha.gwfp.3#1789>
getYearsforDataSet(csv.DictReader(open(df_path, encoding="utf8")))

# load the data with pd.read_csv 
csvViaPD = pd.read_csv(open(df_path, encoding="utf8")) 
DistinctBetween = csvViaPD.BK_BETWEEN.unique()

        
########################################################################################
# iteration over all rows in CSV input file
for count, row in enumerate(df):
    
    # convert it from an OrderedDict to a regular dict
    row = dict(row)
    


    
    
    ########################
    ########################
    if(row['BK_ENTRY'] != ''):
        # bk:debit, bk:credit
        debitOrCredit = row['BK_DEBIT_CREDIT']
        # bk:to bk:from
        To = Literal("anonym")
        From = Literal("anonym")
        # todo dynamic array of bk:money depending on gthe columns
        BK_Money1_Sum = 0
        BK_Money2_Sum = 0
        BK_Money3_Sum = 0
        
        ## URIs
        if(row['BK_ENTRY'] != '[Total]' and row['BK_ENTRY'] != ''):
            Transaction = URIRef(baseURL + PID + "#T" + str(count))
            Transfer1 = URIRef(baseURL + PID + "#T" + str(count) + "T1")
            Transfer2 = URIRef(baseURL + PID + "#T" + str(count) + "T2")
            Measurable_Money1 = URIRef(baseURL + PID + "#T" + str(count) + "M1")
            Measurable_Money2 = URIRef(baseURL + PID + "#T" + str(count) + "M2")
            Measurable_Money3 = URIRef(baseURL + PID + "#T" + str(count) + "M3")
            Commodity = URIRef(baseURL + PID + "#T" + str(count) + "C1")
            
            ###########################
            ### only take bk:Transaction (and not bk:Sum) for creating bk:DataSet
            # BK:DataSet
            
            sum_incomeInYear = 0
            sum_expenseInYear = 0
            # select
            
            # ToDo: get conversion information from input confic file
            # Pound
            if(row["BK_MONEY1"].isdigit()):
                BK_Money1_Sum = atof(row["BK_MONEY1"])
            # 1 Pound = 20 Shilling
            if(row["BK_MONEY2"].isdigit()):
                BK_Money2_Sum = atof(row["BK_MONEY2"])/20
            # 1 Pound = 240 Pence
            if(row["BK_MONEY3"].isdigit()):
                BK_Money3_Sum = atof(row["BK_MONEY3"])/240
            # for every found bk:Transaction with a year in bk:when
            yearRegex = re.compile('([1-3][0-9]{3})') 
            Years = yearRegex.search(row["BK_WHEN"])
            if(Years != None):
                # sums all bk:Money for every year and stores them in a dict {"year":"sum"}
                row_sum = BK_Money1_Sum + BK_Money2_Sum + BK_Money3_Sum
                if(row_sum>0):
                    # shows the calculation for every row
                    #print( debitOrCredit + ": " + str(Years.group()) + ": " + str(BK_Money1_Sum) + "+" + str(BK_Money2_Sum) + "+" + str(BK_Money3_Sum) + " = " +str(BK_Money1_Sum + BK_Money2_Sum + BK_Money3_Sum) )
                    # add current value with existing value in dict;
                    if(debitOrCredit == "Debit"):
                        DataSets[Years.group()]['income'] = float(DataSets[Years.group()]['income']) + row_sum
                    elif(debitOrCredit == "Credit"):
                        DataSets[Years.group()]['expense'] = float(DataSets[Years.group()]['expense']) + row_sum  
                    else:
                        Debug_DebitCreditEmptyRow += 1
        else:
            # Transaction is a bk:Total
            bk_Total = URIRef(baseURL + PID + "#To" + str(count))
            Transfer1 = URIRef(baseURL + PID + "#To" + str(count) + "T1")
            #Transfer2 = URIRef(baseURL + PID + "#S" + str(count) + "T2")
            Measurable_Money1 = URIRef(baseURL + PID + "#S" + str(count) + "M1")
            Measurable_Money2 = URIRef(baseURL + PID + "#S" + str(count) + "M2")
            Measurable_Money3 = URIRef(baseURL + PID + "#S" + str(count) + "M3")
        
        #if a single column exists containing information about debit or credit
        if(debitOrCredit): 
            # debit = Money from X to Washington
            if(debitOrCredit == "Debit"):
                #print("Money from Washington to X")
                From = URIRef(baseURL + PID + "#B." + config_data["BK_MAIN_BETWEEN_ID"])
                To = URIRef(baseURL + PID + "#B." + bk_Between)
            # credit = Money from Washington to X
            elif (debitOrCredit == "Credit"):
                #print("Money from X to Washington")
                To = URIRef(baseURL + PID + "#B." + config_data["BK_MAIN_BETWEEN_ID"] )
                From = URIRef(baseURL + PID + "#B." + bk_Between)           
        # a column for BK_FROM and BK_TO         
        elif (checkKey(row, 'BK_FROM')):
            From = URIRef(baseURL + PID + "#B." + str(row['BK_FROM']) )
        elif (checkKey(row, 'BK_TO')):
            To = URIRef(baseURL + PID + "#B." + str(row['BK_TO']) )
        else:
            # anonym person uri
            #print("ERROR with bk:to or bk:from")
            From = URIRef(baseURL + PID + "#.anonym")
            To = URIRef(baseURL + PID + "#B.anonym")
        
        #TRANSACTION
        if('[Total]' not in row['BK_ENTRY']):
            # bk:Transaction
            output_graph.add((Transaction, RDF.type,  BK.Transaction))
            # bk:source
            output_graph.add((BK.Transaction, BK.source,  Literal(row['BK_SOURCE'])))
            # only bk:Entry have bk:when
            if(checkKey(row, 'BK_WHEN') and row['BK_WHEN'] != ""):
                output_graph.add((Transaction, BK.when,  Literal(row['BK_WHEN']) ))
        # bk:Total  
        elif (row['BK_ENTRY'] == '[Total]'):
            output_graph.add((Transaction, RDF.type,  BK.Total))
        # RegEx to match what is after "[Total] " and use this information for the unit? : "[Total] Virginia Currency"
        elif ('[Total] ' in row['BK_ENTRY']):
            #bk:Total
            output_graph.add((Transaction, RDF.type,  BK.Total))
        else:
            Debug_missedTotal += 1
        
        #BK.entry
        #normalie whitesapce and " and ,
        output_graph.add((Transaction, BK.entry,  Literal(normalizedEntry) ))
        
        output_graph.add((Transaction, BK.consistsOf,  Transfer1))
        if(checkKey(row, 'BK_COMMODITY')):
            output_graph.add((Transaction, BK.consistsOf,  Transfer2))
        if(checkKey(row, 'OBJECT_')):
            output_graph.add((Transaction, BK.type,  Literal(row['OBJECT_'])))
        if(checkKey(row, 'BK_SOURCE')):
            output_graph.add((Transaction, BK.source,  Literal(row['BK_SOURCE'])))
        output_graph.add((Transaction, GAMS.isMemberOfCollection,  URIRef(baseURL + CONTEXT) ))
        
        # isPartofRDF needed?
        #output_graph.add((Transaction, GAMS.isPartofTEI,  URIRef(baseURL + PID) ))
        
        #GAMS.textualContent
        #output_graph.add((Transaction, GAMS.textualContent,  Literal(normalizedEntry) ))
        
        # Money - TRANSFER 1
        output_graph.add((Transfer1, RDF.type,  BK.Transfer))
        if(row['BK_MONEY1'] != ""):
            output_graph.add((Transfer1, BK.transfers,  Measurable_Money1))
        if(row['BK_MONEY2'] != ""):
            output_graph.add((Transfer1, BK.transfers, Measurable_Money2))
        if(row['BK_MONEY3'] != ""):
            output_graph.add((Transfer1, BK.transfers, Measurable_Money3))
        # if a column exists containt debit or credit
        if(debitOrCredit):
            output_graph.add((Transfer1, bk_from, From))
            output_graph.add((Transfer1, BK.to,  To ))
        #  if(debitOrCredit == "Debit"):
        #      output_graph.add((Transfer1, bk_from, From))
        #  elif(debitOrCredit == "Credit"):
        #      output_graph.add((Transfer1, BK.to,  To ))  
        else:
            output_graph.add((Transfer1, bk_from, From))  
            output_graph.add((Transfer1, BK.to,  To))
            
        #Commodity - TRANSFER 2
        if(checkKey(row, 'BK_COMMODITY')):
            output_graph.add((Transfer2, RDF.type,  BK.Transfer))
            output_graph.add((Transfer2, BK.transfers, Commodity))
            output_graph.add((Transfer2, BK.to, To))
            output_graph.add((Transfer2, bk_from, From))
        
        #MONEY: Money1 (like Livre or Dollar)
        getMoney(Measurable_Money1, "BK_MONEY1", "BK_UNIT1_config")
        
        #MONEY: Money2, (like Sous or Shilling)
        getMoney(Measurable_Money2, "BK_MONEY2", "BK_UNIT2_config")
        
        #MONEY: Money2, (like Deniers or Pence)
        getMoney(Measurable_Money3, "BK_MONEY3", "BK_UNIT3_config")
        
        #COMMODIY
        if(checkKey(row, 'BK_COMMODITY')):
            output_graph.add((Commodity, RDF.type,  BK.Commodity))
            output_graph.add((Commodity, BK.commodity,  Literal(row['BK_COMMODITY']) ))
            output_graph.add((Commodity, BK.unit, Literal('error: missing Unit') ))
            output_graph.add((Commodity, BK.quantity, Literal(row['QUANTITE1']) ))
            

        # TO only ID    
        #output_graph.add((To, RDF.type,  BK.Between))

    else:
        Debug_CountEmptyRow += 1 

# create om:Unit


 

  
# create a bk:Dataset for every year
for year in DataSets:
    #   <bk:Dataset rdf:about="https://gams.uni-graz.at/o:depcha.gwfp.3#1771">
    bk_Dataset_URI = baseURL + PID + "#" + year
    DataSet = URIRef(bk_Dataset_URI)
    output_graph.add((DataSet, RDF.type,  BK.Dataset))
    
    # <bk:date>1771</bk:date>
    output_graph.add((DataSet, BK.date, Literal(year) ))
    
    # <gams:isMemberOfCollection rdf:resource="https://gams.uni-graz.at/context:depcha.gwfp"/>
    output_graph.add((DataSet, GAMS.isMemberOfCollection,  URIRef(baseURL + CONTEXT) ))
    
    # <bk:Income rdf:about="https://gams.uni-graz.at/o:depcha.gwfp.3#1789I"/>
    bk_Income = URIRef(bk_Dataset_URI + "I")
    # <bk:debit>
    output_graph.add((DataSet, BK.debit, bk_Income))
    output_graph.add((bk_Income, RDF.type,  BK.Income))
        # bk:sum
    output_graph.add((bk_Income, BK.sum, Literal(round(float(DataSets[year]['income']))) ))
        # bk:unit
    output_graph.add((bk_Income, BK.unit, Literal(config_data["BK_UNIT1_config"]) ))
        # bk:aggregates

    #########
    # <bk:Expense rdf:about="https://gams.uni-graz.at/o:depcha.wheaton.1#1828E">
    bk_Expense = URIRef(bk_Dataset_URI + "E")
    # <bk:credit>
    output_graph.add((DataSet, BK.credit, bk_Expense))
    output_graph.add((bk_Expense, RDF.type,  BK.Expense))
        # bk:sum
    output_graph.add((bk_Expense, BK.sum, Literal(round(float(DataSets[year]['expense']))) ))
        # bk:unit (defined in _config)
    output_graph.add((bk_Expense, BK.unit, Literal(config_data["BK_UNIT1_config"]) ))
    

    # 
    
    #output_graph.add((DataSet, BK.sum,  Literal(round(DataSets[year])) ))
    #print(DataSets[year])
          
####
# format="xml" creates plain rdf/XML (rdf:type bk:Entry)
# format="pretty-xml" ,  abbreviated RDF/XML syntax like bk:Entry
# format="turtle"
"""
print("################## DATASET:")
#print(DataSets)
print("################## Disticnt bk:Between:")
#print(DistinctBetween)
print("################## Columns:")
print(df.columns.values)
print("################## Log:")
print(f"Log: Processed the following config files: {all_JSON_filenames}")
print(f"Log: skipped {str(Debug_CountEmptyRow)} rows with empty bk:entry")
print(f"Log: no bk:debit or bk:credit found for {str(Debug_DebitCreditEmptyRow)} bk:entry")
print(f"Log: missed {str(Debug_missedTotal)} bk:Total")
print(Debug_CurrencyInformation)
print(f"The BK_MAIN_CURRENCY is {BK_MAIN_CURRENCY}")


