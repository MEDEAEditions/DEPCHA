"""TEI -> JSON parser for the SRBAS bookkeeping edition.

Reads the DEPCHA SRBAS TEI files and emits one compact JSON document per year
plus an index. The JSON pairs each transcribed entry with its structured
bookkeeping reading (money quantity/unit, from/to, account, section), which is
what the digital edition renders as a text-data synopsis.

See knowledge/DATA.md for the source model and knowledge/REQUIREMENTS.md for
acceptance criteria.
"""
from __future__ import annotations

import glob
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

TEI_NS = "http://www.tei-c.org/ns/1.0"
XML_ID = "{http://www.w3.org/XML/1998/namespace}id"

DEFAULT_TEI_DIR = os.path.normpath(
    os.path.join(os.path.dirname(__file__), "..", "..", "Collections", "SRBAS", "TEI")
)
DEFAULT_OUT_DIR = os.path.normpath(
    os.path.join(os.path.dirname(__file__), "..", "data")
)

_SUFFIX = re.compile(r"-\d+$")


def local(tag: str) -> str:
    """Return the local name of a namespaced tag."""
    return tag.rsplit("}", 1)[-1]


def _text(el) -> str:
    """Whitespace-collapsed concatenation of all descendant text."""
    return re.sub(r"\s+", " ", "".join(el.itertext())).strip()


def gloss_map(root) -> dict:
    """Map category xml:id -> human label from taxonomy catDesc/gloss."""
    out = {}
    for cat in root.iter(f"{{{TEI_NS}}}category"):
        cid = cat.get(XML_ID)
        if not cid:
            continue
        gloss = cat.find(f"{{{TEI_NS}}}catDesc/{{{TEI_NS}}}gloss")
        label = _text(gloss) if gloss is not None else ""
        out[cid] = label or cid
    return out


def resolve_ref(ref: str | None, glosses: dict) -> dict | None:
    """Resolve a from/to ref to {id, label}, never failing.

    Order: exact category id, then the account id with the trailing -<n>
    stripped, then a prettified fallback.
    """
    if not ref:
        return None
    rid = ref.lstrip("#")
    if rid in glosses:
        return {"id": rid, "label": glosses[rid]}
    account = _SUFFIX.sub("", rid)
    if account in glosses:
        return {"id": account, "label": glosses[account]}
    pretty = account[3:] if account.startswith("bs_") else account
    return {"id": rid, "label": pretty}


def parse_money(el) -> dict:
    """One bk:money measure -> {q, unit, orig}."""
    raw = el.get("quantity")
    try:
        q = float(raw)
        if q == int(q):
            q = int(q)
    except (TypeError, ValueError):
        q = None
    return {"q": q, "unit": el.get("unit") or "", "orig": _text(el)}


def parse_line(p, glosses: dict, kind: str) -> dict:
    """A bk:entry or bk:total paragraph -> structured line."""
    money = [
        parse_money(m)
        for m in p.iter(f"{{{TEI_NS}}}measure")
        if m.get("ana") == "bk:money"
    ]
    frm = to = None
    for n in p.iter(f"{{{TEI_NS}}}name"):
        if n.get("ana") == "bk:from" and frm is None:
            frm = resolve_ref(n.get("ref"), glosses)
        elif n.get("ana") == "bk:to" and to is None:
            to = resolve_ref(n.get("ref"), glosses)
    return {
        "id": p.get(XML_ID),
        "kind": kind,
        "text": _text(p),
        "money": money,
        "from": frm,
        "to": to,
    }


def _line_kind(ana: str) -> str | None:
    if ana == "bk:entry":
        return "entry"
    if ana == "bk:total":
        return "total"
    return None


def parse_account(div, glosses: dict, depth: int) -> dict:
    """A bk:account div -> account with its direct entry/total lines.

    Nested account divs are emitted separately by the section walker, so only
    direct p/closer children are taken here.
    """
    head = None
    for ch in div:
        if local(ch.tag) == "head":
            head = _text(ch)
            break
    acc_id = div.get(XML_ID) or ""
    corresp = (div.get("corresp") or "").lstrip("#")
    label = head or glosses.get(corresp) or glosses.get(_SUFFIX.sub("", acc_id)) or acc_id
    lines = []
    for ch in div:
        if local(ch.tag) in ("p", "closer"):
            kind = _line_kind(ch.get("ana"))
            if kind:
                lines.append(parse_line(ch, glosses, kind))
    return {
        "id": acc_id,
        "accountId": corresp or _SUFFIX.sub("", acc_id),
        "label": label,
        "depth": depth,
        "lines": lines,
    }


def _section_kind(div) -> str:
    sid = (div.get(XML_ID) or "").lower()
    if "einnahmen" in sid:
        return "income"
    if "ausgaben" in sid:
        return "expense"
    if "remanet" in sid:
        return "balance"
    return "other"


def _walk_accounts(div, glosses, depth, out):
    """Depth-first collect of bk:account divs in document order."""
    for ch in div:
        if local(ch.tag) == "div" and ch.get("ana") == "bk:account":
            out.append(parse_account(ch, glosses, depth))
            _walk_accounts(ch, glosses, depth + 1, out)
        elif local(ch.tag) == "div":
            _walk_accounts(ch, glosses, depth, out)


def parse_section(div, glosses: dict) -> dict:
    head = None
    for ch in div:
        if local(ch.tag) == "head":
            head = _text(ch)
            break
    accounts = []
    _walk_accounts(div, glosses, 0, accounts)
    return {
        "id": div.get(XML_ID) or "",
        "head": head or "",
        "kind": _section_kind(div),
        "accounts": accounts,
    }


def _first_text(root, tag, **attr) -> str:
    for el in root.iter(f"{{{TEI_NS}}}{tag}"):
        if all(el.get(k) == v for k, v in attr.items()):
            return _text(el)
    return ""


def _file_id(path: str) -> str:
    m = re.search(r"srbas(\d{4})", os.path.basename(path))
    return f"srbas.{m.group(1)}" if m else os.path.basename(path)


def parse_file(path: str) -> dict:
    """Parse one SRBAS TEI file into a year document."""
    root = ET.parse(path).getroot()
    glosses = gloss_map(root)

    # account holder + currency
    holder = None
    for cat in root.iter(f"{{{TEI_NS}}}category"):
        if cat.get("ana") == "depcha:accountHolder":
            hid = cat.get(XML_ID)
            holder = {"id": hid, "label": glosses.get(hid, hid)}
            break
    currency = ""
    for ud in root.iter(f"{{{TEI_NS}}}unitDef"):
        if ud.get("ana") == "depcha:mainCurrency":
            currency = ud.get(XML_ID) or ""
            break

    # header metadata
    title = _first_text(root, "title")
    pid = _first_text(root, "idno", type="PID")
    date_from = date_to = extent = ""
    for od in root.iter(f"{{{TEI_NS}}}origDate"):
        date_from, date_to, extent = od.get("from", ""), od.get("to", ""), od.get("extent", "")
        break
    archive = {"repository": "", "collection": "", "idno": ""}
    msid = root.find(f".//{{{TEI_NS}}}msIdentifier")
    if msid is not None:
        for tag in ("repository", "collection"):
            el = msid.find(f"{{{TEI_NS}}}{tag}")
            if el is not None:
                archive[tag] = _text(el)
        for el in msid.iter(f"{{{TEI_NS}}}idno"):
            if el.get("type") != "PID":
                archive["idno"] = _text(el)
                break

    # body sections
    body = root.find(f".//{{{TEI_NS}}}body")
    sections = []
    if body is not None:
        for ch in body:
            if local(ch.tag) == "div":
                sections.append(parse_section(ch, glosses))

    n_entries = sum(
        1
        for s in sections
        for a in s["accounts"]
        for ln in a["lines"]
        if ln["kind"] == "entry"
    )
    n_accounts = sum(len(s["accounts"]) for s in sections)

    return {
        "id": _file_id(path),
        "title": title,
        "pid": pid,
        "dateFrom": date_from,
        "dateTo": date_to,
        "extent": extent,
        "archive": archive,
        "accountHolder": holder,
        "currency": currency,
        "sections": sections,
        "stats": {"entries": n_entries, "accounts": n_accounts},
    }


def build(tei_dir: str = DEFAULT_TEI_DIR, out_dir: str = DEFAULT_OUT_DIR) -> dict:
    """Parse every SRBAS file, write per-year JSON and an index."""
    os.makedirs(out_dir, exist_ok=True)
    files = sorted(glob.glob(os.path.join(tei_dir, "*.xml")))
    index = []
    for fp in files:
        try:
            doc = parse_file(fp)
        except Exception as e:  # defensive: one bad file must not stop the build
            print(f"  ! skip {os.path.basename(fp)}: {e}", file=sys.stderr)
            continue
        with open(os.path.join(out_dir, f"{doc['id']}.json"), "w", encoding="utf-8") as f:
            json.dump(doc, f, ensure_ascii=False, separators=(",", ":"))
        index.append({
            "id": doc["id"],
            "title": doc["title"],
            "dateFrom": doc["dateFrom"],
            "dateTo": doc["dateTo"],
            "archive": doc["archive"],
            "entries": doc["stats"]["entries"],
        })
    meta = {
        "collection": "SRBAS",
        "label": "Jahrrechnungen der Stadt Basel 1535–1610",
        "source": "DEPCHA, Digital Edition Publishing Cooperative for Historical Accounts",
        "years": index,
    }
    with open(os.path.join(out_dir, "index.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=1)
    print(f"wrote {len(index)} year files + index.json to {out_dir}")
    return meta


if __name__ == "__main__":
    build()
