// Gemeinsamer Zugang zur App-Store-Connect-API fuer die Werkzeuge, die auch
// in GitHub Actions laufen. Schluessel kommt aus ASC_KEY_PATH (lokal Std.
// E:/AuthKey_4254G5B354.p8, in der Cloud aus dem Secret geschrieben).
//
// Apple lehnt Token mit mehr als 20 Minuten Gueltigkeit ab, daher je Aufruf
// frisch signiert.

const fs = require('fs');
const crypto = require('crypto');
const https = require('https');

const KEY_ID = process.env.ASC_KEY_ID || '4254G5B354';
const ISSUER = process.env.ASC_ISSUER_ID || 'f036d3fc-6983-4fd5-a789-f0a39a7a3e88';
const P8 = process.env.ASC_KEY_PATH || 'E:/AuthKey_4254G5B354.p8';

let schluessel;
function jwt() {
  schluessel = schluessel || fs.readFileSync(P8, 'utf8');
  const enc = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
  const h = enc({ alg: 'ES256', kid: KEY_ID, typ: 'JWT' });
  const p = enc({
    iss: ISSUER, exp: Math.floor(Date.now() / 1000) + 1100,
    aud: 'appstoreconnect-v1',
  });
  return h + '.' + p + '.' + crypto
    .sign('sha256', Buffer.from(h + '.' + p),
      { key: schluessel, dsaEncoding: 'ieee-p1363' }).toString('base64url');
}

/// Liefert immer { code, body } – nie eine Ausnahme. Bei 429/5xx wird bis zu
/// dreimal mit wachsender Pause wiederholt.
function asc(methode, pfad, koerper, versuch = 0) {
  return new Promise((ok) => {
    const daten = koerper ? JSON.stringify(koerper) : null;
    const req = https.request({
      host: 'api.appstoreconnect.apple.com', path: pfad, method: methode,
      headers: {
        Authorization: 'Bearer ' + jwt(),
        ...(daten ? { 'Content-Type': 'application/json',
                      'Content-Length': Buffer.byteLength(daten) } : {}),
      },
    }, (res) => {
      let d = '';
      res.on('data', (c) => (d += c));
      res.on('end', () => {
        let j = {};
        try { j = d ? JSON.parse(d) : {}; } catch (e) { j = {}; }
        ok({ code: res.statusCode, body: j });
      });
    });
    req.on('error', (e) => ok({ code: 0, body: { fehler: e.message } }));
    if (daten) req.write(daten);
    req.end();
  }).then(async (r) => {
    if ((r.code === 429 || r.code >= 500 || r.code === 0) && versuch < 3) {
      await schlaf(5000 * (versuch + 1));
      return asc(methode, pfad, koerper, versuch + 1);
    }
    return r;
  });
}

/// Laedt eine Datei an die von Apple vorgegebenen Upload-Adressen hoch.
async function hochladen(operationen, puffer) {
  for (const op of operationen) {
    const teil = puffer.subarray(op.offset, op.offset + op.length);
    const url = new URL(op.url);
    const kopf = {};
    for (const h of op.requestHeaders || []) kopf[h.name] = h.value;
    // Ohne feste Laenge schickt Node „chunked" – das lehnt Apples Speicher ab.
    kopf['Content-Length'] = teil.length;
    const code = await new Promise((ok) => {
      const req = https.request({
        host: url.host, path: url.pathname + url.search,
        method: op.method, headers: kopf,
      }, (res) => { res.resume(); res.on('end', () => ok(res.statusCode)); });
      req.on('error', () => ok(0));
      req.write(teil);
      req.end();
    });
    if (code >= 300 || code === 0) {
      console.error('Upload-Teil ' + op.offset + ': HTTP ' + code);
      return false;
    }
  }
  return true;
}

const fehlertext = (r) => ((r.body && r.body.errors) || [])
  .map((e) => e.detail || e.title).join('; ') || ('HTTP ' + r.code);

const schlaf = (ms) => new Promise((r) => setTimeout(r, ms));

module.exports = { asc, hochladen, fehlertext, schlaf };
