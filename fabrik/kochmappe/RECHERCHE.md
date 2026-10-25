# Kochmappe – Recherche 2 (Vorbild)

Stand: 2026-10-25. Quellen: iTunes-Lookup (us/de), 58 aktuelle US-Bewertungen des Vorbilds (RSS, 3 Seiten, vollständig gelesen),
Beschreibung, Versionshinweise und Bildschirmfotos (`recherche/vorbild_1…4.jpg`), Suche nach Konkurrenten (us).

## Vorbild
- **MyRecipes** – https://apps.apple.com/us/app/myrecipes/id6755009073 – 4,0 ★ bei 175 Bewertungen (US), nur Englisch,
  Anbieter ist ein Verlagshaus (Rezepte der eigenen Magazine/Seiten, „100.000+ trusted recipes“), Kategorie Food & Drink.
- Preismodell: „Gratis“ laden, aber Konto/Login Pflicht, Werbung, Abo „MyRecipes+“ (Nutzer nennen 7-Tage-Test, danach Abo; „$39.99“ im Jahr)
  für Speichern aus Instagram/TikTok und „keine Werbung“. Früher gab es einen Lifetime-Kauf, der abgeschafft wurde.
- Konkurrenten (alle „Gratis“ + Abo/Kauf, kein Vorbild-Verlag): **Recipe Keeper** (4,84 ★ / 31.013) – https://apps.apple.com/us/app/recipe-keeper/id974683711 ·
  **ReciMe** (4,79 ★ / 319.618) – Import aus Social Media, Abo · **RecipeBox** (4,68 ★ / 14.006) · **Deglaze** (4,87 ★ / 4.021) ·
  außerdem Paprika (Einmalkauf pro Gerät) als Maßstab für „Rezeptmanager, bei dem man nicht abonniert“.
  Gemeinsam: Rezepte aus beliebigen Webseiten speichern (schema.org/Recipe), Mappen/Kategorien, Portionsrechner, Einkaufsliste, Kochmodus.

## Funktionen
| Funktion | beim Vorbild | Urteil der Nutzer | Entscheidung |
|---|---|---|---|
| Rezepte aus Webseiten speichern | ja, „thousands of sites“ (gratis) | gelobt (≈ 6×), aber „Clearer guidance when a recipe fails to save“ → Fehler häufig | **Verbessern:** Link einfügen → lokal gelesen (schema.org/Recipe, Fallback Text-Erkennung); bei Fehler klare Meldung + Option „Text einfügen“ |
| Speichern aus Instagram/TikTok | nur Abo (KI-Server) | „game changer“ (≈ 12×), aber „tried 4 times, all didn't work“, „connection interrupted“ | **Weglassen** (braucht Server/KI → laufende Kosten). Ersatz: **Text einfügen** – Beschreibung/Untertitel kopieren, die App erkennt Zutaten und Schritte lokal, gratis |
| Mappen („Collections“) | ja, mit Konto-Sync | **Hauptklage:** „Where are my collections!?“, „lost dozens of favorites“, „no collections and no recipes“ (≈ 8×), Sync-Streit Web/App | **Verbessern:** alles lokal auf dem Gerät, kein Konto, kein Sync-Fehler; **Sicherung als Datei** (gratis) und Wiederherstellen |
| Rezeptsuche in den eigenen Rezepten | schwach („searching for a saved recipe is useless“) | genervt (≈ 3×) | **Verbessern:** Suche über Titel, Zutaten, Tags, Notizen; Filter nach Mappe, Zeit, Favorit |
| Portionen umrechnen | **fehlt in der App** | „Please add serving size adjustment“, „no guides for reducing or multiplying“, „What happened to the halves?“ (≈ 5×) | **Neu/Verbessern:** Portionen ±, ½ ×1 ×2 ×3, Brüche (½, ¼), metrisch ↔ US-Maße |
| Kochmodus | ja: Bildschirm bleibt an, Zutaten/Schritte umschalten | gelobt („easy to switch“), aber „no view that shows the whole recipe so you have to scroll as you cook“ | **Übernehmen + Verbessern:** großer Schritt-für-Schritt-Modus, Zutaten zum Abhaken in einem Fach, **Timer, die aus dem Text erkannt werden** („15 Minuten“), Gesamtansicht bleibt |
| iPad / große Bildschirme | nur ⅓ des Bildschirms | „Can't go full screen on an iPad?!“, „look to the NYTimes cooking app“ (≈ 6×) | **Verbessern (vorbereitet):** Zwei-Spalten-Layout (Liste + Rezept) und Seitenleiste ab Tablet-Breite sind gebaut und getestet; als iPad-App wird sie erst freigeschaltet, wenn die Pipeline iPad-Bildschirmfotos hochlädt (v1.1). Schriftgröße im Kochmodus einstellbar |
| Bewertungen/Kommentare anderer | verborgen („Reviews are hidden“) | genervt (≈ 3×) | **Weglassen** (Inhalte Dritter, Server). Ersatz: **eigene** Bewertung + „Mein Dreh“-Notiz + Koch-Tagebuch |
| Eigene Rezepte anlegen/ändern | ja | „organize and edit my Categories“ gewünscht | **Übernehmen:** Editor mit Zutaten-/Schritt-Zeilen, Fotos, Tags |
| Rezepte-Katalog (100.000) | ja, lizenzierte Verlags-Inhalte | geliebt („catalog much deeper“) | **Weglassen:** fremde Inhalte/Lizenz, Server. Ersatz: 5 mitgelieferte Beispielrezepte (selbst geschrieben), der Rest ist die eigene Sammlung |
| „Was habe ich da?“ (Zutaten eingeben) | ja, Suche mit Zutat | „life changing“ (≈ 3×) | **Übernehmen:** Zutaten-Suche **in den eigenen Rezepten**: nennt Treffer mit „fehlt noch: …“ |
| Einkaufsliste | – (Beschreibung: Meal-Plan-Sammlung) | – | **Neu:** Zutaten mehrerer Rezepte zusammenfassen (Mengen addiert, auf Portionen skaliert), abhaken, teilen |
| Druck/Teilen | „You can't print“ | genervt (≈ 2×) | **Neu:** Teilen als Text (gratis), Rezeptkarte/Kochbuch als PDF (Pro) |
| Konto, E-Mail-Code, 2-Faktor | Pflicht | „Do we really need two factor authentication?“, **Fehler 403**, „Says I'm offline“, Code kommt nicht (≈ 12×) | **Verbessern:** kein Konto, funktioniert offline |
| Abo/Testphase/Werbung | 7-Tage-Test, „money grab“, „bait & switch“ | „Not free“, „Constant subscription pushing“, Lifetime abgeschafft (≈ 14×) | **Verbessern:** Einmalkauf, keine Werbung, kein Tracking |
| App friert beim Speichern ein | Bug | „locks up and gets all blurry“ (≈ 4×) | **Verbessern:** Speichern lokal und sofort, Prüfung per Test |

## Was Nutzer lieben
(aus den 36 Bewertungen mit 4–5 ★)
- **Alle Rezepte an einem Ort, auch aus Social Media** – „finally one place for all my saved recipes“, „no more screenshots“ (≈ 16×).
- **Saubere, aufgeräumte Rezeptansicht ohne Werbung/Blog-Geschwätz** – „without all the clutter and ads“, „very refined user experience“ (≈ 6×).
- **Zutat eingeben, passende Rezepte sehen** – „type in a specific ingredient you have on hand“ (≈ 3×).
- **Mappen selbst anlegen**, Wochenplanung – „building my own collections“ (≈ 4×).
- **Kochmodus, Bildschirm bleibt wach** (≈ 3×).

## Was Nutzer hassen
(aus den 22 Bewertungen mit 1–3 ★)
1. **Konto/Login kaputt** – 403, „offline“, Code kommt nicht, 2FA (≈ 8×).
2. **Gespeicherte Rezepte/Mappen weg oder laden nicht** – „lost dozens of my favorite recipes“, „shows I have no collections“ (≈ 7×).
3. **Kein iPad-Layout** – „only a third of my iPad screen“ (≈ 5×).
4. **Keine Portionsumrechnung, Suche in Gespeichertem schwach** (≈ 5×).
5. **Abo-Druck, Test wird zur Zahlung, „nicht wirklich gratis“, Lifetime abgeschafft** (≈ 6×).
6. **Social-Import schlägt fehl** (≈ 3×), **App friert beim Speichern** (≈ 3×), Bewertungen anderer versteckt (≈ 3×), kein Druck.

## Design des Vorbilds
- Wirkt hochwertig: große, appetitliche Fotos in abgerundeten Karten, ruhiges Raster, fette Überschrift in den Store-Bildern, klare Herz-Markierung auf den Fotos.
- Schwach: Violett/Rosa-Markenfläche wirkt beliebig, die App lebt komplett von fremden Redaktionsfotos (ohne sie leer), kaum eigener Charakter bei Typografie und Formen, Navigation wie Standard-Tabs; Tablet ungenutzt; Mappen sind Foto-Collagen, aber nicht sortier-/greifbar.
- Unsere Antwort: **„Mappe“ statt Foto-Feed** – eine Leinen-/Papier-Mappe mit farbigen **Registerreitern**, Rezepte als **Karteikarten** mit selbst gezeichnetem Motiv (kein fremdes Foto nötig, eigenes Foto optional). Tiefes Tinten-Blau, Safran-Gelb als Akzent, Leinen-Creme; Schrift Young Serif + Figtree.

## Bauplan
**Name:** Kochmappe: Rezeptsammlung (Kurzname `kochmappe`, Bundle-ID `com.lukasbeutler.kochmappe`).
Kern-Dreh: **Deine Rezepte gehören dir** – ohne Konto, ohne Cloud, ohne Verlust (Sicherung als Datei), Einmalkauf statt Abo, mit Tablet-Layout in Vorbereitung.

**Kernfunktionen (Version 1 kann alle):**
1. Rezept aus Link speichern (lokal gelesen: schema.org/Recipe in JSON-LD, Foto wird auf dem Gerät abgelegt), oder Text einfügen (Zutaten/Schritte erkannt), oder von Hand schreiben.
2. Mappen mit Farbreitern, Tags, Favoriten, 1–5 Sterne, Quelle, Notizen.
3. Suche über alles; „Was habe ich da?“ mit fehlenden Zutaten.
4. Rezeptansicht: Portionen ±, ½/×2/×3, Brüche, metrisch ↔ US-Maße, Zutaten abhaken, Schritte, Zeiten, „Mein Dreh“ (eigene Änderungen), Koch-Tagebuch (wann gekocht + Notiz).
5. Kochmodus: ein Schritt pro Seite, große Schrift, Bildschirm bleibt an, Timer aus dem Text erkannt (mehrere gleichzeitig), Zutaten-Fach.
6. Einkaufsliste aus beliebigen Rezepten (summiert, skaliert), abhaken, teilen.
7. Teilen als Text; Sicherung/Wiederherstellen (JSON-Datei); Rezept als PDF-Karte, ganzes Kochbuch als PDF (Pro).
8. Tablet-Layout (Zwei-Spalten) vorbereitet, Hell/Dunkel.

**Unsere Verbesserungen (jede häufige Beschwerde gelöst):** kein Konto → kein 403/2FA/Offline-Fehler · Mappen lokal + Sicherungsdatei → nichts verschwindet · Tablet-Zweispalter (in 1.1 aktiviert) · Portionsrechner mit Brüchen und US-Maßen · starke Suche · Text-Import statt KI-Server für Social-Rezepte · Fehlermeldungen mit Lösungsweg · kein Abo, keine Werbung · Speichern ohne Wartezeit.
**Eigene Ideen (≥ 3, nicht beim Vorbild):** (1) „Mein Dreh“ – eigene Änderungen am Rezept getrennt vom Original, (2) Koch-Tagebuch mit Datum, Note und Zähler „x-mal gekocht“, (3) Timer-Erkennung im Text mit parallelen Timern, (4) Zutaten-Suche mit „fehlt noch“-Liste, (5) Kochbuch-PDF, (6) Sicherungsdatei als Versicherung gegen Datenverlust.

**Gratis vs. Pro:**
- Gratis: bis 25 Rezepte, 3 Mappen, alle Funktionen (Import, Portionen, Kochmodus, Timer, Suche, Einkaufsliste, Tagebuch, Sicherung, Text teilen).
- Pro (einmalig): unbegrenzt Rezepte und Mappen, PDF (Rezeptkarte + Kochbuch), 5 Farbthemen für die Mappe.

**Preise:** Einmalkauf **6,99 €** (`com.lukasbeutler.kochmappe.pro.lifetime`), **kein Abo**.
Begründung: Das Vorbild verlangt ~40 $/Jahr plus Werbung; Hauptärger ist Abo und abgeschaffter Lifetime-Kauf. Recipe Keeper/Paprika-artige Apps
liegen bei Einmalkäufen im Bereich 5–10 €. Eine Rezeptsammlung ist ein dauerhaftes Werkzeug, 6,99 € einmalig ist leicht zu rechtfertigen und
passt zum Radar-Vorschlag. Ein Abo würde dem Dreh „deine Rezepte gehören dir“ widersprechen – bewusst weggelassen.

**Daten/Kosten:** Keine Server. Link-Import ruft nur die vom Nutzer genannte Seite direkt vom Gerät ab (kein Dienst, kein Schlüssel) und liest die
strukturierten Rezeptdaten für den privaten Gebrauch; Foto wird privat auf dem Gerät abgelegt. Keine Inhalte fremder Verlage mitgeliefert.
Keine Apple-Capability nötig (nur StoreKit). Hinweis: Seiten mit Bezahlschranke/Scripts können fehlschlagen → „Text einfügen“.

**Visuelles Konzept „Mappe“:**
- Stimmung: Leinen-Mappe mit Registerreitern und Karteikarten; ruhig, handwerklich, ein bisschen Küchen-Notizbuch.
- Palette hell: Leinen `#F5F0E6`, Karte `#FFFDF8`, Tinte Tiefblau `#14213D`; Akzent **Safran** `#F2A516`, Beere `#B8335A`, Salbei `#5F8F6B`, Himmel `#4C86C6`.
  Dunkel: Tinten-Nacht `#0E1626`, Karte `#17223A`, Text Leinen.
- Schrift: **Young Serif** (OFL) für Titel/Zahlen, **Figtree** (OFL) für Text.
- Formen: Karteikarten mit Eselsohr, Register-Reiter oben an den Karten, Lochung/Heftrand, gezeichnete Motive je Karte (Teller, Schüssel, Kuchen, Pfanne, Glas, Brot) in Mappenfarben.
- Bewegung: Karten gleiten ein, Zähler/Portionen animiert, Timer-Ringe, Haptik beim Abhaken/Speichern.


## Design-Prüfung
Verglichen mit den Bildschirmfotos des Vorbilds (`recherche/vorbild_1…4.jpg`: violett/rosa Markenfläche, Redaktionsfotos in Rastern, fette Schwarz-Überschrift auf Weiß).
Bilder: `screenshots/out/de_1…7.png`, `en_1…7.png`, dazu eine Dunkelmodus-Durchsicht aller Tabs.

**Runde 1** (erste Bildschirmfotos)
| Kriterium | Punkte | Befund |
|---|---|---|
| Erster Eindruck | 7 | Startseite zeigt sofort Wert (Heute-Karte, Karten mit Motiv), aber Überschrift und Rahmen der Store-Bilder viel zu groß: Gerät unten abgeschnitten, Kaufknopf und Navigation unsichtbar |
| Farbe | 8 | Tinten-Blau + Safran + Leinen klar eigenständig (kein Violett), Kartenfarben stimmig |
| Typografie | 8 | Young Serif für Titel, Figtree für Text, klare Hierarchie |
| Aufbau | 6 | Rezeptseite: Kopfleiste scrollte weg (Zurück-Knopf unerreichbar), Pillen schauten unter die Knöpfe; „Zur Liste“ umbrach; Portionen-Zeile lief auf kleinen Geräten über; Bild 4 (Link-Seite) fast leer; Bild 5 zeigte durch einen Fehler im Test den Leerzustand der Suche |
| Visualisierung | 8 | Gezeichnete Motive (8), Timer-Ringe, Registerreiter |
| Paywall | 8 | Kartenfächer, drei Funktionen mit Vorschau, Preis fest unten; Fächer berührte den Titel |
| Symbol | 8 | Mappe + Karte + Schüssel; Kringel oben rechts und Dampf über dem Kartenkopf wirkten unruhig |

**Überarbeitung nach Runde 1:** Store-Rahmen neu (kleine Überschrift, Gerät komplett mit Navigationsleiste und Kaufknopf); Kopfleiste der Rezeptseite fest mit Hintergrund und Trennlinie beim Scrollen; „Zur Liste“ kürzer; Portionen-/Einheiten-Zeile und Bearbeiten-Zeile umbrechen sauber; Bild 4 zeigt jetzt den Text-Import mit erkannten Zutaten statt einer leeren Seite; Bild 5 mit echten Treffern („Fehlt noch: …“); Fächer höher; Symbol: Schüssel tiefer, Kringel blasser.

**Runde 2**
| Kriterium | Punkte | Befund |
|---|---|---|
| Erster Eindruck | 8 | Heute-Karte, Registerreiter, Motivkarten; Bilder verkaufen Funktionen (Portionen, Kochmodus mit Timer, Vorrat, Tagebuch) |
| Farbe | 9 | Eigenes Konzept in Hell und Dunkel, Safran trägt Aktionen, Kartenfarben nur als Akzent |
| Typografie | 9 | Große Serif-Zahlen/Titel, Fließtext ruhig; im Kochmodus 30 pt, einstellbar |
| Aufbau | 8 | Klare Abschnitte, feste Kopfleiste, Textgröße 130 % auf 320 pt Breite ohne Überlauf (Test) |
| Visualisierung | 8 | Selbst gezeichnete Motive und Ringe; Schwäche: Dunkelmodus-Kartenflächen etwas matt |
| Paywall | 8 | Preis, „einmalig · kein Abo“, Restore/Bedingungen/Datenschutz; „Gratis bleibt“-Karte liegt unter der Preisleiste (scrollbar) |
| Symbol | 8 | Klar, unverwechselbar (Safran-Mappe, Karte, Schüssel) |

Ergebnis: alle Werte ≥ 8. Gegenüber dem Vorbild: eigene Gestaltung statt fremder Redaktionsfotos – die App wirkt auch mit leerer Sammlung hochwertig (gezeichnete Motive), Foto optional.

## Abstand zum Vorbild
Vorbild ist „MyRecipes“ (Verlags-App mit Katalog). Prüfung gegen Store-Seite und Bildschirmfotos:
| Punkt | Bewertung |
|---|---|
| Name | „Kochmappe“ – deutsches Wort, kein Teil von „MyRecipes“, klingt anders; keine Konkurrenzmarke (ReciMe, Recipe Keeper, Paprika …) |
| Symbol | Safran-Mappe + Karteikarte + Schüssel auf Tinten-Blau; Vorbild: violett/rosa Wortmarke – kein ähnliches Motiv oder Farbschema |
| Farben/Schrift | Tinten-Blau/Safran/Leinen, Young Serif + Figtree; Vorbild: Violett/Rosa, Schwarz-Grotesk |
| Startbildschirm-Aufbau | Titel „Meine Mappe“, Suche, Registerreiter, Tagesidee, Karten mit gezeichneten Motiven; Vorbild: Foto-Raster/Empfehlungen aus dem Katalog |
| Store-Bilder | Blauer Verlauf, Überschrift links, gerahmtes Gerät; andere Reihenfolge und Inhalte (Portionen, Kochmodus, Text-Import, Vorrat, Tagebuch, Preis); Vorbild: Violett mit Foto-Collagen |
| Store-Texte/Suchbegriffe | Keine Marken (weder MyRecipes noch Allrecipes, ReciMe, Paprika, Instagram, TikTok); Beschreibung selbst formuliert, nur „liest die Rezeptseite“ sachlich |
| Eigene Ideen (≥ 3) | (1) „Mein Dreh“ – eigene Änderungen getrennt vom Original, (2) Koch-Tagebuch mit Datum/Notiz/Zähler, (3) Timer aus dem Rezepttext, mehrere parallel, (4) „Was habe ich da?“ mit „Fehlt noch“-Liste in den eigenen Rezepten, (5) Sicherungsdatei gegen Datenverlust, (6) Kochbuch-PDF, (7) Tagesidee („am längsten nicht gekocht“) |
| Inhalte | Keine Texte/Bilder/Datenbanken des Vorbilds; nur 6 selbst geschriebene Beispielrezepte; Import liest nur, was der Nutzer selbst angibt, und legt private Kopien an |

Ergebnis: **deutlich eigenständig** – anderes Problem-Verständnis (eigene Sammlung statt Verlagskatalog), andere Optik, andere Texte, anderer Kern-Dreh (kein Konto, Einmalkauf, lokale Daten).
