# Marprof Gradis

## Workflow

* inserting SQL-dump (marprofgradis.sql) into a SQL database
* cleaning up SQL dump: removing all phpMyAdmin (version 4.4.10) specific statments 
  * maybe information loss?
* SQL-Query (bk_data_extraction.sql) extracts all relevant data which can be mapped to the BK-Ontology.
* CSV-Export from this SQL-Query
* CSV to RDF/XML via Python Script
* ingest RDF/XML as RDF-Object in GAMS

* how to connect metadata in this workflow?

## Notes

* all entries with "1" in column NIVEAU are sums ?
* missing are still all sub-quantities
* ID_COMPTE_CREDITEUR (bk:from) and ID_COMPTE_DEBITEUR (bk:to) define bk:from and bk:to
* unit (Baril, ID=26) for commodities?
* LIEU_ID = bk:where ?

 
## Graphical Tepresentation of the Relational DB

* (can not find mail)