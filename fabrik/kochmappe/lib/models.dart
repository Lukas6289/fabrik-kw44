/// One line of a recipe: "2 EL Öl", "1/2 Zwiebel, fein gewürfelt".
class Ing {
  const Ing({this.qty, this.unit = '', required this.name, this.note = '', this.group = ''});
  final double? qty;
  final String unit;
  final String name;
  final String note;

  /// Section heading ("Teig", "Sauce") this line belongs to.
  final String group;

  Map<String, Object?> toJson() => {
        if (qty != null) 'q': qty,
        if (unit.isNotEmpty) 'u': unit,
        'n': name,
        if (note.isNotEmpty) 'o': note,
        if (group.isNotEmpty) 'g': group,
      };

  static Ing fromJson(Map<String, Object?> j) => Ing(
        qty: (j['q'] as num?)?.toDouble(),
        unit: j['u'] as String? ?? '',
        name: j['n'] as String? ?? '',
        note: j['o'] as String? ?? '',
        group: j['g'] as String? ?? '',
      );
}

class CookLog {
  const CookLog(this.day, this.note);
  final DateTime day;
  final String note;
  Map<String, Object?> toJson() => {'d': day.toIso8601String(), if (note.isNotEmpty) 'n': note};
  static CookLog fromJson(Map<String, Object?> j) =>
      CookLog(DateTime.parse(j['d'] as String), j['n'] as String? ?? '');
}

class Recipe {
  Recipe({
    required this.id,
    required this.title,
    this.ingredients = const [],
    this.steps = const [],
    this.servings = 4,
    this.prepMin = 0,
    this.cookMin = 0,
    this.tags = const [],
    this.folders = const [],
    this.source = '',
    this.notes = '',
    this.twist = '',
    this.favorite = false,
    this.rating = 0,
    this.photo = '',
    this.motif = 0,
    this.hue = 0,
    this.log = const [],
    DateTime? created,
  }) : created = created ?? DateTime(2026);

  final String id;
  String title;
  List<Ing> ingredients;
  List<String> steps;
  int servings;
  int prepMin;
  int cookMin;
  List<String> tags;
  List<String> folders;
  String source;

  /// Notes about the original ("from grandma").
  String notes;

  /// "My twist": own changes, kept apart from the original text.
  String twist;
  bool favorite;
  int rating;

  /// File name of the photo in the app's photo folder, empty = drawn card.
  String photo;

  /// Index of the drawn motif and the colour of the card (see design.dart).
  int motif;
  int hue;
  List<CookLog> log;
  DateTime created;

  int get totalMin => prepMin + cookMin;
  int get timesCooked => log.length;
  DateTime? get lastCooked => log.isEmpty ? null : log.map((e) => e.day).reduce((a, b) => a.isAfter(b) ? a : b);

  Recipe copy() => Recipe.fromJson(toJson());

  Map<String, Object?> toJson() => {
        'id': id,
        't': title,
        'i': [for (final i in ingredients) i.toJson()],
        's': steps,
        'sv': servings,
        'pm': prepMin,
        'cm': cookMin,
        'tg': tags,
        'f': folders,
        if (source.isNotEmpty) 'src': source,
        if (notes.isNotEmpty) 'no': notes,
        if (twist.isNotEmpty) 'tw': twist,
        if (favorite) 'fav': true,
        if (rating > 0) 'r': rating,
        if (photo.isNotEmpty) 'ph': photo,
        'mo': motif,
        'hu': hue,
        if (log.isNotEmpty) 'lg': [for (final l in log) l.toJson()],
        'cr': created.toIso8601String(),
      };

  static Recipe fromJson(Map<String, Object?> j) => Recipe(
        id: j['id'] as String,
        title: j['t'] as String? ?? '',
        ingredients: [for (final e in (j['i'] as List? ?? const [])) Ing.fromJson((e as Map).cast())],
        steps: [for (final e in (j['s'] as List? ?? const [])) e as String],
        servings: (j['sv'] as num?)?.toInt() ?? 4,
        prepMin: (j['pm'] as num?)?.toInt() ?? 0,
        cookMin: (j['cm'] as num?)?.toInt() ?? 0,
        tags: [for (final e in (j['tg'] as List? ?? const [])) e as String],
        folders: [for (final e in (j['f'] as List? ?? const [])) e as String],
        source: j['src'] as String? ?? '',
        notes: j['no'] as String? ?? '',
        twist: j['tw'] as String? ?? '',
        favorite: j['fav'] as bool? ?? false,
        rating: (j['r'] as num?)?.toInt() ?? 0,
        photo: j['ph'] as String? ?? '',
        motif: (j['mo'] as num?)?.toInt() ?? 0,
        hue: (j['hu'] as num?)?.toInt() ?? 0,
        log: [for (final e in (j['lg'] as List? ?? const [])) CookLog.fromJson((e as Map).cast())],
        created: DateTime.tryParse(j['cr'] as String? ?? ''),
      );
}

class Folder {
  Folder({required this.id, required this.name, this.hue = 0});
  final String id;
  String name;
  int hue;
  Map<String, Object?> toJson() => {'id': id, 'n': name, 'h': hue};
  static Folder fromJson(Map<String, Object?> j) =>
      Folder(id: j['id'] as String, name: j['n'] as String? ?? '', hue: (j['h'] as num?)?.toInt() ?? 0);
}

/// A line on the shopping list: amount, canonical unit and name (so equal items can be added up).
class ShopItem {
  ShopItem({required this.name, this.qty, this.unit = '', this.done = false, this.from = ''});
  String name;
  double? qty;
  String unit;
  bool done;

  /// Titles of the recipes the line came from (for the small caption).
  String from;
  Map<String, Object?> toJson() => {
        'n': name,
        if (qty != null) 'q': qty,
        if (unit.isNotEmpty) 'u': unit,
        'd': done,
        if (from.isNotEmpty) 'f': from,
      };
  static ShopItem fromJson(Map<String, Object?> j) => ShopItem(
        name: j['n'] as String? ?? '',
        qty: (j['q'] as num?)?.toDouble(),
        unit: j['u'] as String? ?? '',
        done: j['d'] as bool? ?? false,
        from: j['f'] as String? ?? '',
      );
}

enum UnitSystem { metric, us }
