// ignore_for_file: invalid_use_of_visible_for_testing_member
// Renders App Store screenshots (6.9" iPhone, 1290 × 2796) with real fonts.
// Run: flutter test screenshots
// Output: screenshots/out/<lang>_<n>.png
import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kochmappe/design.dart';
import 'package:kochmappe/main.dart';
import 'package:kochmappe/samples.dart';
import 'package:kochmappe/screens/cook_screen.dart';
import 'package:kochmappe/screens/edit_screen.dart';
import 'package:kochmappe/screens/pro_screen.dart';
import 'package:kochmappe/screens/recipe_screen.dart';
import 'package:kochmappe/services.dart';

import '../test/fakes.dart';
import '../test/test_fonts.dart';

/// Headline over a framed app screen, on ink-blue with a saffron index tab.
class _Frame extends StatelessWidget {
  const _Frame({required this.caption, required this.child});
  final ValueNotifier<String> caption;
  final Widget child;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2A4180), Color(0xFF111C33)]),
          ),
          child: ValueListenableBuilder(
            valueListenable: caption,
            builder: (context, c, _) => Stack(children: [
              Positioned(
                left: 30,
                top: 0,
                child: Container(
                  width: 64,
                  height: 20,
                  decoration: const BoxDecoration(color: Color(0xFFF2A516), borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
                ),
              ),
              Column(children: [
                Container(
                  height: 196,
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.fromLTRB(30, 0, 20, 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      c,
                      style: const TextStyle(fontFamily: serif, fontSize: 50, height: 1.06, color: Color(0xFFF4EEDF)),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(color: const Color(0xFF060B16), width: 6),
                          boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 50, offset: Offset(0, 20))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: 430,
                              height: 880,
                              child: MediaQuery(data: MediaQuery.of(context).copyWith(size: const Size(430, 880), padding: const EdgeInsets.only(top: 34, bottom: 18)), child: child),
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
      );
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
      final rig = await Rig.create(pro: false, now: DateTime(2026, 10, 25, 18));
      seedSamples(rig.lib, lang);
      rig.lib.finishOnboarding();
      final lib = rig.lib;
      String idOf(String title) => lib.recipes.firstWhere((r) => r.title.contains(title)).id;
      final soup = idOf(de ? 'Ofentomaten' : 'Oven-roasted');
      final bread = idOf(de ? 'Brot ohne' : 'No-knead');
      final gnocchi = idOf(de ? 'Gnocchi' : 'gnocchi');

      final key = GlobalKey<NavigatorState>();
      final caption = ValueNotifier(de ? 'Alle Rezepte.\nEine Mappe.' : 'All your recipes.\nOne binder.');
      await t.pumpWidget(RepaintBoundary(
        key: const ValueKey('shot'),
        child: _Frame(caption: caption, child: KochmappeApp(services: rig.services, navigatorKey: key)),
      ));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_1');

      // 2 recipe with portions
      caption.value = de ? 'Portionen rechnen –\nauch in oz & cups' : 'Scale portions –\neven to oz & cups';
      key.currentState!.push(softRoute(RecipeScreen(recipeId: soup)));
      await t.pumpAndSettle();
      await t.drag(find.byType(ListView), const Offset(0, -300));
      await t.pumpAndSettle();
      await t.tap(find.text('×2'));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_2');

      // 3 cook mode with timer
      caption.value = de ? 'Kochmodus mit\nTimern aus dem Text' : 'Cook mode with\ntimers from the text';
      key.currentState!.pop();
      await t.pumpAndSettle();
      key.currentState!.push(softRoute(CookScreen(recipeId: bread, servings: 10, startStep: 1)));
      await t.pumpAndSettle();
      await t.tap(find.textContaining(de ? 'Timer starten' : 'Start timer').first);
      await t.pump();
      await t.pump(const Duration(seconds: 2));
      await t.pump();
      await _shot(t, '${lang}_3');
      key.currentState!.pop();
      await t.pumpAndSettle();

      // 4 pasted text recognised, ready to check
      caption.value = de ? 'Text einfügen –\nZutaten erkannt' : 'Paste a text –\ningredients recognised';
      final pasted = de
          ? 'Quarkkeulchen wie früher\nFür 4 Personen\nZutaten\n500 g Quark\n2 Eier\n4 EL Mehl\n1 Prise Salz\n2 EL Butter, zum Braten\nZubereitung\n1. Quark, Eier, Mehl und Salz verrühren.\n2. Kleine Küchlein formen und 4 Minuten pro Seite in Butter braten.\n3. Mit Zimtzucker und Apfelmus servieren.'
          : 'Old-fashioned quark pancakes\nServes 4\nIngredients\n2 cups quark\n2 eggs\n4 tbsp flour\n1 pinch salt\n2 tbsp butter, for frying\nDirections\n1. Stir quark, eggs, flour and salt together.\n2. Shape small cakes and fry 4 minutes per side in butter.\n3. Serve with cinnamon sugar and apple sauce.';
      final draft = rig.services.importer.fromText(pasted).recipe!;
      key.currentState!.push(softRoute(EditScreen(draft: draft)));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_4');
      key.currentState!.pop();
      await t.pumpAndSettle();

      // 5 what do I have
      caption.value = de ? 'Was habe ich da?\nDeine Rezepte wissen es.' : 'What do I have?\nYour recipes know.';
      await t.tap(find.text(de ? 'Vorrat' : 'What I have'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).first, de ? 'Tomaten, Zwiebel, Spinat' : 'tomatoes, onion, spinach');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await _shot(t, '${lang}_5');

      // 6 twist + diary
      caption.value = de ? 'Dein Dreh.\nDein Koch-Tagebuch.' : 'Your twist.\nYour cooking diary.';
      await t.tap(find.text(de ? 'Mappe' : 'Binder'));
      await t.pumpAndSettle();
      key.currentState!.push(softRoute(RecipeScreen(recipeId: soup)));
      await t.pumpAndSettle();
      await t.drag(find.byType(ListView), const Offset(0, -1750));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_6');
      key.currentState!.pop();
      await t.pumpAndSettle();
      expect(gnocchi, isNotEmpty);

      // 7 paywall (free user)
      caption.value = de ? 'Einmal zahlen.\nKein Abo.' : 'Pay once.\nNo subscription.';
      final free = await Rig.create();
      await t.runAsync(free.pro.start);
      key.currentState!.push(MaterialPageRoute<void>(builder: (_) => ServicesScope(services: free.services, child: const ProScreen())));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_7');
    });
  }
}
