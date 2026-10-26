// ignore_for_file: invalid_use_of_visible_for_testing_member
// Renders App Store screenshots (6.9" iPhone, 1290 × 2796) with real fonts.
// Run: flutter test screenshots
// Output: screenshots/out/<lang>_<n>.png
import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:bandsalat/design.dart';
import 'package:bandsalat/main.dart';
import 'package:bandsalat/models.dart';
import 'package:bandsalat/screens/deck_screen.dart';
import 'package:bandsalat/screens/jcard_screen.dart';
import 'package:bandsalat/screens/pro_screen.dart';
import 'package:bandsalat/screens/tape_editor.dart';
import 'package:bandsalat/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/demo.dart';
import '../test/fakes.dart';
import '../test/test_fonts.dart';

/// Loud riso poster: one flat ink colour, a big mono headline, the app framed on a hard shadow.
class _Frame extends StatelessWidget {
  const _Frame({required this.caption, required this.ink, required this.child});
  final ValueNotifier<String> caption;
  final ValueNotifier<(Color, Color)> ink;
  final Widget child;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder(
          valueListenable: ink,
          builder: (context, colors, _) => ValueListenableBuilder(
            valueListenable: caption,
            builder: (context, c, _) => Container(
              color: colors.$1,
              child: Stack(children: [
                // halftone corner
                Positioned.fill(child: CustomPaint(painter: _Dots(colors.$2))),
                Column(children: [
                  Container(
                    height: 150,
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.fromLTRB(32, 0, 24, 18),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: Text(c.toUpperCase(), style: TextStyle(fontFamily: mono, fontSize: 40, height: 1.12, color: colors.$2, letterSpacing: -1)),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        widthFactor: 0.82,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(color: Pal.navy, width: 6),
                            boxShadow: const [BoxShadow(color: Pal.navy, offset: Offset(14, 14))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: 430,
                                height: 880,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(size: const Size(430, 880), padding: const EdgeInsets.only(top: 34, bottom: 18)),
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      );
}

class _Dots extends CustomPainter {
  _Dots(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withValues(alpha: 0.16);
    for (var i = 0; i < 14; i++) {
      for (var j = 0; j < 14; j++) {
        final r = (1 - (i + j) / 28) * 9;
        if (r > 0.5) canvas.drawCircle(Offset(size.width - 30 - i * 26 + (j.isOdd ? 13 : 0), size.height - 30 - j * 24), r, p);
      }
    }
  }

  @override
  bool shouldRepaint(_Dots o) => o.color != color;
}

Future<void> _shot(WidgetTester t, String name) async {
  final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
  await t.runAsync(() async {
    final img = await boundary.toImage(pixelRatio: 3);
    final bytes = await img.toByteData(format: ImageByteFormat.png);
    File('screenshots/out/${Platform.environment['DARK'] == '1' ? 'dark_' : ''}$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(loadFonts);

  for (final lang in ['en', 'de']) {
    testWidgets('screenshots $lang', (t) async {
      t.view.physicalSize = const Size(1290, 2796);
      t.view.devicePixelRatio = 3;
      t.platformDispatcher.localesTestValue = [Locale(lang)];
      addTearDown(() {
        t.view.reset();
        t.platformDispatcher.clearLocalesTestValue();
        t.platformDispatcher.clearPlatformBrightnessTestValue();
      });
      final de = lang == 'de';
      if (Platform.environment['DARK'] == '1') t.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      final rig = await Rig.create(pro: true);
      final summer = seedDemo(rig.lib, lang);
      rig.lib.finishOnboarding();
      rig.lib.remember(summer.id, Side.a);

      final key = GlobalKey<NavigatorState>();
      final caption = ValueNotifier(de ? 'Dein Regal voller Mixtapes' : 'A shelf full of mixtapes');
      final ink = ValueNotifier<(Color, Color)>((Pal.mustard, Pal.navy));
      await t.pumpWidget(RepaintBoundary(
        key: const ValueKey('shot'),
        child: _Frame(caption: caption, ink: ink, child: BandsalatApp(services: rig.services, navigatorKey: key)),
      ));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_1');

      // 2 deck, playing
      caption.value = de ? 'Abspielen, spulen, Band wenden' : 'Play, spool, flip the tape';
      ink.value = (Pal.tomato, Colors.white);
      await rig.deck.load(summer, side: Side.a);
      await rig.deck.seekTo(0.42);
      key.currentState!.push(softRoute(const DeckScreen()));
      await t.pumpAndSettle();
      await rig.deck.play();
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      await _shot(t, '${lang}_2');
      await rig.deck.pause();
      key.currentState!.pop();
      await t.pumpAndSettle();

      // 3 editor: how much tape is left
      caption.value = de ? 'Sieh, wie viel Band noch frei ist' : 'See how much tape is left';
      ink.value = (Pal.teal, Colors.white);
      key.currentState!.push(softRoute(TapeEditor(tape: summer)));
      await t.pumpAndSettle();
      await t.drag(find.byType(ListView).first, const Offset(0, -760));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_3');

      // 4 editor top: colours and labels
      caption.value = de ? 'Acht Farben, acht Etiketten' : 'Eight colours, eight labels';
      ink.value = (Pal.pink, Pal.navy);
      await t.drag(find.byType(ListView).first, const Offset(0, 760));
      await t.pumpAndSettle();
      await t.drag(find.byType(ListView).first, const Offset(0, -300));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_4');
      key.currentState!.pop();
      await t.pumpAndSettle();

      // 5 case card
      caption.value = de ? 'Handbeschriftete Hülle zum Drucken' : 'A hand-lettered case card to print';
      ink.value = (const Color(0xFF2A3B8F), Pal.mustard);
      key.currentState!.push(softRoute(JCardScreen(tape: summer)));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_5');
      key.currentState!.pop();
      await t.pumpAndSettle();

      // 6 crate
      caption.value = de ? 'Deine Songs.\nDeine Dateien.' : 'Your songs.\nYour files.';
      ink.value = (Pal.mustard, Pal.navy);
      await t.tap(find.text(de ? 'Kiste' : 'Crate'));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_6');

      // 7 paywall (free user)
      caption.value = de ? 'Einmal zahlen.\nKein Abo.' : 'Pay once.\nNo subscription.';
      ink.value = (Pal.mustard, Pal.navy);
      final free = await Rig.create();
      await t.runAsync(free.pro.start);
      key.currentState!.push(MaterialPageRoute<void>(builder: (_) => ServicesScope(services: free.services, child: const ProScreen())));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_7');
    });
  }
}
