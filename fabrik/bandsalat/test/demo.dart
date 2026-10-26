import 'package:bandsalat/library.dart';
import 'package:bandsalat/models.dart';

/// Fictional songs and tapes that make screenshots and look-and-feel tests lively.
Tape seedDemo(Library lib, String lang) {
  final de = lang == 'de';
  Song s(String t, String a, int min, int sec) => lib.addSong(
    title: t,
    artist: a,
    file: 'demo-${lib.songs.length}.m4a',
    ms: (min * 60 + sec) * 1000,
  );
  final songs = [
    s(de ? 'Neonregen' : 'Neon Rain', 'Kolibri Club', 3, 24),
    s(de ? 'Bus 47' : 'Bus 47', 'Die Nachtlinie', 4, 2),
    s(de ? 'Sommerbrause' : 'Summer Fizz', 'Lila Hafen', 2, 51),
    s(de ? 'Letzte Reihe' : 'Back Row', 'Mara Wolke', 3, 40),
    s(de ? 'Kaffee um Vier' : 'Coffee at Four', 'Kolibri Club', 3, 8),
    s(de ? 'Rückenwind' : 'Tailwind', 'Paper Planes', 3, 55),
    s(de ? 'Stadtlichter' : 'City Lights', 'Die Nachtlinie', 4, 31),
    s(de ? 'Barfuß' : 'Barefoot', 'Lila Hafen', 2, 47),
    s(de ? 'Hinterhof' : 'Backyard', 'Mara Wolke', 3, 19),
    s(de ? 'Zwei Uhr nachts' : 'Two a.m.', 'Paper Planes', 5, 12),
    s(de ? 'Kleine Wellen' : 'Little Waves', 'Lila Hafen', 3, 3),
    s(de ? 'Wir fahren los' : 'Let’s Drive', 'Kolibri Club', 3, 36),
  ];
  Tape mk(
    String name,
    int min,
    int shell,
    int label,
    String note,
    List<int> a,
    List<int> b,
  ) {
    final t = lib.createTape(
      name: name,
      minutes: min,
      shell: shell,
      label: label,
      dedication: note,
    )!;
    for (final i in a) {
      lib.addToSide(t, Side.a, songs[i].id, force: true);
    }
    for (final i in b) {
      lib.addToSide(t, Side.b, songs[i].id, force: true);
    }
    return t;
  }

  final summer = mk(
    de ? 'Sommer ’26' : 'Summer ’26',
    90,
    3,
    3,
    de ? 'Für Mia – bis zum nächsten Mal' : 'For Mia – see you next time',
    [0, 2, 4, 5, 7, 8, 10, 11],
    [1, 3, 6, 9],
  );
  mk(
    de ? 'Nachtfahrt' : 'Night Drive',
    60,
    4,
    4,
    de ? 'Fenster runter' : 'Windows down',
    [1, 6, 9],
    [3, 8],
  );
  mk(de ? 'Sonntagmorgen' : 'Sunday Morning', 46, 2, 2, '', [4, 7], [10, 2]);
  mk(
    de ? 'Roadtrip' : 'Road Trip',
    90,
    1,
    6,
    de ? 'Kassette 2 von 3' : 'Tape 2 of 3',
    [11, 5, 0],
    [7, 4, 10],
  );
  mk(de ? 'Lagerfeuer' : 'Campfire', 60, 5, 1, '', [8, 2], [7]);
  return summer;
}
