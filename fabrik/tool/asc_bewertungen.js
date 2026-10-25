// Holt die Kundenbewertungen ALLER Apps des Kontos aus App Store Connect und
// legt sie im Repo ab – fuer den Fabrik-Kontrolleur (Claude), der daraus
// wiederkehrende Kritik erkennt und Fehler behebt.
//
//   node fabrik/tool/asc_bewertungen.js [zielordner]   (Std. fabrik/BEWERTUNGEN)
//
// Ergebnis je App: <zielordner>/<bundle-id>.json (neueste zuerst, bis 500) und
// <zielordner>/UEBERSICHT.md (Zahlen je App, neueste Kritik).
// Nur lesen – antwortet nicht auf Bewertungen und aendert nichts bei Apple.

const fs = require('fs');
const path = require('path');
const { asc, fehlertext } = require('./asc_lib');

const ZIEL = process.argv[2] || 'fabrik/BEWERTUNGEN';
const TAG = 86400000;
const liste = (r) => (r.body && r.body.data) || [];

async function alle(pfad, max) {
  const out = [];
  let naechste = pfad;
  while (naechste && out.length < max) {
    const r = await asc('GET', naechste);
    if (r.code >= 300) { console.log(`  ✘ ${fehlertext(r)}`); break; }
    out.push(...liste(r));
    const link = r.body.links && r.body.links.next;
    naechste = link ? link.replace('https://api.appstoreconnect.apple.com', '') : null;
  }
  return out.slice(0, max);
}

(async () => {
  fs.mkdirSync(ZIEL, { recursive: true });
  const apps = await alle('/v1/apps?limit=200&fields[apps]=name,bundleId', 1000);
  console.log(`${apps.length} Apps im Konto`);
  const zeilen = ['# Bewertungen', '', `Stand: ${new Date().toISOString().slice(0, 16).replace('T', ' ')} UTC`, '',
    '| App | Bundle-ID | Bewertungen (geladen) | Ø Sterne | letzte 30 Tage | davon ≤ 3 ★ |', '|---|---|---|---|---|---|'];
  const kritik = [];
  for (const app of apps) {
    const { name, bundleId } = app.attributes;
    const reviews = await alle(`/v1/apps/${app.id}/customerReviews?sort=-createdDate&limit=200&include=response`, 500);
    const daten = reviews.map((r) => ({
      id: r.id,
      sterne: r.attributes.rating,
      titel: r.attributes.title || '',
      text: r.attributes.body || '',
      land: r.attributes.territory || '',
      datum: r.attributes.createdDate,
      beantwortet: !!(r.relationships && r.relationships.response && r.relationships.response.data),
    }));
    fs.writeFileSync(path.join(ZIEL, `${bundleId}.json`), JSON.stringify({ app: name, bundleId, appId: app.id, bewertungen: daten }, null, 1));
    const neu = daten.filter((d) => Date.now() - Date.parse(d.datum) < 30 * TAG);
    const schlecht = neu.filter((d) => d.sterne <= 3);
    const schnitt = daten.length ? (daten.reduce((a, d) => a + d.sterne, 0) / daten.length).toFixed(2) : '–';
    zeilen.push(`| ${name} | ${bundleId} | ${daten.length} | ${schnitt} | ${neu.length} | ${schlecht.length} |`);
    for (const d of schlecht.slice(0, 10)) kritik.push(`- **${name}** · ${d.sterne} ★ · ${d.datum.slice(0, 10)} · ${d.land}: „${d.titel}“ – ${d.text.replace(/\s+/g, ' ').slice(0, 300)}`);
    console.log(`  ${name}: ${daten.length} Bewertungen, ${schlecht.length} kritische in 30 Tagen`);
  }
  zeilen.push('', '## Neueste Kritik (≤ 3 ★, letzte 30 Tage, je App höchstens 10)', '', ...(kritik.length ? kritik : ['Keine.']), '');
  fs.writeFileSync(path.join(ZIEL, 'UEBERSICHT.md'), zeilen.join('\n'));
})();
