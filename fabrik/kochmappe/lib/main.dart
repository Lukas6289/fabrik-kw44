import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'design.dart';
import 'importer.dart';
import 'l10n/app_localizations.dart';
import 'library.dart';
import 'pro.dart';
import 'screens/shell.dart';
import 'screens/welcome_screen.dart';
import 'services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final pro = Pro(prefs, AppleProBackend());
  pro.start();
  runApp(KochmappeApp(
    services: Services(
      library: Library(prefs, pro, photos: DevicePhotoStore()),
      pro: pro,
      sharer: DeviceShareBackend(),
      links: DeviceLinkBackend(),
      fonts: (asset) async => rootBundle.load(asset),
      web: DeviceWebBackend(),
      awake: DeviceAwakeBackend(),
      picker: DevicePhotoPicker(),
      files: DeviceFilePicker(),
    ),
  ));
}

class KochmappeApp extends StatefulWidget {
  const KochmappeApp({super.key, required this.services, this.navigatorKey});
  final Services services;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<KochmappeApp> createState() => _KochmappeAppState();
}

class _KochmappeAppState extends State<KochmappeApp> with WidgetsBindingObserver {
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
        listenable: Listenable.merge([lib, widget.services.pro]),
        builder: (context, _) {
          final theme = widget.services.pro.isPro ? lib.settings.theme : 0;
          return MaterialApp(
            navigatorKey: widget.navigatorKey,
            onGenerateTitle: (c) => L.of(c).appTitle,
            debugShowCheckedModeBanner: false,
            theme: mappeTheme(Brightness.light, theme),
            darkTheme: mappeTheme(Brightness.dark, theme),
            localizationsDelegates: const [
              L.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L.supportedLocales,
            home: lib.settings.onboarded ? const Shell() : const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
