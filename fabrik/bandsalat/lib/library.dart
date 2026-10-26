import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'pro.dart';

/// Songs, tapes and settings. Everything is stored on the device (SharedPreferences, JSON).
class Library extends ChangeNotifier {
  Library(this._prefs, this._pro, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _load();
  }

  final SharedPreferences _prefs;
  final Pro _pro;
  final DateTime Function() _clock;

  final List<Song> songs = [];
  final List<Tape> tapes = [];
  final Settings settings = Settings();
  int _seq = 0;

  // ---- loading / saving

  void _load() {
    try {
      final raw = _prefs.getString('data');
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, Object?>;
        songs.addAll([
          for (final s in (j['songs'] as List? ?? const []))
            Song.fromJson(s as Map<String, Object?>),
        ]);
        tapes.addAll([
          for (final t in (j['tapes'] as List? ?? const []))
            Tape.fromJson(t as Map<String, Object?>),
        ]);
        final st = j['settings'] as Map<String, Object?>? ?? const {};
        settings
          ..onboarded = st['onboarded'] == true
          ..autoFlip = st['autoFlip'] != false
          ..sampleSeeded = st['sampleSeeded'] == true
          ..lastTape = st['lastTape'] as String?
          ..lastSide = st['lastSide'] == 'B' ? Side.b : Side.a;
        _seq = (j['seq'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {
      // A damaged file must never keep the app from starting.
    }
    final known = {for (final s in songs) s.id};
    for (final t in tapes) {
      t.a.removeWhere((id) => !known.contains(id));
      t.b.removeWhere((id) => !known.contains(id));
    }
  }

  void _save() {
    _prefs.setString(
      'data',
      jsonEncode({
        'seq': _seq,
        'songs': [for (final s in songs) s.toJson()],
        'tapes': [for (final t in tapes) t.toJson()],
        'settings': {
          'onboarded': settings.onboarded,
          'autoFlip': settings.autoFlip,
          'sampleSeeded': settings.sampleSeeded,
          'lastTape': settings.lastTape,
          'lastSide': settings.lastSide.letter,
        },
      }),
    );
    notifyListeners();
  }

  String _id(String p) =>
      '$p${_clock().microsecondsSinceEpoch.toRadixString(36)}${(_seq++).toRadixString(36)}';

  // ---- settings

  void finishOnboarding() {
    settings.onboarded = true;
    _save();
  }

  void setAutoFlip(bool on) {
    settings.autoFlip = on;
    _save();
  }

  void remember(String tapeId, Side side) {
    settings.lastTape = tapeId;
    settings.lastSide = side;
    _save();
  }

  // ---- songs

  Song? song(String id) {
    for (final s in songs) {
      if (s.id == id) return s;
    }
    return null;
  }

  Song addSong({
    required String title,
    String artist = '',
    required String file,
    required int ms,
  }) {
    final s = Song(
      id: _id('s'),
      title: title,
      artist: artist,
      file: file,
      ms: ms,
    );
    songs.add(s);
    _save();
    return s;
  }

  void renameSong(String id, String title) {
    final s = song(id);
    if (s == null || title.trim().isEmpty) return;
    s.title = title.trim();
    _save();
  }

  /// Removes a song from the crate and from every tape. Returns the file to delete.
  String? removeSong(String id) {
    final s = song(id);
    if (s == null) return null;
    songs.remove(s);
    for (final t in tapes) {
      t.a.remove(id);
      t.b.remove(id);
    }
    _save();
    return s.isAsset ? null : s.file;
  }

  int tapesWith(String songId) =>
      tapes.where((t) => t.a.contains(songId) || t.b.contains(songId)).length;

  // ---- tapes

  Tape? tape(String id) {
    for (final t in tapes) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool get canAddTape => _pro.isPro || tapes.length < freeTapes;

  /// Style number [i] of the shell colours / label patterns may be used (first [freeStyles] are free).
  bool styleAllowed(int i) => _pro.isPro || i < freeStyles;

  /// Null when the free limit is reached.
  Tape? createTape({
    required String name,
    int minutes = 90,
    int shell = 0,
    int label = 0,
    String dedication = '',
  }) {
    if (!canAddTape) return null;
    final t = Tape(
      id: _id('t'),
      name: name.trim().isEmpty ? 'Mixtape' : name.trim(),
      minutes: Tape.lengths.contains(minutes) ? minutes : 90,
      shell: styleAllowed(shell) ? shell : 0,
      label: styleAllowed(label) ? label : 0,
      dedication: dedication,
      made: _clock(),
    );
    tapes.add(t);
    _save();
    return t;
  }

  /// A tape that is not on the shelf yet; [commit] puts it there.
  Tape draft({String name = ''}) =>
      Tape(id: _id('t'), name: name, made: _clock());

  /// Adds a draft to the shelf (or saves changes to a tape already there). False at the free limit.
  bool commit(Tape t) {
    if (t.name.trim().isEmpty) t.name = 'Mixtape';
    if (!tapes.contains(t)) {
      if (!canAddTape) return false;
      tapes.add(t);
    }
    _save();
    return true;
  }

  void touch() => _save();

  void deleteTape(String id) {
    tapes.removeWhere((t) => t.id == id);
    if (settings.lastTape == id) settings.lastTape = null;
    _save();
  }

  // ---- sides and the tape budget

  int sideMs(Tape t, Side s) =>
      t.side(s).fold(0, (sum, id) => sum + (song(id)?.ms ?? 0));

  int freeMs(Tape t, Side s) => t.sideCapacityMs - sideMs(t, s);

  bool fits(Tape t, Side s, Song song) => freeMs(t, s) >= song.ms;

  /// Puts [songId] on a side. With [force] it may exceed the tape (shown in red, cut when played).
  bool addToSide(Tape t, Side s, String songId, {int? at, bool force = false}) {
    final sg = song(songId);
    if (sg == null) return false;
    if (!force && !fits(t, s, sg)) return false;
    final list = t.side(s);
    final i = at == null ? list.length : at.clamp(0, list.length);
    list.insert(i, songId);
    _save();
    return true;
  }

  void removeFromSide(Tape t, Side s, int index) {
    final list = t.side(s);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _save();
  }

  void reorder(Tape t, Side s, int from, int to) {
    final list = t.side(s);
    if (from < 0 || from >= list.length) return;
    final x = list.removeAt(from);
    list.insert(to.clamp(0, list.length), x);
    _save();
  }

  /// Moves a song to the other side if it fits there.
  bool flipSong(Tape t, Side s, int index) {
    final list = t.side(s);
    if (index < 0 || index >= list.length) return false;
    final sg = song(list[index]);
    if (sg == null || !fits(t, s.other, sg)) return false;
    list.removeAt(index);
    t.side(s.other).add(sg.id);
    _save();
    return true;
  }

  /// Fills side A, then side B, with [ids] in order. Songs that fit nowhere are skipped.
  /// Returns how many were left over.
  int autoFill(Tape t, List<String> ids) {
    var left = 0;
    for (final id in ids) {
      final sg = song(id);
      if (sg == null) continue;
      if (fits(t, Side.a, sg)) {
        t.a.add(id);
      } else if (fits(t, Side.b, sg)) {
        t.b.add(id);
      } else {
        left++;
      }
    }
    _save();
    return left;
  }

  /// Songs not on any side of [t].
  List<Song> unused(Tape t) => [
    for (final s in songs)
      if (!t.a.contains(s.id) && !t.b.contains(s.id)) s,
  ];

  int get totalMs => songs.fold(0, (a, s) => a + s.ms);

  /// The tape shown on the shelf's hero: the last played, else the newest.
  Tape? get featured {
    final id = settings.lastTape;
    if (id != null) {
      final t = tape(id);
      if (t != null) return t;
    }
    return tapes.isEmpty ? null : tapes.first;
  }

  void markSampleSeeded() {
    settings.sampleSeeded = true;
    _save();
  }
}
