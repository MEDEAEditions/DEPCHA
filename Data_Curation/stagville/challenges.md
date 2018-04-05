### Encoding gaps

Several isseus came up relating to original encoding within FromThePage, and should be addressed through more markup or feature development.

#### Implicit Party
We need a way to encode the implicit party, Stagville Plantation Store.  Maybe in the work metadata?  Maybe in a top section heading?  Bang notation?

#### "P Pins"?
`P Pins` is marked up as a subject in the encoding.  Is `"P"` actually a unit of measure?  The resulting export shows
```xml
                        <measure commodity="pins" quantity="1">
                           1
                           <rs ref="#S10566">P Pins</rs>
                           3/-
                        </measure>
```

##### "Son"?
We should mark up references like "Son" when possible, so that they get their own `rs`:
```xml
               <head ana="#bk_party #bk_from #bk_account" depth="2">
                  69
                  <rs ref="#S14350">Nathaniel Carrington</rs>
                  PP Son Dr.
               </head>
```

#### "PP Order Dr"?
What does "PP Order Dr" mean?


### Export/Transformation gaps

#### Dates
The date columns could be automatically populated using some smart understanding of ditto marks and times.

For example:
```xml
                     <cell ana="#bk_when">16</cell>
                     <cell ana="#bk_when">"</cell>
```
could be transformed (with knowledge that the cell represented a date, and that the date was likely the day of a month in August, 1808:
```xml
                     <cell ana="#bk_when" when="1808-08-16">16</cell>
                     <cell ana="#bk_when" when="1808-08-16">"</cell>
```
Empty date columns can be filled in by header information:
```xml
               <head depth="3">Stagville August 4th 1808</head>
```

#### Inline parties
People mentioned inline as parties within the entries are marked as commodities rather than participants, e.g.
```xml
                        <measure commodity="Henry" quantity="1/-" unit="PP">
                           1/- PP
                           <rs ref="#S10793">B. Henry</rs>
                        </measure>
```

#### `#bk_from` vs. `#bk_to`
Accounts are marked as `#bk_from` when they probably should be `#bk_to`




### Challenges

Some commodity unit names are non-standard: `yds` vs. `yd` or `Peck`.  This is a function of deriving the unit from the verbatim transcription, and should perhaps be standardized during post-processing.


### Questions for Discussion

#### Price Encoding

Prices are very important for Stagville; they are also consistently encoded and relatively easy to extract.  I did not encode these, as I'm not clear on whether the price measure should appear within the commodity measure, now how `#bk_price` relates to `#bk_amount`

Example:
```xml
                  <row ana="#bk_entry">
                     <cell ana="#bk_when"   when="1808-08-01"/>
                     <cell ana="#bk_what">
                        <measure commodity="knife">
                           <rs ref="#S10758">Shoe Knife</rs>
                           1/6
                        </measure>
                     </cell>
                     <cell ana="#bk_amount">
                        <measure commodity="currency" unit="pounds" />
                     </cell>
                     <cell ana="#bk_amount">
                        <measure commodity="currency" quantity="1" unit="shillings">1</measure>
                     </cell>
                     <cell ana="#bk_amount">
                        <measure commodity="currency" quantity="6" unit="pence">6</measure>
                     </cell>
                  </row>
```

The price of the knife is 1/6.  Assuming we translate `"1/6"` to `18d`, this could be encoded as 
```xml
                     <cell ana="#bk_what">
                        <measure commodity="knife">
                           <rs ref="#S10758">Shoe Knife</rs>
                           <measure commodity="currency" quantity="18" unit="pence">
			      1/6
			   </measure>
                        </measure>
                     </cell>
```
or as 
```xml
                     <cell ana="#bk_what">
                        <measure commodity="knife">
                           <rs ref="#S10758">Shoe Knife</rs>
                        </measure>
		        <measure commodity="currency" quantity="18" unit="pence">
			   1/6
			</measure>
                     </cell>
```

#### Total Encoding
Most accounting tables in the Stagville documents include a total line under the accounts themselves.  I've encoded these without `#bk_entry` but retained the `#bk_amount` mark-up, as well as the `measure` elements.  Is this correct?  What do we expect to do with the totals?

#### Agent as Party?
Should an agent of the account be marked as `#bk_party`?

#### Transfers of Money?
Should the monetary value of the entry be encoded as a transfer from the purchaser to the seller?  I think I need some examples of how this would work.  Additional question: When there is a purchase made on credit, does the seller receive the transfer then (a transfer of credit) or when the debt is paid (a transfer of currency, _perhaps_)?
