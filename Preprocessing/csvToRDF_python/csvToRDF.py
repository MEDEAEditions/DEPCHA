import csv
from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.namespace import DCTERMS, RDF, RDFS, SKOS, XSD
import pandas as pd

#
input_file = csv.DictReader(open("magprof.csv"))
#
BK = Namespace("https://gams.uni-graz.at/o:depcha.bookkeeping#")
GAMS = Namespace("https://gams.uni-graz.at/o:gams-ontology#")
# 
baseURL = "https://gams.uni-graz.at/"
CONTEXT = "context:depcha.marprof"
PID = "o:marprof.1"

# make a graph
output_graph = Graph()
# define namespace in output file
output_graph.bind("bk", BK)
output_graph.bind("gams", GAMS)

# from is reserved term
bk_from = URIRef("https://gams.uni-graz.at/o:depcha.bookkeeping#from")

# BK_DataSet
DataSet = URIRef(baseURL + PID + "#DataSet")
output_graph.add((DataSet, RDF.type,  BK.DataSet))

for count, row in enumerate(input_file):
    # convert it from an OrderedDict to a regular dict
    row = dict(row)
 
    # URIs
    Transaction = URIRef(baseURL + PID + "#T" + str(count))
    Transfer1 = URIRef(baseURL + PID + "#T" + str(count) + "T1")
    Transfer2 = URIRef(baseURL + PID + "#T" + str(count) + "T2")
    Measurable_Money1 = URIRef(baseURL + PID + "#T" + str(count) + "M1")
    Measurable_Money2 = URIRef(baseURL + PID + "#T" + str(count) + "M2")
    Measurable_Money3 = URIRef(baseURL + PID + "#T" + str(count) + "M3")
    Commodity = URIRef(baseURL + PID + "#T" + str(count) + "C1")
    From = URIRef(baseURL + PID + "#pers." + str(row['BK_FROM']) )
    To = URIRef(baseURL + PID + "#pers." + str(row['BK_TO']) )
    # Data
    normalizedEntry = " ".join(row['BK_ENTRY'].split())
    normalizedEntry =  normalizedEntry.replace('"',"'")
    
    #TRANSACTION
    output_graph.add((Transaction, RDF.type,  BK.Transaction))
    output_graph.add((Transaction, BK.when,  Literal(row['BK_WHEN']) ))
    
    #BK.entry
    #normalie whitesapce and " and ,
    output_graph.add((Transaction, BK.entry,  Literal(normalizedEntry) ))
    
    output_graph.add((Transaction, BK.consistsOf,  Transfer1))
    if(row['BK_COMMODITY']):
        output_graph.add((Transaction, BK.consistsOf,  Transfer2))
    output_graph.add((Transaction, BK.type,  Literal(row['OBJECT_'])))
    output_graph.add((Transaction, GAMS.isMemberOfCollection,  URIRef(baseURL + CONTEXT) ))
    
    # isPartofRDF needed?
    #output_graph.add((Transaction, GAMS.isPartofTEI,  URIRef(baseURL + PID) ))
    
    #GAMS.textualContent
    output_graph.add((Transaction, GAMS.textualContent,  Literal(normalizedEntry) ))
    
    #TRANSFER 1
    output_graph.add((Transfer1, RDF.type,  BK.Transfer))
    output_graph.add((Transfer1, BK.transfers,  Measurable_Money1))
    if(row['BK_MONEY2'] != "0.0"):
        output_graph.add((Transfer1, BK.transfers, Measurable_Money2))
    if(row['BK_MONEY3'] != "0.0"):
        output_graph.add((Transfer1, BK.transfers, Measurable_Money3))
    output_graph.add((Transfer1, bk_from, From))
    output_graph.add((Transfer1, BK.to,  To ))
    #TRANSFER 2
    if(row['BK_COMMODITY']):
        output_graph.add((Transfer2, RDF.type,  BK.Transfer))
        output_graph.add((Transfer2, BK.transfers, Commodity))
        output_graph.add((Transfer2, BK.to, To))
        output_graph.add((Transfer2, bk_from, From))
    
    #MONEY: Money1, Livre
    output_graph.add((Measurable_Money1, RDF.type,  BK.Money))
    output_graph.add((Measurable_Money1, BK.unit, Literal('Livre tournois') ))
    output_graph.add((Measurable_Money1, BK.quantity, Literal(row['BK_MONEY1']) ))
    
    #MONEY: Money2, Sous
    if(row['BK_MONEY2'] != "0.0"):
        output_graph.add((Measurable_Money2, RDF.type,  BK.Money))
        output_graph.add((Measurable_Money2, BK.unit, Literal('Sous') ))
        output_graph.add((Measurable_Money2, BK.quantity, Literal(row['BK_MONEY2']) ))
    
    #MONEY: Money3, Deniers
    if(row['BK_MONEY3'] != "0.0"): 
        output_graph.add((Measurable_Money3, RDF.type,  BK.Money))
        output_graph.add((Measurable_Money3, BK.unit, Literal('Deniers') ))
        output_graph.add((Measurable_Money3, BK.quantity, Literal(row['BK_MONEY3']) ))
    
    #COMMODIY
    if(row['BK_COMMODITY']):
        output_graph.add((Commodity, RDF.type,  BK.Commodity))
        output_graph.add((Commodity, BK.commodity,  Literal(row['BK_COMMODITY']) ))
        output_graph.add((Commodity, BK.unit, Literal('Zwetschgen?') ))
        output_graph.add((Commodity, BK.quantity, Literal(row['QUANTITE1']) ))
         
    #BETWEEN
    # FROM with name, status and profession 
    output_graph.add((From, RDF.type,  BK.Between))
    output_graph.add((From, BK.name,  Literal(row['BK_NAME_FROM']) ))
    if row['BK_BETWEENPROFESSION']:
        output_graph.add((From, BK.profession,  Literal(row['BK_BETWEENPROFESSION']) ))
    if row['BK_BETWEENCIVILTE']:
        output_graph.add((From, BK.status,  Literal(row['BK_BETWEENCIVILTE']) ))
    # TO only ID    
    output_graph.add((To, RDF.type,  BK.Between))

####
# format="xml" creates plain rdf/XML (rdf:type bk:Entry)
# format="pretty-xml" ,  abbreviated RDF/XML syntax like bk:Entry
# format="turtle"
output_graph.serialize(destination='marprof.xml', format="pretty-xml")