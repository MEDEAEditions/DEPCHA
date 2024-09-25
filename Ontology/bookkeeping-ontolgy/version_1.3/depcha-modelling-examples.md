# Medieval Manor Account (1352)

## Ontology Model

```turtle
# Transactions - Income
:transaction1352_rent a bk:Transaction ;
    bk:when [ a bk:Date ; bk:pointInTime "1352-03-15"^^xsd:date ] ;
    bk:where :manor_estate ;
    bk:consistsOf :transfer1352_rent_land, :transfer1352_rent_payment .

:transfer1352_rent_land a bk:Transfer ;
    bk:from :manor ;
    bk:to :tenant_john ;
    bk:transfers [ a bk:Right ;
        bk:quantity "5"^^xsd:decimal ;
        bk:unit :acre ] .

:transfer1352_rent_payment a bk:Transfer ;
    bk:from :tenant_john ;
    bk:to :manor ;
    bk:transfers [ a bk:Money ;
        bk:quantity "600"^^xsd:decimal ;
        bk:unit :penny ] .

:transaction1352_wheat_sale a bk:Transaction ;
    bk:when [ a bk:Date ; bk:pointInTime "1352-05-01"^^xsd:date ] ;
    bk:where :local_market ;
    bk:consistsOf :transfer1352_wheat_sale, :transfer1352_wheat_payment .

:transfer1352_wheat_sale a bk:Transfer ;
    bk:from :manor ;
    bk:to :market_buyers ;
    bk:transfers [ a bk:Commodity ;
        bk:quantity "10"^^xsd:decimal ;
        bk:unit :bushel ;
        bk:classified :wheat ] .

:transfer1352_wheat_payment a bk:Transfer ;
    bk:from :market_buyers ;
    bk:to :manor ;
    bk:transfers [ a bk:Money ;
        bk:quantity "480"^^xsd:decimal ;
        bk:unit :penny ] .

:transaction1352_court_fines a bk:Transaction ;
    bk:when [ a bk:Date ; bk:pointInTime "1352-06-10"^^xsd:date ] ;
    bk:where :manor_court ;
    bk:consistsOf :transfer1352_court_fines .

:transfer1352_court_fines a bk:Transfer ;
    bk:from :offenders ;
    bk:to :manor ;
    bk:transfers [ a bk:Money ;
        bk:quantity "306"^^xsd:decimal ;
        bk:unit :penny ] .

# Transactions - Expenses
:transaction1352_mill_repairs a bk:Transaction ;
    bk:when [ a bk:Date ; bk:starts "1352-04-02"^^xsd:date ; bk:ends "1352-04-06"^^xsd:date ] ;
    bk:where :manor_mill ;
    bk:consistsOf :transfer1352_mill_repairs_service, :transfer1352_mill_repairs_payment .

:transfer1352_mill_repairs_service a bk:Transfer ;
    bk:from :miller_tom ;
    bk:to :manor ;
    bk:transfers [ a bk:Service ;
        bk:quantity "5"^^xsd:decimal ;
        bk:unit :day ] .

:transfer1352_mill_repairs_payment a bk:Transfer ;
    bk:from :manor ;
    bk:to :miller_tom ;
    bk:transfers [ a bk:Money ;
        bk:quantity "120"^^xsd:decimal ;
        bk:unit :penny ] .

:transaction1352_wheat_harvest a bk:Transaction ;
    bk:when [ a bk:Date ; bk:pointInTime "1352-07-15"^^xsd:date ] ;
    bk:where :manor_fields ;
    bk:consistsOf :transfer1352_wheat_harvest_service, :transfer1352_wheat_harvest_payment .

:transfer1352_wheat_harvest_service a bk:Transfer ;
    bk:from :harvester_group ;
    bk:to :manor ;
    bk:transfers [ a bk:Service ;
        bk:quantity "20"^^xsd:decimal ;
        bk:unit :acre ] .

:transfer1352_wheat_harvest_payment a bk:Transfer ;
    bk:from :manor ;
    bk:to :harvester_group ;
    bk:transfers [ a bk:Money ;
        bk:quantity "240"^^xsd:decimal ;
        bk:unit :penny ] .

# Summary
:summary1352 a bk:TotalTransaction ;
    bk:when [ a bk:Date ; bk:starts "1352-03-15"^^xsd:date ; bk:ends "1352-07-15"^^xsd:date ] ;
    bk:comprises 
        [ a bk:Money ; bk:quantity "1386"^^xsd:decimal ; bk:unit :penny ] , # Total Income
        [ a bk:Money ; bk:quantity "360"^^xsd:decimal ; bk:unit :penny ] ,  # Total Expenses
        [ a bk:Money ; bk:quantity "1026"^^xsd:decimal ; bk:unit :penny ] . # Balance

# Economic Agents
:manor a bk:Organisation .
:tenant_john a bk:Individual .
:market_buyers a bk:Group .
:offenders a bk:Group .
:miller_tom a bk:Individual .
:harvester_group a bk:Group .

# Places
:manor_estate a bk:Place .
:local_market a bk:Place .
:manor_court a bk:Place .
:manor_mill a bk:Place .
:manor_fields a bk:Place .
```

## Description

This ontology model represents a Medieval Manor Account from 1352, showcasing various economic transactions and activities typical of a manor during this period. The model uses the Bookkeeping Ontology to structure the information in a standardized format.

### Key Components:

1. **Transactions**: The model includes several transactions, each represented as a `bk:Transaction`. These are divided into income and expense categories.

2. **Transfers**: Each transaction consists of one or more transfers (`bk:Transfer`), representing the movement of goods, services, or money between economic agents.

3. **Economic Agents**: Various parties involved in the transactions are modeled as subclasses of `bk:EconomicAgent`, including the manor itself (`bk:Organisation`), individuals like Tenant John and Miller Tom (`bk:Individual`), and groups like market buyers and harvesters (`bk:Group`).

4. **Economic Assets**: The model represents different types of economic assets:
   - Land rights are modeled as `bk:Right`
   - Commodities like wheat are represented as `bk:Commodity`
   - Services such as mill repairs and harvesting are modeled as `bk:Service`
   - Money is consistently represented using `bk:Money`, with amounts in pennies

5. **Temporal Information**: Each transaction includes temporal data using `bk:Date`, either as a specific point in time (`bk:pointInTime`) or a range (`bk:starts` and `bk:ends`).

6. **Spatial Information**: Locations are included using `bk:where`, linking transactions to specific places on the manor.

7. **Summary**: The model includes a summary of all transactions using `bk:TotalTransaction`, providing totals for income, expenses, and the overall balance.
