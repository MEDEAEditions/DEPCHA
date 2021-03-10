# Notes

* all bk:Entry with the string "[Total]" are bk:Sum; they don't have a bk:when
* Q: are there normalized dates (bk:when) in the GWFP-export?
* Q: there are empty rows in the csv. do they have a meaning?
* 1 Pound = 20 Shilling = 240 pence (?)  --> than pence are more or less irrelevant? like 19pence are 0.03 pound? (if you do rounding; infovis)
* Q: income and expense
  * its an income if in column "BK_DEBIT_CREDIT"  --> Debit
  * its an expense if in column "BK_DEBIT_CREDIT"  -->Credit
  * row exists with no Debit or Credit in BK_DEBIT_CREDIT
* first columns defines the type
  * bk:Transaction
    * bk:Income
    * bk:Expense
  * bk:Transaction with $ and cents (?)
  * mark entries with [Total] as bk:sum, as they have other useage
* i think its necessary to explicitly say that expense or income is 0 (d3.js, d3.max())
* normalization of persons is needed like a person-id 

## Errors found in Data

*  <bk:date>1969</bk:date>



### GWFP_Ledger_C_1790_1799

* what means this line: 
  To Amount Brought over



this are nor bk:entry: 

* [Total]
* To amount brought forward from
* Carried to Folio 350

this row must be clearly define as no bk:Transaction; so it needs a column bk:Type