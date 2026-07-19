"""Executable specification for the SRBAS parser.

Run: python build/test_parse_srbas.py
Checks the acceptance criteria from knowledge/REQUIREMENTS.md against the
manually verified year 1535/1536, plus a full-collection smoke run.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import parse_srbas as P  # noqa: E402

TEI_DIR = P.DEFAULT_TEI_DIR
F1535 = os.path.join(TEI_DIR, "depcha.srbas1535_1536.xml")

_failures = []


def check(name, cond, detail=""):
    status = "ok  " if cond else "FAIL"
    if not cond:
        _failures.append(name)
    print(f"  [{status}] {name}{(' -> ' + detail) if detail and not cond else ''}")


def test_1535():
    doc = P.parse_file(F1535)
    check("id is srbas.1535", doc["id"] == "srbas.1535", doc["id"])
    check("title", doc["title"] == "Jahrrechnung Stadt Basel 1535/1536", doc["title"])
    check("account holder Stadt Basel",
          doc["accountHolder"] and doc["accountHolder"]["label"] == "Stadt Basel",
          str(doc["accountHolder"]))
    check("currency lb", doc["currency"] == "lb", doc["currency"])
    check("date range", doc["dateFrom"] == "1535-06-26" and doc["dateTo"] == "1536-06-24",
          f"{doc['dateFrom']}..{doc['dateTo']}")
    check("archive signature 92.1", doc["archive"]["idno"] == "92.1", str(doc["archive"]))

    income = next((s for s in doc["sections"] if s["kind"] == "income"), None)
    check("income section present", income is not None)
    first = income["accounts"][0] if income and income["accounts"] else None
    check("first income account 'Vom winungelt'",
          first and first["label"] == "Vom winungelt", first and first["label"])

    entries = [ln for ln in first["lines"] if ln["kind"] == "entry"] if first else []
    e0 = entries[0] if entries else None
    check("first entry text", e0 and e0["text"] == "Prima angaria jm lxxxiij lb",
          e0 and e0["text"])
    check("first entry one money part", e0 and len(e0["money"]) == 1,
          e0 and len(e0["money"]))
    check("money quantity 1083 lb",
          e0 and e0["money"][0]["q"] == 1083 and e0["money"][0]["unit"] == "lb",
          e0 and e0["money"][0])
    check("historical numeral preserved",
          e0 and e0["money"][0]["orig"] == "jm lxxxiij lb", e0 and e0["money"][0]["orig"])
    check("from resolves to Weinungeld",
          e0 and e0["from"] and e0["from"]["label"] == "Weinungeld", e0 and e0["from"])
    check("to resolves to Stadt Basel",
          e0 and e0["to"] and e0["to"]["label"] == "Stadt Basel", e0 and e0["to"])

    totals = [ln for ln in first["lines"] if ln["kind"] == "total"]
    has_3660 = any(
        any(m["q"] == 3660 and m["unit"] == "lb" for m in t["money"]) for t in totals
    )
    check("total Suma 3660 lb typed as total", has_3660, str(totals[:1]))


def test_collection_smoke():
    files = sorted(__import__("glob").glob(os.path.join(TEI_DIR, "*.xml")))
    check("76 source files", len(files) == 76, str(len(files)))
    ok = 0
    for fp in files:
        try:
            P.parse_file(fp)
            ok += 1
        except Exception as e:
            check(f"parse {os.path.basename(fp)}", False, str(e))
    check("all files parse without exception", ok == len(files), f"{ok}/{len(files)}")


if __name__ == "__main__":
    print("test_1535:")
    test_1535()
    print("test_collection_smoke:")
    test_collection_smoke()
    print()
    if _failures:
        print(f"FAILED: {len(_failures)} -> {_failures}")
        sys.exit(1)
    print("all checks passed")
