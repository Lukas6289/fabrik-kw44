"""Erzeugt Bilder mit Google Gemini (Nano Banana) – läuft im GitHub-Workflow `bilder.yml`.

Auftrag = JSON-Datei in eduki/bildauftrag/, z. B. tiere-winter.json:
  {"ziel": "eduki/bibliothek/tiere-winter-bogen.png",
   "prompt": "Sticker sheet of 12 ... 4 columns x 3 rows ...",
   "seitenverhaeltnis": "4:3", "referenz": ["eduki/.../vorlage.png"]}   # referenz optional
Der Workflow erzeugt das Bild, legt es unter `ziel` ab, verschiebt den Auftrag nach
eduki/bildauftrag/erledigt/ und committet beides. Schlüssel kommt aus dem Secret GEMINI_API_KEY.
"""
import base64
import json
import os
import pathlib
import sys
import time
import urllib.error
import urllib.request

MODELL = os.environ.get('GEMINI_BILD_MODELL', 'gemini-2.5-flash-image')
URL = f'https://generativelanguage.googleapis.com/v1beta/models/{MODELL}:generateContent'
SCHLUESSEL = os.environ['GEMINI_API_KEY']
PREIS_USD = 0.039  # Listenpreis pro Bild gemini-2.5-flash-image (1024 px), Stand 2026 – bei Modellwechsel anpassen
WURZEL = pathlib.Path(__file__).resolve().parents[2]


def erzeuge(prompt, verhaeltnis, referenz=()):
    teile = [{'text': prompt}]
    for r in referenz:  # Referenzbilder (Stil/Motiv-Vorlage), Pfade relativ zum Repo
        pfad = WURZEL / r
        mime = 'image/png' if pfad.suffix.lower() == '.png' else 'image/jpeg'
        teile.append({'inlineData': {'mimeType': mime, 'data': base64.b64encode(pfad.read_bytes()).decode()}})
    body = {'contents': [{'parts': teile}],
            'generationConfig': {'responseModalities': ['IMAGE'], 'imageConfig': {'aspectRatio': verhaeltnis}}}
    for versuch in range(4):
        req = urllib.request.Request(URL, data=json.dumps(body).encode(), method='POST',
                                     headers={'Content-Type': 'application/json', 'x-goog-api-key': SCHLUESSEL})
        try:
            antwort = json.load(urllib.request.urlopen(req, timeout=180))
        except urllib.error.HTTPError as e:
            text = e.read().decode()[:500]
            print(f'HTTP {e.code}: {text}')
            if e.code in (429, 500, 503) and versuch < 3:
                time.sleep(20 * (versuch + 1))
                continue
            raise SystemExit(1)
        for teil in antwort.get('candidates', [{}])[0].get('content', {}).get('parts', []):
            if 'inlineData' in teil:
                return base64.b64decode(teil['inlineData']['data']), antwort.get('usageMetadata', {})
        print('Kein Bild in der Antwort:', json.dumps(antwort)[:500])
        raise SystemExit(1)


def kosten_eintragen(name, ziel, nutzung):
    """Jedes erzeugte Bild in eduki/KOSTEN.md protokollieren (Lukas will den Verbrauch immer sehen)."""
    datei = WURZEL / 'eduki' / 'KOSTEN.md'
    if not datei.exists():
        datei.write_text('# Gemini-Bildkosten (automatisch vom Bilder-Workflow)\n\n'
                         f'Schätzung mit Listenpreis {PREIS_USD} $ pro Bild. Das echte Restguthaben steht nur in Google AI Studio\n'
                         '(aistudio.google.com → Abrechnung / Billing) bzw. console.cloud.google.com/billing.\n\n'
                         '| Datum (UTC) | Auftrag | Ziel | Modell | Tokens ein/aus | ca. Kosten |\n|---|---|---|---|---|---|\n')
    ein = nutzung.get('promptTokenCount', '?')
    aus = nutzung.get('candidatesTokenCount', '?')
    with datei.open('a') as f:
        f.write(f"| {time.strftime('%Y-%m-%d %H:%M', time.gmtime())} | {name} | {ziel} | {MODELL} | {ein}/{aus} | {PREIS_USD:.3f} $ |\n")


def main():
    ordner = WURZEL / 'eduki' / 'bildauftrag'
    erledigt = ordner / 'erledigt'
    erledigt.mkdir(exist_ok=True)
    auftraege = sorted(ordner.glob('*.json'))
    if not auftraege:
        print('Keine Aufträge.')
        return
    for a in auftraege[:20]:  # Sicherheitsgrenze pro Lauf
        auftrag = json.loads(a.read_text())
        ziel = WURZEL / auftrag['ziel']
        ziel.parent.mkdir(parents=True, exist_ok=True)
        ref = auftrag.get('referenz', [])
        ref = [ref] if isinstance(ref, str) else ref
        daten, nutzung = erzeuge(auftrag['prompt'], auftrag.get('seitenverhaeltnis', '1:1'), ref)
        kosten_eintragen(a.stem, auftrag['ziel'], nutzung)
        ziel.write_bytes(daten)
        auftrag['erledigt'] = time.strftime('%Y-%m-%d %H:%M UTC', time.gmtime())
        auftrag['modell'] = MODELL
        (erledigt / a.name).write_text(json.dumps(auftrag, ensure_ascii=False, indent=1))
        a.unlink()
        print(f'{a.name} → {auftrag["ziel"]} ({len(daten) // 1024} KB)')


if __name__ == '__main__':
    sys.exit(main())
