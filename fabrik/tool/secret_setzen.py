"""Setzt ein Actions-Secret in einem Repo (GitHub verlangt Verschluesselung mit
dem oeffentlichen Schluessel des Repos).  Aufruf:
  GH_TOKEN=... python3 secret_setzen.py <owner/repo> <NAME> <WERT>
"""
import base64, json, os, sys, urllib.request
from nacl import encoding, public

repo, name, wert = sys.argv[1], sys.argv[2], sys.argv[3]
tok = os.environ['GH_TOKEN']

def api(methode, pfad, daten=None):
    req = urllib.request.Request('https://api.github.com' + pfad, method=methode,
        data=json.dumps(daten).encode() if daten is not None else None,
        headers={'Authorization': 'Bearer ' + tok, 'Accept': 'application/vnd.github+json',
                 'X-GitHub-Api-Version': '2022-11-28'})
    with urllib.request.urlopen(req) as r:
        text = r.read()
        return json.loads(text) if text else {}

k = api('GET', f'/repos/{repo}/actions/secrets/public-key')
box = public.SealedBox(public.PublicKey(k['key'].encode(), encoding.Base64Encoder()))
verschl = base64.b64encode(box.encrypt(wert.encode())).decode()
api('PUT', f'/repos/{repo}/actions/secrets/{name}', {'encrypted_value': verschl, 'key_id': k['key_id']})
print(f'Secret {name} in {repo} gesetzt.')
