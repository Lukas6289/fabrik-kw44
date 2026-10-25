// Registriert die Bundle-ID einer Fabrik-App bei Apple und schaltet die
// Capabilities ein, die ihre Runner.entitlements verlangen (z. B. WeatherKit).
// Idempotent: Vorhandenes bleibt, wie es ist.
//
//   node fabrik/tool/asc_bundle.js fabrik/flugfenster
//
// Schlüssel wie bei den anderen asc_*-Werkzeugen über ASC_KEY_PATH.
// Prüft am Ende, ob der App-Eintrag in App Store Connect existiert – den kann
// Apple per API nicht anlegen lassen, das bleibt Handarbeit (fuer-lukas.md).

const fs = require('fs');
const path = require('path');
const { asc, fehlertext } = require('./asc_lib');

// Eintrag in Runner.entitlements → Capability-Typ der App-Store-Connect-API.
const CAPS = {
  'com.apple.developer.weatherkit': 'WEATHERKIT',
  'com.apple.developer.icloud-services': 'ICLOUD',
  'aps-environment': 'PUSH_NOTIFICATIONS',
  'com.apple.developer.healthkit': 'HEALTHKIT',
  'com.apple.developer.associated-domains': 'ASSOCIATED_DOMAINS',
};

function bundleId(dir) {
  const pbx = fs.readFileSync(path.join(dir, 'ios/Runner.xcodeproj/project.pbxproj'), 'utf8');
  const ids = [...pbx.matchAll(/PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);/g)]
    .map((m) => m[1].trim())
    .filter((id) => !id.endsWith('.RunnerTests'));
  if (!ids.length) throw new Error('Keine Bundle-ID in project.pbxproj');
  return ids[0];
}

function caps(dir) {
  const f = path.join(dir, 'ios/Runner/Runner.entitlements');
  if (!fs.existsSync(f)) return [];
  const x = fs.readFileSync(f, 'utf8');
  return Object.entries(CAPS).filter(([k]) => x.includes(`<key>${k}</key>`)).map(([, v]) => v);
}

(async () => {
  const dir = process.argv[2];
  if (!dir) { console.error('Aufruf: node asc_bundle.js fabrik/<app>'); process.exit(2); }
  const id = bundleId(dir);
  const name = path.basename(dir);
  let fehler = 0;

  let r = await asc('GET', `/v1/bundleIds?filter[identifier]=${encodeURIComponent(id)}&limit=5`);
  let b = (r.body.data || []).find((d) => d.attributes.identifier === id);
  if (b) {
    console.log(`✔ Bundle-ID vorhanden: ${id}`);
  } else {
    r = await asc('POST', '/v1/bundleIds', {
      data: { type: 'bundleIds', attributes: { identifier: id, name: `Fabrik ${name}`, platform: 'IOS' } },
    });
    if (r.code >= 300) {
      console.error(`✘ Bundle-ID ${id} nicht angelegt: ${fehlertext(r)}`);
      process.exit(1);
    }
    b = r.body.data;
    console.log(`✔ Bundle-ID angelegt: ${id}`);
  }

  r = await asc('GET', `/v1/bundleIds/${b.id}/bundleIdCapabilities`);
  const da = new Set((r.body.data || []).map((c) => c.attributes.capabilityType));
  for (const cap of caps(dir)) {
    if (da.has(cap)) { console.log(`✔ ${cap} schon aktiv`); continue; }
    r = await asc('POST', '/v1/bundleIdCapabilities', {
      data: {
        type: 'bundleIdCapabilities',
        attributes: { capabilityType: cap },
        relationships: { bundleId: { data: { type: 'bundleIds', id: b.id } } },
      },
    });
    if (r.code >= 300) {
      fehler++;
      console.error(`✘ ${cap} ließ sich per API nicht einschalten: ${fehlertext(r)}`);
      console.error(`  → von Hand: developer.apple.com → Identifiers → ${id} → ${cap} anhaken.`);
    } else {
      console.log(`✔ ${cap} eingeschaltet`);
    }
  }

  r = await asc('GET', `/v1/apps?filter[bundleId]=${encodeURIComponent(id)}`);
  if (!(r.body.data || []).length) {
    console.error(`✘ Kein App-Eintrag für ${id} in App Store Connect.`);
    console.error('  → App Store Connect → Apps → + → Neue App (siehe fabrik/fuer-lukas.md).');
    process.exit(1);
  }
  console.log('✔ App-Eintrag vorhanden');
  process.exit(fehler ? 1 : 0);
})();
