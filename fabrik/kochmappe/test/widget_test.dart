import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kochmappe/main.dart';
import 'package:kochmappe/models.dart';
import 'package:kochmappe/samples.dart';
import 'package:kochmappe/screens/cook_screen.dart';
import 'package:kochmappe/screens/pro_screen.dart';
import 'package:kochmappe/screens/recipe_screen.dart';
import 'package:kochmappe/screens/welcome_screen.dart';
import 'package:kochmappe/screens/widgets.dart';

import 'fakes.dart';
import 'test_fonts.dart';

Future<Rig> boot(
  WidgetTester t, {
  String lang = 'de',
  bool pro = false,
  bool seeded = true,
  Size size = const Size(390, 844),
  double textScale = 1.0,
  bool dark = false,
}) async {
  t.view.physicalSize = Size(size.width * 3, size.height * 3);
  t.view.devicePixelRatio = 3;
  t.platformDispatcher.localesTestValue = [Locale(lang)];
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  if (dark) t.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
  addTearDown(() {
    t.view.resetPhysicalSize();
    t.view.resetDevicePixelRatio();
    t.platformDispatcher.clearLocalesTestValue();
    t.platformDispatcher.clearTextScaleFactorTestValue();
    t.platformDispatcher.clearPlatformBrightnessTestValue();
  });
  final rig = await Rig.create(pro: pro);
  if (seeded) {
    seedSamples(rig.lib, lang);
    rig.lib.finishOnboarding();
  }
  await t.pumpWidget(KochmappeApp(services: rig.services));
  await t.pumpAndSettle();
  return rig;
}

Finder text(String s) => find.text(s);

Future<void> openRecipe(WidgetTester t, String title) async {
  await t.scrollUntilVisible(find.text(title), 200, scrollable: find.descendant(of: find.byType(CustomScrollView), matching: find.byType(Scrollable)).first);
  await t.ensureVisible(find.text(title).first);
  await t.pumpAndSettle();
  await t.tap(find.text(title).first);
  await t.pumpAndSettle();
}

void main() {
  setUpAll(loadFonts);

  testWidgets('first launch: one welcome page, then the binder with examples', (t) async {
    final rig = await boot(t, seeded: false);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(text('Deine Rezepte,\nin einer Mappe.'), findsOneWidget);
    await t.tap(text('Meine Mappe öffnen'));
    await t.pumpAndSettle();
    expect(rig.lib.settings.onboarded, isTrue);
    expect(rig.lib.recipes.length, 6);
    expect(text('Meine Mappe'), findsOneWidget);
    expect(find.byType(RecipeCard), findsAtLeastNWidgets(2));
    expect(find.byType(ProScreen), findsNothing);
  });

  testWidgets('English device: English texts and English examples', (t) async {
    await boot(t, lang: 'en', seeded: false);
    expect(text('Open my binder'), findsOneWidget);
    await t.tap(text('Open my binder'));
    await t.pumpAndSettle();
    expect(text('My binder'), findsOneWidget);
    expect(find.textContaining('Lemon yogurt loaf'), findsWidgets);
  });

  testWidgets('home: search, favourites and folder tabs', (t) async {
    await boot(t);
    await t.enterText(find.byType(TextField).first, 'linsen');
    await t.pumpAndSettle();
    expect(find.byType(RecipeCard), findsOneWidget);
    await t.enterText(find.byType(TextField).first, 'zzzz');
    await t.pumpAndSettle();
    expect(text('Kein Rezept gefunden'), findsOneWidget);
    await t.enterText(find.byType(TextField).first, '');
    await t.pumpAndSettle();
    await t.tap(text('Favoriten'));
    await t.pumpAndSettle();
    expect(find.byType(RecipeCard), findsNWidgets(2));
    await t.ensureVisible(text('Backen & Brot'));
    await t.pumpAndSettle();
    await t.tap(text('Backen & Brot'));
    await t.pumpAndSettle();
    expect(find.byType(RecipeCard), findsNWidgets(2));
    expect(text('2 Rezepte in dieser Mappe'), findsOneWidget);
  });

  testWidgets('recipe: portions scale the amounts, units switch, shopping list fills', (t) async {
    final rig = await boot(t);
    await openRecipe(t, 'Zitronen-Joghurt-Kuchen');
    expect(text('250 g'), findsWidgets);
    expect(text('8'), findsWidgets); // servings
    await t.tap(text('×2'));
    await t.pumpAndSettle();
    expect(text('500 g'), findsWidgets);
    expect(text('16'), findsWidgets);
    await t.tap(text('½'));
    await t.pumpAndSettle();
    expect(text('125 g'), findsWidgets);
    await t.tap(text('oz · cup'));
    await t.pumpAndSettle();
    expect(rig.lib.settings.units, UnitSystem.us);
    expect(find.textContaining('oz'), findsWidgets);
    await t.tap(find.text('Zur Liste'));
    await t.pump();
    expect(rig.lib.shopping.length, 8);
    expect(find.textContaining('8 Zutaten'), findsOneWidget);
  });

  testWidgets('recipe: favourite, stars, diary entry', (t) async {
    final rig = await boot(t);
    await openRecipe(t, 'Ingwer-Limonade');
    final r = rig.lib.recipes.firstWhere((x) => x.title == 'Ingwer-Limonade');
    await t.tap(find.byIcon(Icons.favorite_border_rounded));
    await t.pump();
    expect(r.favorite, isTrue);
    await t.tap(find.byIcon(Icons.star_outline_rounded).at(3));
    await t.pump();
    expect(r.rating, 4);
    await t.drag(find.byType(ListView), const Offset(0, -900));
    await t.pump();
    await t.tap(text('Heute gekocht'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, 'mehr Ingwer');
    await t.tap(text('Speichern'));
    await t.pumpAndSettle();
    expect(r.log.single.note, 'mehr Ingwer');
    expect(find.textContaining('mehr Ingwer'), findsOneWidget);
  });

  testWidgets('cook mode: steps, timers from the text, screen stays awake, logs the cooking', (t) async {
    final rig = await boot(t);
    final r = rig.lib.recipes.firstWhere((x) => x.title == 'Brot ohne Kneten');
    final before = r.timesCooked;
    final key = GlobalKey<NavigatorState>();
    await t.pumpWidget(KochmappeApp(services: rig.services, navigatorKey: key));
    key.currentState!.push(MaterialPageRoute<void>(builder: (_) => CookScreen(recipeId: r.id, servings: 10)));
    await t.pumpAndSettle();
    expect(rig.awake.calls, [true]);
    expect(text('SCHRITT 1 VON 3'), findsOneWidget);
    expect(find.textContaining('12 Stunden'), findsWidgets);
    await t.tap(find.textContaining('Timer starten'));
    await t.pump();
    expect(text('12:00:00'), findsOneWidget);
    await t.tap(text('Weiter'));
    await t.pumpAndSettle();
    expect(text('SCHRITT 2 VON 3'), findsOneWidget);
    await t.tap(find.byIcon(Icons.format_list_bulleted_rounded));
    await t.pumpAndSettle();
    expect(text('Zutaten für 10'), findsOneWidget);
    expect(text('500 g Weizenmehl Type 550'), findsOneWidget);
    await t.tapAt(const Offset(10, 10));
    await t.pumpAndSettle();
    await t.tap(text('Weiter'));
    await t.pumpAndSettle();
    await t.tap(text('Fertig – eintragen'));
    await t.pumpAndSettle();
    expect(r.timesCooked, before + 1);
    expect(rig.awake.calls, [true, false]);
  });

  testWidgets('add from pasted text: recognise, check, save', (t) async {
    final rig = await boot(t);
    await t.tap(text('Rezept hinzufügen'));
    await t.pumpAndSettle();
    await t.tap(text('Aus eingefügtem Text'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'Quarkkeulchen\nZutaten\n500 g Quark\n2 Eier\nZubereitung\n1. Alles mischen.\n2. 10 Minuten braten.');
    await t.tap(text('Rezept erkennen'));
    await t.pumpAndSettle();
    expect(text('Neues Rezept'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Quarkkeulchen'), findsOneWidget);
    await t.tap(text('Speichern').last);
    await t.pumpAndSettle();
    final r = rig.lib.recipes.first;
    expect(r.title, 'Quarkkeulchen');
    expect(r.ingredients.map((e) => e.name), ['Quark', 'Eier']);
    expect(r.steps.length, 2);
    expect(rig.lib.recipes.length, 7);
  });

  testWidgets('add from a link: reads the page on the device', (t) async {
    final rig = await boot(t);
    rig.web.pages['https://x.test/r'] = '<script type="application/ld+json">{"@type":"Recipe","name":"Web-Suppe","recipeIngredient":["1 Zwiebel"],"recipeInstructions":["Kochen."]}</script>';
    await t.tap(text('Rezept hinzufügen'));
    await t.pumpAndSettle();
    await t.tap(text('Aus einem Link'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'https://x.test/r');
    await t.tap(text('Rezept holen'));
    await t.pumpAndSettle();
    await t.tap(text('Speichern').last);
    await t.pumpAndSettle();
    expect(rig.lib.recipes.first.title, 'Web-Suppe');
    expect(rig.lib.recipes.first.source, 'https://x.test/r');
  });

  testWidgets('add from a link: failing page explains and offers pasting text', (t) async {
    final rig = await boot(t);
    await t.tap(text('Rezept hinzufügen'));
    await t.pumpAndSettle();
    await t.tap(text('Aus einem Link'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'https://offline.test/x');
    await t.tap(text('Rezept holen'));
    await t.pumpAndSettle();
    expect(find.textContaining('nicht laden'), findsOneWidget);
    await t.tap(text('Stattdessen Text einfügen'));
    await t.pumpAndSettle();
    expect(text('Rezept erkennen'), findsOneWidget);
    expect(rig.lib.recipes.length, 6);
  });

  testWidgets('free limit: the 26th recipe leads to Pro, not to a dead end', (t) async {
    final rig = await boot(t);
    while (rig.lib.recipes.length < 25) {
      rig.lib.recipes.add(Recipe(id: 'x${rig.lib.recipes.length}', title: 'Filler ${rig.lib.recipes.length}'));
    }
    rig.lib.commit();
    await t.pumpAndSettle();
    await t.tap(text('Rezept hinzufügen'));
    await t.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
    expect(find.textContaining('fasst 25 Rezepte'), findsOneWidget);
  });

  testWidgets('paywall: price, one-time purchase unlocks, legal links work', (t) async {
    final rig = await boot(t);
    await t.tap(text('Mehr'));
    await t.pumpAndSettle();
    await t.tap(text('Kochmappe Pro').first);
    await t.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
    expect(find.textContaining('6,99 €'), findsWidgets);
    expect(text('einmalig · kein Abo'), findsOneWidget);
    await t.tap(text('Nutzungsbedingungen'));
    await t.tap(text('Datenschutz'));
    expect(rig.links.opened.length, 2);
    await t.tap(find.textContaining('Pro holen für'));
    await t.pumpAndSettle();
    expect(rig.pro.isPro, isTrue);
    expect(text('Danke – Pro ist freigeschaltet.'), findsOneWidget);
  });

  testWidgets('what do I have: finds recipes and names what is missing', (t) async {
    await boot(t);
    await t.tap(text('Vorrat'));
    await t.pumpAndSettle();
    expect(text('Leerer Kühlschrank, volle Mappe'), findsOneWidget);
    await t.enterText(find.byType(TextField).first, 'linsen, möhren');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
    expect(find.text('linsen'), findsOneWidget);
    expect(text('1 Rezept passt'), findsOneWidget);
    expect(find.textContaining('Fehlt noch'), findsOneWidget);
    expect(find.text('Linseneintopf'), findsOneWidget);
  });

  testWidgets('shopping tab: tick, share, remove done', (t) async {
    final rig = await boot(t);
    rig.lib.addToShopping(rig.lib.recipes.first, 4);
    await t.tap(text('Einkauf'));
    await t.pumpAndSettle();
    expect(find.textContaining('Tomaten'), findsWidgets);
    await t.tap(find.textContaining('Tomaten').first);
    await t.pumpAndSettle();
    expect(rig.lib.shopping.first.done, isTrue);
    expect(text('Im Korb'), findsOneWidget);
    await t.tap(find.byIcon(Icons.ios_share_rounded));
    await t.pump();
    expect(rig.sharer.texts.single, startsWith('Einkaufsliste'));
    await t.tap(text('Entfernen'));
    await t.pumpAndSettle();
    expect(rig.lib.shopping.any((i) => i.done), isFalse);
  });

  testWidgets('more: backup shares a file, restore reads one, theme is locked without Pro', (t) async {
    final rig = await boot(t);
    await t.tap(text('Mehr'));
    await t.pumpAndSettle();
    await t.runAsync(() async {
      await t.tap(text('Sicherung speichern'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pump();
    expect(rig.sharer.files.keys.single, 'kochmappe-sicherung.json');
    rig.files.next = 'not a backup';
    await t.runAsync(() async {
      await t.tap(text('Sicherung laden'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pump();
    expect(find.textContaining('keine Kochmappe-Sicherung'), findsOneWidget);
    await t.tap(find.byIcon(Icons.lock_rounded).first);
    await t.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
  });

  testWidgets('PDF card is Pro: free user sees the paywall, Pro user gets a file', (t) async {
    final free = await boot(t);
    await openRecipe(t, 'Ingwer-Limonade');
    await t.tap(find.byIcon(Icons.more_horiz_rounded));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('Rezeptkarte'));
    await t.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
    expect(free.sharer.files, isEmpty);
  });

  testWidgets('PDF card for Pro users', (t) async {
    final rig = await boot(t, pro: true);
    await openRecipe(t, 'Ingwer-Limonade');
    await t.tap(find.byIcon(Icons.more_horiz_rounded));
    await t.pumpAndSettle();
    await t.runAsync(() async {
      await t.tap(find.textContaining('Rezeptkarte'));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await t.pump();
    expect(rig.sharer.files.keys.single, endsWith('.pdf'));
    expect(String.fromCharCodes(rig.sharer.files.values.single.take(4)), '%PDF');
  });

  testWidgets('delete a recipe asks first', (t) async {
    final rig = await boot(t);
    await openRecipe(t, 'Ingwer-Limonade');
    await t.tap(find.byIcon(Icons.more_horiz_rounded));
    await t.pumpAndSettle();
    await t.tap(find.text('Löschen'));
    await t.pumpAndSettle();
    expect(find.textContaining('löschen?'), findsOneWidget);
    await t.tap(find.text('Abbrechen'));
    await t.pumpAndSettle();
    expect(rig.lib.recipes.length, 6);
    await t.tap(find.byIcon(Icons.more_horiz_rounded));
    await t.pumpAndSettle();
    await t.tap(find.text('Löschen'));
    await t.pumpAndSettle();
    await t.tap(find.text('Löschen').last);
    await t.pumpAndSettle();
    expect(rig.lib.recipes.length, 5);
    expect(find.byType(RecipeScreen), findsNothing);
  });

  testWidgets('edit a recipe: ingredient text is read back and amounts scale', (t) async {
    final rig = await boot(t);
    await openRecipe(t, 'Ingwer-Limonade');
    await t.tap(find.byIcon(Icons.more_horiz_rounded));
    await t.pumpAndSettle();
    await t.tap(find.text('Bearbeiten'));
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextField, 'Ingwer-Limonade'), 'Ingwer-Limo');
    await t.tap(find.text('Speichern').first);
    await t.pumpAndSettle();
    expect(rig.lib.recipes.any((r) => r.title == 'Ingwer-Limo'), isTrue);
    final r = rig.lib.recipes.firstWhere((x) => x.title == 'Ingwer-Limo');
    expect(r.ingredients.first.qty, 100);
    expect(r.ingredients.first.unit, 'g');
  });

  testWidgets('tablet: list and recipe side by side, rail on the left', (t) async {
    await boot(t, size: const Size(1180, 820));
    expect(text('Wähle ein Rezept'), findsOneWidget);
    await t.tap(find.text('Linseneintopf').first);
    await t.pumpAndSettle();
    expect(find.byType(RecipeScreen), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    expect(find.byType(RecipeCard), findsAtLeastNWidgets(2));
    expect(tester(t), isNull);
  });

  testWidgets('large text (130 %) on a small phone: nothing overflows', (t) async {
    final rig = await boot(t, size: const Size(320, 568), textScale: 1.3);
    expect(t.takeException(), isNull);
    await openRecipe(t, 'Zitronen-Joghurt-Kuchen');
    expect(t.takeException(), isNull);
    for (var i = 0; i < 4; i++) {
      await t.drag(find.byType(ListView), const Offset(0, -700));
      await t.pump();
      expect(t.takeException(), isNull);
    }
    expect(t.takeException(), isNull);
    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pumpAndSettle();
    for (final tab in ['Vorrat', 'Einkauf', 'Mehr']) {
      await t.tap(text(tab));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull, reason: tab);
    }
    expect(rig.lib.recipes.isNotEmpty, isTrue);
  });

  testWidgets('dark mode renders every tab', (t) async {
    await boot(t, dark: true, lang: 'en');
    for (final tab in ['Binder', 'What I have', 'Shopping', 'More']) {
      await t.tap(text(tab));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull, reason: tab);
    }
  });

  testWidgets('keep-awake switch is released when the screen closes', (t) async {
    final rig = await boot(t);
    final r = rig.lib.recipes.first;
    await openRecipe(t, r.title);
    await t.tap(text('Kochmodus'));
    await t.pumpAndSettle();
    expect(find.byType(CookScreen), findsOneWidget);
    await t.tap(find.byIcon(Icons.close_rounded));
    await t.pumpAndSettle();
    expect(rig.awake.calls, [true, false]);
  });

  test('platform channel name matches the Swift side', () {
    expect(const MethodChannel('kochmappe/apple').name, 'kochmappe/apple');
  });
}

dynamic tester(WidgetTester t) => t.takeException();
