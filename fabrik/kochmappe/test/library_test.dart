import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kochmappe/importer.dart';
import 'package:kochmappe/library.dart';
import 'package:kochmappe/models.dart';
import 'package:kochmappe/parse.dart';
import 'package:kochmappe/pro.dart';
import 'package:kochmappe/samples.dart';
import 'package:kochmappe/timers.dart';

import 'fakes.dart';

Recipe make(Library lib, String title, List<String> ings, {List<String> steps = const ['Cook.'], int servings = 4}) {
  final r = lib.blank(title: title)
    ..ingredients = [for (final i in ings) parseIngredient(i)]
    ..steps = steps
    ..servings = servings;
  expect(lib.add(r), isTrue);
  return r;
}

void main() {
  group('recipes and limits', () {
    test('free binder holds 25 recipes, then asks for Pro', () async {
      final rig = await Rig.create();
      for (var i = 0; i < freeRecipes; i++) {
        make(rig.lib, 'R$i', ['1 egg']);
      }
      expect(rig.lib.canAddRecipe, isFalse);
      expect(rig.lib.add(rig.lib.blank(title: 'one more')), isFalse);
      expect(rig.lib.recipes.length, 25);
    });

    test('Pro has no limit', () async {
      final rig = await Rig.create(pro: true);
      for (var i = 0; i < 30; i++) {
        make(rig.lib, 'R$i', ['1 egg']);
      }
      expect(rig.lib.recipes.length, 30);
    });

    test('free: 3 folders, the 4th is refused', () async {
      final rig = await Rig.create();
      for (final n in ['a', 'b', 'c']) {
        expect(rig.lib.addFolder(n), isNotNull);
      }
      expect(rig.lib.addFolder('d'), isNull);
      expect(rig.lib.addFolder('  '), isNull);
    });

    test('everything survives a restart', () async {
      final rig = await Rig.create();
      final r = make(rig.lib, 'Soup', ['2 EL Öl', 'Salz']);
      final f = rig.lib.addFolder('Winter')!;
      rig.lib.setInFolder(r, f, true);
      rig.lib.logCooked(r, note: 'good');
      rig.lib.rate(r, 4);
      rig.lib.setUnits(UnitSystem.us);
      final again = Library(rig.prefs, rig.pro);
      expect(again.recipes.single.title, 'Soup');
      expect(again.recipes.single.ingredients.first.unit, 'tbsp');
      expect(again.recipes.single.folders, [f.id]);
      expect(again.recipes.single.log.single.note, 'good');
      expect(again.recipes.single.rating, 4);
      expect(again.settings.units, UnitSystem.us);
    });

    test('a damaged save does not stop the app', () async {
      final rig = await Rig.create(prefs: {'recipes': '{not json'});
      expect(rig.lib.recipes, isEmpty);
    });

    test('rating the same star twice clears it; favourite toggles', () async {
      final rig = await Rig.create();
      final r = make(rig.lib, 'A', ['1 egg']);
      rig.lib.rate(r, 3);
      rig.lib.rate(r, 3);
      expect(r.rating, 0);
      rig.lib.toggleFavorite(r);
      expect(r.favorite, isTrue);
    });

    test('deleting a folder removes it from the recipes, not the recipes', () async {
      final rig = await Rig.create();
      final r = make(rig.lib, 'A', ['1 egg']);
      final f = rig.lib.addFolder('X')!;
      rig.lib.setInFolder(r, f, true);
      rig.lib.removeFolder(f);
      expect(r.folders, isEmpty);
      expect(rig.lib.recipes.length, 1);
    });

    test('cooking diary counts and finds the last day', () async {
      final rig = await Rig.create();
      final r = make(rig.lib, 'A', ['1 egg']);
      rig.lib.logCooked(r);
      rig.lib.logCooked(r, note: 'again');
      expect(r.timesCooked, 2);
      expect(r.lastCooked, Rig.today);
    });

    test('theme is Pro only', () async {
      final free = await Rig.create();
      free.lib.setTheme(2);
      expect(free.lib.settings.theme, 0);
      final pro = await Rig.create(pro: true);
      pro.lib.setTheme(2);
      expect(pro.lib.settings.theme, 2);
    });

    test('delete all clears everything', () async {
      final rig = await Rig.create();
      seedSamples(rig.lib, 'en');
      expect(rig.lib.recipes.length, 6);
      await rig.lib.deleteAll();
      expect(rig.lib.recipes, isEmpty);
      expect(rig.lib.folders, isEmpty);
    });
  });

  group('search', () {
    test('words must all hit title, ingredient, tag or note; umlauts are forgiving', () async {
      final rig = await Rig.create();
      make(rig.lib, 'Gemüsesuppe', ['2 Möhren', '1 Zwiebel']);
      make(rig.lib, 'Pancakes', ['200 g flour', '2 eggs']).tags = ['Frühstück'];
      expect(rig.lib.search('suppe').map((r) => r.title), ['Gemüsesuppe']);
      expect(rig.lib.search('mohren').map((r) => r.title), ['Gemüsesuppe']);
      expect(rig.lib.search('fruhstuck').single.title, 'Pancakes');
      expect(rig.lib.search('flour eggs').single.title, 'Pancakes');
      expect(rig.lib.search('flour carrot'), isEmpty);
      expect(rig.lib.search('').length, 2);
    });

    test('filter by folder, favourites and time', () async {
      final rig = await Rig.create();
      final a = make(rig.lib, 'A', ['1 egg'])..cookMin = 20;
      final b = make(rig.lib, 'B', ['1 egg'])..cookMin = 90;
      final f = rig.lib.addFolder('F')!;
      rig.lib.setInFolder(a, f, true);
      rig.lib.toggleFavorite(b);
      expect(rig.lib.search('', folderId: f.id).single, a);
      expect(rig.lib.search('', favorites: true).single, b);
      expect(rig.lib.search('', maxMinutes: 30).single, a);
    });

    test('"what do I have" ranks by hits and lists what is missing, ignoring staples', () async {
      final rig = await Rig.create();
      make(rig.lib, 'Spinach omelette', ['3 eggs', '100 g spinach', '1 pinch salt', '30 g cheese']);
      make(rig.lib, 'Boiled egg', ['1 egg', 'Salt']);
      make(rig.lib, 'Cake', ['200 g flour', '3 eggs', '100 g sugar']);
      final m = rig.lib.byIngredients(['eggs', 'spinach']);
      expect(m.first.recipe.title, 'Spinach omelette');
      expect(m.first.have.length, 2);
      expect(m.first.missing, ['cheese']);
      expect(m.map((e) => e.recipe.title), isNot(contains('Nonexistent')));
      expect(rig.lib.byIngredients(['x']), isEmpty);
      expect(rig.lib.byIngredients(['zucchini']), isEmpty);
    });
  });

  group('shopping list', () {
    test('adds up equal items, scaled to the portions', () async {
      final rig = await Rig.create();
      final a = make(rig.lib, 'A', ['200 g flour', '2 eggs'], servings: 2);
      final b = make(rig.lib, 'B', ['100 g Flour', '1 onion'], servings: 4);
      rig.lib.addToShopping(a, 4); // double
      rig.lib.addToShopping(b, 4);
      final flour = rig.lib.shopping.firstWhere((i) => i.name.toLowerCase() == 'flour');
      expect(flour.qty, 500);
      expect(flour.from, 'A, B');
      expect(rig.lib.shopping.firstWhere((i) => i.name == 'eggs').qty, 4);
      expect(rig.lib.shopping.length, 3);
    });

    test('different units are not mixed; done items are not added to', () async {
      final rig = await Rig.create();
      final a = make(rig.lib, 'A', ['1 tbsp sugar', '100 g sugar']);
      rig.lib.addToShopping(a, 4);
      expect(rig.lib.shopping.length, 2);
      rig.lib.toggleShop(rig.lib.shopping.first);
      rig.lib.addToShopping(a, 4);
      expect(rig.lib.shopping.length, 3);
    });

    test('text, clearing and manual items', () async {
      final rig = await Rig.create();
      rig.lib.addShopText(' milk ');
      rig.lib.addShopText('   ');
      rig.lib.addToShopping(make(rig.lib, 'A', ['2 EL Öl']), 4);
      expect(rig.lib.shopping.length, 2);
      rig.lib.toggleShop(rig.lib.shopping.first);
      expect(rig.lib.shoppingText('Einkauf', 'de'), 'Einkauf\n• 2 EL Öl');
      rig.lib.clearDone();
      expect(rig.lib.shopping.length, 1);
      rig.lib.clearShopping();
      expect(rig.lib.shopping, isEmpty);
    });

    test('US units on the list when the user chose them', () async {
      final rig = await Rig.create();
      rig.lib.setUnits(UnitSystem.us);
      rig.lib.addToShopping(make(rig.lib, 'A', ['250 g sugar']), 4);
      expect(rig.lib.shopping.single.unit, 'oz');
    });
  });

  group('backup', () {
    test('export and restore into a fresh app, with photos; restoring twice adds nothing', () async {
      final a = await Rig.create();
      final r = make(a.lib, 'Soup', ['2 tbsp oil']);
      r.photo = await a.lib.photos.save(Uint8List.fromList([1, 2, 3, 4]));
      r.twist = 'more garlic';
      a.lib.addFolder('Winter');
      final text = await a.lib.exportBackup();

      final b = await Rig.create();
      expect(await b.lib.importBackup(text), 1);
      expect(b.lib.recipes.single.title, 'Soup');
      expect(b.lib.recipes.single.twist, 'more garlic');
      expect(await b.lib.photos.load(b.lib.recipes.single.photo), Uint8List.fromList([1, 2, 3, 4]));
      expect(b.lib.folders.single.name, 'Winter');
      expect(await b.lib.importBackup(text), 0);
      expect(b.lib.recipes.length, 1);
    });

    test('not a backup', () async {
      final rig = await Rig.create();
      expect(await rig.lib.importBackup('hello'), -1);
      expect(await rig.lib.importBackup('{"app":"other"}'), -1);
    });
  });

  group('samples', () {
    test('both languages seed six recipes, two folders and rich data', () async {
      for (final lang in ['de', 'en']) {
        final rig = await Rig.create();
        seedSamples(rig.lib, lang);
        expect(rig.lib.recipes.length, 6);
        expect(rig.lib.folders.length, 2);
        expect(rig.lib.recipes.every((r) => r.ingredients.isNotEmpty && r.steps.isNotEmpty), isTrue);
        expect(rig.lib.recipes.any((r) => r.favorite), isTrue);
        expect(rig.lib.recipes.any((r) => timersIn(r.steps.join(' ')).isNotEmpty), isTrue);
        seedSamples(rig.lib, lang); // second call does nothing
        expect(rig.lib.recipes.length, 6);
      }
    });
  });

  group('importer', () {
    const html = '<script type="application/ld+json">{"@type":"Recipe","name":"Pasta","recipeYield":"2","image":"https://x.test/p.jpg","recipeIngredient":["200 g pasta"],"recipeInstructions":["Boil 10 minutes."]}</script>';

    test('link from a page, with the photo kept on the device', () async {
      final rig = await Rig.create();
      rig.web.pages['https://x.test/pasta'] = html;
      rig.web.images['https://x.test/p.jpg'] = Uint8List(2000);
      final out = await rig.services.importer.fromLink('Look: https://x.test/pasta.');
      expect(out.error, isNull);
      expect(out.recipe!.title, 'Pasta');
      expect(out.recipe!.servings, 2);
      expect(out.recipe!.source, 'https://x.test/pasta');
      rig.lib.add(out.recipe!);
      await rig.services.importer.attachPhoto(out.recipe!, out.imageUrl);
      expect(out.recipe!.photo, isNotEmpty);
      expect(await rig.lib.photos.load(out.recipe!.photo), isNotNull);
    });

    test('errors are told apart', () async {
      final rig = await Rig.create();
      rig.web.pages['https://x.test/none'] = '<html><title>Blog</title></html>';
      expect((await rig.services.importer.fromLink('hello')).error, ImportError.badLink);
      expect((await rig.services.importer.fromLink('https://offline.test/a')).error, ImportError.network);
      final none = await rig.services.importer.fromLink('https://x.test/none');
      expect(none.error, ImportError.noRecipe);
      expect(none.pageTitle, 'Blog');
      expect(rig.services.importer.fromText('   ').error, ImportError.noRecipe);
    });

    test('links: www and trailing punctuation', () {
      expect(Importer.linkFrom('www.example.com/rezept.')?.toString(), 'https://www.example.com/rezept');
      expect(Importer.linkFrom('no link here'), isNull);
      expect(Importer.linkFrom('http://localhost/x'), isNull);
    });

    test('a failing image never breaks the saved recipe', () async {
      final rig = await Rig.create();
      final r = make(rig.lib, 'A', ['1 egg']);
      await rig.services.importer.attachPhoto(r, 'https://nowhere.test/x.jpg');
      expect(r.photo, '');
    });
  });

  group('pro', () {
    test('purchase unlocks and is remembered; restore works; store down keeps the cache', () async {
      final rig = await Rig.create();
      expect(rig.pro.isPro, isFalse);
      expect(rig.pro.lifetimePrice, '6,99 €');
      await rig.pro.buy(proLifetimeId);
      expect(rig.pro.isPro, isTrue);
      final again = Pro(rig.prefs, FakeProBackend()..storeDown = true);
      await again.start();
      expect(again.isPro, isTrue);
      expect(again.lifetimePrice, '6,99 €'); // fallback text
    });

    test('cancelled, pending and failed purchases', () async {
      final rig = await Rig.create();
      rig.backend.next = PurchaseResult.cancelled;
      await rig.pro.buy(proLifetimeId);
      expect((rig.pro.isPro, rig.pro.state), (false, ProState.idle));
      rig.backend.next = PurchaseResult.pending;
      await rig.pro.buy(proLifetimeId);
      expect(rig.pro.state, ProState.pending);
      await rig.pro.restore();
      expect(rig.pro.state, ProState.nothingToRestore);
    });
  });

  group('timers', () {
    test('run on the clock, ring once, several at a time', () {
      var now = DateTime(2026, 1, 1, 12);
      final done = <String>[];
      final t = CookTimers(clock: () => now, onDone: (x) => done.add(x.label));
      final a = t.start(60, 'a');
      t.start(120, 'b');
      expect(t.remaining(a).inSeconds, 60);
      now = now.add(const Duration(seconds: 61));
      t.tick();
      t.tick();
      expect(done, ['a']);
      expect(t.running, isTrue);
      expect(t.fraction(a), 0);
      now = now.add(const Duration(seconds: 100));
      t.tick();
      expect(done, ['a', 'b']);
      expect(t.running, isFalse);
      t.cancel(a);
      expect(t.timers.length, 1);
      expect(clockText(const Duration(seconds: 3725)), '1:02:05');
      expect(clockText(const Duration(seconds: 75)), '01:15');
    });
  });
}
