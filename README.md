# App-Fabrik – Wochen-Repo

Automatischer Bau kleiner iOS-Apps (Flutter) mit GitHub Actions.
Dieses Repo ist eine Woche lang öffentlich und wird danach privat gestellt;
die Woche darauf übernimmt ein neues Repo (`woche.yml`).

| Workflow | Zweck |
|---|---|
| `radar.yml` | App-Store-Charts auswerten (nachts) |
| `fabrik.yml` | neue App bauen und an `ios.yml` übergeben |
| `ios.yml` | testen, Store-Eintrag, Mac-Build, TestFlight |
| `einreichen.yml` | App bei Apple einreichen (nur auf Wunsch) |
| `bewertungen.yml` | Kundenbewertungen holen |
| `woche.yml` | Sonntags neues Wochen-Repo, altes privat |
