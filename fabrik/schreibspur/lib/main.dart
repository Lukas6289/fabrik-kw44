import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backends.dart';
import 'design.dart';
import 'parser.dart';
import 'l10n/app_localizations.dart';
import 'pro.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final pro = Pro(prefs, AppleProBackend());
  pro.start();
  runApp(SchreibspurApp(
    pro: pro,
    source: DeviceChatSource(),
    sharer: DeviceShareBackend(),
    incoming: DeviceIncomingChats(),
  ));
}

class SchreibspurApp extends StatelessWidget {
  const SchreibspurApp({
    super.key,
    required this.pro,
    required this.source,
    required this.sharer,
    this.navigatorKey,
    this.initialChat,
    this.incoming,
  });

  final Pro pro;
  final ChatSource source;
  final ShareBackend sharer;
  final GlobalKey<NavigatorState>? navigatorKey;
  final IncomingChats? incoming;

  /// Pre-loaded chat (screenshots).
  final Chat? initialChat;

  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorKey: navigatorKey,
        onGenerateTitle: (c) => L.of(c).appTitle,
        debugShowCheckedModeBanner: false,
        theme: brandTheme(Brightness.light),
        darkTheme: brandTheme(Brightness.dark),
        localizationsDelegates: const [
          L.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: L.supportedLocales,
        home: HomeScreen(pro: pro, source: source, sharer: sharer, initialChat: initialChat, incoming: incoming),
      );
}
