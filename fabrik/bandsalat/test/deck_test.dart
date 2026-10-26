import 'package:bandsalat/deck.dart';
import 'package:bandsalat/models.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<(Rig, Tape, List<int>)> setup({bool autoFlip = true}) async {
  final rig = await Rig.create();
  final lib = rig.lib;
  final t = lib.createTape(name: 'Mix', minutes: 30)!;
  final lens = [60000, 90000, 30000];
  for (var i = 0; i < 3; i++) {
    final s = lib.addSong(title: 'Song $i', file: 'f$i.mp3', ms: lens[i]);
    lib.addToSide(t, i < 2 ? Side.a : Side.b, s.id);
  }
  lib.setAutoFlip(autoFlip);
  return (rig, t, lens);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load queues side A with the right files and tags', () async {
    final (rig, t, _) = await setup();
    await rig.deck.load(t);
    expect(rig.engine.items.map((i) => i.title), ['Song 0', 'Song 1']);
    expect(rig.engine.items.first.source, '/songs/f0.mp3');
    expect(rig.engine.items.first.album, 'Mix · A');
    expect(rig.deck.sideMs, 150000);
    expect(rig.deck.playing, isFalse);
    expect(rig.lib.settings.lastTape, t.id);
  });

  test(
    'play moves the position through the whole side and the counter follows',
    () async {
      final (rig, t, lens) = await setup();
      await rig.deck.load(t, play: true);
      expect(rig.deck.playing, isTrue);
      rig.engine.advance(30000, [lens[0], lens[1]]);
      expect(rig.deck.doneMs, 30000);
      expect(rig.deck.counter, 10);
      rig.engine.advance(45000, [lens[0], lens[1]]);
      expect(rig.deck.index, 1);
      expect(rig.deck.doneMs, 75000);
      expect(rig.deck.progress, closeTo(0.5, 0.001));
    },
  );

  test(
    'next / previous: previous restarts the song first, then goes back',
    () async {
      final (rig, t, lens) = await setup();
      await rig.deck.load(t, play: true);
      await rig.deck.next();
      expect(rig.deck.index, 1);
      rig.engine.advance(10000, [lens[0], lens[1]]);
      await rig.deck.previous();
      expect(rig.deck.index, 1);
      expect(rig.deck.posMs, 0);
      await rig.deck.previous();
      expect(rig.deck.index, 0);
    },
  );

  test(
    'end of side A flips to side B on its own when auto flip is on',
    () async {
      final (rig, t, lens) = await setup();
      await rig.deck.load(t, play: true);
      rig.engine.advance(150000, [lens[0], lens[1]]);
      await Future<void>.delayed(Duration.zero);
      expect(rig.deck.side, Side.b);
      expect(rig.deck.flips, 1);
      expect(rig.engine.items.map((i) => i.title), ['Song 2']);
      expect(rig.deck.playing, isTrue);
    },
  );

  test(
    'without auto flip the deck stops at the end of side A and waits',
    () async {
      final (rig, t, lens) = await setup(autoFlip: false);
      await rig.deck.load(t, play: true);
      rig.engine.advance(150000, [lens[0], lens[1]]);
      await Future<void>.delayed(Duration.zero);
      expect(rig.deck.side, Side.a);
      expect(rig.deck.ended, isTrue);
      expect(rig.deck.playing, isFalse);
      await rig.deck.flip(play: true);
      expect(rig.deck.side, Side.b);
      expect(rig.deck.ended, isFalse);
    },
  );

  test('end of side B ends the tape', () async {
    final (rig, t, _) = await setup();
    await rig.deck.load(t, side: Side.b, play: true);
    rig.engine.advance(30000, [30000]);
    await Future<void>.delayed(Duration.zero);
    expect(rig.deck.ended, isTrue);
    expect(rig.deck.side, Side.b);
  });

  test(
    'spooling forward jumps in big steps and resumes playing on release',
    () async {
      final (rig, t, _) = await setup();
      await rig.deck.load(t, play: true);
      fakeAsync((fa) {
        rig.deck.startScan(1);
        fa.elapse(const Duration(milliseconds: 500));
        expect(rig.deck.scan, 1);
        expect(rig.deck.doneMs, greaterThanOrEqualTo(25000));
        expect(rig.engine.isPlaying, isFalse);
        rig.deck.endScan();
        fa.flushMicrotasks();
        expect(rig.deck.scan, 0);
        expect(rig.engine.isPlaying, isTrue);
      });
    },
  );

  test('spooling back stops at the start of the side', () async {
    final (rig, t, _) = await setup();
    await rig.deck.load(t, startIndex: 1);
    fakeAsync((fa) {
      rig.deck.startScan(-1);
      fa.elapse(const Duration(seconds: 5));
      fa.flushMicrotasks();
      expect(rig.deck.doneMs, 0);
      expect(rig.deck.scan, 0);
    });
  });

  test(
    'sleep timer: volume fades in the last 20 seconds, then it pauses',
    () async {
      final start = DateTime(2026, 10, 26, 22);
      var now = start;
      final rig = await Rig.create(clock: () => now);
      final t = rig.lib.createTape(name: 'x')!;
      final s = rig.lib.addSong(title: 'long', file: 'l.mp3', ms: 600000);
      rig.lib.addToSide(t, Side.a, s.id);
      await rig.deck.load(t, play: true);
      fakeAsync((fa) {
        rig.deck.setSleep(const Duration(seconds: 40));
        expect(rig.deck.sleep, SleepMode.timer);
        void go(int sec) {
          now = start.add(Duration(seconds: sec));
          fa.elapse(Duration(seconds: sec) - (fa.elapsed));
        }

        go(15);
        expect(rig.engine.volume, 1);
        go(30);
        expect(rig.engine.volume, closeTo(0.5, 0.06));
        go(41);
        fa.flushMicrotasks();
        expect(rig.engine.isPlaying, isFalse);
        expect(rig.deck.sleep, SleepMode.off);
        expect(rig.engine.volume, 1);
      });
    },
  );

  test('sleep at the end of the side stops instead of flipping', () async {
    final (rig, t, lens) = await setup();
    await rig.deck.load(t, play: true);
    rig.deck.setSleep(null, endOfSide: true);
    rig.engine.advance(150000, [lens[0], lens[1]]);
    await Future<void>.delayed(Duration.zero);
    expect(rig.deck.side, Side.a);
    expect(rig.deck.ended, isTrue);
    expect(rig.deck.sleep, SleepMode.off);
  });

  test('editing the tape while it is loaded keeps the current song', () async {
    final (rig, t, _) = await setup();
    await rig.deck.load(t, startIndex: 1, play: true);
    final extra = rig.lib.addSong(title: 'New', file: 'n.mp3', ms: 20000);
    rig.lib.addToSide(t, Side.a, extra.id, at: 0);
    await rig.deck.refresh();
    expect(rig.deck.queue.map((s) => s.title), ['New', 'Song 0', 'Song 1']);
    expect(rig.deck.current!.title, 'Song 1');
    rig.lib.deleteTape(t.id);
    await rig.deck.refresh();
    expect(rig.deck.tape, isNull);
  });

  test('a tape with an empty side A opens on side B', () async {
    final rig = await Rig.create();
    final t = rig.lib.createTape(name: 'x')!;
    final s = rig.lib.addSong(title: 'b', file: 'b.mp3', ms: 1000);
    rig.lib.addToSide(t, Side.b, s.id);
    await rig.deck.load(t);
    expect(rig.deck.side, Side.b);
  });
}
