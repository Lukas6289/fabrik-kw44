// Gibt Tester-Konten Zugriff auf eine Fabrik-App in TestFlight – idempotent.
//
//   TESTER="a@b.de c@d.de" node fabrik/tool/asc_testflight.js fabrik/<app>
//
// Ist die Adresse ein App-Store-Connect-Nutzer des Teams, kommt sie in die
// interne Gruppe „Team“ (sieht jeden Build sofort, ohne Apple-Prüfung).
// Sonst kommt sie in die externe Gruppe „Familie“: neuester Build wird der
// Gruppe zugeordnet und – falls nötig – zur TestFlight-Prüfung eingereicht
// (dauert bei Apple meist einige Stunden, nur beim ersten Build einer Version).
// Wartet bis zu WARTEN Minuten (Std. 40), bis Apple den neuesten Build
// verarbeitet hat.

const fs = require('fs');
const path = require('path');
const { asc, fehlertext, schlaf } = require('./asc_lib');

const REFERENZ = process.env.REFERENZ_BUNDLE || 'com.sprachentrainer.farsi';
const WARTEN = Number(process.env.WARTEN || 40);
const liste = (r) => (r.body && r.body.data) || [];
const daten = (r) => (r.body && r.body.data) || null;
let fehler = 0;
const gut = (s) => console.log('✔ ' + s);
const schlecht = (s) => { fehler++; console.log('✘ ' + s); };

function bundleId(dir) {
  const pbx = fs.readFileSync(path.join(dir, 'ios/Runner.xcodeproj/project.pbxproj'), 'utf8');
  return [...pbx.matchAll(/PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);/g)]
    .map((m) => m[1].trim()).find((id) => !id.endsWith('.RunnerTests'));
}

async function gruppe(app, name, intern) {
  const da = liste(await asc('GET', `/v1/apps/${app.id}/betaGroups?limit=50`))
    .find((g) => g.attributes.name === name);
  if (da) return da;
  const r = await asc('POST', '/v1/betaGroups', { data: { type: 'betaGroups',
    attributes: intern ? { name, isInternalGroup: true, hasAccessToAllBuilds: true } : { name },
    relationships: { app: { data: { type: 'apps', id: app.id } } } } });
  if (r.code >= 300) { schlecht(`Gruppe ${name}: ${fehlertext(r)}`); return null; }
  gut(`Gruppe „${name}“ angelegt`);
  return daten(r);
}

async function tester(email, g) {
  const r = await asc('POST', '/v1/betaTesters', { data: { type: 'betaTesters',
    attributes: { email },
    relationships: { betaGroups: { data: [{ type: 'betaGroups', id: g.id }] } } } });
  if (r.code < 300) { gut(`${email} → „${g.attributes.name}“`); return true; }
  // schon vorhanden: in die Gruppe nachtragen
  const vorh = liste(await asc('GET', `/v1/betaTesters?filter[email]=${encodeURIComponent(email)}&limit=5`))[0];
  if (vorh) {
    const r2 = await asc('POST', `/v1/betaGroups/${g.id}/relationships/betaTesters`,
      { data: [{ type: 'betaTesters', id: vorh.id }] });
    if (r2.code < 300) { gut(`${email} → „${g.attributes.name}“ (war schon Tester)`); return true; }
    schlecht(`${email}: ${fehlertext(r2)}`); return false;
  }
  schlecht(`${email}: ${fehlertext(r)}`); return false;
}

async function neuesterBuild(app) {
  const ende = Date.now() + WARTEN * 60000;
  for (;;) {
    const b = liste(await asc('GET', `/v1/builds?filter[app]=${app.id}&sort=-uploadedDate&limit=1`))[0];
    if (b && b.attributes.processingState === 'VALID') return b;
    if (b && ['FAILED', 'INVALID'].includes(b.attributes.processingState)) {
      schlecht(`Build ${b.attributes.version}: Apple meldet ${b.attributes.processingState}`); return null;
    }
    if (Date.now() > ende) { schlecht(`Build noch nicht verarbeitet (${b ? b.attributes.processingState : 'keiner'})`); return null; }
    await schlaf(60000);
  }
}

/// Testinformationen, ohne die Apple keine externe TestFlight-Prüfung annimmt.
async function testInfos(app, dir) {
  let cfg = {};
  try { cfg = JSON.parse(fs.readFileSync(path.join(dir, 'store/asc.json'), 'utf8')); } catch (_) {}
  const ref = liste(await asc('GET', '/v1/apps?filter[bundleId]=' + REFERENZ))[0];
  let kontakt = null;
  if (ref) {
    const ver = liste(await asc('GET', `/v1/apps/${ref.id}/appStoreVersions?limit=1`))[0];
    const rd = ver && daten(await asc('GET', `/v1/appStoreVersions/${ver.id}/appStoreReviewDetail`));
    if (rd) kontakt = rd.attributes;
  }
  const mail = (kontakt && kontakt.contactEmail) || 'lukasbeutler@gmx.de';
  for (const locale of ['de-DE', 'en-US']) {
    const l = (cfg.locales || {})[locale] || {};
    const text = (l.description || l.subtitle || l.name || 'Testversion').slice(0, 3900);
    const vorh = liste(await asc('GET', `/v1/apps/${app.id}/betaAppLocalizations?limit=10`))
      .find((x) => x.attributes.locale === locale);
    const attr = { feedbackEmail: mail, description: text, privacyPolicyUrl: cfg.privacyUrl, marketingUrl: cfg.supportUrl };
    const r = vorh
      ? await asc('PATCH', `/v1/betaAppLocalizations/${vorh.id}`, { data: { type: 'betaAppLocalizations', id: vorh.id, attributes: attr } })
      : await asc('POST', '/v1/betaAppLocalizations', { data: { type: 'betaAppLocalizations',
          attributes: { locale, ...attr }, relationships: { app: { data: { type: 'apps', id: app.id } } } } });
    if (r.code >= 300) schlecht(`Testinfo ${locale}: ${fehlertext(r)}`);
  }
  const rd = daten(await asc('GET', `/v1/apps/${app.id}/betaAppReviewDetail`));
  if (rd && kontakt) {
    const r = await asc('PATCH', `/v1/betaAppReviewDetails/${rd.id}`, { data: { type: 'betaAppReviewDetails', id: rd.id,
      attributes: { contactFirstName: kontakt.contactFirstName, contactLastName: kontakt.contactLastName,
        contactPhone: kontakt.contactPhone, contactEmail: kontakt.contactEmail,
        demoAccountRequired: false, notes: cfg.reviewNotes || '' } } });
    if (r.code >= 300) schlecht(`Prüfer-Kontakt TestFlight: ${fehlertext(r)}`);
  }
}

(async () => {
  const dir = process.argv[2];
  const mails = (process.env.TESTER || '').split(/[\s,]+/).filter(Boolean);
  if (!dir || !mails.length) { console.log('Keine Tester angegeben.'); return; }
  const id = bundleId(dir);
  const app = liste(await asc('GET', `/v1/apps?filter[bundleId]=${encodeURIComponent(id)}`))[0];
  if (!app) { schlecht(`App ${id} nicht gefunden`); process.exit(1); }

  const nutzer = new Set(liste(await asc('GET', '/v1/users?limit=200'))
    .map((u) => (u.attributes.username || '').toLowerCase()));
  const intern = mails.filter((m) => nutzer.has(m.toLowerCase()));
  const extern = mails.filter((m) => !nutzer.has(m.toLowerCase()));

  if (intern.length) {
    const g = await gruppe(app, 'Team', true);
    if (g) for (const m of intern) await tester(m, g);
  }
  if (extern.length) {
    const g = await gruppe(app, 'Familie', false);
    if (g) {
      for (const m of extern) await tester(m, g);
      const b = await neuesterBuild(app);
      if (b) {
        await testInfos(app, dir);
        let r = await asc('POST', `/v1/betaGroups/${g.id}/relationships/builds`, { data: [{ type: 'builds', id: b.id }] });
        if (r.code >= 300 && r.code !== 409) schlecht(`Build → Familie: ${fehlertext(r)}`);
        else gut(`Build ${b.attributes.version} → „Familie“`);
        const status = daten(await asc('GET', `/v1/builds/${b.id}/buildBetaDetail`));
        const ext = status && status.attributes.externalBuildState;
        if (['IN_BETA_TESTING', 'READY_FOR_BETA_TESTING', 'WAITING_FOR_BETA_REVIEW', 'IN_BETA_REVIEW', 'BETA_APPROVED'].includes(ext)) {
          gut(`TestFlight-Prüfung: ${ext}`);
        } else {
          r = await asc('POST', '/v1/betaAppReviewSubmissions', { data: { type: 'betaAppReviewSubmissions',
            relationships: { build: { data: { type: 'builds', id: b.id } } } } });
          if (r.code < 300) gut('Zur TestFlight-Prüfung eingereicht (meist ein paar Stunden)');
          else schlecht(`TestFlight-Prüfung: ${fehlertext(r)}`);
        }
      }
    }
  }
  process.exit(fehler ? 1 : 0);
})();
