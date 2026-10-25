import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'parse.dart';
import 'pro.dart';
import 'scale.dart';

/// Where recipe photos live (a folder on the device). Tests use a memory version.
abstract class PhotoStore {
  Future<String> save(Uint8List bytes);
  Future<Uint8List?> load(String name);
  Future<void> delete(String name);
}

class MemoryPhotoStore implements PhotoStore {
  final files = <String, Uint8List>{};
  @override
  Future<String> save(Uint8List bytes) async {
    final n = 'p${files.length + 1}.jpg';
    files[n] = bytes;
    return n;
  }

  @override
  Future<Uint8List?> load(String name) async => files[name];
  @override
  Future<void> delete(String name) async => files.remove(name);
}

class Settings {
  Settings({this.units = UnitSystem.metric, this.theme = 0, this.onboarded = false});
  UnitSystem units;

  /// Index of the colour theme of the binder (0 is free, the others are Pro).
  int theme;
  bool onboarded;
}

/// A recipe that matches an ingredient search, with what is still missing.
class FridgeMatch {
  FridgeMatch(this.recipe, this.have, this.missing);
  final Recipe recipe;
  final List<String> have;
  final List<String> missing;
}

/// The whole collection: recipes, folders, shopping list, settings. Everything stays on the device.
class Library extends ChangeNotifier {
  Library(this._prefs, this.pro, {DateTime Function()? clock, Random? random, PhotoStore? photos})
      : _clock = clock ?? DateTime.now,
        _random = random ?? Random(),
        photos = photos ?? MemoryPhotoStore() {
    _load();
  }

  final SharedPreferences _prefs;
  final Pro pro;
  final DateTime Function() _clock;
  final Random _random;
  final PhotoStore photos;

  final _photoCache = <String, Uint8List?>{};

  /// Photo bytes with a small memory cache (the lists redraw often).
  Future<Uint8List?> photoBytes(String name) async {
    if (_photoCache.containsKey(name)) return _photoCache[name];
    return _photoCache[name] = await photos.load(name);
  }

  final List<Recipe> recipes = [];
  final List<Folder> folders = [];
  final List<ShopItem> shopping = [];
  Settings settings = Settings();

  DateTime get now => _clock();

  // ------------------------------------------------------------ storage

  void _load() {
    try {
      for (final e in jsonDecode(_prefs.getString('recipes') ?? '[]') as List) {
        recipes.add(Recipe.fromJson((e as Map).cast()));
      }
      for (final e in jsonDecode(_prefs.getString('folders') ?? '[]') as List) {
        folders.add(Folder.fromJson((e as Map).cast()));
      }
      for (final e in jsonDecode(_prefs.getString('shop') ?? '[]') as List) {
        shopping.add(ShopItem.fromJson((e as Map).cast()));
      }
    } catch (_) {
      // A damaged entry must never stop the app; what was read stays.
    }
    settings = Settings(
      units: _prefs.getString('units') == 'us' ? UnitSystem.us : UnitSystem.metric,
      theme: _prefs.getInt('theme') ?? 0,
      onboarded: _prefs.getBool('onboarded') ?? false,
    );
  }

  void _save() {
    _prefs.setString('recipes', jsonEncode([for (final r in recipes) r.toJson()]));
    _prefs.setString('folders', jsonEncode([for (final f in folders) f.toJson()]));
    _prefs.setString('shop', jsonEncode([for (final s in shopping) s.toJson()]));
    _prefs.setString('units', settings.units == UnitSystem.us ? 'us' : 'metric');
    _prefs.setInt('theme', settings.theme);
    _prefs.setBool('onboarded', settings.onboarded);
    notifyListeners();
  }

  void commit() => _save();

  String newId() => '${_clock().microsecondsSinceEpoch.toRadixString(36)}${_random.nextInt(1 << 20).toRadixString(36)}';

  // ------------------------------------------------------------ settings

  void finishOnboarding() {
    settings.onboarded = true;
    _save();
  }

  void setUnits(UnitSystem u) {
    settings.units = u;
    _save();
  }

  void setTheme(int t) {
    settings.theme = pro.isPro ? t : 0;
    _save();
  }

  // ------------------------------------------------------------ recipes

  bool get canAddRecipe => pro.isPro || recipes.length < freeRecipes;
  bool get canAddFolder => pro.isPro || folders.length < freeFolders;

  Recipe? byId(String id) {
    for (final r in recipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Adds a recipe. Returns false when the free limit is reached.
  bool add(Recipe r) {
    if (!canAddRecipe) return false;
    recipes.insert(0, r);
    _save();
    return true;
  }

  Recipe blank({String title = ''}) {
    final id = newId();
    return Recipe(id: id, title: title, motif: _random.nextInt(motifCount), hue: _random.nextInt(hueCount), created: _clock());
  }

  Recipe fromParsed(ParsedRecipe p, {String source = ''}) {
    final r = blank(title: p.title);
    r
      ..ingredients = p.ingredients
      ..steps = p.steps
      ..servings = p.servings
      ..prepMin = p.prepMin
      ..cookMin = p.cookMin
      ..tags = p.tags
      ..source = source;
    return r;
  }

  void update(Recipe r) {
    final i = recipes.indexWhere((x) => x.id == r.id);
    if (i >= 0) {
      recipes[i] = r;
      _save();
    }
  }

  Future<void> remove(String id) async {
    final r = byId(id);
    if (r == null) return;
    recipes.remove(r);
    if (r.photo.isNotEmpty) await photos.delete(r.photo);
    _save();
  }

  void toggleFavorite(Recipe r) {
    r.favorite = !r.favorite;
    _save();
  }

  void rate(Recipe r, int stars) {
    r.rating = r.rating == stars ? 0 : stars;
    _save();
  }

  /// Cooking diary: "cooked it today".
  void logCooked(Recipe r, {String note = ''}) {
    r.log = [...r.log, CookLog(_clock(), note)];
    _save();
  }

  // ------------------------------------------------------------ folders

  Folder? addFolder(String name) {
    final n = name.trim();
    if (n.isEmpty || !canAddFolder) return null;
    final f = Folder(id: newId(), name: n, hue: folders.length % hueCount);
    folders.add(f);
    _save();
    return f;
  }

  void renameFolder(Folder f, String name) {
    if (name.trim().isEmpty) return;
    f.name = name.trim();
    _save();
  }

  void removeFolder(Folder f) {
    folders.remove(f);
    for (final r in recipes) {
      r.folders = [for (final x in r.folders) if (x != f.id) x];
    }
    _save();
  }

  void setInFolder(Recipe r, Folder f, bool on) {
    final s = {...r.folders};
    on ? s.add(f.id) : s.remove(f.id);
    r.folders = s.toList();
    _save();
  }

  int countIn(Folder f) => recipes.where((r) => r.folders.contains(f.id)).length;

  // ------------------------------------------------------------ search

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ß', 'ss');

  /// Free-text search over title, ingredients, tags, notes and source; every word must hit.
  List<Recipe> search(String q, {String? folderId, bool favorites = false, int? maxMinutes}) {
    final words = _norm(q).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    bool hit(Recipe r) {
      if (folderId != null && !r.folders.contains(folderId)) return false;
      if (favorites && !r.favorite) return false;
      if (maxMinutes != null && (r.totalMin == 0 || r.totalMin > maxMinutes)) return false;
      if (words.isEmpty) return true;
      final hay = _norm([
        r.title,
        r.tags.join(' '),
        r.notes,
        r.twist,
        r.source,
        r.ingredients.map((i) => i.name).join(' '),
      ].join(' '));
      return words.every(hay.contains);
    }

    return recipes.where(hit).toList();
  }

  /// "What do I have?": recipes sorted by how many of the typed ingredients they use.
  List<FridgeMatch> byIngredients(List<String> typed) {
    final want = [for (final t in typed) _norm(t.trim())]..removeWhere((t) => t.length < 2);
    if (want.isEmpty) return const [];
    final out = <FridgeMatch>[];
    for (final r in recipes) {
      final names = [for (final i in r.ingredients) _norm(i.name)];
      final have = <String>[];
      final used = <int>{};
      for (final w in want) {
        final k = names.indexWhere((n) => n.contains(w) || (w.length > 3 && w.contains(n) && n.length > 3));
        if (k >= 0) {
          have.add(w);
          used.add(k);
        }
      }
      if (have.isEmpty) continue;
      final missing = [
        for (var k = 0; k < r.ingredients.length; k++)
          if (!used.contains(k) && !_staples.any((s) => names[k].contains(s))) r.ingredients[k].name,
      ];
      out.add(FridgeMatch(r, have, missing));
    }
    out.sort((a, b) {
      final c = b.have.length.compareTo(a.have.length);
      return c != 0 ? c : a.missing.length.compareTo(b.missing.length);
    });
    return out;
  }

  static const _staples = ['salz', 'salt', 'pfeffer', 'pepper', 'wasser', 'water', 'ol', 'oil', 'zucker', 'sugar'];

  // ------------------------------------------------------------ shopping

  /// Puts the ingredients of a recipe, scaled to [servings], on the list. Equal items are added up.
  void addToShopping(Recipe r, int servings) {
    final f = r.servings == 0 ? 1.0 : servings / r.servings;
    for (final i in r.ingredients) {
      final s = scaleIng(i, f, settings.units);
      final name = i.name.trim();
      final k = shopping.indexWhere((x) => !x.done && _norm(x.name) == _norm(name) && x.unit == s.unit && (x.qty == null) == (s.qty == null));
      if (k >= 0) {
        final it = shopping[k];
        if (s.qty != null) it.qty = it.qty! + s.qty!;
        if (!it.from.split(', ').contains(r.title)) it.from = it.from.isEmpty ? r.title : '${it.from}, ${r.title}';
      } else {
        shopping.add(ShopItem(name: name, qty: s.qty, unit: s.unit, from: r.title));
      }
    }
    _save();
  }

  void toggleShop(ShopItem s) {
    s.done = !s.done;
    _save();
  }

  void addShopText(String t) {
    if (t.trim().isEmpty) return;
    shopping.add(ShopItem(name: t.trim()));
    _save();
  }

  void clearDone() {
    shopping.removeWhere((s) => s.done);
    _save();
  }

  void clearShopping() {
    shopping.clear();
    _save();
  }

  String shoppingText(String header, String lang) =>
      '$header\n${[for (final s in shopping) if (!s.done) '• ${shopLine(s, lang)}'].join('\n')}';

  /// Deletes everything (recipes, folders, list, photos). Pro stays with the Apple ID.
  Future<void> deleteAll() async {
    for (final r in recipes) {
      if (r.photo.isNotEmpty) await photos.delete(r.photo);
    }
    recipes.clear();
    folders.clear();
    shopping.clear();
    settings.theme = 0;
    _save();
  }

  // ------------------------------------------------------------ backup

  /// Everything as one JSON text (recipes, folders, photos as base64).
  Future<String> exportBackup() async {
    final ph = <String, String>{};
    for (final r in recipes) {
      if (r.photo.isEmpty) continue;
      final b = await photos.load(r.photo);
      if (b != null) ph[r.photo] = base64Encode(b);
    }
    return jsonEncode({
      'app': 'kochmappe',
      'version': 1,
      'recipes': [for (final r in recipes) r.toJson()],
      'folders': [for (final f in folders) f.toJson()],
      'photos': ph,
    });
  }

  /// Merges a backup into the collection (nothing is overwritten; existing ids are skipped).
  /// Returns the number of new recipes, or -1 if the file is not a backup.
  Future<int> importBackup(String text) async {
    Map<String, Object?> j;
    try {
      j = (jsonDecode(text) as Map).cast();
    } catch (_) {
      return -1;
    }
    if (j['app'] != 'kochmappe') return -1;
    final ph = ((j['photos'] as Map?) ?? const {}).cast<String, String>();
    var n = 0;
    for (final f in (j['folders'] as List? ?? const [])) {
      final fo = Folder.fromJson((f as Map).cast());
      if (!folders.any((x) => x.id == fo.id)) folders.add(fo);
    }
    for (final e in (j['recipes'] as List? ?? const [])) {
      final r = Recipe.fromJson((e as Map).cast());
      if (byId(r.id) != null) continue;
      if (r.photo.isNotEmpty) {
        final data = ph[r.photo];
        r.photo = data == null ? '' : await photos.save(base64Decode(data));
      }
      recipes.add(r);
      n++;
    }
    _save();
    return n;
  }

  // ------------------------------------------------------------ text

  String recipeText(Recipe r, int servings, String lang, {required String ingredientsHead, required String stepsHead, required String servingsLabel}) {
    final f = r.servings == 0 ? 1.0 : servings / r.servings;
    final b = StringBuffer()
      ..writeln(r.title)
      ..writeln('$servingsLabel: $servings');
    if (r.totalMin > 0) b.writeln(minutesText(r.totalMin, lang));
    b
      ..writeln()
      ..writeln(ingredientsHead);
    for (final i in r.ingredients) {
      b.writeln('• ${ingText(i, f, settings.units, lang)}');
    }
    b
      ..writeln()
      ..writeln(stepsHead);
    for (var k = 0; k < r.steps.length; k++) {
      b.writeln('${k + 1}. ${r.steps[k]}');
    }
    if (r.twist.isNotEmpty) b..writeln()..writeln(r.twist);
    return b.toString().trimRight();
  }
}

/// Number of drawn motifs / card colours (see design.dart).
const motifCount = 8;
const hueCount = 6;
