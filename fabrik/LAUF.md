# Letzter Lauf: kochmappe – 2026-10-25 21:27 UTC

https://github.com/Lukas6289/fabrik-kw44/actions/runs/40234733262

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
  posix 6.5.2 (6.5.3 available)
  qr 3.0.2 (4.0.0 available)
  share_plus 12.0.2 (13.3.1 available)
  share_plus_platform_interface 6.1.0 (7.2.0 available)
  test_api 0.7.12 (0.7.15 available)
  win32 5.15.0 (6.4.0 available)
Got dependencies!
11 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing kochmappe...                                          
No issues found! (ran in 13.8s)
::endgroup::

🎉 73 tests passed.
```

## apple

```
✔ Bundle-ID vorhanden: com.lukasbeutler.kochmappe
✔ App-Eintrag vorhanden
```

## store

```
✔ Kategorien: FOOD_AND_DRINK/LIFESTYLE
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
Bei Apple: Build 1 · VALID · 2026-10-25T00:23:01-07:00
Build 2
Neuer Signierschluessel erzeugt und als Secret gespeichert.
[32mFound 1 Bundle ID matching specified filters: identifier=com.lukasbeutler.kochmappe, platform=IOS.[0m
- Fabrik kochmappe com.lukasbeutler.kochmappe (WU569KBT3A)

[32mFound 2 Signing Certificates matching specified filters: certificateType=DISTRIBUTION,IOS_DISTRIBUTION.[0m
[33mDid not find any Signing Certificates for given private key[0m
[34mCreating new Signing Certificate: certificate type: DISTRIBUTION[0m
[32mCreated Signing Certificate 8Y8HB27GH7[0m

Get Profiles for Bundle ID WU569KBT3A
[32mFound 1 Profile for Bundle ID WU569KBT3A matching specified filters: profileState=ACTIVE, profileType=IOS_APP_STORE.[0m

[33mDid not find any Profiles that contain Signing Certificate Apple Distribution: Lukas Beutler (8Y8HB27GH7)[0m
[32mFound 1 Device matching specified filters: platform=IOS, status=ENABLED.[0m
[32mFound 3 Signing Certificates matching specified filters: certificateType=DISTRIBUTION,IOS_DISTRIBUTION.[0m
Get Bundle ID WU569KBT3A
[34mCreating new Profile: name: 'Fabrik kochmappe ios_app_store 1792963281', profile type: IOS_APP_STORE, bundle id: WU569KBT3A, certificates: ['T5G6J9LGD3', '8Y8HB27GH7', 'FNFXKZ7GHM'][0m
[32mCreated Profile 44P77CKBR9[0m

[32mSaved Signing Certificate Apple Distribution: Lukas Beutler (8Y8HB27GH7) to /Users/runner/Library/Developer/Xcode/UserData/Certificates/DISTRIBUTION_8Y8HB27GH7_q1_57o9r.p12[0m
[32mSaved Profile IOS_APP_STORE Fabrik kochmappe ios_app_store 1792963281 (44P77CKBR9) to '/Users/runner/Library/Developer/Xcode/UserData/Provisioning Profiles/IOS_APP_STORE_44P77CKBR9_uet49sc4.mobileprovision'[0m
[34mConfigure code signing settings[0m
Searching for files matching /Users/runner/Library/Developer/Xcode/UserData/Provisioning Profiles/*.mobileprovision
Searching for files matching /Users/runner/Library/Developer/Xcode/UserData/Provisioning Profiles/*.provisionprofile
Searching for files matching /Users/runner/Library/MobileDevice/Provisioning Profiles/*.mobileprovision
Searching for files matching /Users/runner/Library/MobileDevice/Provisioning Profiles/*.provisionprofile
List available code signing certificates in keychain /Users/runner/Library/codemagic-cli-tools/keychains/25-10-26_836lmoc6.keychain-db
Searching for files matching /Users/runner/work/fabrik-kw44/fabrik-kw44/fabrik/kochmappe/**/*.xcodeproj
[32mCompleted configuring code signing settings[0m
 [34m- Using profile "Fabrik kochmappe ios_app_store 1792963281" [b74e87a8-b4dc-413c-92d9-faf4f0bcf7d4] for target "Runner" [Debug] from project "Runner"[0m
 [34m- Using profile "Fabrik kochmappe ios_app_store 1792963281" [b74e87a8-b4dc-413c-92d9-faf4f0bcf7d4] for target "Runner" [Profile] from project "Runner"[0m
 [34m- Using profile "Fabrik kochmappe ios_app_store 1792963281" [b74e87a8-b4dc-413c-92d9-faf4f0bcf7d4] for target "Runner" [Release] from project "Runner"[0m
[32mGenerated options for exporting the project[0m
 [34m- Method: app-store[0m
 [34m- Provisioning Profiles:[0m
     [34m- com.lukasbeutler.kochmappe: Fabrik kochmappe ios_app_store 1792963281[0m
 [34m- Signing Certificate: Apple Distribution[0m
 [34m- Signing Style: manual[0m
 [34m- Team Id: WAZMS5W753[0m
[32mSaved export options to /Users/runner/export_options.plist[0m
Provisioned devices: N/A
Provisions all devices: No
Supported platforms: iPhoneOS
Version code: 2
Version: 1.0.0

[34mUpload "build/ios/ipa/kochmappe.ipa" to App Store Connect[0m
Running altool at path '/Applications/Xcode_26.6.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources/altool'...

26.40.1 (174001)
Running altool at path '/Applications/Xcode_26.6.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources/altool'...

2026-10-25 21:26:31.572  INFO: [ContentDelivery.Uploader.806C5C700] 
==========================================
UPLOAD SUCCEEDED with no errors
Delivery UUID: a8330b35-463e-4fb5-81ce-891d728ad03a
Transferred 24404166 bytes in 0.431 seconds (56.6MB/s, 452.712Mbps)
==========================================
{
  "details" : {
    "delivery-uuid" : "a8330b35-463e-4fb5-81ce-891d728ad03a",
    "transferred" : "24404166 bytes in 0.431 seconds (56.6MB/s, 452.712Mbps)"
  },
  "os-version" : "Version 26.6.2 (Build 25G83)",
  "success-message" : "No errors uploading archive at 'build/ios/ipa/kochmappe.ipa'.",
  "tool-path" : "/Applications/Xcode_26.6.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources",
  "tool-version" : "26.40.1 (174001)"
}

[32mNo errors uploading archive at 'build/ios/ipa/kochmappe.ipa'.[0m
--- flutter build ipa (Fehler/letzte Zeilen) ---
...
  Fetching from https://github.com/zhangao0086/DKCamera...      
  Fetching from https://github.com/zhangao0086/DKPhotoGallery...     
  Fetching from https://github.com/SDWebImage/SDWebImage...     
  Fetching from https://github.com/kirualex/SwiftyGif.git...     
  Fetching from https://github.com/TimOliver/TOCropViewController...     
Archiving com.lukasbeutler.kochmappe...
Running Xcode build...                                          
Xcode archive done.                                         140.2s
✓ Built build/ios/archive/Runner.xcarchive (193.5MB)

[✓] App Settings Validation
    • Version Number: 1.0.0
    • Build Number: 2
    • Display Name: Kochmappe
    • Deployment Target: 16.0
    • Bundle Identifier: com.lukasbeutler.kochmappe

To update the settings, please refer to https://flutter.dev/to/ios-deploy

Building App Store IPA...                                           8.8s
✓ Built IPA to build/ios/ipa (24.5MB)
To upload to the App Store either:
    1. Drag and drop the "build/ios/ipa/*.ipa" bundle into the Apple Transporter macOS app https://apps.apple.com/us/app/transporter/id1450874784
    2. Run "xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey your_api_key --apiIssuer your_issuer_id".
       See "man altool" for details about how to authenticate with the App Store Connect API key.
```

## testflight

```
✘ …@…: Tester(s) cannot be assigned
```
