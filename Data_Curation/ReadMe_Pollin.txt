Titel:CSV to XML
Author: Christopher Pollin 

Add bookkeeping concepts in the first row for identifie the connection data to bk-ontology.
like:

|bk_from|bk_to|bk_when|bk_text|
|chris|georg|1991-01-01|chris gives georg 2 apples|

csvToTEI.xsl

Transform a CSV-File to a TEI/XML with row and cells and its @ana connection to the bk-ontology.
It reads the first row (header), identifie every colomn to its bk-ontology connection and applys the specific rules for it. 
