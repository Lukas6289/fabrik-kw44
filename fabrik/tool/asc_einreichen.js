// Reicht eine Fabrik-App bei Apple zur Pruefung ein – nur auf ausdruecklichen
// Wunsch von Lukas (Datei fabrik/EINREICHEN, Workflow einreichen.yml).
//
//   node fabrik/tool/asc_einreichen.js pruefen <bundle-id>   nur schauen
//   node fabrik/tool/asc_einreichen.js los     <bundle-id>   anhaengen + einreichen
//
// Je App: bearbeitbare Version suchen, neuesten gueltigen Build anhaengen
// (Versionsnummer angleichen), Laender/Preis „gratis mit Kauf"/Rechte setzen,
// falls leer; Einmalkauf und Abo muessen READY_TO_SUBMIT sein und gehen in
// DERSELBEN Einreichung mit (Erst-Kaeufe nimmt Apple nur mit einer Version).
// Klappt ein Kauf-Posten nicht, wird NICHT abgeschickt – die Einreichung
// bleibt als Entwurf liegen und Lukas kann sie im Web fertig machen.
// Preise werden nie geaendert.

const { asc, fehlertext: kurz, schlaf } = require('./asc_lib');
// Apples Fehler samt „associated errors“ (dort steht der eigentliche Grund).
const fehlertext = (r) => {
  const meta = ((r.body && r.body.errors) || [])[0] || {};
  const mehr = meta.meta && meta.meta.associatedErrors ? Object.values(meta.meta.associatedErrors).flat()
    .map((e) => (e.code ? e.code + ': ' : '') + (e.detail || e.title)) : [];
  return [kurz(r), ...mehr].join('\n    ');
};

const liste = (r) => (r.body && r.body.data) || [];
const BEARBEITBAR = ['PREPARE_FOR_SUBMISSION', 'READY_FOR_REVIEW', 'DEVELOPER_REJECTED', 'REJECTED',
  'METADATA_REJECTED', 'INVALID_BINARY'];
const UNTERWEGS = ['WAITING_FOR_REVIEW', 'IN_REVIEW', 'PENDING_DEVELOPER_RELEASE',
  'READY_FOR_SALE', 'PROCESSING_FOR_DISTRIBUTION'];
const KAUF_OK = ['WAITING_FOR_REVIEW', 'IN_REVIEW', 'APPROVED'];

const zeilen = [];
const log = (s) => { console.log(s); zeilen.push(s); };

async function territorien() {
  return liste(await asc('GET', '/v1/territories?limit=200')).map((t) => t.id);
}

async function neuesterBuild(appId) {
  const r = await asc('GET', `/v1/builds?filter[app]=${appId}&sort=-uploadedDate&limit=10` +
    '&include=preReleaseVersion');
  const vers = Object.fromEntries((r.body.included || []).map((x) => [x.id, x.attributes.version]));
  const b = liste(r).find((x) => !x.attributes.expired);
  if (b) b.versionString = vers[b.relationships.preReleaseVersion.data.id];
  return b;
}

async function main() {
  const [befehl, bundle] = process.argv.slice(2);
  const los = befehl === 'los';
  if (!['pruefen', 'los', 'entwurf-weg'].includes(befehl) || !bundle) {
    console.error('Aufruf: asc_einreichen.js pruefen|los|entwurf-weg <bundle-id>'); process.exit(2);
  }
  const app = liste(await asc('GET', `/v1/apps?filter[bundleId]=${bundle}`))[0];
  if (!app) { log(`✘ ${bundle}: kein App-Eintrag`); return false; }
  if (befehl === 'entwurf-weg') {
    // Nur LEERE, nie abgeschickte Entwuerfe abbrechen (blockieren „App entfernen“).
    const subs = liste(await asc('GET', `/v1/reviewSubmissions?filter[app]=${app.id}&filter[state]=READY_FOR_REVIEW`));
    if (!subs.length) { log(`✔ ${bundle}: kein Entwurf`); return true; }
    let ok = true;
    for (const sub of subs) {
      const items = liste(await asc('GET', `/v1/reviewSubmissions/${sub.id}/items`));
      if (items.length) { log(`✘ ${bundle}: Entwurf mit ${items.length} Elementen – nicht angefasst`); ok = false; continue; }
      const r = await asc('PATCH', `/v1/reviewSubmissions/${sub.id}`, { data: {
        type: 'reviewSubmissions', id: sub.id, attributes: { canceled: true } } });
      if (r.code >= 400) { log(`✘ ${bundle}: ${fehlertext(r)}`); ok = false; } else log(`✔ ${bundle}: leerer Entwurf abgebrochen`);
    }
    return ok;
  }
  log(`# ${app.attributes.name} (${bundle}) – ${befehl}`);

  const versionen = liste(await asc('GET',
    `/v1/apps/${app.id}/appStoreVersions?filter[platform]=IOS&limit=5`));
  const unterwegs = versionen.find((v) => UNTERWEGS.includes(v.attributes.appStoreState));
  if (unterwegs) {
    log(`✔ Version ${unterwegs.attributes.versionString}: ${unterwegs.attributes.appStoreState} (schon eingereicht/live)`);
    return true;
  }
  const ver = versionen.find((v) => BEARBEITBAR.includes(v.attributes.appStoreState));
  if (!ver) { log('✘ keine bearbeitbare Version'); return false; }
  const maengel = [];

  // Build
  const b = await neuesterBuild(app.id);
  if (!b) maengel.push('kein Build');
  else if (b.attributes.processingState !== 'VALID') maengel.push(`Build ${b.attributes.version} ${b.attributes.processingState}`);
  else {
    if (b.versionString && b.versionString !== ver.attributes.versionString) {
      log(`  Version ${ver.attributes.versionString} → ${b.versionString}`);
      if (los) {
        const r = await asc('PATCH', `/v1/appStoreVersions/${ver.id}`, { data: {
          type: 'appStoreVersions', id: ver.id, attributes: { versionString: b.versionString } } });
        if (r.code >= 400) maengel.push('Version umbenennen: ' + fehlertext(r));
      }
    }
    const haengt = (await asc('GET', `/v1/appStoreVersions/${ver.id}/build`)).body.data;
    if (!haengt || haengt.id !== b.id) {
      log(`  Build ${b.attributes.version} anhängen`);
      if (los) {
        const r = await asc('PATCH', `/v1/appStoreVersions/${ver.id}/relationships/build`,
          { data: { type: 'builds', id: b.id } });
        if (r.code >= 400) maengel.push('Build anhängen: ' + fehlertext(r));
      }
    } else log(`  Build ${b.attributes.version} hängt schon`);
    if (b.attributes.usesNonExemptEncryption == null) log('  ⚠ Exportvorschrift am Build unbeantwortet');
  }

  // Laender
  const verf = await asc('GET', `/v1/apps/${app.id}/appAvailabilityV2`);
  if (!verf.body.data) {
    log('  Länder fehlen → alle');
    if (los) {
      const t = await territorien();
      const lid = (x) => '${t' + x + '}';
      const r = await asc('POST', '/v2/appAvailabilities', {
        data: { type: 'appAvailabilities', attributes: { availableInNewTerritories: true },
          relationships: { app: { data: { id: app.id, type: 'apps' } },
            territoryAvailabilities: { data: t.map((x) => ({ id: lid(x), type: 'territoryAvailabilities' })) } } },
        included: t.map((x) => ({ id: lid(x), type: 'territoryAvailabilities', attributes: { available: true },
          relationships: { territory: { data: { id: x, type: 'territories' } } } })) });
      if (r.code >= 400) maengel.push('Länder: ' + fehlertext(r));
    }
  }

  // App-Preis: nur wenn GAR KEIN Preis gesetzt ist → gratis (Geld kommt über Pro)
  const preis = await asc('GET', `/v1/apps/${app.id}/appPriceSchedule?include=manualPrices`);
  const preise = preis.body.data && (((preis.body.data.relationships || {}).manualPrices || {}).data || []).length;
  if (!preise) {
    log('  App-Preis fehlt → gratis (mit Kauf in der App)');
    if (los) {
      const pp = liste(await asc('GET', `/v1/apps/${app.id}/appPricePoints?filter[territory]=DEU&limit=5`));
      const frei = pp.find((x) => Number(x.attributes.customerPrice) === 0);
      const r = frei && await asc('POST', '/v1/appPriceSchedules', {
        data: { type: 'appPriceSchedules', relationships: {
          app: { data: { type: 'apps', id: app.id } },
          baseTerritory: { data: { type: 'territories', id: 'DEU' } },
          manualPrices: { data: [{ type: 'appPrices', id: '${preis}' }] } } },
        included: [{ type: 'appPrices', id: '${preis}', attributes: { startDate: null },
          relationships: { appPricePoint: { data: { type: 'appPricePoints', id: frei.id } } } }] });
      if (!r || r.code >= 400) maengel.push('App-Preis: ' + (r ? fehlertext(r) : 'kein Gratis-Preispunkt'));
    }
  }

  if (!app.attributes.contentRightsDeclaration) {
    log('  Inhaltsrechte → keine Inhalte Dritter');
    if (los) await asc('PATCH', `/v1/apps/${app.id}`, { data: { type: 'apps', id: app.id,
      attributes: { contentRightsDeclaration: 'DOES_NOT_USE_THIRD_PARTY_CONTENT' } } });
  }

  // Kaeufe
  const posten = []; // { art, id, name }
  for (const k of liste(await asc('GET', `/v1/apps/${app.id}/inAppPurchasesV2?limit=50`))) {
    const s = k.attributes.state;
    log(`  Kauf ${k.attributes.productId}: ${s}`);
    if (s === 'READY_TO_SUBMIT') posten.push({ art: 'iap', id: k.id, name: k.attributes.productId });
    else if (!KAUF_OK.includes(s)) maengel.push(`${k.attributes.productId} ${s}`);
  }
  for (const g of liste(await asc('GET', `/v1/apps/${app.id}/subscriptionGroups?limit=20`))) {
    for (const s of liste(await asc('GET', `/v1/subscriptionGroups/${g.id}/subscriptions?limit=50`))) {
      const st = s.attributes.state;
      log(`  Abo ${s.attributes.productId}: ${st}`);
      if (st === 'READY_TO_SUBMIT') posten.push({ art: 'abo', id: s.id, gruppe: g.id, name: s.attributes.productId });
      else if (!KAUF_OK.includes(st)) maengel.push(`${s.attributes.productId} ${st}`);
    }
  }

  if (maengel.length) { log('✘ NICHT BEREIT: ' + maengel.join(' · ')); return false; }
  if (!los) { log('✔ bereit zum Einreichen'); return true; }

  // Einreichung (eine offene wiederverwenden)
  const offen = liste(await asc('GET', `/v1/reviewSubmissions?filter[app]=${app.id}&filter[state]=READY_FOR_REVIEW,UNRESOLVED_ISSUES`))[0];
  const sub = offen || liste(await asc('POST', '/v1/reviewSubmissions', { data: {
    type: 'reviewSubmissions', attributes: { platform: 'IOS' },
    relationships: { app: { data: { type: 'apps', id: app.id } } } } }));
  if (!sub || !sub.id) { log('✘ Einreichung anlegen fehlgeschlagen'); return false; }
  const item = (rel) => asc('POST', '/v1/reviewSubmissionItems', { data: { type: 'reviewSubmissionItems',
    relationships: { reviewSubmission: { data: { type: 'reviewSubmissions', id: sub.id } }, ...rel } } });
  const schon = (r) => r.code < 400 || /already|bereits/i.test(fehlertext(r));

  const vr = await item({ appStoreVersion: { data: { type: 'appStoreVersions', id: ver.id } } });
  if (!schon(vr)) {
    const meta = ((vr.body.errors || [])[0] || {}).meta;
    const mehr = meta && meta.associatedErrors ? Object.values(meta.associatedErrors).flat()
      .map((e) => (e.code ? e.code + ': ' : '') + (e.detail || e.title)).join('\n    ') : '';
    log('✘ Version-Posten: ' + fehlertext(vr) + (mehr ? '\n    ' + mehr : ''));
    return false;
  }

  const kaufFehler = [];
  for (const p of posten) {
    if (p.art === 'iap') {
      const v = liste(await asc('GET', `/v2/inAppPurchases/${p.id}/versions?limit=5`))[0];
      const r = v ? await item({ inAppPurchaseVersion: { data: { type: 'inAppPurchaseVersions', id: v.id } } })
        : await asc('POST', '/v1/inAppPurchaseSubmissions', { data: { type: 'inAppPurchaseSubmissions',
          relationships: { inAppPurchaseV2: { data: { type: 'inAppPurchases', id: p.id } } } } });
      if (schon(r)) log(`  + ${p.name}`); else kaufFehler.push(`${p.name}: ${fehlertext(r)}`);
    } else {
      // Erstes Abo: die Gruppen-Version muss mit in dieselbe Einreichung.
      if (!p.gruppeDrin) {
        const gv = liste(await asc('GET', `/v1/subscriptionGroups/${p.gruppe}/versions?limit=5`))[0];
        if (gv) {
          const r = await item({ subscriptionGroupVersion: { data: { type: 'subscriptionGroupVersions', id: gv.id } } });
          if (schon(r)) log('  + Abo-Gruppe'); else kaufFehler.push('Abo-Gruppe: ' + fehlertext(r));
        } else log('  (keine Abo-Gruppen-Version gefunden)');
        posten.filter((x) => x.gruppe === p.gruppe).forEach((x) => { x.gruppeDrin = true; });
      }
      const v = liste(await asc('GET', `/v1/subscriptions/${p.id}/versions?limit=5`))[0];
      let r = v ? await item({ subscriptionVersion: { data: { type: 'subscriptionVersions', id: v.id } } }) : null;
      if (!r || !schon(r)) {
        r = await asc('POST', '/v1/subscriptionSubmissions', { data: { type: 'subscriptionSubmissions',
          relationships: { subscription: { data: { type: 'subscriptions', id: p.id } } } } });
      }
      if (schon(r)) log(`  + ${p.name}`); else kaufFehler.push(`${p.name}: ${fehlertext(r)}`);
    }
  }
  if (kaufFehler.length) {
    log('✘ Kauf nicht anhängbar – NICHT abgeschickt (Entwurf liegt in App Store Connect): ' + kaufFehler.join(' · '));
    return false;
  }
  const go = await asc('PATCH', `/v1/reviewSubmissions/${sub.id}`, { data: {
    type: 'reviewSubmissions', id: sub.id, attributes: { submitted: true } } });
  if (go.code >= 400) { log('✘ Absenden: ' + fehlertext(go)); return false; }
  await schlaf(3000);
  const neu = ((await asc('GET', `/v1/appStoreVersions/${ver.id}`)).body.data || ver).attributes.appStoreState;
  log(`✔ EINGEREICHT → ${neu}`);
  return true;
}

main().then((ok) => {
  require('fs').appendFileSync(process.env.BERICHT || '/dev/null', zeilen.join('\n') + '\n\n');
  process.exit(ok ? 0 : 1);
}).catch((e) => {
  const t = '✘ Absturz: ' + (e.message || e);
  console.log(t);
  require('fs').appendFileSync(process.env.BERICHT || '/dev/null', zeilen.concat(t).join('\n') + '\n\n');
  process.exit(1);
});
