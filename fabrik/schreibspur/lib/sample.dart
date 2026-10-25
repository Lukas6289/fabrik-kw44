import 'parser.dart';

/// A made-up conversation for the "try it with an example" button and the
/// screenshots. No real people.
Chat sampleChat({DateTime? now, String lang = 'de'}) {
  final en = lang != 'de';
  final end = now ?? DateTime.now();
  final today = DateTime(end.year, end.month, end.day);
  final out = <Message>[];
  var seed = 7;
  int rnd(int n) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed % n;
  }

  const luisaDe = [
    'Guten Morgen! Hast du gut geschlafen?',
    'Kaffee heute Abend? ☕',
    'Das war so lustig gestern 😂',
    'Ich bin gleich da, nur noch kurz Zähne putzen',
    'Hast du das Foto gesehen? Wahnsinn',
    'Pizza oder Pasta? Ich nehme Pizza 🍕',
    'Wann kommst du aus dem Büro?',
    'Danke dir, du bist der Beste ❤️',
  ];
  const jonasDe = [
    'Morgen! Ja, bis der Wecker kam.',
    'Klar, um acht beim Italiener?',
    'Haha, ich lache immer noch 😂',
    'Ich bin schon unterwegs, Pizza klingt gut',
    'Gesehen. Sieht nach Urlaub aus',
    'Pasta! Wie immer, Pasta',
    'Gegen sechs, dann Pizza',
    'Immer gern, Kaffee geht auf mich ☕',
  ];
  const maraDe = [
    'Ich bin dabei! Wann treffen wir uns?',
    'Bringe Kuchen mit 🎂',
    'Bin leider etwas später da',
    'Super Idee, Pizza passt',
  ];
  const luisaEn = [
    'Good morning! Did you sleep well?',
    'Coffee tonight? ☕',
    'That was so funny yesterday 😂',
    'Almost there, just brushing my teeth',
    'Did you see the photo? Amazing',
    'Pizza or pasta? I will take pizza 🍕',
    'When are you leaving the office?',
    'Thank you, you are the best ❤️',
  ];
  const jonasEn = [
    'Morning! Yes, until the alarm went off.',
    'Sure, eight at the Italian place?',
    'Haha, still laughing 😂',
    'Already on my way, pizza sounds good',
    'Seen it. Looks like holidays',
    'Pasta! Always pasta',
    'Around six, then pizza',
    'Anytime, coffee is on me ☕',
  ];
  const maraEn = [
    "I'm in! When do we meet?",
    'Bringing cake 🎂',
    'Running a bit late, sorry',
    'Great idea, pizza works',
  ];
  final luisa = en ? luisaEn : luisaDe;
  final jonas = en ? jonasEn : jonasDe;
  final mara = en ? maraEn : maraDe;
  for (var d = 400; d >= 0; d--) {
    final day = today.subtract(Duration(days: d));
    final weekend = day.weekday >= 6;
    final base = d < 200 ? 8 : 4; // the recent half is chattier
    final holiday = (d > 60 && d < 75) || (d > 250 && d < 262); // trips: busy days
    final n = holiday ? 18 + rnd(14) : (weekend ? base + rnd(10) : base + rnd(8));
    if (rnd(holiday ? 40 : 7) == 0) continue; // quiet day
    var t = DateTime(day.year, day.month, day.day, 7 + rnd(3), rnd(60));
    var turn = rnd(2);
    for (var i = 0; i < n; i++) {
      t = t.add(Duration(minutes: 1 + rnd(i % 5 == 4 ? 240 : 25)));
      if (t.hour > 23 || (t.day != day.day)) break;
      if (rnd(3) != 0) turn = 1 - turn;
      final who = rnd(9) == 0 ? 2 : turn;
      final line = who == 0
          ? luisa[rnd(luisa.length)]
          : who == 1
              ? jonas[rnd(jonas.length)]
              : mara[rnd(mara.length)];
      out.add(Message(t, ['Luisa', 'Jonas', 'Mara'][who], line));
    }
  }
  return Chat(out);
}
