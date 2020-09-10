import csv
from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.namespace import DCTERMS, RDF, RDFS, SKOS, XSD
import pandas as pd


input_file = csv.DictReader(open("magprof.csv"))

BK = Namespace("https://gams.uni-graz.at/o:depcha.bookkeeping#")

baseURL = "https://gams.uni-graz.at/"
context = "context:marprof"
PID = "o:marprof.1"

# make a graph
output_graph = Graph()
output_graph.bind("bk", BK)

# from is reserved term
bk_from = URIRef("https://gams.uni-graz.at/o:depcha.bookkeeping#from")

for count, row in enumerate(input_file):
    # convert it from an OrderedDict to a regular dict
    row = dict(row)
    
    #TRANSACTION
    Transaction = URIRef(baseURL + PID + "#T" + str(count))
    Transfer = URIRef(baseURL + PID + "#T" + str(count) + "T1")
    Measurable = URIRef(baseURL + PID + "#T" + str(count) + "M1")
    Between = URIRef(baseURL + PID + "#pers." + row['BK_BETWEENID'])
    
    output_graph.add((Transaction, RDF.type,  BK.Transaction))
    output_graph.add((Transaction, BK.when,  Literal(row['BK_WHEN']) ))
    output_graph.add((Transaction, BK.entry,  Literal(row['BK_ENTRY']) ))
    output_graph.add((Transaction, BK.consistsOf,  Transfer))
    
    #TRNSFER
    output_graph.add((Transfer, RDF.type,  BK.Transfer))
    output_graph.add((Transfer, BK.transfers,  Measurable))
    output_graph.add((Transfer, bk_from, Between))
    output_graph.add((Transfer, BK.to,  URIRef(baseURL + PID + "#pers." + 'AGENT0') ))
    
    #Measurable
    output_graph.add((Measurable, RDF.type,  BK.Money))
    output_graph.add((Transfer, BK.unit, Literal(row['BK_CURRENCY'])))
    output_graph.add((Transfer, BK.quantity,  Literal(row['BK_MONEY1']) ))
    
    #BETWEEN
    output_graph.add((Between, RDF.type,  BK.Between))
    output_graph.add((Between, BK.name,  Literal(row['BK_NAME']) ))
    
    if row['BK_BETWEENPROFESSION']:
        output_graph.add((Between, BK.profession,  Literal(row['BK_BETWEENPROFESSION']) ))
    
    if row['BK_BETWEENCIVILTE']:
        output_graph.add((Between, BK.status,  Literal(row['BK_BETWEENCIVILTE']) ))

    
    

output_graph.serialize(destination='marprof.ttl', format="turtle")