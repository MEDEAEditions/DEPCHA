import csv
from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.namespace import DCTERMS, RDF, RDFS, SKOS, XSD
import re
import pandas as pd
import json
import hashlib
from locale import atof, setlocale, LC_NUMERIC

# https://stackoverflow.com/questions/6633523/how-can-i-convert-a-string-with-dot-and-comma-into-a-float-in-python
# . and , in float numbers depending on default locale
setlocale(LC_NUMERIC, '') 

########################################################################################
# FUNCTIONS

# 
def createDataSet(): 
    # define 2 sets
    Years = dict()
    yearRegex = re.compile('([1-3][0-9]{3})') 
    sum_incomeInYear = 0
    sum_expenseInYear = 0
    '''
    #TODO make the same for debit/credit for each distinct year
    # go through the rows; select BK_WHEN; goes through all entries and add the years (selected via regEx) to a set;
    for row in input_file:
        mo = yearRegex.search(row["BK_WHEN"])
        if(row["BK_MONEY1"].isdigit() and row["BK_MONEY2"].isdigit() and row["BK_MONEY3"].isdigit()):
            # Englisch:   	1 Pound = 	20 Shillings  = 240 Pence
            row_sum = float(row["BK_MONEY1"]) + round(float(row["BK_MONEY2"])/20) + round(float(row["BK_MONEY3"])/240)
        else:
            print("Error: BK_MONEY is not a digit:1 " + row["BK_MONEY1"] +";2 " + row["BK_MONEY2"] + ";3 " + row["BK_MONEY3"])
        if(mo != None):
            #Years.add(mo.group())
            Years[mo.group()] = row_sum
            #if(row["BK_MONEY1"].isdigit()):
            #    sum_incomeInYear += int(row["BK_MONEY1"])
    ''' 
    
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
def getYearsforDataSet(input_file):
    for count, row in enumerate(input_file):
        row = dict(row)
        yearRegex = re.compile('([1-3][0-9]{3})') 
        Years = yearRegex.search(row["BK_WHEN"])
        if(Years != None):
            DataSets.update( {Years.group(): {'income': '0', 'expense':'0'}} )

########################################################################################
# creates a bk:Money and add bk:unit and bk:quantity 
def getMoney(Measurable_Money1, bk_money, bk_unit_config):
    if(row[bk_money] != ""):
        output_graph.add((Measurable_Money1, RDF.type,  BK.Money))
        output_graph.add((Measurable_Money1, BK.quantity, Literal(row[bk_money]) ))
        # if unit is defined in config file
        if(config_data[bk_unit_config]):
            output_graph.add((Measurable_Money1, BK.unit, Literal(config_data[bk_unit_config]) ))
        # a column for bk:unit exists
        else:
            output_graph.add((Measurable_Money1, BK.unit, Literal(row["BK_UNIT1"]) ))

########################################################################################
########################################################################################
# MAIN
path = "gwfp/"

########################################################################################
# load CSV
with open(path + "csvToRDF_config__Ledger_A.json") as json_config_file:
    config_data = json.load(json_config_file)
#
input_file = csv.DictReader(open(path + config_data["FILENAME"], encoding="utf8"))
#
BK = Namespace("https://gams.uni-graz.at/o:depcha.bookkeeping#")
GAMS = Namespace("https://gams.uni-graz.at/o:gams-ontology#")
# 
baseURL = "https://gams.uni-graz.at/"
CONTEXT = config_data["CONTEXT"]
PID = config_data["PID"]

# make a graph
output_graph = Graph()
# define namespace in output file
output_graph.bind("bk", BK)
output_graph.bind("gams", GAMS)

# from is reserved term
bk_from = URIRef("https://gams.uni-graz.at/o:depcha.bookkeeping#from")

########################################################################################


# bk:DataSet
DataSets = dict()
getYearsforDataSet(csv.DictReader(open(path + config_data["FILENAME"], encoding="utf8")))

        
########################################################################################
# iteration over all rows in CSV input file
for count, row in enumerate(input_file):
    
    # convert it from an OrderedDict to a regular dict
    row = dict(row)
    
    ### VARIABLES
    # bk:entry
    normalizedEntry = " ".join(row['BK_ENTRY'].split())
    normalizedEntry =  normalizedEntry.replace('"',"'")
    # bk:debit, bk:credit
    debitOrCredit = row['BK_DEBIT_CREDIT']
    # bk:to bk:from
    To = Literal("anonym")
    From = Literal("anonym")
    #
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
                    print("Error: no Debit or Credit in BK_DEBIT_CREDIT")
    else:
        # Transaction is a bk:Sum
        Transaction = URIRef(baseURL + PID + "#S" + str(count))
        Transfer1 = URIRef(baseURL + PID + "#S" + str(count) + "T1")
        Transfer2 = URIRef(baseURL + PID + "#S" + str(count) + "T2")
        Measurable_Money1 = URIRef(baseURL + PID + "#S" + str(count) + "M1")
        Measurable_Money2 = URIRef(baseURL + PID + "#S" + str(count) + "M2")
        Measurable_Money3 = URIRef(baseURL + PID + "#S" + str(count) + "M3")
        Commodity = URIRef(baseURL + PID + "#S" + str(count) + "C1")
    
    #if a single column exists containing information about debit or credit
    if(debitOrCredit): 
        # debit = Money from X to Washington
        if(debitOrCredit == "Debit"):
            #print("Money from Washington to X")
            From = URIRef(baseURL + PID + "#Between." + config_data["BK_MAIN_BETWEEN_ID"])
            To = URIRef(baseURL + PID + "#Between." + str(id(row['BK_BETWEEN'])) )   
        # credit = Money from Washington to X
        elif (debitOrCredit == "Credit"):
            #print("Money from X to Washington")
            To = URIRef(baseURL + PID + "#Between." + config_data["BK_MAIN_BETWEEN_ID"] )
            From = URIRef(baseURL + PID + "#Between." + str(id(row['BK_BETWEEN'])) )           
    # a column for BK_FROM and BK_TO         
    elif (checkKey(row, 'BK_FROM')):
        From = URIRef(baseURL + PID + "#Between." + str(row['BK_FROM']) )
    elif (checkKey(row, 'BK_TO')):
        To = URIRef(baseURL + PID + "#Between." + str(row['BK_TO']) )
    else:
        # anonym person uri
        #print("ERROR with bk:to or bk:from")
        From = URIRef(baseURL + PID + "#Between.anonym")
        To = URIRef(baseURL + PID + "#Between.anonym")
    
    
    #TRANSACTION
    if(row['BK_ENTRY'] != '[Total]' ):
        output_graph.add((Transaction, RDF.type,  BK.Transaction))
        # only bk:Entry have bk:when
        if(checkKey(row, 'BK_WHEN')):
            output_graph.add((Transaction, BK.when,  Literal(row['BK_WHEN']) ))
    else:
        output_graph.add((Transaction, RDF.type,  BK.Sum))
    
    
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
    output_graph.add((Transaction, GAMS.textualContent,  Literal(normalizedEntry) ))
    
    # Money - TRANSFER 1
    output_graph.add((Transfer1, RDF.type,  BK.Transfer))
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
        
    #BETWEEN
    # if a BK_BETWEEN column exists create a distinct set of them
    if(checkKey(row, 'BK_BETWEEN')):
        Between = URIRef(baseURL + PID + "#Between." + str(id(row['BK_BETWEEN'])) )
        output_graph.add((Between, RDF.type,  BK.Between))
        if(row['BK_BETWEEN']):
            output_graph.add((From, BK.name,  Literal(row['BK_BETWEEN']) ))
        else:
            output_graph.add((From, BK.name,  Literal('anon') ))
    else:
        if(checkKey(row, 'BK_NAME_FROM')):
            output_graph.add((From, RDF.type,  BK.Between))
            if(checkKey(row, 'BK_NAME_FROM')):
                output_graph.add((From, BK.name,  Literal(row['BK_NAME_FROM']) ))
            if(checkKey(row, 'BK_BETWEENPROFESSION')):
                output_graph.add((From, BK.profession,  Literal(row['BK_BETWEENPROFESSION']) ))
            if(checkKey(row, 'BK_BETWEENCIVILTE')):
                output_graph.add((From, BK.status,  Literal(row['BK_BETWEENCIVILTE']) ))
    # FROM with name, status and profession 
    output_graph.add((From, RDF.type,  BK.Between))
    if(checkKey(row, 'BK_NAME_FROM')):
        output_graph.add((From, BK.name,  Literal(row['BK_NAME_FROM']) ))

    # TO only ID    
    #output_graph.add((To, RDF.type,  BK.Between))
    
    #### free variables
    ##########################
    '''## bk:Sum
    else:
        ### SUM
        ## URIs
        Transaction_Sum = URIRef(baseURL + PID + "#S" + str(count))
        Transfer1_Sum = URIRef(baseURL + PID + "#S" + str(count) + "T1")
        Transfer2_Sum = URIRef(baseURL + PID + "#S" + str(count) + "T2")
        Measurable_Money1_Sum = URIRef(baseURL + PID + "#S" + str(count) + "M1")
        Measurable_Money2_Sum = URIRef(baseURL + PID + "#S" + str(count) + "M2")
        Measurable_Money3_Sum = URIRef(baseURL + PID + "#S" + str(count) + "M3")
        Commodity_Sum = URIRef(baseURL + PID + "#S" + str(count) + "C1"
        print(row['BK_ENTRY'])
    '''
   
  

# create a bk:Dataset for every year
print(DataSets)
for year in DataSets:
    DataSet = URIRef(baseURL + PID + "#DataSet" + year)
    output_graph.add((DataSet, RDF.type,  BK.DataSet))
    output_graph.add((DataSet, BK.date,  Literal(year) ))
    if(float(DataSets[year]['income']) > 0):
        output_graph.add((DataSet, BK.income,  Literal(round(float(DataSets[year]['income']))) ))
    if(float(DataSets[year]['expense']) > 0):
        output_graph.add((DataSet, BK.expense,  Literal(round(float(DataSets[year]['expense']))) ))
    #output_graph.add((DataSet, BK.sum,  Literal(round(DataSets[year])) ))
    #print(DataSets[year])
          
####
# format="xml" creates plain rdf/XML (rdf:type bk:Entry)
# format="pretty-xml" ,  abbreviated RDF/XML syntax like bk:Entry
# format="turtle"
output_graph.serialize(destination= config_data["OUTPUT-FILE-NAME"] + '.xml', format="pretty-xml")