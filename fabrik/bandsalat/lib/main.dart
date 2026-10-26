import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio.dart';
import 'deck.dart';
import 'design.dart';
import 'l10n/app_localizations.dart';
import 'library.dart';
import 'pro.dart';
import 'screens/shell.dart';
import 'screens/welcome_screen.dart';
import 'services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.lukasbeutler.bandsalat.audio',
    androidNotificationChannelName: 'Bandsalat',
    androidNotificationOngoing: true,
  );
  final prefs = await SharedPreferences.getInstance();
  final docs = (await getApplicationDocumentsDirectory()).path;
  final pro = Pro(prefs, AppleProBackend());
  pro.start();
  final lib = Library(prefs, pro);
  final files = DeviceSongFiles(docs);
  final deck = Deck(
    JustAudioEngine(),
    lib,
    (s) => s.isAsset ? s.file : files.pathOf(s.file),
  );
  runApp(
    BandsalatApp(
      services: Services(
        library: lib,
        pro: pro,
        deck: deck,
        sharer: DeviceShareBackend(),
        links: DeviceLinkBackend(),
        fonts: (asset) async => rootBundle.load(asset),
        importer: SongImporter(
          lib,
          DeviceAudioPicker(),
          DeviceAudioInfo(),
          files,
        ),
        songFiles: files,
      ),
    ),
  );
}

class BandsalatApp extends StatefulWidget {
  const BandsalatApp({super.key, required this.services, this.navigatorKey});
  final Services services;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<BandsalatApp> createState() => _BandsalatAppState();
}

class _BandsalatAppState extends State<BandsalatApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.services.pro.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final lib = widget.services.library;
    return ServicesScope(
      services: widget.services,
      child: ListenableBuilder(
        listenable: lib,
        builder: (context, _) => MaterialApp(
          navigatorKey: widget.navigatorKey,
          onGenerateTitle: (c) => L.of(c).appTitle,
          debugShowCheckedModeBanner: false,
          theme: bandTheme(Brightness.light),
          darkTheme: bandTheme(Brightness.dark),
          localizationsDelegates: const [
            L.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L.supportedLocales,
          home: lib.settings.onboarded ? const Shell() : const WelcomeScreen(),
        ),
      ),
    );
  }
}
