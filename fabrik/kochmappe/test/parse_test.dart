import 'package:flutter_test/flutter_test.dart';
import 'package:kochmappe/models.dart';
import 'package:kochmappe/parse.dart';
import 'package:kochmappe/scale.dart';

void main() {
  group('parseIngredient', () {
    test('amount, unit, name', () {
      final i = parseIngredient('2 EL Olivenöl');
      expect((i.qty, i.unit, i.name), (2.0, 'tbsp', 'Olivenöl'));
    });
    test('fractions and notes', () {
      final i = parseIngredient('1 1/2 cups flour, sifted');
      expect((i.qty, i.unit, i.name, i.note), (1.5, 'cup', 'flour', 'sifted'));
      expect(parseIngredient('½ Zwiebel').qty, 0.5);
      expect(parseIngredient('1½ TL Salz').qty, 1.5);
    });
    test('decimal comma and ranges', () {
      expect(parseIngredient('2,5 kg Kartoffeln').qty, 2.5);
      expect(parseIngredient('2-3 Zwiebeln').qty, 3.0);
    });
    test('no amount', () {
      final i = parseIngredient('Salz');
      expect(i.qty, isNull);
      expect(i.name, 'Salz');
    });
    test('bullet and parentheses', () {
      final i = parseIngredient('• 400 g Tomaten (aus der Dose)');
      expect((i.qty, i.unit, i.name, i.note), (400.0, 'g', 'Tomaten', 'aus der Dose'));
    });
    test('a word that only looks like a unit stays in the name', () {
      final i = parseIngredient('3 Gurken');
      expect(i.unit, '');
      expect(i.name, 'Gurken');
    });
    test('can: "1 can tomatoes"', () {
      final i = parseIngredient('1 can chopped tomatoes');
      expect((i.unit, i.name), ('can', 'chopped tomatoes'));
    });
  });

  group('time', () {
    test('ISO durations', () {
      expect(parseIsoMinutes('PT1H30M'), 90);
      expect(parseIsoMinutes('PT45M'), 45);
      expect(parseIsoMinutes('P0DT0H20M'), 20);
      expect(parseIsoMinutes(null), 0);
      expect(parseIsoMinutes('bad'), 0);
    });
    test('timers in steps', () {
      final t = timersIn('Bake 20-25 minutes, then rest for 1 hour.');
      expect(t.map((e) => e.seconds), [25 * 60, 3600]);
      expect(timersIn('Das Blech 35 Minuten backen.').single.seconds, 35 * 60);
      expect(timersIn('12 Stunden gehen lassen').single.seconds, 12 * 3600);
      expect(timersIn('Mix 2 eggs'), isEmpty);
      expect(timersIn('Add 200 g flour'), isEmpty);
    });
  });

  group('web pages', () {
    const page = '''
<html><head><title>Cake &amp; more</title>
<script type="application/ld+json">{"@context":"https://schema.org","@graph":[{"@type":"WebSite","name":"x"},
{"@type":"Recipe","name":"Lemon Cake","recipeYield":["8","8 servings"],"prepTime":"PT15M","cookTime":"PT40M",
"image":{"@type":"ImageObject","url":"/img/cake.jpg"},"recipeCategory":"Dessert","recipeCuisine":["Italian"],
"recipeIngredient":["250 g flour","2 eggs","1 pinch salt"],
"recipeInstructions":[{"@type":"HowToSection","itemListElement":[{"@type":"HowToStep","text":"Mix everything."}]},{"@type":"HowToStep","text":"Bake 40 minutes &amp; cool."}]}]}</script>
</head><body></body></html>''';

    test('reads JSON-LD recipe from a graph', () {
      final r = recipeFromHtml(page)!;
      expect(r.title, 'Lemon Cake');
      expect(r.servings, 8);
      expect((r.prepMin, r.cookMin), (15, 40));
      expect(r.ingredients.map((e) => e.name), ['flour', 'eggs', 'salt']);
      expect(r.steps, ['Mix everything.', 'Bake 40 minutes & cool.']);
      expect(r.tags, ['Dessert', 'Italian']);
      expect(r.imageUrl, '/img/cake.jpg');
    });
    test('steps as one string with line breaks', () {
      final r = recipeFromHtml('<script type="application/ld+json">{"@type":"Recipe","name":"A","recipeIngredient":["1 egg"],"recipeInstructions":"One\\nTwo"}</script>')!;
      expect(r.steps, ['One', 'Two']);
    });
    test('page without a recipe', () {
      expect(recipeFromHtml(page.replaceAll('Recipe', 'Article')), isNull);
      expect(recipeFromHtml('<html></html>'), isNull);
      expect(titleFromHtml(page), 'Cake & more');
    });
    test('broken JSON is skipped, the next block is used', () {
      final r = recipeFromHtml('<script type="application/ld+json">{oops</script>$page');
      expect(r?.title, 'Lemon Cake');
    });
  });

  group('pasted text', () {
    test('with headings (de)', () {
      final p = parseRecipeText('Omas Pflaumenkuchen\nFür 6 Personen\nZutaten\n300 g Mehl\n2 Eier\nTeig:\n100 g Butter\nZubereitung\n1. Alles verrühren.\n2. 40 Minuten backen.');
      expect(p.title, 'Omas Pflaumenkuchen');
      expect(p.servings, 6);
      expect(p.ingredients.map((e) => e.name), ['Mehl', 'Eier', 'Butter']);
      expect(p.ingredients.last.group, 'Teig');
      expect(p.steps, ['Alles verrühren.', '40 Minuten backen.']);
    });
    test('without headings: amounts are ingredients, long lines are steps', () {
      final p = parseRecipeText('Quick pasta\n200 g pasta\n1 jar sauce\nBoil the pasta in salted water until it is just tender, then drain it and stir in the sauce.');
      expect(p.title, 'Quick pasta');
      expect(p.ingredients.length, 2);
      expect(p.steps.length, 1);
      expect(p.usable, isTrue);
    });
    test('empty text is not usable', () {
      expect(parseRecipeText('   \n ').usable, isFalse);
    });
  });

  group('scaling', () {
    const l = 'en';
    test('quantities double', () {
      final i = parseIngredient('200 g flour');
      expect(ingText(i, 2, UnitSystem.metric, l), '400 g flour');
      expect(ingText(i, 5, UnitSystem.metric, l), '1 kg flour');
    });
    test('fractions for spoons and cups', () {
      final i = parseIngredient('1 tbsp oil');
      expect(ingText(i, 1.5, UnitSystem.metric, l), '1½ tbsp oil');
      expect(ingText(parseIngredient('1 tsp salt'), 0.25, UnitSystem.metric, l), '¼ tsp salt');
    });
    test('metric to US and back', () {
      final g = parseIngredient('250 g sugar');
      expect(ingText(g, 1, UnitSystem.us, l), '8.8 oz sugar');
      final c = parseIngredient('2 cups milk');
      expect(ingText(c, 1, UnitSystem.metric, l), '480 ml milk');
      expect(ingText(parseIngredient('500 ml water'), 1, UnitSystem.us, l), '2⅛ cups water');
    });
    test('german labels and decimal comma', () {
      final i = parseIngredient('1,5 EL Honig');
      expect(ingText(i, 1, UnitSystem.metric, 'de'), '1½ EL Honig');
      expect(ingText(parseIngredient('125 g Butter'), 1.1, UnitSystem.metric, 'de'), '140 g Butter');
      expect(formatQty(2.5, 'de'), '2,5');
    });
    test('lines without amount stay as they are', () {
      expect(ingText(parseIngredient('Salz, nach Geschmack'), 3, UnitSystem.metric, 'de'), 'Salz, nach Geschmack');
    });
    test('editor text reads back the same', () {
      for (final line in ['2 EL Olivenöl', '1½ Tassen Mehl, gesiebt', '250 g Zucker', 'Salz', '3 Zehen Knoblauch']) {
        final i = parseIngredient(line);
        final back = parseIngredient(ingSource(i, 'de'));
        expect((back.qty, back.unit, back.name, back.note), (i.qty, i.unit, i.name, i.note), reason: line);
      }
    });
    test('minutes text', () {
      expect(minutesText(45, 'en'), '45 min');
      expect(minutesText(80, 'en'), '1 h 20 min');
      expect(minutesText(120, 'en'), '2 h');
      expect(minutesText(0, 'en'), '');
    });
  });
}
