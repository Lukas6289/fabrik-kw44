# Letzter Lauf: schreibspur – 2026-10-25 21:37 UTC

https://github.com/Lukas6289/fabrik-kw44/actions/runs/40235246932

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
  share_plus 12.0.2 (13.3.1 available)
  share_plus_platform_interface 6.1.0 (7.2.0 available)
  shared_preferences_android 2.5.1 (2.5.3 available)
  test_api 0.7.12 (0.7.15 available)
  web 1.1.1 (1.1.2 available)
  win32 5.15.0 (6.4.0 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing schreibspur...                                        
No issues found! (ran in 11.5s)
::endgroup::

🎉 44 tests passed.
```

## apple

```
✔ Bundle-ID vorhanden: com.lukasbeutler.schreibspur
✔ App-Eintrag vorhanden
```

## store

```
✔ Kategorien: UTILITIES/LIFESTYLE
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
Bei Apple: Build 3 · VALID · 2026-10-22T13:02:21-07:00
Bei Apple: Build 2 · VALID · 2026-10-22T12:31:55-07:00
Bei Apple: Build 1 · VALID · 2026-10-22T04:02:18-07:00
Build 4
[32mFound 1 Bundle ID matching specified filters: identifier=com.lukasbeutler.schreibspur, platform=IOS.[0m
- Fabrik schreibspur com.lukasbeutler.schreibspur (P4F9NL3TZ8)

[32mFound 3 Signing Certificates matching specified filters: certificateType=DISTRIBUTION,IOS_DISTRIBUTION.[0m
[32mFiltered out 1 Signing Certificate for given private key[0m
- Apple Distribution: Lukas Beutler (8Y8HB27GH7)

Get Profiles for Bundle ID P4F9NL3TZ8
[32mFound 1 Profile for Bundle ID P4F9NL3TZ8 matching specified filters: profileState=ACTIVE, profileType=IOS_APP_STORE.[0m

[33mDid not find any Profiles that contain Signing Certificate Apple Distribution: Lukas Beutler (8Y8HB27GH7)[0m
[32mFound 1 Device matching specified filters: platform=IOS, status=ENABLED.[0m
[32mFound 3 Signing Certificates matching specified filters: certificateType=DISTRIBUTION,IOS_DISTRIBUTION.[0m
Get Bundle ID P4F9NL3TZ8
[34mCreating new Profile: name: 'Fabrik schreibspur ios_app_store 1792963853', profile type: IOS_APP_STORE, bundle id: P4F9NL3TZ8, certificates: ['8Y8HB27GH7', 'FNFXKZ7GHM', 'T5G6J9LGD3'][0m
[32mCreated Profile N7WY896B4M[0m

[32mSaved Signing Certificate Apple Distribution: Lukas Beutler (8Y8HB27GH7) to /Users/runner/Library/Developer/Xcode/UserData/Certificates/DISTRIBUTION_8Y8HB27GH7__xedpkno.p12[0m
[32mSaved Profile IOS_APP_STORE Fabrik schreibspur ios_app_store 1792963853 (N7WY896B4M) to '/Users/runner/Library/Developer/Xcode/UserData/Provisioning Profiles/IOS_APP_STORE_N7WY896B4M_ryyiwc9g.mobileprovision'[0m
[34mConfigure code signing settings[0m
Searching for files matching /Users/runner/Library/Developer/Xcode/UserData/Provisioning Profiles/*.mobileprovision
Searching for files matching /Users/runner/Library/Developer/Xcode/UserData/Provisioning Profiles/*.provisionprofile
Searching for files matching /Users/runner/Library/MobileDevice/Provisioning Profiles/*.mobileprovision
Searching for files matching /Users/runner/Library/MobileDevice/Provisioning Profiles/*.provisionprofile
List available code signing certificates in keychain /Users/runner/Library/codemagic-cli-tools/keychains/25-10-26_j6l_kzd4.keychain-db
Searching for files matching /Users/runner/work/fabrik-kw44/fabrik-kw44/fabrik/schreibspur/**/*.xcodeproj
[32mCompleted configuring code signing settings[0m
 [34m- Using profile "Fabrik schreibspur ios_app_store 1792963853" [357aa2ac-19fd-4b00-9809-6cfeedfb3570] for target "Runner" [Debug] from project "Runner"[0m
 [34m- Using profile "Fabrik schreibspur ios_app_store 1792963853" [357aa2ac-19fd-4b00-9809-6cfeedfb3570] for target "Runner" [Profile] from project "Runner"[0m
 [34m- Using profile "Fabrik schreibspur ios_app_store 1792963853" [357aa2ac-19fd-4b00-9809-6cfeedfb3570] for target "Runner" [Release] from project "Runner"[0m
[32mGenerated options for exporting the project[0m
 [34m- Method: app-store[0m
 [34m- Provisioning Profiles:[0m
     [34m- com.lukasbeutler.schreibspur: Fabrik schreibspur ios_app_store 1792963853[0m
 [34m- Signing Certificate: Apple Distribution[0m
 [34m- Signing Style: manual[0m
 [34m- Team Id: WAZMS5W753[0m
[32mSaved export options to /Users/runner/export_options.plist[0m
Provisioned devices: N/A
Provisions all devices: No
Supported platforms: iPhoneOS
Version code: 4
Version: 1.0.0

[34mUpload "build/ios/ipa/schreibspur.ipa" to App Store Connect[0m
Running altool at path '/Applications/Xcode_26.6.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources/altool'...

26.40.1 (174001)
Running altool at path '/Applications/Xcode_26.6.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources/altool'...

2026-10-25 21:36:22.132  INFO: [ContentDelivery.Uploader.B16C506C0] 
==========================================
UPLOAD SUCCEEDED with no errors
Delivery UUID: 3670eb5a-8e49-4a46-862f-591961722ed3
Transferred 22284120 bytes in 0.847 seconds (26.3MB/s, 210.403Mbps)
==========================================
{
  "details" : {
    "delivery-uuid" : "3670eb5a-8e49-4a46-862f-591961722ed3",
    "transferred" : "22284120 bytes in 0.847 seconds (26.3MB/s, 210.403Mbps)"
  },
  "os-version" : "Version 26.6.2 (Build 25G83)",
  "success-message" : "No errors uploading archive at 'build/ios/ipa/schreibspur.ipa'.",
  "tool-path" : "/Applications/Xcode_26.6.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources",
  "tool-version" : "26.40.1 (174001)"
}

[32mNo errors uploading archive at 'build/ios/ipa/schreibspur.ipa'.[0m
--- flutter build ipa (Fehler/letzte Zeilen) ---
...
  Fetching from https://github.com/zhangao0086/DKCamera...      
  Fetching from https://github.com/zhangao0086/DKPhotoGallery...     
  Fetching from https://github.com/kirualex/SwiftyGif.git...     
  Fetching from https://github.com/SDWebImage/SDWebImage...     
  Fetching from https://github.com/TimOliver/TOCropViewController...     
Archiving com.lukasbeutler.schreibspur...
Running Xcode build...                                          
Xcode archive done.                                         163.6s
✓ Built build/ios/archive/Runner.xcarchive (186.5MB)

[✓] App Settings Validation
    • Version Number: 1.0.0
    • Build Number: 4
    • Display Name: Schreibspur
    • Deployment Target: 16.0
    • Bundle Identifier: com.lukasbeutler.schreibspur

To update the settings, please refer to https://flutter.dev/to/ios-deploy

Building App Store IPA...                                          10.9s
✓ Built IPA to build/ios/ipa (22.4MB)
To upload to the App Store either:
    1. Drag and drop the "build/ios/ipa/*.ipa" bundle into the Apple Transporter macOS app https://apps.apple.com/us/app/transporter/id1450874784
    2. Run "xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey your_api_key --apiIssuer your_issuer_id".
       See "man altool" for details about how to authenticate with the App Store Connect API key.
```

## testflight

```
✘ …@…: Tester(s) cannot be assigned
```
