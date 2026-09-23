# /// script
# requires-python = ">=3.11"
# dependencies = ["rdflib>=7,<8", "python-dateutil>=2.8"]
# ///
"""Convert a tabulated account book (CSV) into DEPCHA RDF, Bookkeeping Ontology model 1.2.

Purpose
    Sources for which TEI encoding is impractical enter DEPCHA as CSV plus a JSON
    configuration. The RDF produced here has the model 1.2 shape that
    depcha-TORDF.xsl produces for TEI objects (bk:Transaction, bk:Transfer,
    bk:Money, bk:EconomicAgent, depcha:Dataset with yearly depcha:Aggregation,
    huc:HistoricalUnit), so the same queries and checks apply to both paths.

Data flow
    JSON config (+ command-line overrides) -> CSV rows -> rdflib graph -> RDF/XML
    file. Each row becomes a bk:Transaction or bk:TotalTransaction, or is skipped.
    Problems in single cells are collected, reported at the end and signalled by
    exit code 1; the RDF is written regardless, without the faulty statements.

Usage
    uv run csvToRDF.py gwfp/csvToRDF_config__Ledger_A.json --out-dir build
    uv run csvToRDF.py gwfp/*.json --out-dir build --report build/report.json
    uv run csvToRDF.py mvdb/mvdb_config.json --output build/mvdb.xml --pid o:depcha.mvdb.1

Design decisions
    - Column roles come from normalised header names (bk_entry, bk_id, bk_when,
      bk_debit_credit, bk_economic_unit, bk_money*, bk_what*, bk_quantity). The
      n-th bk_money column holds the currency whose config id is "n".
    - Resource IRIs of transactions, transfers, amounts, dataset and aggregations
      are kept from the 2022 script, so a re-ingest keeps their identity. Agent
      IRIs are <PID>#<fragment>; the 2022 script omitted the "#".
    - Literal escaping (quotes in entries and labels) is kept as in the 2022
      script, because removing it is an open decision for model 1.2
      (ZIMLAB depcha knowledge/specification.md, Open decisions).
    - The void:Dataset header states the model version with dcterms:conformsTo.
      A dcterms:source is not written, because the GAMS objects of CSV datasets
      hold no datastream with the CSV to point to.
    - Revenue and expenses follow depcha-TORDF.xsl: only dated bk:Transaction
      resources whose transfer goes to (revenue) or from (expenses) the account
      holder count, with amounts in the main currency or in a unit that converts
      directly to it.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import tempfile
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

import dateutil.parser
from rdflib import FOAF, RDF, RDFS, Graph, Literal, Namespace, URIRef
from rdflib.namespace import DC, DCTERMS

BK = Namespace("https://gams.uni-graz.at/o:depcha.bookkeeping#")
DEPCHA = Namespace("https://gams.uni-graz.at/o:depcha.ontology#")
GAMS = Namespace("https://gams.uni-graz.at/o:gams-ontology#")
HUC = Namespace("https://gams.uni-graz.at/o:depcha.huc-ontology#")
SCHEMA = Namespace("https://schema.org/")
VOID = Namespace("http://rdfs.org/ns/void#")

MODEL_VERSION_IRI = URIRef("https://gams.uni-graz.at/o:depcha.bookkeeping-1.2")
DEFAULT_BASE_URL = "https://gams.uni-graz.at/"
DC_METADATA_KEYS = (
    "title",
    "creator",
    "date",
    "contributor",
    "language",
    "source",
    "subject",
)
# Project-level statements every DEPCHA CSV dataset carried since 2021.
STATIC_DC = (
    (DC.relation, "Digital Edition Publishing Cooperative for Historical Accounts"),
    (DC.relation, "http://gams.uni-graz.at/depcha"),
    (DC.publisher, "Institute Centre for Information Modelling, University of Graz"),
    (DC.rights, "Creative Commons BY 4.0"),
    (DC.rights, "https://creativecommons.org/licenses/by/4.0"),
)

# Characters that may not appear in an IRI fragment, plus separators of the name.
_FRAGMENT_DROP = re.compile(r'[\s,()\[\]<>"{}|\\^`#%]')
_IRI_TOKEN = re.compile(r'^[^\s#<>"{}|\\^`]+$')
_FORMULA = re.compile(r"^\$BaseUnit\s*/\s*(\d+(?:\.\d+)?)$")
_FRACTION = re.compile(r"(?:(\d+)\s+)?(\d+)\s*/\s*(\d+)")
_DECIMAL = re.compile(r"\d+(?:\.\d*)?|\.\d+")
_FOUR_DIGITS = re.compile(r"\d{4}")
# Fragments the script mints itself inside <PID>#: transactions, totals, their
# transfers and amounts, the dataset node and the yearly aggregations.
_RESERVED_FRAGMENT = re.compile(r"(?:To?\d+(?:TM|M\d+)?|Dataset|\d{4})")


@dataclass(frozen=True)
class Currency:
    id: str
    unit: str
    converts_to: str | None = None
    formula: str | None = None
    divisor: float | None = None


@dataclass(frozen=True)
class Config:
    source: Path
    csv_path: Path
    output_path: Path
    base_url: str
    context: str
    pid: str
    holder_id: str
    holder_label: str
    currencies: tuple[Currency, ...]
    dc_metadata: dict[str, str]
    total_marker: str | None
    skip_markers: tuple[str, ...]


@dataclass
class Report:
    config: str
    output: str = ""
    counts: Counter[str] = field(default_factory=Counter)
    skipped: Counter[str] = field(default_factory=Counter)
    errors: list[dict[str, Any]] = field(default_factory=list)

    def error(
        self, kind: str, row: int | None, line: int | None, column: str, value: str
    ) -> None:
        self.errors.append(
            {"kind": kind, "row": row, "line": line, "column": column, "value": value}
        )

    def to_dict(self) -> dict[str, Any]:
        return {
            "config": self.config,
            "output": self.output,
            "counts": dict(self.counts),
            "skipped": dict(self.skipped),
            "errors": self.errors,
        }


@dataclass
class Table:
    """CSV content with normalised column names; duplicated names keep their positions."""

    columns: list[str]
    rows: list[tuple[int, int, list[str]]]  # (row index, source line, cells)

    def first(self, name: str) -> int | None:
        return self.columns.index(name) if name in self.columns else None

    def containing(self, part: str) -> list[int]:
        return [i for i, c in enumerate(self.columns) if part in c]


# Configuration and input (trust boundary: fail fast)


def _require(data: dict[str, Any], key: str, where: Path) -> Any:
    value = data.get(key)
    if value in (None, "", [], {}):
        raise SystemExit(
            f"ERROR: {where}: required config field '{key}' is missing or empty"
        )
    return value


def _iri_token(value: str, key: str, where: Path) -> str:
    if not _IRI_TOKEN.match(value):
        raise SystemExit(
            f"ERROR: {where}: '{key}' = {value!r} cannot be used inside an IRI"
        )
    return value


def _load_currencies(data: dict[str, Any], where: Path) -> tuple[Currency, ...]:
    entries = _require(_require(data, "BK_CURRENCY", where), "currency", where)
    currencies = []
    for entry in entries:
        unit = _iri_token(str(_require(entry, "unit", where)), "unit", where)
        conversion = entry.get("conversion")
        if not conversion:
            currencies.append(Currency(id=str(_require(entry, "id", where)), unit=unit))
            continue
        formula = str(_require(conversion, "formula", where))
        match = _FORMULA.match(formula.strip())
        if not match:
            raise SystemExit(
                f"ERROR: {where}: formula {formula!r} of '{unit}' is not of the form '$BaseUnit / <number>'"
            )
        currencies.append(
            Currency(
                id=str(_require(entry, "id", where)),
                unit=unit,
                converts_to=str(_require(conversion, "convertsTo", where)),
                formula=formula,
                divisor=float(match.group(1)),
            )
        )
    ids = [c.id for c in currencies]
    units = {c.unit for c in currencies}
    if len(set(ids)) != len(ids):
        raise SystemExit(f"ERROR: {where}: currency ids are not unique: {ids}")
    for c in currencies:
        if c.converts_to is not None and c.converts_to not in units:
            raise SystemExit(
                f"ERROR: {where}: '{c.unit}' converts to unknown unit '{c.converts_to}'"
            )
    return tuple(currencies)


def load_config(path: Path, overrides: argparse.Namespace | None = None) -> Config:
    """Read a JSON config; command-line values replace the corresponding fields."""
    if not path.is_file():
        raise SystemExit(f"ERROR: config file not found: {path}")
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise SystemExit(f"ERROR: {path}: invalid JSON: {exc}") from exc
    o = overrides or argparse.Namespace()
    csv_path = Path(
        getattr(o, "csv", None) or path.parent / _require(data, "FILENAME", path)
    )
    if not csv_path.is_file():
        raise SystemExit(f"ERROR: {path}: CSV file not found: {csv_path}")
    if getattr(o, "output", None):
        output_path = Path(o.output)
    else:
        out_dir = Path(getattr(o, "out_dir", None) or ".")
        output_path = out_dir / f"{_require(data, 'OUTPUT-FILE-NAME', path)}.xml"
    base_url = getattr(o, "base_url", None) or data.get("BASE_URL") or DEFAULT_BASE_URL
    if not base_url.endswith("/"):
        raise SystemExit(f"ERROR: {path}: base URL must end with '/': {base_url}")
    metadata = data.get("DEPCHA_DATASET_DC_METADATA") or {}
    return Config(
        source=path,
        csv_path=csv_path,
        output_path=output_path,
        base_url=base_url,
        context=_iri_token(
            getattr(o, "context", None) or _require(data, "CONTEXT", path),
            "CONTEXT",
            path,
        ),
        pid=_iri_token(
            getattr(o, "pid", None) or _require(data, "PID", path), "PID", path
        ),
        holder_id=_iri_token(
            _require(data, "depcha_accountHolder_id", path),
            "depcha_accountHolder_id",
            path,
        ),
        holder_label=_require(data, "depcha_accountHolder_label", path),
        currencies=_load_currencies(data, path),
        dc_metadata={k: str(metadata[k]) for k in DC_METADATA_KEYS if metadata.get(k)},
        total_marker=data.get("TOTAL_MARKER") or None,
        skip_markers=tuple(data.get("SKIP_ENTRY_MARKERS") or ()),
    )


def _normalise_column(name: str) -> str:
    return name.strip().lower().replace(" ", "_").replace("(", "").replace(")", "")


def read_table(path: Path) -> Table:
    """Read the CSV as UTF-8.

    Completely blank lines are skipped without taking a row index, as pandas
    did in the 2022 script, because the index forms the transaction IRIs.
    """
    try:
        with path.open(encoding="utf-8-sig", newline="") as handle:
            reader = csv.reader(handle)
            header = next(reader, None)
            if header is None:
                raise SystemExit(f"ERROR: {path}: empty CSV file")
            rows = []
            for cells in reader:
                if not cells:
                    continue
                rows.append((len(rows), reader.line_num, cells))
    except UnicodeDecodeError as exc:
        raise SystemExit(
            f"ERROR: {path}: not UTF-8 ({exc}); convert the file to UTF-8"
        ) from exc
    return Table([_normalise_column(c) for c in header], rows)


# Cell-level parsing (per-row: skip, log, collect)


def parse_quantity(raw: str) -> float | None:
    """Parse an amount; a comma is a decimal separator, "1 1/2" a vulgar fraction."""
    text = raw.strip()
    fraction = _FRACTION.fullmatch(text)
    if fraction:
        whole, numerator, denominator = fraction.groups()
        if int(denominator) == 0:
            return None
        return int(whole or 0) + int(numerator) / int(denominator)
    text = text.replace(" ", "").replace(",", ".")
    return float(text) if _DECIMAL.fullmatch(text) else None


def parse_when(raw: str) -> str | None:
    """Return the date at the precision the source gives (YYYY, YYYY-MM or YYYY-MM-DD).

    Parsing twice with different defaults shows which parts the text supplies,
    so a missing month or day is never filled with the date of the run. A text
    without an explicit four-digit year yields None.
    """
    text = " ".join(raw.split())
    try:
        a = dateutil.parser.parse(text, default=datetime(1, 1, 1, tzinfo=UTC))
        b = dateutil.parser.parse(text, default=datetime(2, 2, 2, tzinfo=UTC))
    except (ValueError, OverflowError):
        return None
    if a.year != b.year or f"{a.year:04d}" not in _FOUR_DIGITS.findall(text):
        return None
    if a.month != b.month:
        return f"{a.year:04d}"
    if a.day != b.day:
        return f"{a.year:04d}-{a.month:02d}"
    return a.date().isoformat()


def agent_fragment(name: str) -> str:
    """Fragment of an agent IRI: the name without whitespace, commas, brackets and IRI-illegal characters."""
    return _FRAGMENT_DROP.sub("", name)


def _label(text: str) -> str:
    # Kept from the 2022 script: JSON-style quote escaping (open decision for model 1.2).
    return " ".join(text.replace('"', '\\"').split())


def _entry(text: str) -> str:
    # Kept from the 2022 script: double quotes become single quotes (open decision for
    # model 1.2). A line break inside the cell ("\r\n", "\r" or "\n") becomes one space.
    text = text.replace('"', "'")
    for control in ("\r\n", "\r", "\n", "\t", "\u000b"):
        text = text.replace(control, " ")
    return text.strip()


def _direction(raw: str | None) -> str | None:
    if raw is None:
        return None
    if re.search("debit", raw, re.IGNORECASE):
        return "debit"
    if re.search("credit", raw, re.IGNORECASE):
        return "credit"
    return None


# Graph construction


@dataclass
class _Columns:
    entry: int | None
    id: int | None
    when: int | None
    debit_credit: int | None
    agent: int | None
    quantity: int | None
    money: list[int]
    what: list[int]


def _columns(table: Table, config: Config) -> _Columns:
    cols = _Columns(
        entry=table.first("bk_entry"),
        id=table.first("bk_id"),
        when=table.first("bk_when"),
        debit_credit=table.first("bk_debit_credit"),
        agent=table.first("bk_economic_unit"),
        quantity=table.first("bk_quantity"),
        money=table.containing("bk_money"),
        what=table.containing("bk_what"),
    )
    if cols.entry is None and cols.id is None:
        raise SystemExit(
            f"ERROR: {config.csv_path}: needs a BK_ENTRY or a BK_ID column to identify transactions"
        )
    ids = {c.id for c in config.currencies}
    missing = [str(n) for n in range(len(cols.money)) if str(n) not in ids]
    if missing:
        raise SystemExit(
            f"ERROR: {config.source}: the CSV has {len(cols.money)} BK_MONEY columns, "
            f"but no currency with id {', '.join(missing)}"
        )
    return cols


def _cell(cells: list[str], index: int | None) -> str | None:
    # An empty cell is missing, as pandas treated it in the 2022 script.
    if index is None or index >= len(cells) or cells[index] == "":
        return None
    return cells[index]


def _add_header(g: Graph, config: Config, dataset: URIRef) -> None:
    g.add((dataset, RDF.type, VOID.Dataset))
    g.add((dataset, DCTERMS.conformsTo, MODEL_VERSION_IRI))
    g.add((dataset, FOAF.homepage, dataset))
    g.add((dataset, DCTERMS.modified, Literal(datetime.now(tz=UTC).date())))
    g.add((dataset, VOID.feature, URIRef("http://www.w3.org/ns/formats/RDF_XML")))
    # RDF-only GAMS objects keep their RDF in the ONTOLOGY datastream.
    g.add((dataset, VOID.dataDump, URIRef(f"{dataset}/ONTOLOGY")))
    for vocabulary in (
        "https://gams.uni-graz.at/o:depcha.bookkeeping#",
        "https://gams.uni-graz.at/o:gams-ontology#",
        "http://purl.org/dc/terms/",
        "http://www.ontology-of-units-of-measure.org/resource/om-2/",
    ):
        g.add((dataset, VOID.vocabulary, URIRef(vocabulary)))
    if config.dc_metadata:
        for key, value in config.dc_metadata.items():
            g.add((dataset, DC[key], Literal(value)))
        for predicate, value in STATIC_DC:
            g.add((dataset, predicate, Literal(value)))


def _add_agents(
    g: Graph, table: Table, cols: _Columns, config: Config, report: Report
) -> dict[str, URIRef]:
    """Create one bk:EconomicAgent per distinct name; report names that share an IRI."""
    agents: dict[str, URIRef] = {}
    labels_by_iri: dict[URIRef, set[str]] = defaultdict(set)
    seen: set[str] = set()
    for row, line, cells in table.rows:
        name = _cell(cells, cols.agent)
        if name is None or name in seen:
            continue
        seen.add(name)
        fragment = agent_fragment(name)
        if not fragment or _RESERVED_FRAGMENT.fullmatch(fragment):
            report.error("agent_without_iri", row, line, "bk_economic_unit", name)
            continue
        iri = URIRef(f"{config.base_url}{config.pid}#{fragment}")
        agents[name] = iri
        label = _label(name)
        if labels_by_iri[iri] and label not in labels_by_iri[iri]:
            report.error(
                "agent_iri_shared", row, line, "bk_economic_unit", f"{name} -> {iri}"
            )
        labels_by_iri[iri].add(label)
        g.add((iri, RDF.type, BK.EconomicAgent))
        g.add((iri, RDFS.label, Literal(label)))
        g.add((iri, SCHEMA.name, Literal(label)))
    report.counts["bk:EconomicAgent"] = len(labels_by_iri)
    return agents


def _convert(unit: Currency, quantity: float, main: Currency) -> float | None:
    if unit.unit == main.unit:
        return quantity
    if unit.converts_to == main.unit and unit.divisor:
        return quantity / unit.divisor
    return None


def build_graph(config: Config, table: Table, report: Report) -> Graph:
    """Map every row to RDF; cell problems go to the report, the row continues without them."""
    cols = _columns(table, config)
    g = Graph()
    for prefix, namespace in (
        ("bk", BK),
        ("gams", GAMS),
        ("void", VOID),
        ("foaf", FOAF),
        ("dcterms", DCTERMS),
        ("dc", DC),
        ("depcha", DEPCHA),
        ("huc", HUC),
        ("schema", SCHEMA),
    ):
        g.bind(prefix, namespace)

    base, pid = config.base_url, config.pid
    dataset = URIRef(base + pid)
    collection = URIRef(base + config.context)
    holder = URIRef(f"{base}{config.context}#{config.holder_id}")
    unit_iri = {
        c.id: URIRef(f"{base}{config.context}#{c.unit}") for c in config.currencies
    }
    currency_by_id = {c.id: c for c in config.currencies}
    main = config.currencies[0]

    _add_header(g, config, dataset)
    g.add((holder, RDF.type, BK.EconomicAgent))
    g.add((holder, RDFS.label, Literal(_label(config.holder_label))))
    agents = (
        _add_agents(g, table, cols, config, report) if cols.agent is not None else {}
    )

    revenue: dict[str, float] = defaultdict(float)
    expenses: dict[str, float] = defaultdict(float)
    years: set[str] = set()

    for row, line, cells in table.rows:
        entry = _cell(cells, cols.entry)
        if cols.id is not None:
            key = _cell(cells, cols.id)
            if key is None:
                report.error("missing_id", row, line, "bk_id", "")
                continue
        else:
            key = str(row)
        is_total = False
        if cols.entry is not None:
            if entry is None:
                report.skipped["empty bk_entry"] += 1
                continue
            is_total = bool(config.total_marker) and config.total_marker in entry
            if not is_total and any(marker in entry for marker in config.skip_markers):
                report.skipped["skip marker in bk_entry"] += 1
                continue

        subject = URIRef(f"{base}{pid}#{'To' if is_total else 'T'}{key}")
        g.add((subject, RDF.type, BK.TotalTransaction if is_total else BK.Transaction))
        if entry is not None:
            g.add((subject, BK.entry, Literal(_entry(entry))))
        g.add((subject, GAMS.isMemberOfCollection, collection))
        g.add((subject, GAMS.isPartOf, dataset))

        when = None
        raw_when = _cell(cells, cols.when)
        if raw_when is not None:
            when = parse_when(raw_when)
            if when is None:
                report.error("invalid_date", row, line, "bk_when", raw_when)
            else:
                g.add((subject, BK.when, Literal(when)))
                if not is_total:
                    years.add(when[:4])

        transfer = URIRef(f"{subject}TM")
        g.add((subject, BK.consistsOf, transfer))
        g.add((transfer, RDF.type, BK.Transfer))

        if cols.what and cols.quantity is not None:
            raw_quantity = _cell(cells, cols.quantity)
            quantity = None if raw_quantity is None else parse_quantity(raw_quantity)
            if raw_quantity is not None and quantity is None:
                report.error("invalid_amount", row, line, "bk_quantity", raw_quantity)
            elif quantity is not None and quantity.is_integer():
                # Whole counts stay xsd:integer, as pandas typed them in the 2022 script.
                quantity = int(quantity)
            for n, column in enumerate(cols.what):
                measurable = URIRef(f"{subject}M{n}")
                g.add((measurable, RDF.type, BK.Measurable))
                g.add((transfer, BK.transfers, measurable))
                what = _cell(cells, column)
                if what is not None:
                    g.add((measurable, BK.what, Literal(what)))
                if quantity is not None:
                    g.add((measurable, BK.quantity, Literal(quantity)))

        if not cols.money:
            continue
        amounts: list[tuple[Currency, float]] = []
        for n, column in enumerate(cols.money):
            raw = _cell(cells, column)
            if raw is None:
                continue
            value = parse_quantity(raw)
            if value is None:
                report.error("invalid_amount", row, line, table.columns[column], raw)
                continue
            currency = currency_by_id[str(n)]
            money = URIRef(f"{subject}M{n}")
            g.add((money, RDF.type, BK.Money))
            g.add((transfer, BK.transfers, money))
            g.add((money, BK.quantity, Literal(value)))
            g.add((money, BK.unit, unit_iri[currency.id]))
            amounts.append((currency, value))

        raw_direction = _cell(cells, cols.debit_credit)
        direction = _direction(raw_direction)
        if direction == "debit":
            g.add((transfer, BK.debit, Literal(raw_direction)))
        elif direction == "credit":
            g.add((transfer, BK.credit, Literal(raw_direction)))
        agent_name = _cell(cells, cols.agent)
        agent = agents.get(agent_name) if agent_name is not None else None
        if agent is not None and direction == "debit":
            g.add((transfer, BK.to, holder))
            g.add((transfer, BK["from"], agent))
        elif agent is not None and direction == "credit":
            g.add((transfer, BK.to, agent))
            g.add((transfer, BK["from"], holder))

        # As in depcha-TORDF.xsl, a transfer to the account holder is revenue and one
        # from the account holder an expense; totals and undated transactions do not count.
        if is_total or when is None or agent is None or direction is None:
            continue
        sums = revenue if direction == "debit" else expenses
        for currency, value in amounts:
            converted = _convert(currency, value, main)
            if converted is not None:
                sums[when[:4]] += converted

    _count(g, report)
    _add_dataset(g, config, report, holder, unit_iri, years, revenue, expenses)
    # void:triples counts the graph including this statement itself.
    g.add((dataset, VOID.triples, Literal(len(g) + 1)))
    return g


def _count(g: Graph, report: Report) -> None:
    """Count distinct resources as depcha-TORDF.xsl does; rows sharing a BK_ID form one transaction."""
    transactions = set(g.subjects(RDF.type, BK.Transaction))
    transfers = {t for s in transactions for t in g.objects(s, BK.consistsOf)}
    money = set(g.subjects(RDF.type, BK.Money))
    report.counts["bk:Transaction"] = len(transactions)
    report.counts["bk:TotalTransaction"] = len(
        set(g.subjects(RDF.type, BK.TotalTransaction))
    )
    report.counts["bk:Transfer of bk:Transaction"] = len(transfers)
    report.counts["bk:Transfer of bk:Transaction with bk:Money"] = sum(
        1 for t in transfers if any(m in money for m in g.objects(t, BK.transfers))
    )
    report.counts["bk:Money"] = len(money)


def _add_dataset(
    g: Graph,
    config: Config,
    report: Report,
    holder: URIRef,
    unit_iri: dict[str, URIRef],
    years: set[str],
    revenue: dict[str, float],
    expenses: dict[str, float],
) -> None:
    """depcha:Dataset with the counters and yearly aggregations depcha-TORDF.xsl defines."""
    base, pid, context = config.base_url, config.pid, config.context
    node = URIRef(f"{base}{pid}#Dataset")
    main = config.currencies[0]
    counts = report.counts
    g.add((node, RDF.type, DEPCHA.Dataset))
    g.add((node, GAMS.isMemberOfCollection, URIRef(base + context)))
    g.add((node, GAMS.isPartOf, URIRef(base + pid)))
    g.add((node, DEPCHA.accountHolder, holder))
    for predicate, value in (
        (DEPCHA.numberOfTransactions, counts["bk:Transaction"]),
        (DEPCHA.numberOfTransfers, counts["bk:Transfer of bk:Transaction"]),
        (DEPCHA.numberOfEconomicAgents, counts["bk:EconomicAgent"] + 1),
        (DEPCHA.numberOfEconomicGoods, 0),
        (
            DEPCHA.numberOfMonetaryValues,
            counts["bk:Transfer of bk:Transaction with bk:Money"],
        ),
        (DEPCHA.numberOfServices, 0),
        (DEPCHA.numberOfCommodities, 0),
        (DEPCHA.numberOfRights, 0),
        (DEPCHA.numberOfTotals, counts["bk:TotalTransaction"]),
        (DEPCHA.numberOfPlaces, 0),
        (DEPCHA.numberOfAccounts, 0),
    ):
        g.add((node, predicate, Literal(value)))
    g.add((node, DEPCHA.isMainCurrency, unit_iri[main.id]))

    for year in sorted(years):
        aggregation = URIRef(f"{base}{pid}#{year}")
        g.add((aggregation, RDF.type, DEPCHA.Aggregation))
        g.add((node, DEPCHA.aggregates, aggregation))
        g.add((aggregation, DEPCHA.date, Literal(year)))
        g.add((aggregation, BK.unit, Literal(main.unit)))
        g.add((aggregation, DEPCHA.revenue, Literal(float(revenue[year]))))
        g.add((aggregation, DEPCHA.expenses, Literal(float(expenses[year]))))

    for currency in config.currencies:
        unit = unit_iri[currency.id]
        g.add((unit, RDF.type, HUC.HistoricalUnit))
        g.add((unit, RDFS.label, Literal(_label(currency.unit))))
        g.add((node, DEPCHA.currency, unit))
        if currency.converts_to is not None:
            conversion = URIRef(f"{base}{context}#{currency.unit}Conversion")
            g.add((conversion, RDF.type, HUC.Conversion))
            g.add((conversion, HUC.convertsFrom, unit))
            g.add(
                (
                    conversion,
                    HUC.convertsTo,
                    URIRef(f"{base}{context}#{currency.converts_to}"),
                )
            )
            g.add((conversion, HUC.formula, Literal(_label(currency.formula or ""))))


def _write(g: Graph, path: Path) -> None:
    # Write next to the target and replace, so a failed run never leaves a half-written file.
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=f".{path.name}.", suffix=".tmp")
    os.close(fd)
    try:
        g.serialize(destination=tmp, format="pretty-xml")
        Path(tmp).replace(path)
    except BaseException:
        Path(tmp).unlink(missing_ok=True)
        raise


def convert(config: Config) -> tuple[Graph, Report]:
    report = Report(config=str(config.source), output=str(config.output_path))
    graph = build_graph(config, read_table(config.csv_path), report)
    return graph, report


def _print_report(report: Report) -> None:
    counts = ", ".join(f"{v} {k}" for k, v in sorted(report.counts.items()))
    print(f"OK {report.config} -> {report.output}: {counts}")
    for reason, n in sorted(report.skipped.items()):
        print(f"SKIP {n} rows: {reason}")
    by_kind = Counter(e["kind"] for e in report.errors)
    for kind, n in sorted(by_kind.items()):
        examples = [e for e in report.errors if e["kind"] == kind][:5]
        shown = "; ".join(
            f"line {e['line']} {e['column']}={e['value']!r}" for e in examples
        )
        print(f"ERROR {n} x {kind}, e.g. {shown}", file=sys.stderr)


def _arguments(argv: list[str] | None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert CSV account books to DEPCHA RDF (model 1.2)."
    )
    parser.add_argument("configs", nargs="+", type=Path, help="JSON config file(s)")
    parser.add_argument(
        "--out-dir",
        type=Path,
        help="directory for <OUTPUT-FILE-NAME>.xml (default: current directory)",
    )
    parser.add_argument("--output", type=Path, help="output file, single config only")
    parser.add_argument(
        "--csv", type=Path, help="input CSV instead of FILENAME, single config only"
    )
    parser.add_argument("--pid", help="object PID instead of PID, single config only")
    parser.add_argument(
        "--context", help="collection PID instead of CONTEXT, single config only"
    )
    parser.add_argument(
        "--base-url", help=f"base URL instead of BASE_URL (default {DEFAULT_BASE_URL})"
    )
    parser.add_argument(
        "--report", type=Path, help="write the collected counts and errors as JSON"
    )
    args = parser.parse_args(argv)
    single = [f"--{n}" for n in ("output", "csv", "pid", "context") if getattr(args, n)]
    if single and len(args.configs) > 1:
        parser.error(f"{', '.join(single)} apply to a single config only")
    return args


def main(argv: list[str] | None = None) -> int:
    # Line buffering keeps OK/SKIP (stdout) and ERROR (stderr) lines in order.
    sys.stdout.reconfigure(encoding="utf-8", line_buffering=True)
    sys.stderr.reconfigure(encoding="utf-8")
    args = _arguments(argv)
    configs = [load_config(path, args) for path in args.configs]
    outputs = [c.output_path.resolve() for c in configs]
    if len(set(outputs)) != len(outputs):
        raise SystemExit(
            "ERROR: several configs write the same output file; use separate --out-dir runs"
        )
    reports = []
    for config in configs:
        graph, report = convert(config)
        _write(graph, config.output_path)
        _print_report(report)
        reports.append(report)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(
            json.dumps([r.to_dict() for r in reports], ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
    failed = sum(len(r.errors) for r in reports)
    if failed:
        print(
            f"ERROR: {failed} cell errors collected; the RDF was written without those statements",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
