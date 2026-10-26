import 'library.dart';
import 'models.dart';

/// Four tiny original jingles that ship with the app, so the first tape plays right away.
/// (Written for Bandsalat; roughly 16–25 seconds each.)
const _jingles = [
  ('assets/sample/morgenkaffee.wav', 20871),
  ('assets/sample/nachtbus.wav', 18462),
  ('assets/sample/sommerbrause.wav', 16001),
  ('assets/sample/letzte-reihe.wav', 25263),
];

/// Puts the sample songs and one sample tape into an empty library (once).
void seedSample(Library lib, String lang) {
  if (lib.settings.sampleSeeded ||
      lib.songs.isNotEmpty ||
      lib.tapes.isNotEmpty) {
    lib.markSampleSeeded();
    return;
  }
  final de = lang == 'de';
  final names = de
      ? ['Morgenkaffee', 'Nachtbus', 'Sommerbrause', 'Letzte Reihe']
      : ['Morning Coffee', 'Night Bus', 'Summer Fizz', 'Back Row'];
  final songs = <Song>[
    for (var i = 0; i < _jingles.length; i++)
      lib.addSong(
        title: names[i],
        artist: 'Bandsalat',
        file: 'asset:${_jingles[i].$1}',
        ms: _jingles[i].$2,
      ),
  ];
  final t = lib.createTape(
    name: de ? 'Probier-Band' : 'Test Tape',
    minutes: 30,
    shell: 0,
    label: 0,
    dedication: de ? 'Zum Reinhören' : 'Just to try',
  )!;
  lib.addToSide(t, Side.a, songs[0].id);
  lib.addToSide(t, Side.a, songs[1].id);
  lib.addToSide(t, Side.b, songs[2].id);
  lib.addToSide(t, Side.b, songs[3].id);
  lib.markSampleSeeded();
}
