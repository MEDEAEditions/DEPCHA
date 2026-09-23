# CSV to RDF for DEPCHA

`csvToRDF.py` converts a tabulated account book (CSV) with a JSON configuration into RDF/XML for a DEPCHA data object. The output follows the Bookkeeping Ontology model 1.2 in the shape that `depcha-TORDF.xsl` produces for TEI objects, so the same SPARQL queries and checks apply to CSV and TEI datasets. The void:Dataset header of every output states the model version with `dcterms:conformsTo <https://gams.uni-graz.at/o:depcha.bookkeeping-1.2>`.

## Setup

The script and its test declare their dependencies inline (PEP 723). [uv](https://docs.astral.sh/uv/) installs them on the first run, nothing else is needed.

## Usage

```
uv run csvToRDF.py gwfp/csvToRDF_config__Ledger_A.json --out-dir build
uv run csvToRDF.py gwfp/*.json --out-dir build --report build/report.json
uv run csvToRDF.py mvdb/mvdb_config.json --output build/mvdb.xml --pid o:depcha.mvdb.1
```

Options:

- `--out-dir DIR` writes `<OUTPUT-FILE-NAME>.xml` into `DIR`, the current directory by default. The generated files committed in this folder are earlier outputs, the Washington ones identical to the copies under `Collections/Washington/rdf`, so write new output elsewhere and compare before replacing them.
- `--output FILE` sets the output file of a single config.
- `--csv FILE`, `--pid PID` and `--context PID` replace `FILENAME`, `PID` and `CONTEXT` of a single config.
- `--base-url URL` replaces `BASE_URL`, default `https://gams.uni-graz.at/`.
- `--report FILE` writes counts, skipped rows and every collected error as JSON.

A missing or inconsistent config, a missing CSV or a CSV that is not UTF-8 stops the run before any output is written. Problems in single cells (an amount or a date that cannot be read, an agent name that yields no IRI) are collected instead. The RDF is written without the affected statements, the errors are listed at the end with their CSV line, and the exit code is 1. Exit code 0 means every cell was converted.

## Configuration

One JSON file per data object. The CSV path is resolved relative to the config file.

| Field | Required | Content |
|---|---|---|
| `FILENAME` | yes | CSV file, UTF-8 |
| `CONTEXT` | yes | collection PID, for example `context:depcha.gwfp` |
| `PID` | yes | object PID, for example `o:depcha.gwfp.1` |
| `OUTPUT-FILE-NAME` | yes, unless `--output` | output name without `.xml` |
| `BK_CURRENCY.currency` | yes | list of units with `id`, `unit` and optionally `conversion` with `convertsTo` and `formula` (`$BaseUnit / <number>`). The first unit is the main currency. The n-th `BK_MONEY` column holds the unit with id `"n"`. |
| `depcha_accountHolder_label`, `depcha_accountHolder_id` | yes | account holder, IRI `<CONTEXT>#<id>` |
| `TOTAL_MARKER` | no | text in `BK_ENTRY` that marks a total row, `[Total]` for the Washington ledgers |
| `SKIP_ENTRY_MARKERS` | no | texts in `BK_ENTRY` that mark rows which are not transactions, such as carry-overs |
| `DEPCHA_DATASET_DC_METADATA` | no | `title`, `creator`, `date`, `contributor`, `language`, `source`, `subject` as Dublin Core statements of the dataset. When present, the project-level relation, publisher and rights statements are added. |
| `BASE_URL` | no | base of all IRIs |

## CSV columns

Header names are normalised to lower case, spaces become underscores and brackets are removed. The following columns have a role, all others are ignored.

- `BK_ENTRY` makes each non-empty row a `bk:Transaction` (`<PID>#T<row>`, the row counted from 0 after the header) or, with the total marker, a `bk:TotalTransaction` (`<PID>#To<row>`). Rows without entry or with a skip marker are skipped and counted.
- `BK_ID` replaces the row number in the IRI (`<PID>#T<id>`). Rows with the same id form one transaction.
- `BK_WHEN` becomes `bk:when` at the precision the text gives, `YYYY`, `YYYY-MM` or `YYYY-MM-DD`. A date without an explicit four-digit year is reported and left out.
- `BK_MONEY` columns, in order, become `bk:Money` with `bk:quantity` and `bk:unit` inside one `bk:Transfer` (`<IRI>TM`). A comma is read as decimal separator, `1 1/2` as a fraction.
- `BK_DEBIT_CREDIT` containing "debit" or "credit" becomes `bk:debit` or `bk:credit`. With `BK_ECONOMIC_UNIT`, a debit is a transfer from the named agent to the account holder and a credit the reverse.
- `BK_ECONOMIC_UNIT` names the counterparty. Each distinct name becomes a `bk:EconomicAgent` with IRI `<PID>#<name without spaces, commas, brackets and characters not allowed in IRIs>`.
- `BK_WHAT` columns with `BK_QUANTITY` become `bk:Measurable` with `bk:what` and `bk:quantity`, used by mvdb.

The `depcha:Dataset` node (`<PID>#Dataset`) carries the counters and one `depcha:Aggregation` per year of the dated transactions. Revenue sums the transfers to the account holder, expenses those from the account holder, in the main currency and in units that convert directly to it, as `depcha-TORDF.xsl` does.

## Checks

```
uv run test_csvToRDF.py
uvx ruff check --select E,F,W,I,UP,B,C4,SIM,PTH,RUF --ignore E501 csvToRDF.py test_csvToRDF.py
uvx ruff format --check csvToRDF.py test_csvToRDF.py
```

The test converts `gwfp/GWFP_Ledger_C_minimal.csv` and compares the result with `test_expected_Ledger_minimal.nt`. It also checks that every `bk:from` and `bk:to` target is a defined agent, that the header states the model version and that each yearly revenue and expense equals the sum recomputed from the transfers in the graph. A deliberate change of the output requires regenerating the expected file and reviewing its difference.

## Datasets in this folder

- `gwfp/` holds the four Washington configs, general ledgers A, B and C and a minimal sample. Their CSVs contain misaligned rows, so dates, names and amounts sometimes stand in the wrong column. The run reports these cells. Carry-over rows are recognised only by the configured markers, while the ledgers use further wordings such as "Carried forward" or "Amount brought forward".
- `mvdb/mvdb_config.json` converts `mvdb_all_bk_small.csv`, records of printing, sales and pulping of music editions (`print`, `sales`, `maculation`), into transactions with `bk:Measurable`.
- `mvdb/csvToRDF_config__Ledger_C.json` and `example/` hold older copies of Washington data whose agent column is still named `BK_BETWEEN`, so their output has no agents and no revenue or expenses.
- `marprof/` holds the Marprof CSV and `marprof.ttl` from a 2020 version of this workflow. Its CSV has another column layout (account ids in `BK_FROM` and `BK_TO`) and is not UTF-8, and its config names a file that does not exist, so the current script does not convert it. `marprof/marprof.xml` contains Washington data (`o:gfwp.1`) despite its name.
