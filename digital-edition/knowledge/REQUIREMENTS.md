---
type: promptotyping-requirements
project: depcha-digital-edition
created: 2026-06-28
status: active
human-reviewed: false
---

# Anforderungen digitale Edition SRBAS

## Zweck

Eine digitale Edition der DEPCHA-Daten zu den Jahrrechnungen der Stadt Basel, die für jeden Buchungssatz die historische Transkription und ihre Lesart nach der Bookkeeping-Ontologie nebeneinanderstellt. Kern ist die Text-Data-Synopse: links der Text wie überliefert, rechts die strukturierte Buchung, also Betrag mit errechneter Menge und Einheit, Transferrichtung von und zu sowie die Zuordnung zu Konto und Sektion.

## Form

Statische Single-Page-Anwendung aus `index.html`, `app.js`, `style.css` ohne Buildschritt. Die Anwendung liest vorgenerierte JSON-Dateien aus `data/`. Lauffähig über einen einfachen HTTP-Server und damit auf GitHub Pages publizierbar. Ein Python-Skript unter `build/` erzeugt die JSON-Dateien aus den TEI-Quellen.

## Funktionale Anforderungen

1. Die gesamte SRBAS-Collection ist erschlossen, alle 76 Jahrgänge sind auswählbar, der Stub von 1584/1585 wird als leer ausgewiesen statt zu scheitern.
2. Eine Übersicht listet die Jahrgänge mit Titel, Datumsspanne, Archivsignatur und Anzahl der Buchungssätze.
3. Die Jahresansicht zeigt die drei Sektionen Empfangen, Ausgaben und Remanet mit ihren Konten in Originalreihenfolge.
4. Jeder Buchungssatz erscheint als Synopse aus Transkription und strukturierter Buchung. Beträge zeigen die historische Schreibweise und die errechnete Menge mit Einheit.
5. `bk:from` und `bk:to` werden zu lesbaren Konto- und Akteursnamen aufgelöst.
6. Summenzeilen sind als solche markiert und von Buchungssätzen unterscheidbar.

## Akzeptanzkriterien

Geprüft am Jahrgang 1535/1536, da dieser manuell verifiziert ist.

- Der Parser erzeugt ein Jahresdokument mit `id` `srbas.1535` und Titel `Jahrrechnung Stadt Basel 1535/1536`.
- Der Rechnungsführer löst zu `Stadt Basel` auf, die Leitwährung ist `lb`.
- Das erste Einnahmenkonto trägt den Kopf `Vom winungelt`. Sein erster Buchungssatz hat den Text `Prima angaria jm lxxxiij lb`, genau ein Geldteil mit `quantity` 1083 und Einheit `lb`, und die Originalschreibweise `jm lxxxiij lb` bleibt erhalten.
- Eine Summenzeile `Suma ...` mit `quantity` 3660 lb existiert und ist als Total typisiert.
- Eine `bk:from`-Referenz `bs_Weinungeld-1` löst über das abgestreifte Suffix zum Konto `Weinungeld` auf, `bk:to` `stadtbasel` zu `Stadt Basel`.
- Der Lauf über alle 76 Dateien wirft keine Ausnahme und schreibt eine `index.json` mit 76 Einträgen.

## Edge Cases und Trust Boundaries

- Stub-Datei 1584/1585 ohne Körper, muss als leerer Jahrgang durchlaufen.
- Einträge mit mehreren Geldteilen, bis zu drei, lb plus ß plus d, müssen vollständig erfasst werden.
- Summen können als `p` oder als `closer` ausgezeichnet sein.
- `ref`-Auflösung darf nie scheitern, sondern fällt am Ende auf eine formatierte Kennung zurück.
- Trust Boundary ist die XML-Eingabe. Der Parser liest fest aus dem bekannten DEPCHA-Repository, validiert Namensräume und überspringt unerwartete Strukturen defensiv, statt abzubrechen.
- Die SPA rendert Quelltext aus den Daten ausschließlich über `textContent`, nie über `innerHTML`, damit Markup aus den Transkriptionen nicht als HTML interpretiert wird.

## Nicht im Umfang

Faksimiles, da die Bilddateien nicht vorliegen. Volltextsuche, SPARQL-Anbindung und Editionsapparat über die Synopse hinaus.

## Related

- [[DATA]]
