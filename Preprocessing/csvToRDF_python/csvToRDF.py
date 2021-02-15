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
from datetime import datetime
import numpy as np

# https://stackoverflow.com/questions/6633523/how-can-i-convert-a-string-with-dot-and-comma-into-a-float-in-python
# . and , in float numbers depending on default locale
setlocale(LC_NUMERIC, '') 

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
        if (pd.notnull(bk_quantity)):
            output_graph.add((Measurable_Money, RDF.type,  BK.Money))
            output_graph.add((Transfer, BK.transfers, Measurable_Money))
            # <bk:quantity>
            output_graph.add((Measurable_Money, BK.quantity, Literal(str(bk_quantity))))
            for currency in config_data["BK_CURRENCY"]["currency"]:
                if(currency.get("id") == bk_unit_index):
                    bk_unit = currency.get("unit")        
            output_graph.add((Measurable_Money, BK.unit, URIRef(BASE_URL + CONTEXT + "#" + bk_unit) ))
            # print(bk_quantity)
    except:
        print(f"No valid number in BK_MONEY: Currencies cannot contain commas, spaces, or characters:{bk_quantity}")
    # <bk:unit>  https://gams.uni-graz.at/context:depcha.gwfp#pence
       
 
                                                
########################################################################################
# this function add bk:entry, gams:isMemberOfCollection to the output_graph
# param: URIRef() of the bk:Transaction
def getBKCoreElements(Class):
    # replace " with ' as the JSON output in DEPCHA has problems with it; replace "VT" in CSV with " "
    # in the csv are VT (vertical tabs; \u000B) String newString = oldString.replace('\u000B', ' ');
    helpString = row["bk_entry"].replace('"',"'")
    normalizedEntry = (helpString.replace('\u000B', ' ')).strip()
    output_graph.add((Class, BK.entry, Literal(normalizedEntry) )) 
    output_graph.add((Class, GAMS.isMemberOfCollection,  URIRef(BASE_URL + CONTEXT) )) 


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
def createTransferOfMoney(Transaction_URI, Transaction):
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
        ### <bk:debit>, <bk:credit>
        getCreditOrDebit(Transfer) 
        ##################
        ### bk:from, bk:to
        getFromOrTo(Transfer)
        
        
########################################################################################
#
# 
def getFromOrTo(Transfer):
    if(pd.notnull(row["bk_between"])):
        #Between_URI = BASE_URL + PID + "#B." + str(normalized_name)
        Between_URI = BASE_URL + PID + "#B." + normalizeStringforURI(row["bk_between"])
        Between = URIRef(Between_URI)
        # check the already graph pattern if the current transfer has bk:debit or bk:credit
        # if bk:debit than Washington is spending money
        if (Transfer, BK.debit, None) in output_graph:
            output_graph.add((Transfer, BK.to,  Between))
            output_graph.add((Transfer, BK_from_property, ACCOUNTHOLDER ))    
        # if bk:credit than Washington is getting money
        elif (Transfer, BK.credit, None) in output_graph:
            output_graph.add((Transfer, BK.to, ACCOUNTHOLDER))
            output_graph.add((Transfer, BK_from_property, Between))  
        else:
            False
            #Debug_FromToEmpty += 1
    
    
########################################################################################
#
#     
def add_Quantity_To_Sum(sum_, quantity, ConversionValue):
    try:
        sum_ += atof(quantity)/ConversionValue
        return sum_
    except:
        print("Not a valid number in add_Quantity_To_Sum function")
        
 
########################################################################################
#
#     
def sumQuantityFromQueryResult(QueryResult):
    sum_ = 0
    for row in QueryResult:
        if(patternforYear.search(row[0]) is not None):
            date = patternforYear.search(row[0]).group(0)               
            if(date == year):
                unit = row[1]
                quantity = row[2]
                
                if(str(unit) == "https://gams.uni-graz.at/context:depcha.gwfp#pound"):
                    sum_ = add_Quantity_To_Sum(sum_, quantity, 1) 
                elif(str(unit) == "https://gams.uni-graz.at/context:depcha.gwfp#shilling"):
                    sum_ = add_Quantity_To_Sum(sum_, quantity, 20) 
                elif(str(unit) == "https://gams.uni-graz.at/context:depcha.gwfp#pence"):
                    sum_ = add_Quantity_To_Sum(sum_, quantity, 240) 
                Dataset_Dict[year]["expense"] = sum_
    sum_ = 0
        
        
########################################################################################
########################################################################################
#### MAIN

########################################################################################
# VARIABLES
Debug_CountEmptyRow = 0
Debug_DebitCreditEmptyCell = 0
Debug_FromToEmpty = 0
Debug_missedTotal = 0
Debug_CurrencyInformation = "BK_CURRENCY: check"

# this programm iterate over all .json (=confic files) in a folder. it gets the needed infomration from 
# this file including the filename of the.csv
# the .csv is loaded and for every row is mapped to a RDF-Serialization  a bk:Transaction is created 

folder = "gwfp"
file_extension = ".json"

###
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


    ##############################
    ### define variables for RDF graph
    BK = Namespace("https://gams.uni-graz.at/o:depcha.bookkeeping#")
    GAMS = Namespace("https://gams.uni-graz.at/o:gams-ontology#") 
    OM = Namespace("http://www.ontology-of-units-of-measure.org/resource/om-2/")
    BASE_URL = "https://gams.uni-graz.at/"
    # make a graph
    output_graph = Graph()
    # define namespace in output file
    output_graph.bind("bk", BK)
    output_graph.bind("gams", GAMS)
    output_graph.bind("om", OM)

    #############################
    ### load data from confic file
    CONTEXT = config_data["CONTEXT"]
    PID = config_data["PID"]
    ACCOUNTHOLDER_URI = BASE_URL + CONTEXT + "#B." + config_data["BK_MAIN_BETWEEN_ID"]
    ACCOUNTHOLDER = URIRef(ACCOUNTHOLDER_URI)

    # from is reserved term in python
    BK_from_property = URIRef("https://gams.uni-graz.at/o:depcha.bookkeeping#from")


    ########################################################################################
    ### Currency <om:Unit rdf:about="https://gams.uni-graz.at/context:depcha.gwfp#pound">
    if(config_data["BK_CURRENCY"]):
        # the first mentioned currency is the main currency all other are mapepd to
        BK_MAIN_CURRENCY = config_data["BK_CURRENCY"]["currency"][0]
        # <om:Unit rdf:about="https://gams.uni-graz.at/context:depcha.gwfp#shilling"> <om:hasBaseUnit>, <rdfs:label>, <bk:conversionFormular> (?)
        for currency in config_data["BK_CURRENCY"]["currency"]:
            OM_Unit = URIRef(BASE_URL + CONTEXT + "#" + currency["unit"])
            output_graph.add((OM_Unit, RDF.type, OM.Unit ))
            output_graph.add((OM_Unit, RDFS.label, Literal(currency["unit"]) ))
            if(currency.get("conversion", False)):
                BaseUnit = URIRef(BASE_URL + CONTEXT + "#" + currency["conversion"]["hasBaseUnit"])
                output_graph.add((OM_Unit, OM.hasBaseUnit, BaseUnit ))
                # Todo find om:proeprty for conversion: ConversionStmt with value and operator in property ?
                output_graph.add((OM_Unit, BK.conversionFormular, Literal(currency["conversion"]["formular"]) ))  
        print("Log: BK_CURRENCY ... check")   
    #########################################
        # if bk_currency is in the spreadsheet?
        # case 1: bk_currency column with multiple values in it like: pound, shilling, cents
        # case 2: for each bk:currency a column and every cell is filled up with the same value 
    elif('bk_currency' in df.columns):
        print("ToDo bk_currency")
    ######################################### 
    else:
        Debug_CurrencyInformation = "Error 'BK_CURRENCY' missing: no Information about currency in spreadsheet or in confic file"
        print("Log: BK_CURRENCY ... failed")   
        
        
    ########################################################################################
    ### BETWEEN 
    # if a BK_BETWEEN column exists create a distinct set of <bk:Between>
    for name in df.bk_between.unique():
        # normalize for URI
        if(type(name)==str):
            normalized_name = normalizeStringforURI(name)
            Between_URI = BASE_URL + PID + "#B." + str(normalized_name)
            Between = URIRef(Between_URI)
            output_graph.add((Between, RDF.type,  BK.Between))
            output_graph.add((Between , BK.name,  Literal(normalizeStringforJSON(name)) ))
            
    print("Log: distinct BK_BETWEEN ... check")  


    # bk:Between
    # multiple names in column, seperator from forename and surname is the same as seperator from names
    # hack: if 1 or less , than its just on name or cash or orgName
        
        
    ########################################################################################
    # iterate over all rows; every row is a bk:Transaction or bk:Total 
    # (itertuples does not support coulmns with same name like bk_money.1, bk_money.2 etc. ?)
    for index, row in df.iterrows():
    
        #########################################
        if (pd.notnull(row["bk_entry"]) and not "[Total]" in str(row["bk_entry"])):
            ### <bk:Transaction>
            Transaction_URI = BASE_URL + PID + "#T" + str(index)
            Transaction = URIRef(Transaction_URI)
            output_graph.add((Transaction, RDF.type,  BK.Transaction))
            ### <bk:entry>, <gams:isMemberOfCollection>
            getBKCoreElements(Transaction)
            ### <bk:Transfer> <bk:Money>
            createTransferOfMoney(Transaction_URI, Transaction)
            
            ### <bk:when>
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
        # GWFP: [Total] in bk:entry marks bk:Total, Todo optional row.BK_TOTAL ?
        elif ("[Total]" in str(row["bk_entry"])):  
            ### <bk:Total>
            Total_URI = BASE_URL + PID + "#To" + str(index)
            Total = URIRef(Total_URI)
            output_graph.add((Total, RDF.type,  BK.Total))
            ### <bk:entry>, <gams:isMemberOfCollection>
            getBKCoreElements(Total)
            ### <bk:Transfer> <bk:Money>
            createTransferOfMoney(Total_URI, Total)
            
        #########################################
        else:
            Debug_CountEmptyRow += 1
            
    print("Log: bk:Transactions|bk:Total ... check")       
        
    ########################################################################################
    ### <bk:Dataset>
    ########################################################################################
    # get all distinct dates like YYYY or YYYY-MM (todo); store them in a set()
    # query the already created graph for all Transactions with bk:from and bk:to refering to the account holder
    # iteration over the result set of the queries and create sum up income and expense in Dataset_Dict  {'1793': {'income': 0, 'expense': 0}
    # ToDo conversion information from confic file
    
    Dataset_Dict = dict()
    yearSet = set()
    patternforYear = re.compile('\d{4}')  
    # maybe this coudl be done better?
    for datestring in df['bk_when']:
        if (pd.notnull(datestring)):
            if(patternforYear.search(datestring) is not None):
                yearSet.add(patternforYear.search(datestring).group(0))
                
    for year in yearSet:
        Dataset_Dict.update( {year: {'income': '0', 'expense':'0'}} )
    
    
    
    # Money from AccotunHolder to X = EXPENSE
    Money_From_AccotunHolder_To_X = output_graph.query(
    """SELECT ?d ?unit ?quantity
       WHERE {
          ?Transaction a bk:Transaction ;
                       bk:when ?d ;
                       bk:consistsOf ?Transfer.   
          ?Transfer bk:from <https://gams.uni-graz.at/context:depcha.gwfp#B.GeorgeWashington> ;
                    bk:transfers ?Money.
          ?Money bk:unit ?unit;
                 bk:quantity ?quantity.
                 
       }""")
    
    print("Log: Query bk:from ... check") 
    
    # Money from  X to AccotunHolder = INCOME
    Money_From_X_To_AccotunHoler = output_graph.query(
    """SELECT ?d ?unit ?quantity
       WHERE {
          ?Transaction a bk:Transaction ;
                       bk:when ?d ;
                       bk:consistsOf ?Transfer.
          ?Transfer bk:to <https://gams.uni-graz.at/context:depcha.gwfp#B.GeorgeWashington> ;
                    bk:transfers ?Money.
          ?Money bk:unit ?unit;
                 bk:quantity ?quantity.
       }""")

    print("Log: Query bk:to ... check") 
    
    expense_sum = 0
    income_sum = 0
    
    ''' for year in yearSet:
        
        sumQuantityFromQueryResult(Money_From_AccotunHolder_To_X)
        sumQuantityFromQueryResult(Money_From_X_To_AccotunHoler)
      
        for query_result_row in Money_From_AccotunHolder_To_X:
            if(patternforYear.search(query_result_row[0]) is not None):
                date = patternforYear.search(query_result_row[0]).group(0)               
                if(date == year):
                    unit = query_result_row[1]
                    quantity = query_result_row[2]
                    
                    if(str(unit) == "https://gams.uni-graz.at/context:depcha.gwfp#pound"):
                        add_Quantity_To_Sum(income_sum, quantity, 1) 
                    elif(str(unit) == "https://gams.uni-graz.at/context:depcha.gwfp#shilling"):
                        add_Quantity_To_Sum(income_sum, quantity, 20) 
                    elif(str(unit) == "https://gams.uni-graz.at/context:depcha.gwfp#pence"):
                        add_Quantity_To_Sum(income_sum, quantity, 240) 
                    Dataset_Dict[year]["expense"] = expense_sum 
        expense_sum = 0
        for query_result_row in Money_From_X_To_AccotunHoler:
            if(patternforYear.search(query_result_row[0]) is not None):
                date = patternforYear.search(query_result_row[0]).group(0)
                if(date == year):
                    unit = query_result_row[1]
                    quantity = query_result_row[2]
                    if(str(unit) == "https://gams.uni-graz.at/context:depcha.gwfp#pound"):
                        add_Quantity_To_Sum(income_sum, quantity, 1) 
                    elif(str(unit) == "https://gams.uni-graz.at/context:depcha.gwfp#shilling"):
                        add_Quantity_To_Sum(income_sum, quantity, 20)
                    elif(str(unit) == "https://gams.uni-graz.at/context:depcha.gwfp#pence"):
                        add_Quantity_To_Sum(income_sum, quantity, 240)
                    Dataset_Dict[year]["income"] = income_sum 
        income_sum = 0'''
        
    print("Log: income_sum and expense_sum  ... check")    

    for year in yearSet:
        
        # <bk:Dataset rdf:about="https://gams.uni-graz.at/o:depcha.gwfp.3#1771">
        bk_Dataset_URI = BASE_URL + PID + "#" + year
        DataSet = URIRef(bk_Dataset_URI)
        output_graph.add((DataSet, RDF.type,  BK.Dataset))
        output_graph.add((DataSet, GAMS.isMemberOfCollection,  URIRef(BASE_URL + CONTEXT) ))
        
        # <bk:date>1771</bk:date>
        output_graph.add((DataSet, BK.date, Literal(year) ))
        
        # <bk:credit> <bk:Income>
        bk_Income = URIRef(bk_Dataset_URI + "I")
        output_graph.add((DataSet, BK.credit, bk_Income))
        output_graph.add((bk_Income, RDF.type,  BK.Income))
        # bk:sum
        output_graph.add((bk_Income, BK.sum, Literal(round(float(Dataset_Dict[year]['income']),2)) ))
        # bk:unit
        output_graph.add((bk_Income, BK.unit, URIRef(BASE_URL + CONTEXT + "#" + BK_MAIN_CURRENCY["unit"]) ))
        
        # <bk:debit> <bk:Expense>
        bk_Expense = URIRef(bk_Dataset_URI + "E")
        output_graph.add((DataSet, BK.debit, bk_Expense))
        output_graph.add((bk_Expense, RDF.type,  BK.Expense))
        # bk:sum
        output_graph.add((bk_Expense, BK.sum, Literal(round(float(Dataset_Dict[year]['expense']),2)) ))
        # bk:unit
        output_graph.add((bk_Expense, BK.unit, URIRef(BASE_URL + CONTEXT + "#" + BK_MAIN_CURRENCY["unit"]) ))

    print(Dataset_Dict)
    ########################################################################################
    ########################################################################################
    ### OUTPUT file .xml
    output_graph.serialize(destination = config_data["OUTPUT-FILE-NAME"] + '.xml', format="pretty-xml")
    
########################################################################################
### DEBUGGING
print("################## DATASET:")
#print(DataSets)
print("################## Disticnt bk:Between:")
#print(DistinctBetween)
print("################## Columns:")
print(df.columns.values)
print("################## Log:")
print(f"Log: Processed the following config files: {all_JSON_filenames}")
print(f"Log: skipped {str(Debug_CountEmptyRow)} rows with empty bk:entry")
print(f"Log: no bk:debit or bk:credit found for {str(Debug_DebitCreditEmptyCell)} bk:entry")
print(f"Log: was not able to identify bk:from or bk:to for {str(Debug_FromToEmpty)} bk:entry")
print(f"Log: missed {str(Debug_missedTotal)} bk:Total")
print(Debug_CurrencyInformation)
print(f"The BK_MAIN_CURRENCY is {BK_MAIN_CURRENCY}")   


""" 


            
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
            bk_Total = URIRef(BASE_URL + PID + "#To" + str(count))
            Transfer1 = URIRef(BASE_URL + PID + "#To" + str(count) + "T1")
            #Transfer2 = URIRef(BASE_URL + PID + "#S" + str(count) + "T2")
            Measurable_Money1 = URIRef(BASE_URL + PID + "#S" + str(count) + "M1")
            Measurable_Money2 = URIRef(BASE_URL + PID + "#S" + str(count) + "M2")
            Measurable_Money3 = URIRef(BASE_URL + PID + "#S" + str(count) + "M3")
        
        #if a single column exists containing information about debit or credit
        if(debitOrCredit): 
            # debit = Money from X to Washington
            if(debitOrCredit == "Debit"):
                #print("Money from Washington to X")
                From = URIRef(BASE_URL + PID + "#B." + config_data["BK_MAIN_BETWEEN_ID"])
                To = URIRef(BASE_URL + PID + "#B." + bk_Between)
            # credit = Money from Washington to X
            elif (debitOrCredit == "Credit"):
                #print("Money from X to Washington")
                To = URIRef(BASE_URL + PID + "#B." + config_data["BK_MAIN_BETWEEN_ID"] )
                From = URIRef(BASE_URL + PID + "#B." + bk_Between)           
        # a column for BK_FROM and BK_TO         
        elif (checkKey(row, 'BK_FROM')):
            From = URIRef(BASE_URL + PID + "#B." + str(row['BK_FROM']) )
        elif (checkKey(row, 'BK_TO')):
            To = URIRef(BASE_URL + PID + "#B." + str(row['BK_TO']) )
        else:
            # anonym person uri
            #print("ERROR with bk:to or bk:from")
            From = URIRef(BASE_URL + PID + "#.anonym")
            To = URIRef(BASE_URL + PID + "#B.anonym")
        
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
        output_graph.add((Transaction, GAMS.isMemberOfCollection,  URIRef(BASE_URL + CONTEXT) ))
        
        # isPartofRDF needed?
        #output_graph.add((Transaction, GAMS.isPartofTEI,  URIRef(BASE_URL + PID) ))
        
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
    bk_Dataset_URI = BASE_URL + PID + "#" + year
    DataSet = URIRef(bk_Dataset_URI)
    output_graph.add((DataSet, RDF.type,  BK.Dataset))
    
    # <bk:date>1771</bk:date>
    output_graph.add((DataSet, BK.date, Literal(year) ))
    
    # <gams:isMemberOfCollection rdf:resource="https://gams.uni-graz.at/context:depcha.gwfp"/>
    output_graph.add((DataSet, GAMS.isMemberOfCollection,  URIRef(BASE_URL + CONTEXT) ))
    
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