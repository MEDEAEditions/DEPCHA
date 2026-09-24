# Schema

`depcha.odd` is the TEI profile of the DEPCHA account books. It admits the whole of TEI and adds the requirements of the RDF transformation `depcha-TORDF.xsl` in the presentation repository [gams-www](https://zimlab.uni-graz.at/gams/projects/depcha/gams-www) as ISO Schematron in `constraintSpec` elements. Every constraint states in its description which behaviour of the transformation it protects.

## Severity

A constraint with the role `error` marks data on which the transformation aborts, produces no usable graph, or meets an annotation token the profile does not define. A constraint with the role `warning` marks data the transformation accepts while the RDF loses or misplaces information, such as a dangling reference or an amount that drops out of the yearly totals. The harness check exits with a failure on any error, and with `--strict` also on any warning.

## Vocabulary

The `bk:` and `depcha:` tokens allowed in `@ana` are the tokens the transformation tests for, together with `bk:price` and `bk:agent`, which the annotation tutorial documents although model 1.2 of the Bookkeeping Ontology does not map them. Any other token with these prefixes is an error. A new token enters the list in the ODD together with its mapping in the transformation or its documentation in the tutorial.

## Validation

The local harness of the presentation repository validates every TEI file of this repository against the profile with `uv run check_tei.py` in `local-test-build/`. It extracts the Schematron from the ODD and runs it with lxml, which needs no Java runtime. The rules are written in XPath 1.0 for that reason. The expressions used are also valid XPath 2.0, so the profile should compile with the TEI Stylesheets and their XSLT 2.0 binding, which has not been tested for lack of a Java runtime. The extracted Schematron is a build product and is not kept here.

The check does not replace validation against `tei_all.rng`, which the TEI files reference and which remains the test of TEI conformance.

## Other files

`Bookkeeping.xsd` and `xml.xsd` are an XML Schema of 2018 for a reduced TEI subset. The TEI files under `Collections/*/TEI` do not reference it, and the profile does not derive from it.

## Licence

CC BY 4.0.
