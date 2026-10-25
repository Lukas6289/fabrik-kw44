// Gibt die naechste freie Buildnummer einer App aus: hoechste bei Apple
// vorhandene + 1, ueber alle Versionen hinweg.
//
//   node tool/asc_buildnummer.js com.maxlangu.tamil   → 261
//
// Codemagic zaehlte selbst hoch (PROJECT_BUILD_NUMBER); in GitHub Actions gibt
// es keinen Zaehler je App, und eine schon vergebene Nummer lehnt Apple beim
// Hochladen ab. Daher fragt die Pipeline Apple direkt.

const { asc } = require('./asc_lib');

(async () => {
  const bundle = process.argv[2];
  const app = ((await asc('GET', '/v1/apps?filter[bundleId]=' + bundle)).body.data || [])[0];
  if (!app) { console.error('App nicht gefunden: ' + bundle); process.exit(1); }
  const r = await asc('GET', `/v1/builds?filter[app]=${app.id}&sort=-uploadedDate&limit=50`);
  if (r.code >= 400) { console.error('HTTP ' + r.code); process.exit(1); }
  const hoechste = Math.max(0, ...(r.body.data || []).map((b) => Number(b.attributes.version) || 0));
  // Für den Bericht: was Apple von dieser App kennt (stderr landet im Build-Log).
  for (const b of (r.body.data || []).slice(0, 5)) {
    console.error(`Bei Apple: Build ${b.attributes.version} · ${b.attributes.processingState} · ${b.attributes.uploadedDate}`);
  }
  if (!(r.body.data || []).length) console.error('Bei Apple: noch kein Build sichtbar');
  console.log(hoechste + 1);
})();
