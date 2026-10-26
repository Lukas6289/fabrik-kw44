# Letzter Lauf: bandsalat – 2026-10-26 05:03 UTC

https://github.com/Lukas6289/fabrik-kw44/actions/runs/40272050526

| Schritt | Ergebnis |
|---|---|
| Tests | ✅ success |
| Apple (Bundle-ID, App-Eintrag) | ❌ failure |
| Store-Eintrag ausfüllen | ⏭ skipped |
| Bauen + TestFlight | ⏭ skipped |
| TestFlight-Tester | ⏭ skipped |

## test

```
Resolving dependencies...
Downloading packages...
  cross_file 0.3.5+5 (0.4.0 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  dbus 0.7.15 (0.8.0 available)
  file_picker 10.3.10 (13.2.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  qr 3.0.2 (4.0.0 available)
  share_plus 12.0.2 (13.3.1 available)
  share_plus_platform_interface 6.1.0 (7.2.0 available)
  test_api 0.7.12 (0.7.15 available)
  win32 5.15.0 (6.4.0 available)
Got dependencies!
10 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing bandsalat...                                          
No issues found! (ran in 15.6s)
Try `flutter pub outdated` for more information.

::group::✅ Passing tests
::endgroup::

🎉 34 tests passed.
```

## apple

```
✔ Bundle-ID angelegt: com.lukasbeutler.bandsalat
✘ Kein App-Eintrag für com.lukasbeutler.bandsalat in App Store Connect.
  → App Store Connect → Apps → + → Neue App (siehe fabrik/fuer-lukas.md).
```
