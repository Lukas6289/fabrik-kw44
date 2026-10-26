import 'package:bandsalat/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test(
    'import copies files, reads length and tags, skips what cannot be read',
    () async {
      final rig = await Rig.create();
      rig.info.known['Night_Bus.mp3'] = const AudioInfo(200000);
      rig.info.known['x.m4a'] = const AudioInfo(
        185000,
        title: 'Tagged Title',
        artist: 'The Band',
      );
      rig.picker.next = const [
        PickedFile('/tmp/Night_Bus.mp3', 'Night_Bus.mp3'),
        PickedFile('/tmp/x.m4a', 'x.m4a'),
        PickedFile('/tmp/notes.txt', 'notes.txt'),
      ];
      final r = await rig.services.importer.run();
      expect(r.added, 2);
      expect(r.failed, 1);
      expect(rig.lib.songs.map((s) => s.title), ['Night Bus', 'Tagged Title']);
      expect(rig.lib.songs[1].artist, 'The Band');
      expect(rig.lib.songs[0].ms, 200000);
      expect(rig.files.stored, ['f0.mp3', 'f1.m4a']);
    },
  );

  test('removing a song deletes its file, samples have none', () async {
    final rig = await Rig.create();
    final s = rig.lib.addSong(title: 'a', file: 'f0.mp3', ms: 1000);
    await rig.services.importer.remove(s.id);
    expect(rig.files.deleted, ['f0.mp3']);
    expect(rig.lib.songs, isEmpty);
  });

  test('cancelling the picker adds nothing', () async {
    final rig = await Rig.create();
    final r = await rig.services.importer.run();
    expect(r.added, 0);
    expect(r.failed, 0);
  });
}
