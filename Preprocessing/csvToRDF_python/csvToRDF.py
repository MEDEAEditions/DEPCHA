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
CONTEXT = "context:marprof"
PID = "o:marprof.1"

# make a graph
output_graph = Graph()
# define namespace in output file
output_graph.bind("bk", BK)
output_graph.bind("gams", GAMS)

# from is reserved term
bk_from = URIRef("https://gams.uni-graz.at/o:depcha.bookkeeping#from")

for count, row in enumerate(input_file):
    # convert it from an OrderedDict to a regular dict
    row = dict(row)
 
    # URIs
    Transaction = URIRef(baseURL + PID + "#T" + str(count))
    Transfer = URIRef(baseURL + PID + "#T" + str(count) + "T1")
    Measurable_Money1 = URIRef(baseURL + PID + "#T" + str(count) + "M1")
    Measurable_Money2 = URIRef(baseURL + PID + "#T" + str(count) + "M2")
    Measurable_Money3 = URIRef(baseURL + PID + "#T" + str(count) + "M3")
    
    Between = URIRef(baseURL + PID + "#pers." + row['BK_BETWEENID'])
    # Data
    normalizedEntry = " ".join(row['BK_ENTRY'].split())
    
    #TRANSACTION
    output_graph.add((Transaction, RDF.type,  BK.Transaction))
    output_graph.add((Transaction, BK.when,  Literal(row['BK_WHEN']) ))
    # normalize whitespace
    output_graph.add((Transaction, BK.entry,  Literal(normalizedEntry) ))
    output_graph.add((Transaction, BK.consistsOf,  Transfer))
    output_graph.add((Transaction, BK.type,  Literal(row['OBJECT_'])))
    output_graph.add((Transaction, GAMS.isMemberOfCollection,  URIRef(baseURL + CONTEXT) ))
    output_graph.add((Transaction, GAMS.isPartofTEI,  URIRef(baseURL + PID) ))
    output_graph.add((Transaction, GAMS.textualContent,  Literal(normalizedEntry) ))
    
    #TRNSFER
    output_graph.add((Transfer, RDF.type,  BK.Transfer))
    output_graph.add((Transfer, BK.transfers,  Measurable_Money1))
    if(row['BK_MONEY2'] != "0.0"):
        output_graph.add((Transfer, BK.transfers,  Measurable_Money2))
    if(row['BK_MONEY3'] != "0.0"):
        output_graph.add((Transfer, BK.transfers,  Measurable_Money3))
    output_graph.add((Transfer, bk_from, Between))
    output_graph.add((Transfer, BK.to,  URIRef(baseURL + PID + "#pers." + 'AGENT0') ))
    
    #Measurable:Money1, Livre
    output_graph.add((Measurable_Money1, RDF.type,  BK.Money))
    output_graph.add((Measurable_Money1, BK.unit, Literal('Livre tournois') ))
    output_graph.add((Measurable_Money1, BK.quantity,  Literal(row['BK_MONEY1']) ))
    
    #Measurable:Money2, Sous
    if(row['BK_MONEY2'] != "0.0"):
        output_graph.add((Measurable_Money2, RDF.type,  BK.Money))
        output_graph.add((Measurable_Money2, BK.unit, Literal('Sous') ))
        output_graph.add((Measurable_Money2, BK.quantity,  Literal(row['BK_MONEY2']) ))
    
    #Measurable:Money3, Deniers
    if(row['BK_MONEY3'] != "0.0"): 
        output_graph.add((Measurable_Money3, RDF.type,  BK.Money))
        output_graph.add((Measurable_Money3, BK.unit, Literal('Deniers') ))
        output_graph.add((Measurable_Money3, BK.quantity,  Literal(row['BK_MONEY3']) ))
    
    #BETWEEN
    output_graph.add((Between, RDF.type,  BK.Between))
    output_graph.add((Between, BK.name,  Literal(row['BK_NAME']) ))
    
    if row['BK_BETWEENPROFESSION']:
        output_graph.add((Between, BK.profession,  Literal(row['BK_BETWEENPROFESSION']) ))
    
    if row['BK_BETWEENCIVILTE']:
        output_graph.add((Between, BK.status,  Literal(row['BK_BETWEENCIVILTE']) ))

    
    

output_graph.serialize(destination='marprof.ttl', format="turtle")