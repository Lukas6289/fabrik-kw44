import 'package:bandsalat/main.dart';
import 'package:bandsalat/models.dart';
import 'package:bandsalat/pro.dart';
import 'package:bandsalat/samples.dart';
import 'package:bandsalat/screens/deck_screen.dart';
import 'package:bandsalat/screens/jcard_screen.dart';
import 'package:bandsalat/screens/pro_screen.dart';
import 'package:bandsalat/screens/widgets.dart';
import 'package:bandsalat/screens/tape_editor.dart';
import 'package:bandsalat/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'demo.dart';
import 'fakes.dart';
import 'test_fonts.dart';

Future<GlobalKey<NavigatorState>> pump(
  WidgetTester t,
  Rig rig, {
  String lang = 'de',
  double scale = 1,
  Size size = const Size(390, 844),
}) async {
  t.view.physicalSize = size * 3;
  t.view.devicePixelRatio = 3;
  t.platformDispatcher.localesTestValue = [Locale(lang)];
  t.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(() {
    t.view.reset();
    t.platformDispatcher.clearLocalesTestValue();
    t.platformDispatcher.clearTextScaleFactorTestValue();
  });
  final key = GlobalKey<NavigatorState>();
  await t.pumpWidget(BandsalatApp(services: rig.services, navigatorKey: key));
  await t.pumpAndSettle();
  return key;
}

void main() {
  setUpAll(loadFonts);

  testWidgets('first start: welcome, then the shelf with the sample tape', (
    t,
  ) async {
    final rig = await Rig.create();
    await pump(t, rig);
    expect(find.text('Los geht’s'), findsOneWidget);
    await t.tap(find.text('Los geht’s'));
    await t.pumpAndSettle();
    expect(rig.lib.tapes.single.name, 'Probier-Band');
    expect(rig.lib.songs.length, 4);
    expect(find.text('Probier-Band'), findsWidgets);
    expect(find.text('Abspielen'), findsOneWidget);
  });

  testWidgets('English device shows English', (t) async {
    final rig = await Rig.create();
    await pump(t, rig, lang: 'en');
    expect(find.text('Let’s go'), findsOneWidget);
    seedSample(rig.lib, 'en');
    rig.lib.finishOnboarding();
    await t.pumpAndSettle();
    expect(
      find.text('Your tapes'.toUpperCase()),
      findsNothing,
    ); // set in Rubik as typed
    expect(find.text('Your tapes'), findsOneWidget);
    expect(find.text('Test Tape'), findsWidgets);
  });

  testWidgets('play on the hero starts the deck and shows the mini player', (
    t,
  ) async {
    final rig = await Rig.create();
    seedSample(rig.lib, 'de');
    rig.lib.finishOnboarding();
    await pump(t, rig);
    await t.tap(find.text('Abspielen'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(rig.engine.isPlaying, isTrue);
    expect(rig.deck.tape!.name, 'Probier-Band');
    expect(find.text('Morgenkaffee'), findsWidgets);
    await rig.deck.pause();
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(rig.deck.playing, isFalse);
    for (final r in t.widgetList<Reeling>(find.byType(Reeling))) {
      expect(r.active, isFalse, reason: 'reels must stop turning when paused');
    }
  });

  testWidgets('deck screen: keys and queue work', (t) async {
    final rig = await Rig.create(pro: true);
    final tape = seedDemo(rig.lib, 'de');
    rig.lib.finishOnboarding();
    final key = await pump(t, rig);
    await rig.deck.load(tape);
    key.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ServicesScope(services: rig.services, child: const DeckScreen()),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Kaffee um Vier'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(rig.deck.index, 2);
    expect(rig.deck.playing, isTrue);
    await t.tap(find.byIcon(Icons.pause_rounded).last);
    await t.pump();
    expect(rig.deck.playing, isFalse);
    await t.tap(find.byIcon(Icons.flip_rounded));
    await t.pumpAndSettle();
    expect(rig.deck.side, Side.b);
  });

  testWidgets('editor: build a tape, songs that do not fit are refused', (
    t,
  ) async {
    final rig = await Rig.create();
    for (var i = 0; i < 4; i++) {
      rig.lib.addSong(title: 'Song $i', file: 's$i.mp3', ms: 6 * 60000);
    }
    rig.lib.finishOnboarding();
    final key = await pump(t, rig);
    final draft = rig.lib.draft();
    key.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => ServicesScope(
          services: rig.services,
          child: TapeEditor(tape: draft, isNew: true),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'Mein Band');
    await t.tap(find.text('C30'));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.text('Songs hinzufügen'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await t.tap(find.text('Songs hinzufügen').first);
    await t.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await t.tap(find.text('Song $i'));
      await t.pump();
    }
    await t.pumpAndSettle();
    expect(find.text('zu lang'), findsOneWidget);
    await t.tap(find.textContaining('hinzufügen').last);
    await t.pumpAndSettle();
    expect(draft.a.length, 2); // 15 min per side: two of three 6-minute songs
    expect(rig.lib.tapes, isEmpty);
    await t.tap(find.text('Fertig'));
    await t.pumpAndSettle();
    expect(rig.lib.tapes.single.name, 'Mein Band');
    expect(rig.lib.tapes.single.minutes, 30);
  });

  testWidgets('limit: the 4th tape leads to the paywall; buying unlocks', (
    t,
  ) async {
    final rig = await Rig.create();
    for (var i = 0; i < freeTapes; i++) {
      rig.lib.createTape(name: 'T$i');
    }
    rig.lib.finishOnboarding();
    await pump(t, rig);
    await t.tap(find.byIcon(Icons.add_rounded));
    await t.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
    expect(find.textContaining('4,99'), findsWidgets);
    await t.tap(find.text('Pro für 4,99 € holen'));
    await t.pumpAndSettle();
    expect(rig.pro.isPro, isTrue);
    expect(find.text('Danke! Pro ist freigeschaltet.'), findsOneWidget);
  });

  testWidgets('a Pro look sends free users to the paywall', (t) async {
    final rig = await Rig.create();
    rig.lib.finishOnboarding();
    final key = await pump(t, rig);
    final draft = rig.lib.draft();
    key.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => ServicesScope(
          services: rig.services,
          child: TapeEditor(tape: draft, isNew: true),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.text('KASSETTENFARBE'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);
    await t.tap(find.byIcon(Icons.lock_rounded).first);
    await t.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
    expect(draft.shell, 0);
  });

  testWidgets('case card: image shared; PDF needs Pro', (t) async {
    final maker = await Rig.create(pro: true);
    seedDemo(maker.lib, 'de');
    maker.lib.finishOnboarding();
    final rig = await Rig.create(
      prefs: {'data': maker.prefs.getString('data')!},
    );
    final tape = rig.lib.tapes.first;
    final key = await pump(t, rig);
    key.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => ServicesScope(
          services: rig.services,
          child: JCardScreen(tape: tape),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('gemacht mit Bandsalat'), findsOneWidget);
    await t.runAsync(() async {
      await t.tap(find.text('Als Bild teilen'));
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await t.pumpAndSettle();
    expect(rig.sharer.files.keys.single, endsWith('.png'));
    await t.tap(find.textContaining('PDF zum Drucken'));
    await t.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
  });

  for (final (name, size, scale) in [
    ('small phone', const Size(320, 568), 1.0),
    ('big text', const Size(390, 844), 1.3),
  ]) {
    testWidgets('no overflow: $name', (t) async {
      final rig = await Rig.create(pro: true);
      final tape = seedDemo(rig.lib, 'de');
      rig.lib.finishOnboarding();
      final key = await pump(t, rig, size: size, scale: scale);
      for (final tab in ['Kiste', 'Mehr', 'Regal']) {
        await t.tap(find.text(tab).last);
        await t.pumpAndSettle();
      }
      await rig.deck.load(tape);
      for (final page in <Widget>[
        const DeckScreen(),
        TapeEditor(tape: tape),
        JCardScreen(tape: tape),
        const ProScreen(),
      ]) {
        key.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => ServicesScope(services: rig.services, child: page),
          ),
        );
        await t.pumpAndSettle();
        key.currentState!.pop();
        await t.pumpAndSettle();
      }
      expect(t.takeException(), isNull);
    });
  }
}
