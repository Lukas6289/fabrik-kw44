import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:bandsalat/audio.dart';
import 'package:bandsalat/deck.dart';
import 'package:bandsalat/library.dart';
import 'package:bandsalat/pro.dart';
import 'package:bandsalat/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeProBackend implements ProBackend {
  List<String> owned = [];
  PurchaseResult next = PurchaseResult.purchased;
  bool storeDown = false;

  @override
  Future<Map<String, String>> prices(List<String> ids) async {
    if (storeDown) throw Exception('no store');
    return {proLifetimeId: '4,99 €'};
  }

  @override
  Future<PurchaseResult> purchase(String id) async {
    if (next == PurchaseResult.purchased) owned = [...owned, id];
    return next;
  }

  @override
  Future<List<String>> entitlements() async {
    if (storeDown) throw Exception('no store');
    return owned;
  }

  @override
  Future<List<String>> restore() async => owned;
}

class FakeSharer implements ShareBackend {
  final texts = <String>[];
  final files = <String, Uint8List>{};

  @override
  Future<void> shareText(String text, {Rect? origin}) async => texts.add(text);

  @override
  Future<void> shareFile(
    Uint8List bytes, {
    required String name,
    required String mime,
    Rect? origin,
  }) async {
    files[name] = bytes;
  }
}

class FakeLinks implements LinkBackend {
  final opened = <String>[];
  @override
  Future<void> open(String url) async => opened.add(url);
}

/// A player that only moves when the test says so: [advance] plays time forward.
class FakeEngine implements AudioEngine {
  final _index = StreamController<int>.broadcast(sync: true);
  final _position = StreamController<Duration>.broadcast(sync: true);
  final _playing = StreamController<bool>.broadcast(sync: true);
  final _completed = StreamController<void>.broadcast(sync: true);

  List<EngineItem> items = const [];
  int cur = 0;
  Duration pos = Duration.zero;
  bool isPlaying = false;
  double volume = 1;
  int opens = 0;

  @override
  Stream<int> get indexStream => _index.stream;
  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<bool> get playingStream => _playing.stream;
  @override
  Stream<void> get completedStream => _completed.stream;

  @override
  Future<void> open(
    List<EngineItem> items, {
    int index = 0,
    Duration position = Duration.zero,
  }) async {
    this.items = items;
    cur = index;
    pos = position;
    opens++;
    _index.add(index);
  }

  @override
  Future<void> play() async {
    isPlaying = true;
    _playing.add(true);
  }

  @override
  Future<void> pause() async {
    isPlaying = false;
    _playing.add(false);
  }

  @override
  Future<void> seek(Duration position, {int? index}) async {
    if (index != null && index != cur) {
      cur = index;
      _index.add(index);
    }
    pos = position;
    _position.add(position);
  }

  @override
  Future<void> setVolume(double v) async => volume = v;

  /// Plays [ms] of time forward through the queue, firing the events a real player would.
  void advance(int ms, List<int> songLengths) {
    var left = ms;
    while (left > 0 && isPlaying) {
      final room = songLengths[cur] - pos.inMilliseconds;
      if (left < room) {
        pos += Duration(milliseconds: left);
        _position.add(pos);
        return;
      }
      left -= room;
      if (cur + 1 < songLengths.length) {
        cur++;
        pos = Duration.zero;
        _index.add(cur);
        _position.add(pos);
      } else {
        pos = Duration(milliseconds: songLengths[cur]);
        isPlaying = false;
        _playing.add(false);
        _completed.add(null);
        return;
      }
    }
  }
}

class FakePicker implements AudioPicker {
  List<PickedFile> next = [];
  @override
  Future<List<PickedFile>> pick() async => next;
}

/// Lengths by file name; unknown names count as "not audio".
class FakeInfo implements AudioInfoBackend {
  final known = <String, AudioInfo>{};
  @override
  Future<AudioInfo?> info(String path) async => known[path.split('/').last];
}

class FakeSongFiles implements SongFiles {
  final stored = <String>[];
  final deleted = <String>[];

  @override
  Future<String> store(String sourcePath, String ext) async {
    final n = 'f${stored.length}.$ext';
    stored.add(n);
    return n;
  }

  @override
  String pathOf(String file) => '/songs/$file';

  @override
  Future<void> delete(String file) async => deleted.add(file);

  @override
  Future<int> bytes() async => stored.length * 3 * 1048576;
}

/// A whole app without a network, a store or a phone: fakes for every seam.
class Rig {
  Rig._(
    this.prefs,
    this.services,
    this.backend,
    this.sharer,
    this.links,
    this.engine,
    this.picker,
    this.info,
    this.files,
  );
  final SharedPreferences prefs;
  final Services services;
  final FakeProBackend backend;
  final FakeSharer sharer;
  final FakeLinks links;
  final FakeEngine engine;
  final FakePicker picker;
  final FakeInfo info;
  final FakeSongFiles files;

  Library get lib => services.library;
  Pro get pro => services.pro;
  Deck get deck => services.deck;

  static final today = DateTime(2026, 10, 26, 18);

  static Future<Rig> create({
    Map<String, Object> prefs = const {},
    bool pro = false,
    DateTime Function()? clock,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final p = await SharedPreferences.getInstance();
    final backend = FakeProBackend();
    if (pro) backend.owned = [proLifetimeId];
    final proObj = Pro(p, backend);
    await proObj.start();
    final sharer = FakeSharer();
    final links = FakeLinks();
    final engine = FakeEngine();
    final picker = FakePicker();
    final info = FakeInfo();
    final files = FakeSongFiles();
    final lib = Library(p, proObj, clock: clock ?? () => today);
    final deck = Deck(
      engine,
      lib,
      (s) => s.isAsset ? s.file : files.pathOf(s.file),
      clock: clock,
    );
    final services = Services(
      library: lib,
      pro: proObj,
      deck: deck,
      sharer: sharer,
      links: links,
      fonts: (asset) async =>
          ByteData.sublistView(File(asset).readAsBytesSync()),
      importer: SongImporter(lib, picker, info, files),
      songFiles: files,
    );
    return Rig._(
      p,
      services,
      backend,
      sharer,
      links,
      engine,
      picker,
      info,
      files,
    );
  }
}
