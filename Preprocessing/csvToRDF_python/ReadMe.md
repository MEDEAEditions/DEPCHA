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