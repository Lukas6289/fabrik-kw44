# Letzter Lauf: bandsalat – 2026-10-26 09:58 UTC

https://github.com/Lukas6289/fabrik-kw44/actions/runs/40302349929

| Schritt | Ergebnis |
|---|---|
| Tests | ✅ success |
| Apple (Bundle-ID, App-Eintrag) | ✅ success |
| Store-Eintrag ausfüllen | ✅ success |
| Bauen + TestFlight | ✅ success |
| TestFlight-Tester | ❌ failure |

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
No issues found! (ran in 14.5s)
Try `flutter pub outdated` for more information.

::group::✅ Passing tests
::endgroup::

🎉 34 tests passed.
```

## apple

```
✔ Bundle-ID vorhanden: com.lukasbeutler.bandsalat
✔ App-Eintrag vorhanden
```

## store

```
✔ Kategorien: MUSIC/LIFESTYLE
✔ Altersfreigabe 4+
✔ Name, Untertitel, Datenschutz-URL de-DE
✔ Name, Untertitel, Datenschutz-URL en-US
✔ Prüfer-Kontakt und Hinweise
✔ Beschreibung, Keywords, Werbetext de-DE
✔ Bildschirmfotos de-DE schon da
✔ Beschreibung, Keywords, Werbetext en-US
✔ Bildschirmfotos en-US schon da

ERGEBNIS: 9 erledigt, 0 offen
```

## build

```
Bei Apple: noch kein Build sichtbar
Build 1
[32mFound 1 Bundle ID matching specified filters: identifier=com.lukasbeutler.bandsalat, platform=IOS.[0m
- Fabrik bandsalat com.lukasbeutler.bandsalat (PYTMT6MXVZ)

[32mFound 3 Signing Certificates matching specified filters: certificateType=DISTRIBUTION,IOS_DISTRIBUTION.[0m
[32mFiltered out 1 Signing Certificate for given private key[0m
- Apple Distribution: Lukas Beutler (8Y8HB27GH7)

Get Profiles for Bundle ID PYTMT6MXVZ
[32mFound 1 Profile for Bundle ID PYTMT6MXVZ matching specified filters: profileState=ACTIVE, profileType=IOS_APP_STORE.[0m

[32mFiltered out 1 Profile that contain Signing Certificate Apple Distribution: Lukas Beutler (8Y8HB27GH7)[0m
- IOS_APP_STORE Fabrik bandsalat ios_app_store 1792992037 (5GS25N4Q9K)

[32mSaved Signing Certificate Apple Distribution: Lukas Beutler (8Y8HB27GH7) to /Users/runner/Library/Developer/Xcode/UserData/Certificates/DISTRIBUTION_8Y8HB27GH7_z26xgk9n.p12[0m
[32mSaved Profile IOS_APP_STORE Fabrik bandsalat ios_app_store 1792992037 (5GS25N4Q9K) to '/Users/runner/Library/Developer/Xcode/UserData/Provisioning Profiles/IOS_APP_STORE_5GS25N4Q9K_dqkadni7.mobileprovision'[0m
[34mConfigure code signing settings[0m
Searching for files matching /Users/runner/Library/Developer/Xcode/UserData/Provisioning Profiles/*.mobileprovision
Searching for files matching /Users/runner/Library/Developer/Xcode/UserData/Provisioning Profiles/*.provisionprofile
Searching for files matching /Users/runner/Library/MobileDevice/Provisioning Profiles/*.mobileprovision
Searching for files matching /Users/runner/Library/MobileDevice/Provisioning Profiles/*.provisionprofile
List available code signing certificates in keychain /Users/runner/Library/codemagic-cli-tools/keychains/26-10-26_bwaum139.keychain-db
Searching for files matching /Users/runner/work/fabrik-kw44/fabrik-kw44/fabrik/bandsalat/**/*.xcodeproj
[32mCompleted configuring code signing settings[0m
 [34m- Using profile "Fabrik bandsalat ios_app_store 1792992037" [91a244e3-55f6-48b8-b402-824fa38fdc18] for target "Runner" [Debug] from project "Runner"[0m
 [34m- Using profile "Fabrik bandsalat ios_app_store 1792992037" [91a244e3-55f6-48b8-b402-824fa38fdc18] for target "Runner" [Profile] from project "Runner"[0m
 [34m- Using profile "Fabrik bandsalat ios_app_store 1792992037" [91a244e3-55f6-48b8-b402-824fa38fdc18] for target "Runner" [Release] from project "Runner"[0m
[32mGenerated options for exporting the project[0m
 [34m- Method: app-store[0m
 [34m- Provisioning Profiles:[0m
     [34m- com.lukasbeutler.bandsalat: Fabrik bandsalat ios_app_store 1792992037[0m
 [34m- Signing Certificate: Apple Distribution[0m
 [34m- Signing Style: manual[0m
 [34m- Team Id: WAZMS5W753[0m
[32mSaved export options to /Users/runner/export_options.plist[0m
Provisioned devices: N/A
Provisions all devices: No
Supported platforms: iPhoneOS
Version code: 1
Version: 1.0.0

[34mUpload "build/ios/ipa/Bandsalat.ipa" to App Store Connect[0m
Running altool at path '/Applications/Xcode_26.6.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources/altool'...

26.40.1 (174001)
Running altool at path '/Applications/Xcode_26.6.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources/altool'...

2026-10-26 09:57:23.890  INFO: [ContentDelivery.Uploader.796C48700] 
==========================================
UPLOAD SUCCEEDED with no errors
Delivery UUID: ab30ecb0-a8ff-4c5f-ac88-bb24a5e3d267
Transferred 26632626 bytes in 0.648 seconds (41.1MB/s, 328.549Mbps)
==========================================
{
  "details" : {
    "delivery-uuid" : "ab30ecb0-a8ff-4c5f-ac88-bb24a5e3d267",
    "transferred" : "26632626 bytes in 0.648 seconds (41.1MB/s, 328.549Mbps)"
  },
  "os-version" : "Version 26.6.2 (Build 25G83)",
  "success-message" : "No errors uploading archive at 'build/ios/ipa/Bandsalat.ipa'.",
  "tool-path" : "/Applications/Xcode_26.6.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources",
  "tool-version" : "26.40.1 (174001)"
}

[32mNo errors uploading archive at 'build/ios/ipa/Bandsalat.ipa'.[0m
--- flutter build ipa (Fehler/letzte Zeilen) ---
...
  Fetching from https://github.com/zhangao0086/DKCamera...      
  Fetching from https://github.com/zhangao0086/DKPhotoGallery...     
  Fetching from https://github.com/SDWebImage/SDWebImage...     
  Fetching from https://github.com/kirualex/SwiftyGif.git...     
  Fetching from https://github.com/TimOliver/TOCropViewController...     
Archiving com.lukasbeutler.bandsalat...
Running Xcode build...                                          
Xcode archive done.                                         187.9s
✓ Built build/ios/archive/Runner.xcarchive (196.6MB)

[✓] App Settings Validation
    • Version Number: 1.0.0
    • Build Number: 1
    • Display Name: Bandsalat
    • Deployment Target: 16.0
    • Bundle Identifier: com.lukasbeutler.bandsalat

To update the settings, please refer to https://flutter.dev/to/ios-deploy

Building App Store IPA...                                           8.8s
✓ Built IPA to build/ios/ipa (26.7MB)
To upload to the App Store either:
    1. Drag and drop the "build/ios/ipa/*.ipa" bundle into the Apple Transporter macOS app https://apps.apple.com/us/app/transporter/id1450874784
    2. Run "xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey your_api_key --apiIssuer your_issuer_id".
       See "man altool" for details about how to authenticate with the App Store Connect API key.
```

## testflight

```
✘ …@…: Tester(s) cannot be assigned
```
