import 'library.dart';
import 'models.dart';
import 'parse.dart';

/// A few recipes of our own so the first start is not an empty page. Written for this app.
class _S {
  const _S(this.id, this.title, this.servings, this.prep, this.cook, this.motif, this.hue, this.tags, this.ings, this.steps, {this.fav = false, this.stars = 0, this.cooked = 0, this.twist = '', this.folder = -1});
  final String id;
  final String title;
  final int servings, prep, cook, motif, hue, stars, cooked, folder;
  final List<String> tags, ings, steps;
  final bool fav;
  final String twist;
}

const _de = [
  _S('s1', 'Ofentomaten-Suppe mit Basilikum', 4, 10, 40, 0, 4, ['Suppe', 'Vegetarisch'], [
    '1 kg Tomaten, halbiert',
    '1 Zwiebel, grob gewürfelt',
    '4 Knoblauchzehen',
    '3 EL Olivenöl',
    '1 TL Zucker',
    '500 ml Gemüsebrühe',
    '1 Handvoll Basilikum',
    'Salz',
    'Pfeffer',
  ], [
    'Ofen auf 200 °C vorheizen. Tomaten, Zwiebel und Knoblauch auf einem Blech mit Öl, Zucker und etwas Salz mischen.',
    'Das Blech 35 Minuten backen, bis die Tomaten an den Rändern dunkel werden.',
    'Alles mit der Brühe in einen Topf geben, Basilikum zufügen und fein pürieren. 5 Minuten köcheln lassen.',
    'Mit Salz und Pfeffer abschmecken und mit einem Löffel Joghurt oder Olivenöl servieren.',
  ], fav: true, stars: 5, cooked: 3, twist: 'Mit einer Prise Chili und einem Schuss Balsamico – so mögen wir sie.', folder: 0),
  _S('s2', 'Zitronen-Joghurt-Kuchen', 8, 15, 40, 2, 0, ['Kuchen', 'Backen'], [
    '250 g Mehl',
    '200 g Zucker',
    '1 Päckchen Backpulver',
    '250 g Naturjoghurt',
    '3 Eier',
    '100 ml Rapsöl',
    '2 Zitronen, Schale und Saft',
    '1 Prise Salz',
  ], [
    'Ofen auf 180 °C vorheizen, eine Kastenform einfetten.',
    'Eier mit Zucker und Zitronenschale schaumig rühren, Joghurt und Öl unterrühren.',
    'Mehl, Backpulver und Salz mischen und kurz unterheben.',
    'Teig in die Form füllen und 40 Minuten backen. Mit Zitronensaft beträufeln, solange der Kuchen warm ist.',
  ], stars: 4, cooked: 2, folder: 1),
  _S('s3', 'Pfannen-Gnocchi mit Spinat', 2, 5, 15, 1, 2, ['Schnell', 'Vegetarisch'], [
    '500 g Gnocchi',
    '200 g Blattspinat',
    '2 EL Butter',
    '2 Knoblauchzehen',
    '100 g Frischkäse',
    '50 g Parmesan',
    'Salz',
    'Muskat',
  ], [
    'Butter in einer großen Pfanne erhitzen und die Gnocchi 8 Minuten goldbraun braten.',
    'Knoblauch und Spinat zugeben und 2 Minuten zusammenfallen lassen.',
    'Frischkäse und einen Schluck Wasser einrühren, mit Salz und Muskat würzen und mit Parmesan bestreuen.',
  ], fav: true, stars: 4, cooked: 5, folder: 0),
  _S('s4', 'Brot ohne Kneten', 10, 20, 45, 3, 4, ['Brot', 'Backen'], [
    '500 g Weizenmehl Type 550',
    '400 ml lauwarmes Wasser',
    '1 TL Salz',
    '¼ TL Trockenhefe',
  ], [
    'Alle Zutaten in einer Schüssel nur kurz mischen, abdecken und 12 Stunden bei Zimmertemperatur gehen lassen.',
    'Teig auf bemehlter Fläche falten und 30 Minuten ruhen lassen. Gleichzeitig einen Gusstopf im Ofen auf 240 °C vorheizen.',
    'Teig in den heißen Topf legen und mit Deckel 30 Minuten backen, dann ohne Deckel 15 Minuten fertig backen.',
  ], stars: 5, cooked: 2, folder: 1),
  _S('s5', 'Ingwer-Limonade', 6, 10, 10, 4, 0, ['Getränk'], [
    '100 g frischer Ingwer',
    '150 g Zucker',
    '3 Limetten, Saft',
    '1 l Sprudelwasser',
    'Eiswürfel',
  ], [
    'Ingwer in Scheiben schneiden, mit Zucker und 300 ml Wasser 10 Minuten köcheln lassen.',
    'Abkühlen lassen, absieben und mit Limettensaft mischen.',
    'Mit Eis und Sprudelwasser auffüllen.',
  ]),
  _S('s6', 'Linseneintopf', 4, 15, 35, 5, 3, ['Eintopf', 'Vegan'], [
    '250 g rote Linsen',
    '2 Möhren, gewürfelt',
    '1 Zwiebel',
    '1 EL Tomatenmark',
    '1 TL Kreuzkümmel',
    '800 ml Gemüsebrühe',
    '1 Zitrone, Saft',
  ], [
    'Zwiebel und Möhren in etwas Öl 5 Minuten anbraten, Tomatenmark und Kreuzkümmel kurz mitrösten.',
    'Linsen und Brühe zugeben und 20 Minuten leise köcheln lassen.',
    'Mit Zitronensaft, Salz und Pfeffer abschmecken.',
  ], stars: 4, cooked: 1, folder: 0),
];

const _en = [
  _S('s1', 'Oven-roasted tomato soup with basil', 4, 10, 40, 0, 4, ['Soup', 'Vegetarian'], [
    '2 lb tomatoes, halved',
    '1 onion, roughly chopped',
    '4 cloves garlic',
    '3 tbsp olive oil',
    '1 tsp sugar',
    '2 cups vegetable stock',
    '1 handful basil',
    'Salt',
    'Pepper',
  ], [
    'Heat the oven to 400°F. Toss tomatoes, onion and garlic on a tray with the oil, sugar and a little salt.',
    'Roast for 35 minutes until the edges of the tomatoes darken.',
    'Tip everything into a pot with the stock, add the basil and blend smooth. Simmer for 5 minutes.',
    'Season with salt and pepper and serve with a spoon of yogurt or a drizzle of olive oil.',
  ], fav: true, stars: 5, cooked: 3, twist: 'A pinch of chili and a splash of balsamic – the way we like it.', folder: 0),
  _S('s2', 'Lemon yogurt loaf', 8, 15, 40, 2, 0, ['Cake', 'Baking'], [
    '2 cups flour',
    '1 cup sugar',
    '2 tsp baking powder',
    '1 cup plain yogurt',
    '3 eggs',
    '½ cup vegetable oil',
    '2 lemons, zest and juice',
    '1 pinch salt',
  ], [
    'Heat the oven to 350°F and grease a loaf pan.',
    'Whisk eggs with sugar and lemon zest until fluffy, then stir in the yogurt and oil.',
    'Mix flour, baking powder and salt and fold in briefly.',
    'Pour into the pan and bake for 40 minutes. Drizzle with lemon juice while the cake is still warm.',
  ], stars: 4, cooked: 2, folder: 1),
  _S('s3', 'Skillet gnocchi with spinach', 2, 5, 15, 1, 2, ['Quick', 'Vegetarian'], [
    '1 lb gnocchi',
    '7 oz baby spinach',
    '2 tbsp butter',
    '2 cloves garlic',
    '½ cup cream cheese',
    '½ cup grated parmesan',
    'Salt',
    'Nutmeg',
  ], [
    'Melt the butter in a large skillet and fry the gnocchi for 8 minutes until golden.',
    'Add garlic and spinach and let it wilt for 2 minutes.',
    'Stir in the cream cheese and a splash of water, season with salt and nutmeg and top with parmesan.',
  ], fav: true, stars: 4, cooked: 5, folder: 0),
  _S('s4', 'No-knead bread', 10, 20, 45, 3, 4, ['Bread', 'Baking'], [
    '4 cups bread flour',
    '1¾ cups lukewarm water',
    '1 tsp salt',
    '¼ tsp instant yeast',
  ], [
    'Mix everything briefly in a bowl, cover and let rise for 12 hours at room temperature.',
    'Fold the dough on a floured surface and rest for 30 minutes. Meanwhile heat a Dutch oven in the oven to 465°F.',
    'Place the dough in the hot pot and bake covered for 30 minutes, then uncovered for 15 minutes.',
  ], stars: 5, cooked: 2, folder: 1),
  _S('s5', 'Ginger lemonade', 6, 10, 10, 4, 0, ['Drink'], [
    '4 oz fresh ginger',
    '¾ cup sugar',
    '3 limes, juiced',
    '1 qt sparkling water',
    'Ice cubes',
  ], [
    'Slice the ginger and simmer with the sugar and 1¼ cups water for 10 minutes.',
    'Let it cool, strain and mix with the lime juice.',
    'Top up with ice and sparkling water.',
  ]),
  _S('s6', 'Red lentil stew', 4, 15, 35, 5, 3, ['Stew', 'Vegan'], [
    '1¼ cups red lentils',
    '2 carrots, diced',
    '1 onion',
    '1 tbsp tomato paste',
    '1 tsp cumin',
    '3½ cups vegetable stock',
    '1 lemon, juiced',
  ], [
    'Cook the onion and carrots in a little oil for 5 minutes, then toast the tomato paste and cumin briefly.',
    'Add lentils and stock and simmer gently for 20 minutes.',
    'Season with lemon juice, salt and pepper.',
  ], stars: 4, cooked: 1, folder: 0),
];

/// Puts the samples (in the device language) into an empty collection. Not for Pro limits: they are ours.
void seedSamples(Library lib, String lang) {
  if (lib.recipes.isNotEmpty) return;
  final de = lang == 'de';
  final fo = [
    Folder(id: 'f1', name: de ? 'Unter der Woche' : 'Weeknights', hue: 2),
    Folder(id: 'f2', name: de ? 'Backen & Brot' : 'Baking & bread', hue: 0),
  ];
  lib.folders.addAll(fo);
  for (final s in (de ? _de : _en)) {
    final r = Recipe(
      id: s.id,
      title: s.title,
      servings: s.servings,
      prepMin: s.prep,
      cookMin: s.cook,
      motif: s.motif,
      hue: s.hue,
      tags: s.tags,
      ingredients: [for (final i in s.ings) parseIngredient(i)],
      steps: s.steps,
      favorite: s.fav,
      rating: s.stars,
      twist: s.twist,
      folders: s.folder >= 0 ? [fo[s.folder].id] : [],
      created: lib.now.subtract(Duration(days: 40 - int.parse(s.id.substring(1)) * 3)),
      log: [for (var k = 0; k < s.cooked; k++) CookLog(lib.now.subtract(Duration(days: 2 + k * 9 + int.parse(s.id.substring(1)))), '')],
    );
    lib.recipes.add(r);
  }
  lib.commit();
}
