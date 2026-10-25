# Recherche 2: Schreibspur

## Vorbild
- **The Cringe: Chat Wrapped** – https://apps.apple.com/de/app/the-cringe-chat-wrapped/id6766070732
  4,0 ★ (317 Bewertungen de), 4,2 ★ (370 us), gratis laden + Abo-Pflicht für alle Statistiken.
  Umsatzrang 42 in Dienstprogramme bei 167 Tagen Alter (App-Radar 2026-10-22).
- Konkurrenten (iOS): Spilk – Wrapped, Chat Analyse (4,6 ★, 14), ChatRecap AI (3,9 ★, 50),
  ChatWrapped: Love Wrapped, The Ick. Android: Narya – Wrapped Chat Recap (500.000+, nur 3,0 ★).
- Quellen: iTunes-Lookup (Beschreibung, Versionshinweise), App-Store-Seite mit Bewertungen,
  App-Radar-Daten. Der RSS-Bewertungs-Feed war aus dieser Umgebung gesperrt (robots), deshalb
  nur die auf der Store-Seite sichtbaren Bewertungen.

## Funktionen
| Funktion | beim Vorbild | Urteil der Nutzer | Entscheidung |
|---|---|---|---|
| WhatsApp-Export einlesen | ja | Kernnutzen | **Übernehmen** – plus direkt aus dem Teilen-Menü |
| Nachrichten je Person | ja | beliebt | **Übernehmen** |
| Antwortzeit auf die Minute | ja | beliebt | **Übernehmen** (Median, robust gegen Nachtpausen) |
| Wortzählung / „Muster“ | ja | beliebt | **Verbessern**: Lieblingswörter + Wortwolke nach Person |
| Statistik-Dashboard | ja | – | **Übernehmen** als Karten |
| „Wrapped“-Präsentation | Name/Konzept | Trend, teilbar | **Verbessern**: echte Story mit Folien, Zähl-Animation, jede Folie als Bild |
| Import aus Bildschirmfotos (OCR, jeder Messenger) | ja | unbekannt | **Später** (1.1): Vision-OCR ohne Zeitstempel liefert nur Teilwerte, ohne Gerätetest zu riskant |
| Spanische u. a. Exporte | fehlerhaft („nur wenige Nachrichten gefunden“) | 1★-Grund | **Verbessern**: Platzhalter/gelöschte/bearbeitete Nachrichten in 8 Sprachen erkannt, getestet |
| Abo-Pflicht für alles | ja | Hauptbeschwerde | **Weglassen**: Gratis-Teil nützlich, Pro auch als Einmalkauf |
| Gruppenchats | eingeschränkt | – | **Verbessern**: Auszeichnungen für Gruppen |
| Zeitraum-Vergleich, Chat-Jahr, Poster | nein | – | **Eigene Extras** |

## Was Nutzer lieben
- „Very cool“ – der Wrapped-Effekt, schnelle Zahlen zum Teilen (mehrere positive Kurzbewertungen).
- Exakte Zahlen statt Raten (Kernversprechen der Beschreibung, 4 ★ Durchschnitt).

## Was Nutzer hassen
- Abo-Zwang, ohne Bezahlen nichts zu sehen (4 von 6 sichtbaren Bewertungen: „Why does your app have subscription“, „turn off premium mode“, „tells users what they have to pay“).
- Spanische Chats werden nicht erkannt („Solo se encontraron unos pocos mensajes“, 1 Bewertung).

## Design des Vorbilds
- Stark: Wrapped-Anmutung, große Zahlen, teilbare Bilder – das erwartet die Zielgruppe.
- Schwach: „Cringe“-Ton (Bloßstellen), Paywall vor dem ersten Ergebnis, Dashboard eher nüchtern.
- Unsere Version 1 (vor der Überarbeitung) war zu brav: Standard-Lila, graue Karten, Standardschrift.

## Bauplan
- Kernfunktionen (alle in 1.0): Export-Import (Datei, Zwischenablage, Teilen-Menü), Überblick,
  Rhythmus, Lieblingswörter, Wortwolke, Antwortzeit, Wer fängt an, Emoji, Rekorde, Auszeichnungen,
  Chat-Jahr, Früher vs. jetzt, Poster, **Story-Rückblick** mit teilbaren Folien.
- Verbesserungen: freundlicher Ton, sichtbar offline (Flugmodus-Beweis), mehrsprachiger Parser,
  ehrliche Preise (Einmalkauf 12,99 € oder 4,99 €/Jahr), Gratis-Teil mit echter Story (5 Folien).
- Gratis: Überblick, Rhythmus, 3 Wörter, Story bis „Euer Wort“, Überblick teilen. Pro: alles andere.
- Visuelles Konzept: „warmes Papier + Wrapped-Verläufe“. Grund Creme (#FFF6EC) bzw. Nacht (#120E1C),
  Tinte #1C1530; jede Karte ein eigener Verlauf (Violett, Koralle, Türkis, Sonne, Pink, Blau, Nacht)
  mit weißer Schrift; Schrift Bricolage Grotesque (Display 96 opsz für Zahlen/Titel, Text 14 opsz);
  runde Formen (Radius 28), Sprechblasen-Motive, Zähl-Animationen, Haptik.

## Design-Prüfung
Runde 1 (nach dem Umbau, Bildschirmfotos de/en angesehen):
| Kriterium | Punkte | Befund |
|---|---|---|
| Erster Eindruck | 8 | Hero mit Sprechblasen stark; Story-Folie „Nachrichten“ wirkte leer |
| Farbe | 9 | Verläufe je Karte, gut lesbar, Dunkelmodus stimmig |
| Typografie | 8 | Bricolage markant; Story-Inhalte zu klein |
| Aufbau | 7 | Bildschirmfoto-Überschriften unterschiedlich lang → Gerät springt |
| Visualisierung | 8 | Wortwolke, Chat-Jahr gut; englische Wolke mit Füllwörtern |
| Paywall | 8 | Verlaufskopf mit Vorschau, Optionen mit Abzeichen |
| Symbol | 7 | Farben passten nicht mehr zur neuen Palette |

Überarbeitet: Monats-Balken auf der Zahlen-Folie, Story-Inhalte 120 %, feste Überschriftenhöhe,
englische/deutsche Füllwörter ergänzt, Symbol in Markenfarben, Startbildschirm (Creme + Symbol)
statt Flutter-Platzhalter, Zahl im Hero nach Gerätesprache.

Runde 2:
| Kriterium | Punkte |
|---|---|
| Erster Eindruck | 9 |
| Farbe | 9 |
| Typografie | 8 |
| Aufbau | 8 |
| Visualisierung | 8 |
| Paywall | 8 |
| Symbol | 8 |

Geprüft außerdem: Dunkelmodus und Textgröße 130 % (keine Überläufe), Story mit Ahem-Testschrift
(Überlauf in der Fußzeile gefunden und behoben).

## Abstand zum Vorbild
Geprüft 24.10.2026 (Vorbild „The Cringe: Chat Wrapped“).
- Name/Untertitel: „Schreibspur: Chat-Rückblick“ – kein Namensteil; „Wrapped“ (Spotify-Begriff) bewusst nicht
  verwendet, 24.10. auch aus den Suchbegriffen entfernt. ✔
- Symbol: eigenes Motiv in Markenfarben. ✔
- Design: Creme/Nacht + Verlaufskarten, Bricolage Grotesque, eigene Story-Folien. ✔
- Store-Texte: WhatsApp nur sachlich für Kompatibilität, mit Hinweis „nicht verbunden mit WhatsApp“. ✔
- Eigene Ideen (≥ 3): freundlicher statt bloßstellender Ton, sichtbar offline (nichts gespeichert),
  Früher-vs.-jetzt-Vergleich, Chat-Jahr-Streifen, Poster aller Karten, Auszeichnungen, Gratis-Teil statt Bezahlwand. ✔
Ergebnis: deutlich eigenständig.
