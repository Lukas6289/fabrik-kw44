// Erzeugt die Support-Seite einer Fabrik-App aus store/asc.json und kopiert
// die Datenschutzseite dazu – Ziel ist ein Ordner im Repo Lukas6289.github.io.
//
//   node fabrik/tool/seiten.js fabrik/<app> <ziel>/<app>

const fs = require('fs');
const path = require('path');

const [dir, ziel] = process.argv.slice(2);
if (!dir || !ziel) { console.error('Aufruf: node seiten.js fabrik/<app> <zielordner>'); process.exit(2); }

const asc = JSON.parse(fs.readFileSync(path.join(dir, 'store/asc.json'), 'utf8'));
const de = asc.locales['de-DE'];
const en = asc.locales['en-US'] || de;
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const mail = 'lukasbeutler@gmx.de';
const agb = 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

const html = `<!doctype html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(de.name)} – Support</title>
<style>
  body { font: 16px/1.55 -apple-system, system-ui, sans-serif; max-width: 680px; margin: 0 auto; padding: 24px 16px; color: #1b1f24; background: #fff; }
  h1 { font-size: 1.6rem; } h2 { font-size: 1.15rem; margin-top: 2rem; }
  a { color: #2f6fb3; }
  @media (prefers-color-scheme: dark) { body { color: #e6e9ee; background: #111418; } a { color: #8ab4f8; } }
</style>
</head>
<body>
<h1>${esc(de.name)}</h1>
<p>${esc(de.subtitle || '')}</p>

<h2>Hilfe &amp; Kontakt</h2>
<p>Fragen, Fehler oder Wünsche? Schreib an <a href="mailto:${mail}?subject=${encodeURIComponent(de.name)}">${mail}</a>.</p>

<h2>Häufige Fragen</h2>
<p><strong>Pro gekauft, aber nicht freigeschaltet?</strong> In der App „Käufe wiederherstellen“ tippen.</p>
<p><strong>Abo kündigen?</strong> iPhone-Einstellungen → dein Name → Abonnements.</p>

<p><a href="datenschutz.html">Datenschutz</a> · <a href="${agb}">Nutzungsbedingungen</a></p>

<hr>
<h2>${esc(en.name)} – Support</h2>
<p>Questions or problems? Email <a href="mailto:${mail}?subject=${encodeURIComponent(en.name)}">${mail}</a>. Pro not unlocked: tap "Restore purchases" in the app. Cancel the subscription: iPhone Settings → your name → Subscriptions.</p>
<p><a href="datenschutz.html">Privacy Policy</a> · <a href="${agb}">Terms of Use</a></p>
</body>
</html>
`;

fs.mkdirSync(ziel, { recursive: true });
fs.writeFileSync(path.join(ziel, 'index.html'), html);
fs.copyFileSync(path.join(dir, 'store/datenschutz.html'), path.join(ziel, 'datenschutz.html'));
console.log('Seiten geschrieben: ' + ziel);
