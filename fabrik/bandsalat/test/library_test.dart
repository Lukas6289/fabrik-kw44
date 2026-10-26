import 'package:bandsalat/models.dart';
import 'package:bandsalat/pro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test(
    'title from file name drops extension, track number and underscores',
    () {
      expect(titleFromFile('03 - Night_Bus.mp3'), 'Night Bus');
      expect(titleFromFile('12. Sommerregen.m4a'), 'Sommerregen');
      expect(titleFromFile('/a/b/Track.wav'), 'Track');
      expect(titleFromFile('1999.mp3'), '1999');
      expect(clock(125000), '2:05');
    },
  );

  test(
    'side budget: songs that do not fit are refused, free time is counted',
    () async {
      final rig = await Rig.create();
      final lib = rig.lib;
      final t = lib.createTape(name: 'C30', minutes: 30)!; // 15 min per side
      final a = lib.addSong(title: 'A', file: 'a.mp3', ms: 6 * 60000);
      final b = lib.addSong(title: 'B', file: 'b.mp3', ms: 6 * 60000);
      final c = lib.addSong(title: 'C', file: 'c.mp3', ms: 6 * 60000);
      expect(lib.addToSide(t, Side.a, a.id), isTrue);
      expect(lib.addToSide(t, Side.a, b.id), isTrue);
      expect(lib.freeMs(t, Side.a), 3 * 60000);
      expect(lib.addToSide(t, Side.a, c.id), isFalse);
      expect(lib.addToSide(t, Side.b, c.id), isTrue);
      expect(lib.sideMs(t, Side.b), 6 * 60000);
      expect(lib.addToSide(t, Side.a, c.id, force: true), isTrue);
      expect(lib.freeMs(t, Side.a), lessThan(0));
    },
  );

  test('auto fill goes A then B and reports what is left over', () async {
    final rig = await Rig.create();
    final lib = rig.lib;
    final t = lib.createTape(name: 'x', minutes: 30)!;
    final ids = [
      for (var i = 0; i < 6; i++)
        lib.addSong(title: 'S$i', file: 's$i.mp3', ms: 5 * 60000).id,
    ];
    final left = lib.autoFill(t, ids);
    expect(t.a.length, 3);
    expect(t.b.length, 3);
    expect(left, 0);
    final more = lib.addSong(title: 'Z', file: 'z.mp3', ms: 5 * 60000);
    expect(lib.autoFill(t, [more.id]), 1);
    expect(lib.unused(t).map((s) => s.title), ['Z']);
  });

  test('reorder, flip a song to the other side, remove', () async {
    final rig = await Rig.create();
    final lib = rig.lib;
    final t = lib.createTape(name: 'x')!;
    final s = [
      for (var i = 0; i < 3; i++)
        lib.addSong(title: '$i', file: '$i.mp3', ms: 60000),
    ];
    for (final x in s) {
      lib.addToSide(t, Side.a, x.id);
    }
    lib.reorder(t, Side.a, 0, 2);
    expect(t.a, [s[1].id, s[2].id, s[0].id]);
    expect(lib.flipSong(t, Side.a, 0), isTrue);
    expect(t.b, [s[1].id]);
    expect(t.a.length, 2);
    lib.removeFromSide(t, Side.a, 0);
    expect(t.a, [s[0].id]);
  });

  test(
    'deleting a song removes it from every tape; returns the file to delete',
    () async {
      final rig = await Rig.create();
      final lib = rig.lib;
      final t = lib.createTape(name: 'x')!;
      final s = lib.addSong(title: 'a', file: 'f1.mp3', ms: 1000);
      lib.addToSide(t, Side.a, s.id);
      expect(lib.tapesWith(s.id), 1);
      expect(lib.removeSong(s.id), 'f1.mp3');
      expect(t.a, isEmpty);
      final sample = lib.addSong(
        title: 'b',
        file: 'asset:assets/sample/x.wav',
        ms: 1000,
      );
      expect(lib.removeSong(sample.id), isNull);
    },
  );

  test('free limits: 3 tapes, 3 looks; Pro lifts both', () async {
    final rig = await Rig.create();
    final lib = rig.lib;
    for (var i = 0; i < freeTapes; i++) {
      expect(lib.createTape(name: 'T$i'), isNotNull);
    }
    expect(lib.canAddTape, isFalse);
    expect(lib.createTape(name: 'one more'), isNull);
    expect(lib.commit(lib.draft(name: 'draft')), isFalse);
    expect(lib.styleAllowed(2), isTrue);
    expect(lib.styleAllowed(3), isFalse);
    await rig.pro.buy(proLifetimeId);
    expect(rig.pro.isPro, isTrue);
    expect(lib.canAddTape, isTrue);
    expect(lib.styleAllowed(7), isTrue);
    expect(lib.createTape(name: 'fancy', shell: 6), isNotNull);
  });

  test('a free user cannot smuggle in a Pro look', () async {
    final rig = await Rig.create();
    final t = rig.lib.createTape(name: 'x', shell: 5, label: 6)!;
    expect(t.shell, 0);
    expect(t.label, 0);
  });

  test('everything survives a restart; broken data does not crash', () async {
    final rig = await Rig.create();
    final lib = rig.lib;
    final t = lib.createTape(name: 'Mix', minutes: 60, dedication: 'für dich')!;
    final s = lib.addSong(
      title: 'Song',
      artist: 'Band',
      file: 'f.mp3',
      ms: 90000,
    );
    lib.addToSide(t, Side.b, s.id);
    lib.setAutoFlip(false);
    final again = (await Rig.create(
      prefs: {'data': rig.prefs.getString('data')!},
    )).lib;
    expect(again.tapes.single.name, 'Mix');
    expect(again.tapes.single.b, [s.id]);
    expect(again.songs.single.artist, 'Band');
    expect(again.settings.autoFlip, isFalse);
    final broken = (await Rig.create(prefs: {'data': '{not json'})).lib;
    expect(broken.tapes, isEmpty);
  });

  test('tape ids of songs that vanished are dropped on load', () async {
    final rig = await Rig.create();
    final lib = rig.lib;
    final t = lib.createTape(name: 'x')!;
    final s = lib.addSong(title: 'a', file: 'f.mp3', ms: 1000);
    lib.addToSide(t, Side.a, s.id);
    var raw = rig.prefs.getString('data')!;
    raw = raw.replaceFirst('"songs":[{', '"songs":[],"x":[{');
    final again = (await Rig.create(prefs: {'data': raw})).lib;
    expect(again.tapes.single.a, isEmpty);
  });
}
