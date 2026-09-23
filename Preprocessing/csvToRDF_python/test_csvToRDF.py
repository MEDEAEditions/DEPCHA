# /// script
# requires-python = ">=3.11"
# dependencies = ["rdflib>=7,<8", "python-dateutil>=2.8", "pytest>=8"]
# ///
"""Checks for csvToRDF.py against the minimal Washington sample in gwfp/.

The fixture is the repository's own GWFP_Ledger_C_minimal.csv with its config.
test_expected_Ledger_minimal.nt holds its conversion as reviewed on 2026-09-23;
the revenue and expense values in it were recomputed by hand from the CSV.
Run with: uv run test_csvToRDF.py
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest
from rdflib import RDF, Graph, URIRef
from rdflib.namespace import DCTERMS

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.dont_write_bytecode = True  # keep __pycache__ out of the data repository

import csvToRDF

CONFIG = HERE / "gwfp" / "csvToRDF_config__Ledger_minimal.json"
EXPECTED = HERE / "test_expected_Ledger_minimal.nt"
BK = csvToRDF.BK
DEPCHA = csvToRDF.DEPCHA


@pytest.fixture(scope="module")
def converted() -> tuple[Graph, csvToRDF.Report, csvToRDF.Config]:
    if not CONFIG.is_file() or not EXPECTED.is_file():
        pytest.fail(f"fixture missing: {CONFIG} or {EXPECTED}")
    config = csvToRDF.load_config(CONFIG)
    graph, report = csvToRDF.convert(config)
    return graph, report, config


def test_matches_expected_triples(
    converted: tuple[Graph, csvToRDF.Report, csvToRDF.Config],
) -> None:
    graph, report, _ = converted
    actual = {t for t in graph if t[1] != DCTERMS.modified}  # date of the run
    expected = set(Graph().parse(EXPECTED, format="nt"))
    missing = expected - actual
    extra = actual - expected
    assert not missing and not extra, (
        f"missing {sorted(missing)[:5]}, unexpected {sorted(extra)[:5]}"
    )
    assert report.errors == []


def test_agent_references_resolve(
    converted: tuple[Graph, csvToRDF.Report, csvToRDF.Config],
) -> None:
    graph, _, config = converted
    agents = set(graph.subjects(RDF.type, BK.EconomicAgent))
    targets = {o for p in (BK.to, BK["from"]) for o in graph.objects(None, p)}
    assert targets and targets <= agents
    for agent in agents - {
        URIRef(f"{config.base_url}{config.context}#{config.holder_id}")
    }:
        assert str(agent).startswith(f"{config.base_url}{config.pid}#")


def test_header_states_model_version(
    converted: tuple[Graph, csvToRDF.Report, csvToRDF.Config],
) -> None:
    graph, _, config = converted
    assert (
        URIRef(config.base_url + config.pid),
        DCTERMS.conformsTo,
        csvToRDF.MODEL_VERSION_IRI,
    ) in graph


def test_aggregations_follow_transfers_to_and_from_holder(
    converted: tuple[Graph, csvToRDF.Report, csvToRDF.Config],
) -> None:
    """Recompute revenue and expenses from the graph by the definition in depcha-TORDF.xsl."""
    graph, _, config = converted
    holder = URIRef(f"{config.base_url}{config.context}#{config.holder_id}")
    main = config.currencies[0].unit
    divisor = {
        f"#{c.unit}": c.divisor or 1.0
        for c in config.currencies
        if c.unit == main or c.converts_to == main
    }
    sums: dict[tuple[str, str], float] = {}
    for transaction in graph.subjects(RDF.type, BK.Transaction):
        when = graph.value(transaction, BK.when)
        for transfer in graph.objects(transaction, BK.consistsOf):
            if (transfer, BK.to, holder) in graph:
                side = "revenue"
            elif (transfer, BK["from"], holder) in graph:
                side = "expenses"
            else:
                continue
            if when is None:
                continue
            for money in graph.objects(transfer, BK.transfers):
                unit = "#" + str(graph.value(money, BK.unit)).split("#")[-1]
                if unit in divisor:
                    key = (str(when)[:4], side)
                    sums[key] = (
                        sums.get(key, 0.0)
                        + float(graph.value(money, BK.quantity)) / divisor[unit]
                    )
    for aggregation in graph.subjects(RDF.type, DEPCHA.Aggregation):
        year = str(graph.value(aggregation, DEPCHA.date))
        for side in ("revenue", "expenses"):
            stated = float(graph.value(aggregation, DEPCHA[side]))
            assert stated == pytest.approx(sums.get((year, side), 0.0)), (year, side)


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("1772", "1772"),
        ("September 1790", "1790-09"),
        (" December 1771", "1771-12"),
        ("2 April 1750", "1750-04-02"),
        ("1809-01-17", "1809-01-17"),
        ("5 February", None),
        ("November", None),
        ("14.Aug", None),
        ("171 794", None),
    ],
)
def test_parse_when_keeps_source_precision(raw: str, expected: str | None) -> None:
    assert csvToRDF.parse_when(raw) == expected


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("371", 371.0),
        ("3,5", 3.5),
        ("167. 5", 167.5),
        ("1 1/2", 1.5),
        ("01.Feb", None),
        ("$4605", None),
        ("7.75, 4.25", None),
    ],
)
def test_parse_quantity(raw: str, expected: float | None) -> None:
    assert csvToRDF.parse_quantity(raw) == expected


@pytest.mark.parametrize(
    ("name", "fragment"),
    [
        ("Fairfax, George William", "FairfaxGeorgeWilliam"),
        ("Ballinger (Ballenger), Francis", "BallingerBallengerFrancis"),
        ("Ballinger (Ballenger), James", "BallingerBallengerJames"),
        ("Carlyle & Adam (firm)", "Carlyle&Adamfirm"),
    ],
)
def test_agent_fragment_keeps_names_apart(name: str, fragment: str) -> None:
    assert csvToRDF.agent_fragment(name) == fragment


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-q", "-p", "no:cacheprovider"]))
