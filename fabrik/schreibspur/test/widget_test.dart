import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schreibspur/main.dart';
import 'package:schreibspur/pro.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'parser_test.dart' show iosDe;

Future<({Pro pro, FakeSource source, FakeSharer sharer})> _pump(
  WidgetTester t, {
  bool owned = false,
  FakeSource? source,
  Locale? locale,
  FakeIncoming? incoming,
}) async {
  t.view.physicalSize = const Size(1290, 2796);
  t.view.devicePixelRatio = 3;
  if (locale != null) t.platformDispatcher.localesTestValue = [locale];
  addTearDown(() {
    t.view.reset();
    t.platformDispatcher.clearLocalesTestValue();
  });
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final backend = FakeProBackend();
  if (owned) backend.owned = [proLifetimeId];
  final pro = Pro(prefs, backend);
  await pro.start();
  final src = source ?? FakeSource();
  final sharer = FakeSharer();
  await t.pumpWidget(SchreibspurApp(pro: pro, source: src, sharer: sharer, incoming: incoming));
  await t.pumpAndSettle();
  return (pro: pro, source: src, sharer: sharer);
}

/// Rendering an image can take a while on slow machines: wait up to 15 s.
Future<void> _waitShared(WidgetTester t, FakeSharer sharer) async {
  for (var i = 0; i < 75 && sharer.shared.isEmpty; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await t.pump();
  }
}

Future<void> _scrollTo(WidgetTester t, Finder f) =>
    t.scrollUntilVisible(f, 400, scrollable: find.byType(Scrollable).first);

void main() {
  testWidgets('landing shows the offline promise and the export how-to', (t) async {
    await _pump(t, locale: const Locale('en'));
    await _scrollTo(t, find.textContaining('airplane mode'));
    expect(find.textContaining('airplane mode'), findsOneWidget);
    expect(find.text('Choose exported chat'), findsOneWidget);
    expect(find.textContaining('Export Chat'), findsWidgets);
  });

  testWidgets('German device language', (t) async {
    await _pump(t, locale: const Locale('de'));
    expect(find.text('Exportierten Chat wählen'), findsOneWidget);
    await _scrollTo(t, find.textContaining('Flugmodus'));
    expect(find.textContaining('Flugmodus'), findsOneWidget);
  });

  testWidgets('picked file is analysed; Pro cards are locked for free users', (t) async {
    final r = await _pump(t, locale: const Locale('en'), source: FakeSource(file: utf8.encode(iosDe)));
    await t.tap(find.text('Choose exported chat'));
    await t.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Anna'), findsWidgets);
    // only the overview card can be shared for free
    expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);
    await _scrollTo(t, find.text('Reply time'));
    expect(find.textContaining('Part of Pro'), findsWidgets);
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);
    expect(r.sharer.shared, isEmpty);
  });

  testWidgets('a locked card opens the paywall with price, terms and privacy', (t) async {
    await _pump(t, locale: const Locale('en'), source: FakeSource(file: utf8.encode(iosDe)));
    await t.tap(find.text('Choose exported chat'));
    await t.pumpAndSettle();
    await _scrollTo(t, find.text('Reply time'));
    await t.tap(find.text('Reply time'));
    await t.pumpAndSettle();
    expect(find.text('Schreibspur Pro'), findsOneWidget);
    await _scrollTo(t, find.textContaining('4,99 €'));
    expect(find.textContaining('12,99 €'), findsOneWidget);
    expect(find.textContaining('4,99 €'), findsOneWidget);
    await _scrollTo(t, find.text('Terms of Use'));
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.textContaining('renews automatically'), findsWidgets);
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.text('Pro is active – thank you!'), findsOneWidget);
  });

  testWidgets('bad file and empty clipboard show a hint', (t) async {
    await _pump(t, locale: const Locale('en'), source: FakeSource(file: utf8.encode('hello')));
    await t.tap(find.text('Choose exported chat'));
    await t.pumpAndSettle();
    expect(find.textContaining('No messages found'), findsOneWidget);
    await t.tap(find.text('Paste from clipboard'));
    await t.pumpAndSettle();
    expect(find.text('The clipboard is empty.'), findsOneWidget);
  });

  testWidgets('pasted text works', (t) async {
    await _pump(t, locale: const Locale('en'), source: FakeSource(clipboard: iosDe));
    await t.tap(find.text('Paste from clipboard'));
    await t.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
  });

  testWidgets('example chat with Pro: all cards open, every card can be shared', (t) async {
    final r = await _pump(t, owned: true, locale: const Locale('de'));
    await t.tap(find.text('Beispiel ansehen'));
    await t.pumpAndSettle();
    expect(find.textContaining('erfundene Personen'), findsOneWidget);
    for (final title in ['Antwortzeit', 'Wer fängt an?', 'Lieblings-Emoji', 'Rekorde', 'Auszeichnungen', 'Früher vs. jetzt']) {
      await _scrollTo(t, find.text(title));
      expect(find.text(title), findsOneWidget);
    }
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
    await t.drag(find.byType(Scrollable).first, const Offset(0, 20000));
    await t.pumpAndSettle();
    await t.runAsync(() => t.tap(find.byIcon(Icons.ios_share_rounded).first));
    await t.pump(const Duration(milliseconds: 50));
    await _waitShared(t, r.sharer);
    expect(find.byType(SnackBar), findsNothing);
    expect(r.sharer.shared.length, 1);
    expect(r.sharer.shared.single.sublist(1, 4), 'PNG'.codeUnits);
    expect(r.sharer.texts.single, 'Erstellt mit Schreibspur');
  });

  testWidgets('poster, word cloud and chat year are Pro; the poster opens the paywall for free users', (t) async {
    await _pump(t, locale: const Locale('en'));
    await t.tap(find.text('Try an example'));
    await t.pumpAndSettle();
    await t.tap(find.text('Create poster'));
    await t.pumpAndSettle();
    expect(find.text('Schreibspur Pro'), findsOneWidget);
    expect(find.textContaining('word cloud'), findsOneWidget);
    await t.pageBack();
    await t.pumpAndSettle();
    await _scrollTo(t, find.text('Chat year'));
    expect(find.text('Word cloud'), findsOneWidget);
    expect(find.textContaining('days with messages'), findsNothing);
  });

  testWidgets('with Pro: cloud and year band show, the poster is shared as one PNG', (t) async {
    final r = await _pump(t, owned: true, locale: const Locale('de'));
    await t.tap(find.text('Beispiel ansehen'));
    await t.pumpAndSettle();
    await _scrollTo(t, find.textContaining('Tagen geschrieben'));
    expect(find.text('Wortwolke'), findsOneWidget);
    expect(find.textContaining('wer es am meisten schreibt'), findsOneWidget);
    await t.drag(find.byType(Scrollable).first, const Offset(0, 20000));
    await t.pumpAndSettle();
    await t.tap(find.text('Poster erstellen'));
    await t.pumpAndSettle();
    expect(find.text('Poster'), findsOneWidget);
    expect(find.textContaining('offline ausgewertet'), findsOneWidget);
    await t.runAsync(() => t.tap(find.text('Poster teilen')));
    await t.pump(const Duration(milliseconds: 50));
    await _waitShared(t, r.sharer);
    expect(find.byType(SnackBar), findsNothing);
    expect(r.sharer.shared.length, 1);
    expect(r.sharer.shared.single.sublist(1, 4), 'PNG'.codeUnits);
  });

  testWidgets('a chat shared from WhatsApp opens straight away, even from another screen', (t) async {
    final incoming = FakeIncoming();
    await _pump(t, locale: const Locale('en'), incoming: incoming);
    await t.tap(find.byTooltip('Schreibspur Pro'));
    await t.pumpAndSettle();
    expect(find.text('Schreibspur Pro'), findsOneWidget);
    incoming.controller.add(Uint8List.fromList(utf8.encode(iosDe)));
    await t.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Anna'), findsWidgets);
    incoming.controller.add(Uint8List.fromList(utf8.encode('nothing here')));
    await t.pumpAndSettle();
    expect(find.textContaining('No messages found'), findsOneWidget);
  });

  testWidgets('story: free users see the first slides, then the Pro slide', (t) async {
    await _pump(t, locale: const Locale('en'));
    await t.tap(find.text('Try an example'));
    await t.pumpAndSettle();
    await t.tap(find.text('Play your recap'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('days in messages'), findsOneWidget);
    for (var i = 0; i < 8; i++) {
      await t.tapAt(const Offset(380, 500));
      await t.pump(const Duration(milliseconds: 600));
    }
    await t.pump(const Duration(seconds: 2));
    expect(find.text('That was just the start.'), findsOneWidget);
    await t.tap(find.text('See Pro'));
    await t.pumpAndSettle();
    expect(find.text('Schreibspur Pro'), findsOneWidget);
  });

  testWidgets('story with Pro: slides advance by themselves and a slide is shared as PNG', (t) async {
    final r = await _pump(t, owned: true, locale: const Locale('de'));
    await t.tap(find.text('Beispiel ansehen'));
    await t.pumpAndSettle();
    await t.tap(find.text('Rückblick abspielen'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('EUER CHAT'), findsOneWidget);
    await t.pump(const Duration(seconds: 8)); // auto-advance after 7 s
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Nachrichten'), findsOneWidget);
    await t.runAsync(() => t.tap(find.byTooltip('Folie teilen')));
    await t.pump(const Duration(milliseconds: 50));
    await _waitShared(t, r.sharer);
    expect(r.sharer.shared.length, 1);
    expect(r.sharer.shared.single.sublist(1, 4), 'PNG'.codeUnits);
    await t.tap(find.byTooltip('Schließen'));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('Rückblick abspielen'), findsOneWidget);
  });

  testWidgets('"another chat" returns to the start', (t) async {
    await _pump(t, locale: const Locale('en'));
    await t.tap(find.text('Try an example'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Another chat'));
    await t.pumpAndSettle();
    expect(find.text('Choose exported chat'), findsOneWidget);
  });
}
