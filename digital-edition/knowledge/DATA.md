---
type: promptotyping-data
project: depcha-digital-edition
created: 2026-06-28
source: DEPCHA/Collections/SRBAS/TEI
status: active
human-reviewed: false
---

# Datenmodell SRBAS (Jahrrechnungen Stadt Basel 1535–1610)

Quelle sind 76 TEI-Dateien unter `DEPCHA/Collections/SRBAS/TEI/depcha.srbas<JJJJ>_<JJJJ>.xml`, zusammen rund 42,8 MB, mit 175.111 Annotationen im Namensraum `bk:` und `depcha:`. Die Dateien sind UTF-8, müssen also explizit als UTF-8 gelesen werden, sonst erscheinen Umlaute als Mojibake. Eine Datei, `depcha.srbas1584_1585.xml`, ist ein Stub mit nur sechs Annotationen und trägt keinen auswertbaren Körper.

## Bookkeeping-Annotation, gezählt über alle Dateien

Die Annotation hängt am TEI-Attribut `ana` und ist rein monetär, Waren kommen in SRBAS nicht vor.

| Annotation | Trägerelement | Vorkommen | Bedeutung |
|---|---|---|---|
| `bk:money` | `measure` | 159.087 | Betrag mit `quantity` und `unit`, `type` immer `currency` |
| `bk:from` | `name` | 78.795 | Herkunft des Transfers, `ref` auf Konto/Akteur |
| `bk:to` | `name` | 78.795 | Ziel des Transfers, `ref` auf Konto/Akteur |
| `bk:entry` | `p`, `note` | 78.795 | transkribierter Buchungssatz |
| `bk:total` | `p`, `closer` | 9.998 | Summenzeile |
| `bk:account` | `div`, `taxonomy` | 7.479 | Kontoabschnitt |
| `depcha:accountHolder` | `category` | 76 | Rechnungsführer, hier durchgehend `stadtbasel` |
| `depcha:mainCurrency` | `unitDef` | 76 | Leitwährung, hier durchgehend `lb` |

## Währung

Das Geld folgt dem lsd-System. Ein Eintrag trägt bis zu drei `measure`-Kinder, die zusammen einen Betrag in Pfund, Schilling und Pfennig bilden.

| `unit` | Vorkommen | Auflösung |
|---|---|---|
| `lb` | 74.043 | Pfund (libra) |
| `ß-w` | 59.333 | Schilling (solidus), Währungsschilling |
| `d` | 25.356 | Pfennig (denarius) |
| `lbd` | 354 | seltene Mischangabe, im Original teils mit „h" (Heller) notiert |
| `sh` | 1 | Einzelfall |

Das Verhältnis ist 1 lb = 20 ß = 240 d. Die `quantity` ist die errechnete Lesart, der Elementtext der `measure` hält die historische Schreibweise, etwa `jm lxxxiij lb` für `quantity="1083"`.

## Labels und Referenzauflösung

Konten und Akteure sind in einer `taxonomy` aus `category`-Elementen definiert. Das Label steht in `catDesc/gloss`, die Kennung im `xml:id`. Beispiele: `stadtbasel` → „Stadt Basel", `income` → „Income", `bs_Weinungeld` → „Weinungeld".

Die `ref` von `bk:from` und `bk:to` zeigen überwiegend nicht auf Kategorien, sondern auf Eintrags-IDs im Muster `bs_<Konto>-<n>`. Nur etwa eine von mehreren hundert Referenzen ist direkt eine Kategorie-ID. Die Auflösung läuft daher dreistufig: erst die `ref` selbst in der Taxonomie suchen, sonst das Suffix `-<n>` abstreifen und das verbleibende Konto suchen, sonst die Kennung lesbar formatieren.

## Aufbau einer Jahresdatei

Im `teiHeader` stehen Titel (`Jahrrechnung Stadt Basel JJJJ/JJJJ`), PID (`o:depcha.srbas.JJJJ`), Datumsspanne (`origDate` mit `from`, `to`, `extent`) und Archivsignatur (`repository` StABS, `collection` Finanz H, `idno` etwa 92.1). Dann folgt die Taxonomie mit Rechnungsführer, Leitwährung und allen Konten.

Der `body` gliedert sich in drei Sektionen als direkte `div`-Kinder.

1. Empfangen, `id` enthält `Einnahmen`, die Einnahmenseite.
2. „Dargegen uszgeben", `id` enthält `Ausgaben`, die Ausgabenseite.
3. Remanet, `id` enthält `Remanet`, der Saldo, oft ohne `head`.

Jede Sektion enthält Konto-`div` mit `ana="bk:account"`, teils verschachtelt. Ein Kontoabschnitt trägt einen `head` als Kontoname und darunter Buchungssätze als `p ana="bk:entry"` sowie Summenzeilen als `p` oder `closer` mit `ana="bk:total"`. Ein Buchungssatz besteht aus dem transkribierten Text, einem bis drei `measure ana="bk:money"` und je einem `name ana="bk:from"` und `name ana="bk:to"`.

Für die Einnahmenseite verweist `bk:from` auf die im Text genannte Quelle und `bk:to` auf `stadtbasel`. Auf der Ausgabenseite ist die Richtung umgekehrt, die Stadt zahlt an einen Empfänger.

## Faksimiles

Die `pb`-Elemente tragen `facs`-Verweise wie `#fol_1r`, die zugehörigen Bilddateien liegen jedoch nicht im Repository, das Verzeichnis `SRBAS/img` ist leer. Faksimiles werden daher als optionale, derzeit nicht verfügbare Information behandelt.

## Related

- [[REQUIREMENTS]]
