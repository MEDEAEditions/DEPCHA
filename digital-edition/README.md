# Digitale Edition SRBAS

Eine digitale Edition der DEPCHA-Daten zu den Jahrrechnungen der Stadt Basel 1535–1610. Sie stellt für jeden Buchungssatz die historische Transkription und ihre Lesart nach der Bookkeeping-Ontologie nebeneinander, also eine Text-Data-Synopse. Links steht der Text wie überliefert mit seiner historischen Zahlschreibweise, rechts der strukturierte Eintrag mit errechnetem Betrag und Einheit, der Transferrichtung von und zu sowie der Zuordnung zu Konto und Sektion.

## Aufbau

```
digital-edition/
  knowledge/        Spezifikation und Datenmodell (REQUIREMENTS.md, DATA.md)
  build/            parse_srbas.py (TEI -> JSON) und test_parse_srbas.py
  data/             generierte JSON-Dateien (index.json + srbas.<jahr>.json)
  index.html        Single-Page-Edition
  app.js
  style.css
```

## Daten erzeugen

Der Parser liest die TEI-Dateien aus `../Collections/SRBAS/TEI` und schreibt die JSON nach `data/`.

```
python build/parse_srbas.py
```

Test der Akzeptanzkriterien gegen den verifizierten Jahrgang 1535/1536 und ein Smoke-Lauf über alle 76 Dateien.

```
python build/test_parse_srbas.py
```

## Edition ansehen

Die Anwendung lädt JSON per `fetch`, ein lokaler HTTP-Server ist daher nötig.

```
python -m http.server 8765
```

Dann `http://localhost:8765/index.html` öffnen. Die Sammlung ist GitHub-Pages-fähig, da rein statisch.

## Ontologie-Abbildung

| Anzeige | Annotation in der Quelle |
|---|---|
| Betragschip mit Menge und Einheit | `measure ana="bk:money"` mit `quantity` und `unit` |
| Original im Tooltip des Chips | Elementtext der `measure`, etwa `jm lxxxiij lb` |
| Quelle → Ziel | `name ana="bk:from"` und `name ana="bk:to"`, `ref` aufgelöst über die Taxonomie |
| Kontoname | `head` des `div ana="bk:account"` |
| Summenzeile | `p` oder `closer` mit `ana="bk:total"` |
| Sektionen Einnahmen, Ausgaben, Saldo | die drei Körper-`div` Empfangen, Dargegen uszgeben, Remanet |

Details zum Quellmodell in [knowledge/DATA.md](knowledge/DATA.md), Anforderungen und Akzeptanzkriterien in [knowledge/REQUIREMENTS.md](knowledge/REQUIREMENTS.md).

## Stand und Grenzen

Faksimiles sind nicht eingebunden, da die Bilddateien nicht im Repository liegen. Der Jahrgang 1584/1585 ist in der Quelle ein Stub ohne Buchungskörper und wird als leerer Jahrgang ausgewiesen. Nicht enthalten sind Volltextsuche und SPARQL-Anbindung.
