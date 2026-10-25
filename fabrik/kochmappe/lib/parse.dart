import 'dart:convert';

import 'models.dart';

/// Reads recipes out of web pages and pasted text, completely on the device.

// ---------------------------------------------------------------- amounts

const _vulgar = {
  '½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 1 / 3, '⅔': 2 / 3, '⅛': 0.125, '⅜': 0.375, '⅝': 0.625, '⅞': 0.875,
  '⅕': 0.2, '⅖': 0.4, '⅗': 0.6, '⅘': 0.8, '⅙': 1 / 6, '⅚': 5 / 6,
};

/// Unit spellings (en + de) → canonical unit key.
const unitAliases = <String, String>{
  'g': 'g', 'gr': 'g', 'gramm': 'g', 'gram': 'g', 'grams': 'g', 'kg': 'kg', 'kilogramm': 'kg', 'kilogram': 'kg',
  'mg': 'mg', 'ml': 'ml', 'milliliter': 'ml', 'cl': 'cl', 'dl': 'dl', 'l': 'l', 'liter': 'l', 'litre': 'l', 'liters': 'l',
  'el': 'tbsp', 'esslöffel': 'tbsp', 'tbsp': 'tbsp', 'tablespoon': 'tbsp', 'tablespoons': 'tbsp', 'tbs': 'tbsp',
  'tl': 'tsp', 'teelöffel': 'tsp', 'tsp': 'tsp', 'teaspoon': 'tsp', 'teaspoons': 'tsp',
  'cup': 'cup', 'cups': 'cup', 'tasse': 'cup', 'tassen': 'cup',
  'oz': 'oz', 'ounce': 'oz', 'ounces': 'oz', 'lb': 'lb', 'lbs': 'lb', 'pound': 'lb', 'pounds': 'lb',
  'pfund': 'pfund', 'dash': 'msp', 'prise': 'pinch', 'prisen': 'pinch', 'pinch': 'pinch', 'msp': 'msp', 'messerspitze': 'msp',
  'bund': 'bunch', 'bunch': 'bunch', 'dose': 'can', 'dosen': 'can', 'can': 'can', 'cans': 'can',
  'pck': 'pack', 'pck.': 'pack', 'päckchen': 'pack', 'packung': 'pack', 'pkg': 'pack', 'package': 'pack',
  'stück': 'pc', 'stk': 'pc', 'st': 'pc', 'pc': 'pc', 'pcs': 'pc', 'piece': 'pc', 'pieces': 'pc',
  'zehe': 'clove', 'zehen': 'clove', 'clove': 'clove', 'cloves': 'clove', 'scheibe': 'slice', 'scheiben': 'slice',
  'slice': 'slice', 'slices': 'slice', 'handvoll': 'handful', 'handful': 'handful', 'zweig': 'sprig', 'zweige': 'sprig',
  'sprig': 'sprig', 'sprigs': 'sprig', 'stange': 'stick', 'stangen': 'stick', 'stick': 'stick', 'sticks': 'stick',
};

final _number = RegExp(r'^(\d+)\s+(\d+)\s*/\s*(\d+)|^(\d+)\s*/\s*(\d+)|^(\d+(?:[.,]\d+)?)');

/// Parses a leading amount ("1 1/2", "½", "2-3", "1,5"). Returns the amount and the rest of the text.
({double? qty, String rest}) parseAmount(String line) {
  var s = line.trim();
  // "1½" or "1 ½"
  double? whole;
  final m0 = RegExp(r'^(\d+)\s*([½¼¾⅓⅔⅛⅜⅝⅞⅕⅖⅗⅘⅙⅚])').firstMatch(s);
  if (m0 != null) {
    return (qty: int.parse(m0[1]!) + _vulgar[m0[2]]!, rest: s.substring(m0.end).trim());
  }
  if (s.isNotEmpty && _vulgar.containsKey(s[0])) {
    return (qty: _vulgar[s[0]], rest: s.substring(1).trim());
  }
  final m = _number.firstMatch(s);
  if (m == null) return (qty: null, rest: s);
  if (m[1] != null) {
    final d = int.parse(m[3]!);
    if (d != 0) whole = int.parse(m[1]!) + int.parse(m[2]!) / d;
  } else if (m[4] != null) {
    final d = int.parse(m[5]!);
    if (d != 0) whole = int.parse(m[4]!) / d;
  } else {
    whole = double.parse(m[6]!.replaceAll(',', '.'));
  }
  if (whole == null) return (qty: null, rest: s);
  var rest = s.substring(m.end).trim();
  // range "2-3" / "2 bis 3" / "2 to 3": use the upper bound
  final r = RegExp(r'^(?:[-–]|bis|to)\s*(\d+(?:[.,]\d+)?)\s*').firstMatch(rest);
  if (r != null) {
    whole = double.parse(r[1]!.replaceAll(',', '.'));
    rest = rest.substring(r.end).trim();
  }
  return (qty: whole, rest: rest);
}

/// "2 EL Öl", "1/2 Zwiebel, fein gewürfelt", "Salz" → [Ing].
Ing parseIngredient(String raw, {String group = ''}) {
  var line = raw.replaceAll(RegExp(r'^[\s•\-*·]+'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  final a = parseAmount(line);
  var rest = a.rest;
  var unit = '';
  if (a.qty != null) {
    final m = RegExp(r'^([A-Za-zÄÖÜäöüß]+\.?)(?=\s|$)').firstMatch(rest);
    if (m != null) {
      final key = unitAliases[m[1]!.toLowerCase().replaceAll('.', '')];
      if (key != null && rest.length > m[0]!.length) {
        unit = key;
        rest = rest.substring(m[0]!.length).trim();
      }
    }
    rest = rest.replaceFirst(RegExp(r'^(of|von)\s+', caseSensitive: false), '');
  }
  var note = '';
  final c = rest.indexOf(',');
  if (c > 0) {
    note = rest.substring(c + 1).trim();
    rest = rest.substring(0, c).trim();
  }
  final p = RegExp(r'^(.*?)\s*\(([^)]*)\)\s*$').firstMatch(rest);
  if (p != null && p[1]!.isNotEmpty) {
    note = note.isEmpty ? p[2]! : '${p[2]}, $note';
    rest = p[1]!;
  }
  if (rest.isEmpty) rest = line;
  return Ing(qty: a.qty, unit: unit, name: rest, note: note, group: group);
}

// ---------------------------------------------------------------- time

/// ISO 8601 duration ("PT1H30M") → minutes.
int parseIsoMinutes(String? s) {
  if (s == null) return 0;
  final m = RegExp(r'^P(?:(\d+)D)?T?(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$', caseSensitive: false).firstMatch(s.trim());
  if (m == null) return 0;
  int g(int i) => int.tryParse(m[i] ?? '') ?? 0;
  return g(1) * 1440 + g(2) * 60 + g(3) + (g(4) >= 30 ? 1 : 0);
}

/// A time found in a step ("bake 20-25 minutes") – for the timer buttons.
class StepTimer {
  const StepTimer(this.seconds, this.label);
  final int seconds;
  final String label;
}

final _timeRe = RegExp(
    r'(\d+(?:[.,]\d+)?)(?:\s*(?:-|–|bis|to)\s*(\d+(?:[.,]\d+)?))?\s*(stunden?|std\.?|h|hours?|hrs?|minuten?|min\.?|minutes?|mins?|sekunden?|sek\.?|seconds?|secs?)\b',
    caseSensitive: false);

/// Finds all times in a step. A range ("20-25 min") uses the upper bound.
List<StepTimer> timersIn(String step) {
  final out = <StepTimer>[];
  for (final m in _timeRe.allMatches(step)) {
    final v = double.parse((m[2] ?? m[1])!.replaceAll(',', '.'));
    final u = m[3]!.toLowerCase();
    final secs = u.startsWith('st') || u.startsWith('h')
        ? v * 3600
        : u.startsWith('s')
            ? v * 1
            : v * 60;
    if (secs < 10 || secs > 24 * 3600) continue;
    out.add(StepTimer(secs.round(), m[0]!.trim()));
  }
  return out;
}

// ---------------------------------------------------------------- web pages

class ParsedRecipe {
  ParsedRecipe({
    required this.title,
    required this.ingredients,
    required this.steps,
    this.servings = 4,
    this.prepMin = 0,
    this.cookMin = 0,
    this.tags = const [],
    this.imageUrl = '',
  });
  final String title;
  final List<Ing> ingredients;
  final List<String> steps;
  final int servings;
  final int prepMin;
  final int cookMin;
  final List<String> tags;
  final String imageUrl;

  bool get usable => title.isNotEmpty && (ingredients.isNotEmpty || steps.isNotEmpty);
}

String decodeEntities(String s) {
  const named = {'amp': '&', 'lt': '<', 'gt': '>', 'quot': '"', 'apos': "'", 'nbsp': ' ', 'deg': '°', 'frac12': '½', 'frac14': '¼', 'frac34': '¾', 'ndash': '–', 'mdash': '—'};
  return s.replaceAllMapped(RegExp(r'&(#x?[0-9a-fA-F]+|[a-zA-Z0-9]+);'), (m) {
    final e = m[1]!;
    if (e.startsWith('#x')) return String.fromCharCode(int.tryParse(e.substring(2), radix: 16) ?? 63);
    if (e.startsWith('#')) return String.fromCharCode(int.tryParse(e.substring(1)) ?? 63);
    return named[e] ?? m[0]!;
  });
}

String _clean(Object? v) => decodeEntities(v.toString().replaceAll(RegExp(r'<[^>]+>'), ' ')).replaceAll(RegExp(r'\s+'), ' ').trim();

/// Finds the schema.org/Recipe in the JSON-LD blocks of a page.
ParsedRecipe? recipeFromHtml(String html) {
  final blocks = RegExp(r'<script[^>]*type\s*=\s*["\x27]application/ld\+json["\x27][^>]*>(.*?)</script>', caseSensitive: false, dotAll: true)
      .allMatches(html);
  for (final b in blocks) {
    Object? data;
    try {
      data = jsonDecode(b[1]!.trim());
    } catch (_) {
      continue;
    }
    final r = _findRecipe(data);
    if (r != null) {
      final p = _fromSchema(r);
      if (p.usable) return p;
    }
  }
  return null;
}

Map<String, Object?>? _findRecipe(Object? d) {
  if (d is List) {
    for (final e in d) {
      final r = _findRecipe(e);
      if (r != null) return r;
    }
  } else if (d is Map) {
    final t = d['@type'];
    if (t == 'Recipe' || (t is List && t.contains('Recipe'))) return d.cast();
    final g = d['@graph'];
    if (g != null) return _findRecipe(g);
    for (final v in d.values) {
      if (v is List || v is Map) {
        final r = _findRecipe(v);
        if (r != null) return r;
      }
    }
  }
  return null;
}

ParsedRecipe _fromSchema(Map<String, Object?> r) {
  final steps = <String>[];
  void walk(Object? v) {
    if (v is String) {
      for (final line in v.split(RegExp(r'\r?\n|<br\s*/?>|</li>|</p>', caseSensitive: false))) {
        final t = _clean(line);
        if (t.isNotEmpty) steps.add(t);
      }
    } else if (v is List) {
      v.forEach(walk);
    } else if (v is Map) {
      if (v['itemListElement'] != null) {
        walk(v['itemListElement']);
      } else {
        final t = v['text'] ?? v['name'];
        if (t != null) walk(t);
      }
    }
  }

  walk(r['recipeInstructions']);
  final parts = steps;
  final ings = <Ing>[
    for (final i in (r['recipeIngredient'] is List ? r['recipeIngredient'] as List : const []))
      if (_clean(i).isNotEmpty) parseIngredient(_clean(i)),
  ];
  var servings = 4;
  final y = r['recipeYield'];
  final ys = y is List ? (y.isEmpty ? '' : y.first.toString()) : (y?.toString() ?? '');
  final ym = RegExp(r'\d+').firstMatch(ys);
  if (ym != null) servings = (int.tryParse(ym[0]!) ?? 4).clamp(1, 99);
  String image = '';
  final im = r['image'];
  if (im is String) {
    image = im;
  } else if (im is List && im.isNotEmpty) {
    final f = im.first;
    image = f is String ? f : (f is Map ? (f['url']?.toString() ?? '') : '');
  } else if (im is Map) {
    image = im['url']?.toString() ?? '';
  }
  final tags = <String>{};
  for (final k in ['recipeCategory', 'recipeCuisine']) {
    final v = r[k];
    for (final t in (v is List ? v : [v])) {
      if (t != null && _clean(t).isNotEmpty && _clean(t).length < 24) tags.add(_clean(t));
    }
  }
  var prep = parseIsoMinutes(r['prepTime']?.toString());
  var cook = parseIsoMinutes(r['cookTime']?.toString());
  if (prep == 0 && cook == 0) cook = parseIsoMinutes(r['totalTime']?.toString());
  return ParsedRecipe(
    title: _clean(r['name'] ?? ''),
    ingredients: ings,
    steps: [for (final s in parts) if (s.trim().isNotEmpty) s.trim()],
    servings: servings,
    prepMin: prep,
    cookMin: cook,
    tags: tags.take(4).toList(),
    imageUrl: image,
  );
}

/// Page title as a last resort when the page has no recipe data at all.
String titleFromHtml(String html) {
  final m = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true).firstMatch(html);
  return m == null ? '' : _clean(m[1]);
}

// ---------------------------------------------------------------- pasted text

final _ingHeads = RegExp(r'^\s*(zutaten|ingredients?|you(?:\s|\x27)ll need|das brauchst du|du brauchst)\s*:?\s*$', caseSensitive: false);
final _stepHeads = RegExp(r'^\s*(zubereitung|anleitung|so geht(?:\x27s|s)?|schritte|directions?|instructions?|method|steps|preparation)\s*:?\s*$', caseSensitive: false);

/// Reads a recipe out of free text (a social-media caption, an e-mail, a note).
/// Understands "Zutaten/Ingredients" and "Zubereitung/Directions" headings; without headings,
/// lines that start with an amount are ingredients and the rest are steps.
ParsedRecipe parseRecipeText(String text) {
  final lines = text.replaceAll('\r', '').split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  if (lines.isEmpty) return ParsedRecipe(title: '', ingredients: const [], steps: const []);
  var title = '';
  final ings = <Ing>[];
  final steps = <String>[];
  var mode = 0; // 0 start, 1 ingredients, 2 steps
  var servings = 4;
  var group = '';
  final hasHeads = lines.any((l) => _ingHeads.hasMatch(l) || _stepHeads.hasMatch(l));
  final stepNum = RegExp(r'^(?:\d+\s*[.)]|schritt\s*\d+\s*:?|step\s*\d+\s*:?)\s*', caseSensitive: false);
  for (final l in lines) {
    if (_ingHeads.hasMatch(l)) {
      mode = 1;
      continue;
    }
    if (_stepHeads.hasMatch(l)) {
      mode = 2;
      continue;
    }
    final sv = RegExp(r'(?:für|serves|servings?|portionen|makes)\s*:?\s*(\d+)', caseSensitive: false).firstMatch(l);
    if (sv != null && l.length < 40) {
      servings = (int.tryParse(sv[1]!) ?? 4).clamp(1, 99);
      continue;
    }
    if (title.isEmpty && mode == 0) {
      title = l.replaceAll(RegExp(r'^[#*\s]+|[#*\s]+$'), '');
      continue;
    }
    if (hasHeads) {
      if (mode == 1) {
        if (l.endsWith(':') && l.length < 40) {
          group = l.substring(0, l.length - 1);
        } else {
          ings.add(parseIngredient(l, group: group));
        }
      } else {
        steps.add(l.replaceFirst(stepNum, ''));
      }
    } else {
      if (stepNum.hasMatch(l) || l.length > 60) {
        steps.add(l.replaceFirst(stepNum, ''));
      } else if (parseAmount(l).qty != null || RegExp(r'^[•\-*]').hasMatch(l)) {
        ings.add(parseIngredient(l));
      } else if (l.length <= 60) {
        ings.add(parseIngredient(l));
      }
    }
  }
  return ParsedRecipe(title: title, ingredients: ings, steps: steps, servings: servings);
}
