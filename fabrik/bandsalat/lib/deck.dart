import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio.dart';
import 'library.dart';
import 'models.dart';

/// Resolves a stored song file to something the engine can open.
typedef SongPath = String Function(Song song);

enum SleepMode { off, timer, endOfSide }

/// The tape deck: one tape, one side at a time. Plays the side as a queue, knows the position
/// on the whole side (for the reels and the counter), spools forward/back while a key is held,
/// flips from A to B and runs a sleep timer that fades the tape out.
class Deck extends ChangeNotifier {
  Deck(this._engine, this._lib, this._path, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _subs = [
      _engine.indexStream.listen(_onIndex),
      _engine.positionStream.listen(_onPosition),
      _engine.playingStream.listen(_onPlaying),
      _engine.completedStream.listen((_) => _onSideEnd()),
    ];
  }

  final AudioEngine _engine;
  final Library _lib;
  final SongPath _path;
  final DateTime Function() _clock;
  late final List<StreamSubscription<Object?>> _subs;

  Tape? tape;
  Side side = Side.a;
  List<Song> queue = const [];
  int index = 0;
  int posMs = 0;
  bool playing = false;

  /// -1 rewinding, 1 fast-forwarding, 0 normal.
  int scan = 0;

  /// Counts up whenever the tape is turned over; screens animate on change.
  int flips = 0;

  /// The side ran to its end and nothing follows.
  bool ended = false;

  SleepMode sleep = SleepMode.off;
  DateTime? _sleepAt;
  Timer? _sleepTimer;
  Timer? _scanTimer;
  int _scanTicks = 0;
  bool _resumeAfterScan = false;
  bool _opening = false;

  bool get loaded => tape != null && queue.isNotEmpty;
  int get sideMs => queue.fold(0, (a, s) => a + s.ms);
  int get doneMs => queue.take(index).fold(0, (a, s) => a + s.ms) + posMs;
  double get progress => sideMs == 0 ? 0 : (doneMs / sideMs).clamp(0.0, 1.0);
  Song? get current => index >= 0 && index < queue.length ? queue[index] : null;
  Duration? get sleepLeft => _sleepAt?.difference(_clock());

  /// Three-digit tape counter, one step per three seconds like the real thing.
  int get counter => (doneMs ~/ 3000).clamp(0, 999);

  List<Song> _queueFor(Tape t, Side s) => [
    for (final id in t.side(s)) ?_lib.song(id),
  ];

  /// Puts [t] into the deck. Optionally starts playing.
  Future<void> load(
    Tape t, {
    Side? side,
    int startIndex = 0,
    bool play = false,
    bool silent = false,
  }) async {
    final s = side ?? (t.a.isEmpty && t.b.isNotEmpty ? Side.b : Side.a);
    await _stopScan();
    tape = t;
    this.side = s;
    queue = _queueFor(t, s);
    index = queue.isEmpty ? 0 : startIndex.clamp(0, queue.length - 1);
    posMs = 0;
    ended = false;
    playing = false;
    if (!silent) _lib.remember(t.id, s);
    notifyListeners();
    if (queue.isEmpty) return;
    _opening = true;
    try {
      await _engine.open([
        for (final sg in queue)
          EngineItem(
            id: sg.id,
            title: sg.title,
            artist: sg.artist,
            album: '${t.name} · ${s.letter}',
            source: _path(sg),
          ),
      ], index: index);
      await _engine.setVolume(1);
    } finally {
      _opening = false;
    }
    if (play) await this.play();
  }

  Future<void> play() async {
    if (!loaded) return;
    if (ended) {
      await _seekSide(0);
      ended = false;
    }
    playing = true;
    notifyListeners();
    await _engine.play();
  }

  Future<void> pause() async {
    playing = false;
    notifyListeners();
    await _engine.pause();
  }

  Future<void> toggle() => playing ? pause() : play();

  /// Stop: pause and wind back to the start of the side.
  Future<void> stop() async {
    await _stopScan();
    playing = false;
    await _engine.pause();
    await _seekSide(0);
    notifyListeners();
  }

  Future<void> next() async {
    if (!loaded) return;
    if (index + 1 < queue.length) {
      index++;
      posMs = 0;
      notifyListeners();
      await _engine.seek(Duration.zero, index: index);
    } else {
      await _onSideEnd();
    }
  }

  Future<void> previous() async {
    if (!loaded) return;
    if (posMs > 3000 || index == 0) {
      posMs = 0;
      notifyListeners();
      await _engine.seek(Duration.zero, index: index);
    } else {
      index--;
      posMs = 0;
      notifyListeners();
      await _engine.seek(Duration.zero, index: index);
    }
  }

  Future<void> jumpTo(int i) async {
    if (!loaded || i < 0 || i >= queue.length) return;
    index = i;
    posMs = 0;
    ended = false;
    notifyListeners();
    await _engine.seek(Duration.zero, index: i);
    if (!playing) await play();
  }

  /// Turns the cassette over. Plays on if it was playing.
  Future<void> flip({bool? play}) async {
    final t = tape;
    if (t == null) return;
    final keep = play ?? playing;
    flips++;
    HapticFeedback.mediumImpact();
    await load(t, side: side.other, play: keep);
  }

  Future<void> eject() async {
    await _stopScan();
    await _engine.pause();
    tape = null;
    queue = const [];
    playing = false;
    posMs = 0;
    index = 0;
    cancelSleep();
    notifyListeners();
  }

  /// Called when the tape was deleted or changed in the editor.
  Future<void> refresh() async {
    final t = tape;
    if (t == null) return;
    if (_lib.tape(t.id) == null) {
      await eject();
      return;
    }
    final was = playing;
    final cur = current?.id;
    final newQueue = _queueFor(t, side);
    final same =
        newQueue.length == queue.length &&
        [for (var i = 0; i < queue.length; i++) newQueue[i].id == queue[i].id]
            .every((x) => x);
    if (same) {
      notifyListeners();
      return;
    }
    final at = cur == null ? 0 : newQueue.indexWhere((s) => s.id == cur);
    await load(
      t,
      side: side,
      startIndex: at < 0 ? 0 : at,
      play: was && at >= 0,
      silent: true,
    );
  }

  // ---- spooling

  Future<void> startScan(int dir) async {
    if (!loaded) return;
    await _stopScan();
    scan = dir;
    _resumeAfterScan = playing;
    if (playing) await _engine.pause();
    _scanTicks = 0;
    HapticFeedback.selectionClick();
    _scanTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _scanStep(),
    );
    notifyListeners();
  }

  Future<void> endScan() async {
    if (scan == 0) return;
    final resume = _resumeAfterScan;
    await _stopScan();
    if (ended) return;
    if (resume) await _engine.play();
  }

  Future<void> _stopScan() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    if (scan != 0) {
      scan = 0;
      notifyListeners();
    }
  }

  Future<void> _scanStep() async {
    final total = sideMs;
    final target = doneMs + scan * 6000;
    _scanTicks++;
    if (_scanTicks % 3 == 0) {
      HapticFeedback.selectionClick();
    }
    if (target >= total) {
      await _stopScan();
      await _engine.pause();
      if (_resumeAfterScan) {
        await _onSideEnd();
      } else {
        await _seekSide(total - 1);
      }
      return;
    }
    if (target <= 0) {
      await _stopScan();
      await _seekSide(0);
      if (_resumeAfterScan) await _engine.play();
      return;
    }
    await _seekSide(target);
  }

  /// Moves to [ms] on the whole side.
  Future<void> _seekSide(int ms) async {
    var rest = ms.clamp(0, sideMs);
    var i = 0;
    while (i < queue.length - 1 && rest >= queue[i].ms) {
      rest -= queue[i].ms;
      i++;
    }
    index = i;
    posMs = rest;
    notifyListeners();
    await _engine.seek(Duration(milliseconds: rest), index: i);
  }

  /// For the sleeper screen / tests: jump somewhere on the side.
  Future<void> seekTo(double fraction) =>
      _seekSide((sideMs * fraction).round());

  // ---- engine events

  void _onIndex(int i) {
    if (_opening || queue.isEmpty || i >= queue.length) return;
    if (i != index) {
      index = i;
      posMs = 0;
      notifyListeners();
    }
  }

  void _onPosition(Duration d) {
    if (_opening || scan != 0) return;
    posMs = d.inMilliseconds;
    notifyListeners();
  }

  void _onPlaying(bool p) {
    if (_opening || scan != 0 || p == playing) return;
    playing = p;
    notifyListeners();
  }

  Future<void> _onSideEnd() async {
    if (!loaded || ended) return;
    final t = tape!;
    final wasAuto = _lib.settings.autoFlip;
    if (sleep == SleepMode.endOfSide) {
      cancelSleep();
      await _finishSide();
      return;
    }
    if (wasAuto && side == Side.a && t.b.isNotEmpty) {
      await flip(play: true);
      return;
    }
    await _finishSide();
  }

  Future<void> _finishSide() async {
    playing = false;
    ended = true;
    posMs = 0;
    index = 0;
    notifyListeners();
    await _engine.pause();
    if (queue.isNotEmpty) await _engine.seek(Duration.zero, index: 0);
  }

  // ---- sleep timer

  void setSleep(Duration? d, {bool endOfSide = false}) {
    cancelSleep();
    if (endOfSide) {
      sleep = SleepMode.endOfSide;
    } else if (d != null) {
      sleep = SleepMode.timer;
      _sleepAt = _clock().add(d);
      _sleepTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _sleepTick(),
      );
    }
    notifyListeners();
  }

  void cancelSleep() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepAt = null;
    if (sleep != SleepMode.off) {
      sleep = SleepMode.off;
      _engine.setVolume(1);
      notifyListeners();
    }
  }

  Future<void> _sleepTick() async {
    final left = sleepLeft;
    if (left == null) return;
    if (left <= Duration.zero) {
      cancelSleep();
      await pause();
      await _engine.setVolume(1);
      return;
    }
    // The tape runs out: the last 20 seconds fade away.
    if (left.inSeconds < 20) {
      await _engine.setVolume(left.inMilliseconds / 20000);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _sleepTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
