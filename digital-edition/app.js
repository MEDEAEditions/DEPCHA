"use strict";

const DATA = "data/";
const UNIT_LABEL = { "lb": "lb", "ß-w": "ß", "d": "d", "lbd": "lbd", "sh": "ß" };
const SECTION_LABEL = { income: "Einnahmen", expense: "Ausgaben", balance: "Saldo", other: "" };

const yearsEl = document.getElementById("years");
const contentEl = document.getElementById("content");
const filterEl = document.getElementById("filter");

let index = null;
const cache = new Map();

function el(tag, cls, text) {
  const n = document.createElement(tag);
  if (cls) n.className = cls;
  if (text != null) n.textContent = text;
  return n;
}

function shortYear(id) {
  return id.replace("srbas.", "");
}

async function loadIndex() {
  const res = await fetch(DATA + "index.json");
  index = await res.json();
  renderYearList(index.years);
}

function renderYearList(years) {
  const q = filterEl.value.trim().toLowerCase();
  yearsEl.textContent = "";
  const current = location.hash.slice(1);
  for (const y of years) {
    if (q && !(y.title.toLowerCase().includes(q) || y.id.includes(q))) continue;
    const li = el("li");
    const a = el("a");
    a.href = "#" + y.id;
    if (y.id === current) a.classList.add("active");
    a.appendChild(el("span", null, y.title.replace("Jahrrechnung Stadt Basel ", "")));
    const meta = el("span", "yr-meta",
      `${y.entries} Buchungssätze · ${y.archive.collection} ${y.archive.idno}`.trim());
    a.appendChild(meta);
    li.appendChild(a);
    yearsEl.appendChild(li);
  }
}

async function loadYear(id) {
  if (cache.has(id)) return cache.get(id);
  const res = await fetch(DATA + id + ".json");
  if (!res.ok) throw new Error("not found: " + id);
  const doc = await res.json();
  cache.set(id, doc);
  return doc;
}

function moneyChips(money) {
  const frag = document.createDocumentFragment();
  for (const m of money) {
    const unit = UNIT_LABEL[m.unit] || m.unit;
    const chip = el("span", "chip money", `${m.q != null ? m.q : "?"} ${unit}`);
    if (m.orig) chip.title = "Original: " + m.orig;
    frag.appendChild(chip);
  }
  return frag;
}

function flowEl(from, to) {
  if (!from && !to) return null;
  const wrap = el("span", "flow");
  wrap.appendChild(el("span", "agent", from ? from.label : "?"));
  wrap.appendChild(el("span", "arrow", "→"));
  wrap.appendChild(el("span", "agent", to ? to.label : "?"));
  return wrap;
}

function renderLine(ln) {
  const row = el("div", "line" + (ln.kind === "total" ? " total" : ""));
  const text = el("div", "text");
  if (ln.kind === "total") text.appendChild(el("span", "badge total", "Summe"));
  text.appendChild(document.createTextNode((ln.kind === "total" ? " " : "") + (ln.text || "")));
  row.appendChild(text);

  const data = el("div", "data");
  if (ln.money && ln.money.length) data.appendChild(moneyChips(ln.money));
  const flow = ln.kind === "entry" ? flowEl(ln.from, ln.to) : null;
  if (flow) data.appendChild(flow);
  row.appendChild(data);
  return row;
}

function renderAccount(acc) {
  const box = el("div", "account");
  box.dataset.depth = String(acc.depth || 0);
  if (acc.label) box.appendChild(el("div", "account-head", acc.label));
  for (const ln of acc.lines) box.appendChild(renderLine(ln));
  return box;
}

function renderSection(sec) {
  const s = el("section", "section");
  const h = el("h3");
  const label = SECTION_LABEL[sec.kind];
  if (label) h.appendChild(el("span", "badge " + sec.kind, label));
  h.appendChild(document.createTextNode(" " + (sec.head || label || "")));
  s.appendChild(h);
  if (!sec.accounts.length) s.appendChild(el("p", "empty-note", "Keine Konten in dieser Sektion."));
  for (const acc of sec.accounts) s.appendChild(renderAccount(acc));
  return s;
}

function renderYear(doc) {
  contentEl.textContent = "";
  const head = el("div", "year-head");
  head.appendChild(el("h2", null, doc.title));
  const meta = el("div", "year-meta");
  const bits = [];
  if (doc.dateFrom) bits.push(["Laufzeit", `${doc.dateFrom} bis ${doc.dateTo}${doc.extent ? " (" + doc.extent + ")" : ""}`]);
  if (doc.accountHolder) bits.push(["Rechnungsführer", doc.accountHolder.label]);
  if (doc.currency) bits.push(["Leitwährung", doc.currency]);
  bits.push(["Signatur", `${doc.archive.repository} ${doc.archive.collection} ${doc.archive.idno}`.trim()]);
  bits.push(["Buchungssätze", String(doc.stats.entries)]);
  if (doc.pid) bits.push(["PID", doc.pid]);
  for (const [k, v] of bits) {
    const span = el("span");
    span.appendChild(el("b", null, k + ": "));
    span.appendChild(document.createTextNode(v));
    meta.appendChild(span);
  }
  head.appendChild(meta);
  contentEl.appendChild(head);

  const hasBody = doc.sections.some(s => s.accounts.length);
  if (!hasBody) {
    contentEl.appendChild(el("p", "empty-note", "Für diesen Jahrgang liegt kein erschlossener Buchungskörper vor (Stub-Datei)."));
    return;
  }
  for (const sec of doc.sections) {
    if (sec.accounts.length) contentEl.appendChild(renderSection(sec));
  }
}

async function route() {
  const id = location.hash.slice(1);
  if (!index) return;
  renderYearList(index.years);
  if (!id) { contentEl.innerHTML = ""; contentEl.appendChild(el("p", "placeholder", "Jahrgang wählen.")); return; }
  contentEl.textContent = "";
  contentEl.appendChild(el("p", "placeholder", "Lade…"));
  try {
    const doc = await loadYear(id);
    renderYear(doc);
    window.scrollTo(0, 0);
  } catch (e) {
    contentEl.textContent = "";
    contentEl.appendChild(el("p", "placeholder", "Konnte Jahrgang nicht laden: " + id));
  }
}

document.getElementById("legendToggle").addEventListener("click", (e) => {
  const lg = document.getElementById("legend");
  const open = lg.hasAttribute("hidden");
  if (open) lg.removeAttribute("hidden"); else lg.setAttribute("hidden", "");
  e.currentTarget.setAttribute("aria-expanded", String(open));
});
filterEl.addEventListener("input", () => renderYearList(index.years));
window.addEventListener("hashchange", route);

loadIndex().then(route).catch(() => {
  contentEl.textContent = "";
  contentEl.appendChild(el("p", "placeholder", "Daten nicht gefunden. Bitte build/parse_srbas.py ausführen und über einen lokalen Server öffnen."));
});
