// Füllt den Store-Eintrag einer Fabrik-App in App Store Connect aus – alles,
// was Apples API erlaubt. Daten aus fabrik/<app>/store/asc.json.
// Idempotent: Vorhandenes wird übersprungen oder nur überschrieben.
//
//   node fabrik/tool/asc_einrichten.js fabrik/flugfenster
//
// Erledigt: Rechte-Erklärung, Preis (gratis) und Länder, Kategorien,
// Altersfreigabe, Name/Untertitel/Datenschutz-URL (de-DE + en-US),
// Beschreibung/Keywords/Werbetext/Support-URL, Copyright, Prüfer-Kontakt
// (von der Referenz-App), Bildschirmfotos, Pro-Einmalkauf und Pro-Jahresabo
// mit Preis, Ländern, Texten und Prüfbild.
// Bleibt bei Lukas: App-Eintrag anlegen, Datenschutz-Fragebogen
// („App-Datenschutz“), Build wählen und einreichen.
//
// Muster aus sprachentraining/tool (asc_iap.js, asc_metadata.js, asc_release.js).

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { asc, hochladen, fehlertext, schlaf } = require('./asc_lib');

const REFERENZ = process.env.REFERENZ_BUNDLE || 'com.sprachentrainer.farsi';
const IPHONE_TYP = 'APP_IPHONE_67'; // 1290 × 2796 (6,7″/6,9″)
const BEARBEITBAR = ['PREPARE_FOR_SUBMISSION', 'DEVELOPER_REJECTED', 'REJECTED',
  'METADATA_REJECTED', 'INVALID_BINARY'];

// Wie in sprachentraining: Apple nimmt „alles leer“ nicht als beantwortet.
const ALTER = {
  advertising: false, alcoholTobaccoOrDrugUseOrReferences: 'NONE', contests: 'NONE',
  gambling: false, gamblingSimulated: 'NONE', gunsOrOtherWeapons: 'NONE',
  healthOrWellnessTopics: false, lootBox: false, medicalOrTreatmentInformation: 'NONE',
  messagingAndChat: false, parentalControls: false, profanityOrCrudeHumor: 'NONE',
  sexualContentGraphicAndNudity: 'NONE', sexualContentOrNudity: 'NONE', socialMedia: false,
  horrorOrFearThemes: 'NONE', matureOrSuggestiveThemes: 'NONE', unrestrictedWebAccess: false,
  userGeneratedContent: false, violenceCartoonOrFantasy: 'NONE',
  violenceRealisticProlongedGraphicOrSadistic: 'NONE', violenceRealistic: 'NONE',
};

/// Apple ergänzt die Altersfreigabe laufend um neue Pflichtfragen (z. B.
/// ageAssurance). Fehlt eine, steht ihr Name in der Fehlermeldung: dann mit
/// „nein“ (false bzw. 'NONE') beantworten und erneut senden.
async function altersfreigabe(id) {
  const attr = { ...ALTER };
  let r;
  for (let i = 0; i < 8; i++) {
    r = await asc('PATCH', `/v1/ageRatingDeclarations/${id}`,
      { data: { type: 'ageRatingDeclarations', id, attributes: attr } });
    if (r.code < 400) return r;
    const t = fehlertext(r);
    const fehlend = t.match(/value for the attribute '([A-Za-z]+)'/);
    const falsch = t.match(/'([^']+)' is not a valid value for the attribute '([A-Za-z]+)'/)
      || t.match(/attribute '([A-Za-z]+)'.*(?:invalid|not valid|expected)/i);
    if (fehlend && !(fehlend[1] in attr)) { attr[fehlend[1]] = false; continue; }
    if (falsch) {
      const name = falsch[2] || falsch[1];
      if (attr[name] === false) { attr[name] = 'NONE'; continue; }
      if (attr[name] === 'NONE') { attr[name] = false; continue; }
    }
    return r;
  }
  return r;
}

const ok = [];
const fehlt = [];
const gut = (s) => { ok.push(s); console.log('✔ ' + s); };
const schlecht = (s) => { fehlt.push(s); console.log('✘ ' + s); };
const daten = (r) => (r.body && r.body.data) || null;
const liste = (r) => (r.body && r.body.data) || [];

async function pruefe(r, was) {
  if (r.code >= 400 || r.code === 0) { schlecht(`${was}: ${fehlertext(r)}`); return false; }
  return true;
}

let territorien;
async function alleTerritorien() {
  if (!territorien) territorien = liste(await asc('GET', '/v1/territories?limit=200')).map((t) => t.id);
  return territorien;
}

async function alleSeiten(pfad) {
  const out = [];
  let p = pfad;
  while (p) {
    const r = await asc('GET', p);
    out.push(...liste(r));
    const next = r.body && r.body.links && r.body.links.next;
    p = next ? next.replace('https://api.appstoreconnect.apple.com', '') : null;
  }
  return out;
}

async function bildHoch(pfadPost, typ, rel, datei) {
  const puffer = fs.readFileSync(datei);
  const r = await asc('POST', pfadPost, { data: {
    type: typ, attributes: { fileName: path.basename(datei), fileSize: puffer.length },
    relationships: rel } });
  const id = daten(r) && r.body.data.id;
  if (!id || !(await hochladen(r.body.data.attributes.uploadOperations, puffer))) {
    schlecht(`Bild ${path.basename(datei)}: ${fehlertext(r)}`);
    return false;
  }
  const p = await asc('PATCH', `${pfadPost}/${id}`, { data: { type: typ, id, attributes: {
    uploaded: true, sourceFileChecksum: crypto.createHash('md5').update(puffer).digest('hex') } } });
  return pruefe(p, `Bild ${path.basename(datei)} bestätigen`);
}

// ---------------------------------------------------------------- App

async function appGrundlagen(app) {
  if (!app.attributes.contentRightsDeclaration) {
    const r = await asc('PATCH', `/v1/apps/${app.id}`, { data: { type: 'apps', id: app.id,
      attributes: { contentRightsDeclaration: 'DOES_NOT_USE_THIRD_PARTY_CONTENT' } } });
    if (await pruefe(r, 'Rechte-Erklärung')) gut('Rechte-Erklärung');
  }

  const preis = await asc('GET', `/v1/apps/${app.id}/appPriceSchedule?include=manualPrices`);
  const hatPreis = daten(preis) &&
    (((preis.body.data.relationships || {}).manualPrices || {}).data || []).length;
  if (!hatPreis) {
    const pp = liste(await asc('GET', `/v1/apps/${app.id}/appPricePoints?filter[territory]=DEU&limit=5`));
    const frei = pp.find((x) => Number(x.attributes.customerPrice) === 0);
    if (!frei) schlecht('Preis: kein Gratis-Preispunkt gefunden');
    else {
      const r = await asc('POST', '/v1/appPriceSchedules', {
        data: { type: 'appPriceSchedules', relationships: {
          app: { data: { type: 'apps', id: app.id } },
          baseTerritory: { data: { type: 'territories', id: 'DEU' } },
          manualPrices: { data: [{ type: 'appPrices', id: '${preis}' }] } } },
        included: [{ type: 'appPrices', id: '${preis}', attributes: { startDate: null },
          relationships: { appPricePoint: { data: { type: 'appPricePoints', id: frei.id } } } }],
      });
      if (await pruefe(r, 'Preis')) gut('Preis: kostenlos');
    }
  }

  const v = await asc('GET', `/v1/apps/${app.id}/appAvailabilityV2`);
  if (!daten(v)) {
    const t = await alleTerritorien();
    const lokal = (x) => '${t' + x + '}';
    const r = await asc('POST', '/v2/appAvailabilities', {
      data: { type: 'appAvailabilities', attributes: { availableInNewTerritories: true },
        relationships: {
          app: { data: { id: app.id, type: 'apps' } },
          territoryAvailabilities: { data: t.map((x) => ({ id: lokal(x), type: 'territoryAvailabilities' })) },
        } },
      included: t.map((x) => ({ id: lokal(x), type: 'territoryAvailabilities', attributes: { available: true },
        relationships: { territory: { data: { id: x, type: 'territories' } } } })),
    });
    if (await pruefe(r, 'Länder')) gut(`Länder: alle ${t.length}`);
  }
}

async function appInfos(app, cfg) {
  const infos = liste(await asc('GET', `/v1/apps/${app.id}/appInfos`));
  const info = infos.find((i) => i.attributes.state !== 'READY_FOR_DISTRIBUTION') || infos[0];
  if (!info) { schlecht('Keine App-Info gefunden'); return; }

  const rel = { primaryCategory: { data: { id: cfg.primaryCategory, type: 'appCategories' } } };
  if (cfg.secondaryCategory) rel.secondaryCategory = { data: { id: cfg.secondaryCategory, type: 'appCategories' } };
  let r = await asc('PATCH', `/v1/appInfos/${info.id}`, { data: { id: info.id, type: 'appInfos', relationships: rel } });
  if (await pruefe(r, 'Kategorien')) gut(`Kategorien: ${cfg.primaryCategory}/${cfg.secondaryCategory || '–'}`);

  const ar = daten(await asc('GET', `/v1/appInfos/${info.id}/ageRatingDeclaration`));
  if (ar) {
    r = await altersfreigabe(ar.id);
    if (await pruefe(r, 'Altersfreigabe')) gut('Altersfreigabe 4+');
  }

  const locs = liste(await asc('GET', `/v1/appInfos/${info.id}/appInfoLocalizations`));
  for (const [locale, t] of Object.entries(cfg.locales)) {
    const attrs = { name: t.name, subtitle: t.subtitle, privacyPolicyUrl: cfg.privacyUrl };
    const da = locs.find((l) => l.attributes.locale === locale);
    r = da
      ? await asc('PATCH', `/v1/appInfoLocalizations/${da.id}`,
        { data: { id: da.id, type: 'appInfoLocalizations', attributes: attrs } })
      : await asc('POST', '/v1/appInfoLocalizations', { data: { type: 'appInfoLocalizations',
        attributes: { locale, ...attrs },
        relationships: { appInfo: { data: { type: 'appInfos', id: info.id } } } } });
    if (await pruefe(r, `Name/Untertitel ${locale}`)) gut(`Name, Untertitel, Datenschutz-URL ${locale}`);
  }
}

// ---------------------------------------------------------------- Version

async function referenz() {
  const app = liste(await asc('GET', '/v1/apps?filter[bundleId]=' + REFERENZ))[0];
  if (!app) return {};
  const ver = liste(await asc('GET', `/v1/apps/${app.id}/appStoreVersions?limit=1`))[0];
  if (!ver) return {};
  const rd = daten(await asc('GET', `/v1/appStoreVersions/${ver.id}/appStoreReviewDetail`));
  return {
    copyright: ver.attributes.copyright,
    kontakt: rd && {
      contactFirstName: rd.attributes.contactFirstName, contactLastName: rd.attributes.contactLastName,
      contactPhone: rd.attributes.contactPhone, contactEmail: rd.attributes.contactEmail,
    },
  };
}

async function version(app, cfg, dir) {
  const vers = liste(await asc('GET', `/v1/apps/${app.id}/appStoreVersions?filter[platform]=IOS&limit=5`));
  const ver = vers.find((v) => BEARBEITBAR.includes(v.attributes.appStoreState));
  if (!ver) { schlecht('Keine bearbeitbare Version (schon eingereicht?)'); return; }
  const ref = await referenz();

  if (!ver.attributes.copyright) {
    const c = (ref.copyright || '').replace(/\d{4}/, String(new Date().getFullYear())) ||
      `${new Date().getFullYear()} Lukas Beutler`;
    const r = await asc('PATCH', `/v1/appStoreVersions/${ver.id}`,
      { data: { type: 'appStoreVersions', id: ver.id, attributes: { copyright: c } } });
    if (await pruefe(r, 'Copyright')) gut(`Copyright: ${c}`);
  }

  const rd = daten(await asc('GET', `/v1/appStoreVersions/${ver.id}/appStoreReviewDetail`));
  const kontakt = { ...(ref.kontakt || {}), notes: cfg.reviewNotes || '', demoAccountRequired: false };
  if (!ref.kontakt && !rd) schlecht(`Prüfer-Kontakt: Referenz-App ${REFERENZ} ohne Kontakt`);
  else {
    const r = rd
      ? await asc('PATCH', `/v1/appStoreReviewDetails/${rd.id}`,
        { data: { type: 'appStoreReviewDetails', id: rd.id, attributes: { notes: kontakt.notes } } })
      : await asc('POST', '/v1/appStoreReviewDetails', { data: { type: 'appStoreReviewDetails',
        attributes: kontakt,
        relationships: { appStoreVersion: { data: { type: 'appStoreVersions', id: ver.id } } } } });
    if (await pruefe(r, 'Prüfer-Kontakt')) gut('Prüfer-Kontakt und Hinweise');
  }

  let locs = liste(await asc('GET', `/v1/appStoreVersions/${ver.id}/appStoreVersionLocalizations`));
  for (const [locale, t] of Object.entries(cfg.locales)) {
    const attrs = { description: t.description, keywords: t.keywords,
      promotionalText: t.promotionalText, supportUrl: cfg.supportUrl };
    let loc = locs.find((l) => l.attributes.locale === locale);
    const r = loc
      ? await asc('PATCH', `/v1/appStoreVersionLocalizations/${loc.id}`,
        { data: { id: loc.id, type: 'appStoreVersionLocalizations', attributes: attrs } })
      : await asc('POST', '/v1/appStoreVersionLocalizations', { data: {
        type: 'appStoreVersionLocalizations', attributes: { locale, ...attrs },
        relationships: { appStoreVersion: { data: { type: 'appStoreVersions', id: ver.id } } } } });
    if (!(await pruefe(r, `Texte ${locale}`))) continue;
    gut(`Beschreibung, Keywords, Werbetext ${locale}`);
    loc = loc || daten(r);

    // Bildschirmfotos: hochladen, wenn der Satz leer ist oder andere Dateien enthält
    // (z. B. nach neuen Bildschirmfotos); sonst nichts tun.
    const prefix = cfg.screenshots && cfg.screenshots[locale];
    if (!prefix) continue;
    const dateien = fs.readdirSync(path.join(dir, path.dirname(prefix)))
      .filter((f) => f.startsWith(path.basename(prefix)) && f.endsWith('.png')).sort()
      .map((f) => path.join(dir, path.dirname(prefix), f));
    const saetze = liste(await asc('GET', `/v1/appStoreVersionLocalizations/${loc.id}/appScreenshotSets`));
    let satz = saetze.find((s) => s.attributes.screenshotDisplayType === IPHONE_TYP);
    if (satz) {
      const vorh = liste(await asc('GET', `/v1/appScreenshotSets/${satz.id}/appScreenshots?limit=20`));
      const soll = dateien.map((d) => path.basename(d)).join('|');
      const ist = vorh.map((v) => v.attributes.fileName).join('|');
      const fertig = vorh.every((v) => ((v.attributes.assetDeliveryState || {}).state || 'COMPLETE') === 'COMPLETE');
      if (vorh.length && ist === soll && fertig) {
        gut(`Bildschirmfotos ${locale} schon da`);
        continue;
      }
      for (const v of vorh) await asc('DELETE', `/v1/appScreenshots/${v.id}`);
      if (vorh.length) gut(`${vorh.length} alte Bildschirmfotos ${locale} ersetzt`);
    }
    if (!satz) {
      const s = await asc('POST', '/v1/appScreenshotSets', { data: {
        type: 'appScreenshotSets', attributes: { screenshotDisplayType: IPHONE_TYP },
        relationships: { appStoreVersionLocalization: { data: { type: 'appStoreVersionLocalizations', id: loc.id } } } } });
      if (!(await pruefe(s, `Bildschirmfoto-Satz ${locale}`))) continue;
      satz = daten(s);
    }
    let n = 0;
    for (const d of dateien) {
      if (await bildHoch('/v1/appScreenshots', 'appScreenshots',
        { appScreenshotSet: { data: { type: 'appScreenshotSets', id: satz.id } } }, d)) n++;
    }
    if (n) gut(`${n} Bildschirmfotos ${locale}`);
  }
}

// ---------------------------------------------------------------- Käufe

async function einmalkauf(app, k, dir, cfg) {
  let iap = liste(await asc('GET', `/v1/apps/${app.id}/inAppPurchasesV2?filter[productId]=${k.productId}`))[0];
  if (!iap) {
    const r = await asc('POST', '/v2/inAppPurchases', { data: { type: 'inAppPurchases',
      attributes: { name: k.referenceName, productId: k.productId,
        inAppPurchaseType: 'NON_CONSUMABLE', familySharable: false },
      relationships: { app: { data: { id: app.id, type: 'apps' } } } } });
    if (!(await pruefe(r, `Einmalkauf ${k.productId}`))) return;
    iap = daten(r);
    gut(`Einmalkauf angelegt: ${k.productId}`);
  }
  const locs = liste(await asc('GET', `/v2/inAppPurchases/${iap.id}/inAppPurchaseLocalizations`));
  for (const [locale, t] of Object.entries(k.loc)) {
    if (locs.some((l) => l.attributes.locale === locale)) continue;
    const r = await asc('POST', '/v1/inAppPurchaseLocalizations', { data: { type: 'inAppPurchaseLocalizations',
      attributes: { locale, name: t.name, description: t.description },
      relationships: { inAppPurchaseV2: { data: { id: iap.id, type: 'inAppPurchases' } } } } });
    if (await pruefe(r, `Einmalkauf-Text ${locale}`)) gut(`Einmalkauf-Text ${locale}`);
  }
  const sched = await asc('GET', `/v2/inAppPurchases/${iap.id}/iapPriceSchedule`);
  if (!daten(sched)) {
    const punkte = await alleSeiten(`/v2/inAppPurchases/${iap.id}/pricePoints?filter[territory]=DEU&limit=200`);
    const pp = punkte.find((p) => p.attributes.customerPrice === k.price);
    if (!pp) schlecht(`Einmalkauf: kein Preispunkt ${k.price} €`);
    else {
      const r = await asc('POST', '/v1/inAppPurchasePriceSchedules', { data: {
        type: 'inAppPurchasePriceSchedules', relationships: {
          inAppPurchase: { data: { id: iap.id, type: 'inAppPurchases' } },
          baseTerritory: { data: { id: 'DEU', type: 'territories' } },
          manualPrices: { data: [{ id: '${preis}', type: 'inAppPurchasePrices' }] } } },
        included: [{ id: '${preis}', type: 'inAppPurchasePrices', attributes: { startDate: null, endDate: null },
          relationships: { inAppPurchasePricePoint: { data: { id: pp.id, type: 'inAppPurchasePricePoints' } } } }] });
      if (await pruefe(r, 'Einmalkauf-Preis')) gut(`Einmalkauf-Preis ${k.price} €`);
    }
  }
  const av = await asc('GET', `/v2/inAppPurchases/${iap.id}/inAppPurchaseAvailability`);
  if (!daten(av)) {
    const t = await alleTerritorien();
    const r = await asc('POST', '/v1/inAppPurchaseAvailabilities', { data: {
      type: 'inAppPurchaseAvailabilities', attributes: { availableInNewTerritories: true },
      relationships: { inAppPurchase: { data: { type: 'inAppPurchases', id: iap.id } },
        availableTerritories: { data: t.map((x) => ({ type: 'territories', id: x })) } } } });
    if (await pruefe(r, 'Einmalkauf-Länder')) gut('Einmalkauf-Länder');
  }
  const bild = daten(await asc('GET', `/v2/inAppPurchases/${iap.id}/appStoreReviewScreenshot`));
  if (!bild && cfg.reviewScreenshot) {
    if (await bildHoch('/v1/inAppPurchaseAppStoreReviewScreenshots', 'inAppPurchaseAppStoreReviewScreenshots',
      { inAppPurchaseV2: { data: { type: 'inAppPurchases', id: iap.id } } },
      path.join(dir, cfg.reviewScreenshot))) gut('Einmalkauf-Prüfbild');
  }
}

async function jahresabo(app, k, dir, cfg) {
  const gruppen = liste(await asc('GET', `/v1/apps/${app.id}/subscriptionGroups?limit=50`));
  let gruppe = gruppen.find((g) => g.attributes.referenceName === k.group.referenceName);
  if (!gruppe) {
    const r = await asc('POST', '/v1/subscriptionGroups', { data: { type: 'subscriptionGroups',
      attributes: { referenceName: k.group.referenceName },
      relationships: { app: { data: { type: 'apps', id: app.id } } } } });
    if (!(await pruefe(r, 'Abo-Gruppe'))) return;
    gruppe = daten(r);
    gut(`Abo-Gruppe „${k.group.referenceName}“`);
  }
  const glocs = liste(await asc('GET', `/v1/subscriptionGroups/${gruppe.id}/subscriptionGroupLocalizations`));
  for (const [locale, name] of Object.entries(k.group.loc)) {
    if (glocs.some((l) => l.attributes.locale === locale)) continue;
    const r = await asc('POST', '/v1/subscriptionGroupLocalizations', { data: {
      type: 'subscriptionGroupLocalizations', attributes: { locale, name },
      relationships: { subscriptionGroup: { data: { type: 'subscriptionGroups', id: gruppe.id } } } } });
    if (await pruefe(r, `Abo-Gruppe ${locale}`)) gut(`Abo-Gruppe ${locale}`);
  }

  const abos = liste(await asc('GET', `/v1/subscriptionGroups/${gruppe.id}/subscriptions?limit=50`));
  let abo = abos.find((s) => s.attributes.productId === k.productId);
  if (!abo) {
    const r = await asc('POST', '/v1/subscriptions', { data: { type: 'subscriptions',
      attributes: { name: k.referenceName, productId: k.productId, subscriptionPeriod: k.period,
        familySharable: false, groupLevel: 1 },
      relationships: { group: { data: { type: 'subscriptionGroups', id: gruppe.id } } } } });
    if (!(await pruefe(r, `Abo ${k.productId}`))) return;
    abo = daten(r);
    gut(`Abo angelegt: ${k.productId}`);
  }
  const slocs = liste(await asc('GET', `/v1/subscriptions/${abo.id}/subscriptionLocalizations`));
  for (const [locale, t] of Object.entries(k.loc)) {
    if (slocs.some((l) => l.attributes.locale === locale)) continue;
    const r = await asc('POST', '/v1/subscriptionLocalizations', { data: { type: 'subscriptionLocalizations',
      attributes: { locale, name: t.name, description: t.description },
      relationships: { subscription: { data: { type: 'subscriptions', id: abo.id } } } } });
    if (await pruefe(r, `Abo-Text ${locale}`)) gut(`Abo-Text ${locale}`);
  }

  const av = await asc('GET', `/v1/subscriptions/${abo.id}/subscriptionAvailability`);
  if (!daten(av)) {
    const t = await alleTerritorien();
    const r = await asc('POST', '/v1/subscriptionAvailabilities', { data: {
      type: 'subscriptionAvailabilities', attributes: { availableInNewTerritories: true },
      relationships: { subscription: { data: { type: 'subscriptions', id: abo.id } },
        availableTerritories: { data: t.map((x) => ({ type: 'territories', id: x })) } } } });
    if (await pruefe(r, 'Abo-Länder')) gut('Abo-Länder');
  }

  // Preis: Deutschland setzen, alle anderen Länder mit Apples Umrechnung.
  // Preise: Deutschland + Umrechnung fuer alle Laender. Fehlen einzelne Laender (abgebrochener
  // Lauf – Schreibspur hatte nur 37), werden genau diese nachgetragen; vorhandene bleiben.
  const terr = (x) => ((x.relationships || {}).territory || {}).data && x.relationships.territory.data.id;
  const vorhanden = await alleSeiten(`/v1/subscriptions/${abo.id}/prices?include=territory&limit=200`);
  const hat = new Set(vorhanden.map(terr).filter(Boolean));
  if (!hat.size || hat.size < 150) {
    const punkte = await alleSeiten(`/v1/subscriptions/${abo.id}/pricePoints?filter[territory]=DEU&limit=200`);
    const pp = punkte.find((p) => p.attributes.customerPrice === k.price);
    if (!pp) { schlecht(`Abo: kein Preispunkt ${k.price} €`); }
    else {
      const gleich = await alleSeiten(`/v1/subscriptionPricePoints/${pp.id}/equalizations?include=territory&limit=200`);
      let n = 0;
      for (const punkt of [pp, ...gleich]) {
        const t = terr(punkt) || (punkt === pp ? 'DEU' : null);
        if (t && hat.has(t)) continue;
        const r = await asc('POST', '/v1/subscriptionPrices', { data: { type: 'subscriptionPrices',
          attributes: { startDate: null, preserveCurrentPrice: false },
          relationships: {
            subscription: { data: { type: 'subscriptions', id: abo.id } },
            subscriptionPricePoint: { data: { type: 'subscriptionPricePoints', id: punkt.id } } } } });
        if (r.code < 400) n++;
        else if (punkt === pp && !hat.size) { await pruefe(r, 'Abo-Preis DE'); break; }
      }
      if (n) gut(`Abo-Preis ${k.price} € (+ Umrechnung, ${n} Länder neu, vorher ${hat.size})`);
    }
  }

  const bild = daten(await asc('GET', `/v1/subscriptions/${abo.id}/appStoreReviewScreenshot`));
  if (!bild && cfg.reviewScreenshot) {
    if (await bildHoch('/v1/subscriptionAppStoreReviewScreenshots', 'subscriptionAppStoreReviewScreenshots',
      { subscription: { data: { type: 'subscriptions', id: abo.id } } },
      path.join(dir, cfg.reviewScreenshot))) gut('Abo-Prüfbild');
  }
}

// ---------------------------------------------------------------- Ablauf

(async () => {
  const dir = process.argv[2];
  const cfg = JSON.parse(fs.readFileSync(path.join(dir, 'store/asc.json'), 'utf8'));
  const pbx = fs.readFileSync(path.join(dir, 'ios/Runner.xcodeproj/project.pbxproj'), 'utf8');
  const bundle = [...pbx.matchAll(/PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);/g)]
    .map((m) => m[1].trim()).find((b) => !b.endsWith('.RunnerTests'));
  const app = liste(await asc('GET', `/v1/apps?filter[bundleId]=${encodeURIComponent(bundle)}`))[0];
  if (!app) { console.log(`✘ Kein App-Eintrag für ${bundle}`); process.exit(1); }

  const schritte = [
    ['App', () => appGrundlagen(app)],
    ['App-Infos', () => appInfos(app, cfg)],
    ['Version', () => version(app, cfg, dir)],
    ['Einmalkauf', () => cfg.lifetime && einmalkauf(app, cfg.lifetime, dir, cfg)],
    ['Jahresabo', () => cfg.yearly && jahresabo(app, cfg.yearly, dir, cfg)],
  ];
  for (const [name, f] of schritte) {
    try { await f(); } catch (e) { schlecht(`${name}: ${e.message}`); }
    await schlaf(200);
  }
  console.log(`\nERGEBNIS: ${ok.length} erledigt, ${fehlt.length} offen`);
  for (const f of fehlt) console.log('  offen: ' + f);
  process.exit(fehlt.length ? 1 : 0);
})();
