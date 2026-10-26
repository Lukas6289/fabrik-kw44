/// A song in the crate: a local copy of a file the user picked (or a bundled sample).
class Song {
  Song({
    required this.id,
    required this.title,
    this.artist = '',
    required this.file,
    required this.ms,
  });

  final String id;
  String title;
  String artist;

  /// File name inside the app's songs folder, or `asset:<path>` for bundled samples.
  final String file;

  /// Length in milliseconds.
  final int ms;

  bool get isAsset => file.startsWith('asset:');

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'file': file,
    'ms': ms,
  };

  factory Song.fromJson(Map<String, Object?> j) => Song(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    artist: j['artist'] as String? ?? '',
    file: j['file'] as String,
    ms: (j['ms'] as num?)?.toInt() ?? 0,
  );
}

enum Side { a, b }

extension SideX on Side {
  String get letter => this == Side.a ? 'A' : 'B';
  Side get other => this == Side.a ? Side.b : Side.a;
}

/// A mixtape: two sides, a total length (C30 … C120), a look and a handwritten dedication.
class Tape {
  Tape({
    required this.id,
    required this.name,
    this.minutes = 90,
    this.shell = 0,
    this.label = 0,
    this.dedication = '',
    List<String>? a,
    List<String>? b,
    DateTime? made,
  }) : a = a ?? [],
       b = b ?? [],
       made = made ?? DateTime.now();

  final String id;
  String name;
  int minutes;
  int shell;
  int label;
  String dedication;
  final List<String> a;
  final List<String> b;
  final DateTime made;

  static const lengths = [30, 46, 60, 90, 120];

  /// One side holds half of the tape.
  int get sideCapacityMs => minutes * 30 * 1000;

  List<String> side(Side s) => s == Side.a ? a : b;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'minutes': minutes,
    'shell': shell,
    'label': label,
    'dedication': dedication,
    'a': a,
    'b': b,
    'made': made.toIso8601String(),
  };

  factory Tape.fromJson(Map<String, Object?> j) => Tape(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    minutes: (j['minutes'] as num?)?.toInt() ?? 90,
    shell: (j['shell'] as num?)?.toInt() ?? 0,
    label: (j['label'] as num?)?.toInt() ?? 0,
    dedication: j['dedication'] as String? ?? '',
    a: [for (final x in (j['a'] as List? ?? const [])) x as String],
    b: [for (final x in (j['b'] as List? ?? const [])) x as String],
    made: DateTime.tryParse(j['made'] as String? ?? ''),
  );
}

class Settings {
  bool onboarded = false;
  bool autoFlip = true;
  bool sampleSeeded = false;
  String? lastTape;
  Side lastSide = Side.a;
}

String clock(int ms) {
  final s = (ms / 1000).round();
  final m = s ~/ 60;
  final r = s % 60;
  return '$m:${r.toString().padLeft(2, '0')}';
}

/// Title from a file name: no extension, no leading track number, underscores to spaces.
String titleFromFile(String name) {
  var t = name.split('/').last;
  final dot = t.lastIndexOf('.');
  if (dot > 0) t = t.substring(0, dot);
  t = t.replaceAll('_', ' ').trim();
  t = t.replaceFirst(RegExp(r'^\d{1,3}\s*[-.)]\s*'), '');
  t = t.replaceFirst(RegExp(r'^\d{1,3}\s+(?=\D)'), '');
  return t.isEmpty ? name : t;
}
