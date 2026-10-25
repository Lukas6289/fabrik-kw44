import 'package:flutter_test/flutter_test.dart';
import 'package:schreibspur/parser.dart';
import 'package:schreibspur/sample.dart';
import 'package:schreibspur/cards.dart' show YearBandBody;
import 'package:schreibspur/stats.dart';

Message m(String who, DateTime t, [String text = 'hallo']) => Message(t, who, text);

void main() {
  final d = DateTime(2026, 10, 19, 9); // a Monday

  test('counts, shares and words (stop words and numbers are skipped)', () {
    final chat = Chat([
      m('A', d, 'Pizza Pizza und 123 der Hund'),
      m('B', d.add(const Duration(minutes: 1)), 'Pizza gut'),
      m('A', d.add(const Duration(minutes: 2)), 'Hund Hund Hund'),
    ]);
    final s = computeStats(chat);
    expect(s.total, 3);
    expect(s.people.first.name, 'A');
    expect(s.share(s.people.first), closeTo(2 / 3, 1e-9));
    expect(s.topWords.map((e) => '${e.key}:${e.value}').take(2), ['hund:4', 'pizza:3']);
    expect(s.topWords.any((e) => e.key == 'der' || e.key == '123'), isFalse);
    expect(s.people.first.words, 9);
  });

  test('reply times use the median and ignore long silences', () {
    final chat = Chat([
      m('A', d),
      m('B', d.add(const Duration(minutes: 2))),
      m('A', d.add(const Duration(minutes: 3))),
      m('B', d.add(const Duration(minutes: 13))),
      m('A', d.add(const Duration(hours: 20))), // new talk, not a reply
    ]);
    final s = computeStats(chat);
    final b = s.people.firstWhere((p) => p.name == 'B');
    expect(b.replyTimes, [const Duration(minutes: 2), const Duration(minutes: 10)]);
    expect(b.medianReply, const Duration(minutes: 10));
    final a = s.people.firstWhere((p) => p.name == 'A');
    expect(a.replyTimes, [const Duration(minutes: 1)]);
  });

  test('conversation starters: first message and after 6 h of silence', () {
    final chat = Chat([
      m('A', d),
      m('B', d.add(const Duration(minutes: 5))),
      m('B', d.add(const Duration(hours: 8))),
      m('A', d.add(const Duration(hours: 8, minutes: 1))),
      m('A', d.add(const Duration(hours: 14, minutes: 2))),
    ]);
    final s = computeStats(chat);
    expect(s.people.firstWhere((p) => p.name == 'A').starts, 2);
    expect(s.people.firstWhere((p) => p.name == 'B').starts, 1);
  });

  test('rhythm, records, streak and pause', () {
    final chat = Chat([
      m('A', DateTime(2026, 10, 19, 23)), // Mon
      m('A', DateTime(2026, 10, 20, 23)),
      m('B', DateTime(2026, 10, 21, 23)),
      m('B', DateTime(2026, 10, 21, 23, 5)),
      m('A', DateTime(2026, 10, 25, 3)), // Sun, after a pause
    ]);
    final s = computeStats(chat);
    expect(s.peakHour, 23);
    expect(s.byWeekday[0], 1);
    expect(s.peakWeekday, 2); // Wednesday, two messages
    expect(s.busiestDay, DateTime(2026, 10, 21));
    expect(s.busiestDayCount, 2);
    expect(s.longestStreak, 3);
    expect(s.activeDays, 4);
    expect(s.days, 7);
    expect(s.longestPause, DateTime(2026, 10, 25, 3).difference(DateTime(2026, 10, 21, 23, 5))); // real time, DST-aware
    expect(s.pauseFrom, DateTime(2026, 10, 21, 23, 5));
    expect(s.people.firstWhere((p) => p.name == 'A').night, 1);
  });

  test('emoji are counted, variation selectors ignored', () {
    final chat = Chat([m('A', d, 'toll 😂😂 ❤️ ❤'), m('B', d, 'ja 😂')]);
    final s = computeStats(chat);
    expect(s.topEmoji.map((e) => '${e.key}:${e.value}'), ['😂:3', '❤:2']);
  });

  test('period filter keeps only messages inside', () {
    final chat = Chat([
      m('A', DateTime(2026, 1, 1, 10)),
      m('A', DateTime(2026, 6, 1, 10)),
      m('A', DateTime(2026, 6, 2, 10)),
    ]);
    final s = computeStats(chat, range: DateRange(DateTime(2026, 6, 1), DateTime(2026, 7, 1)));
    expect(s.total, 2);
  });

  test('awards need meaningful winners', () {
    final s = computeStats(sampleChat(now: DateTime(2026, 10, 22)));
    final kinds = awardsFor(s).map((a) => a.$1).toSet();
    expect(kinds, containsAll([AwardKind.most, AwardKind.fast, AwardKind.starter, AwardKind.novel]));
    final solo = computeStats(Chat([m('A', d)]));
    expect(awardsFor(solo), isEmpty);
  });

  test('default comparison splits older and newer; short chats give none', () {
    final chat = sampleChat(now: DateTime(2026, 10, 22));
    final (before, now) = defaultComparison(chat)!;
    expect(before.to, now.from);
    final a = computeStats(chat, range: before);
    final b = computeStats(chat, range: now);
    expect(a.total, greaterThan(0));
    expect(b.total, greaterThan(a.total), reason: 'the sample gets chattier');
    expect(defaultComparison(Chat([m('A', d), m('B', d.add(const Duration(days: 3)))])), isNull);
  });

  test('empty range gives empty stats without crashing', () {
    final chat = Chat([m('A', d)]);
    final s = computeStats(chat, range: DateRange(DateTime(2000), DateTime(2001)));
    expect(s.isEmpty, isTrue);
    expect(s.perDay, 0);
  });

  test('word cloud: biggest first, coloured by who writes the word most', () {
    final chat = Chat([
      m('A', d, 'Pizza Pizza Pizza Kino'),
      m('B', d.add(const Duration(minutes: 1)), 'Kino Kino Pizza'),
    ]);
    final s = computeStats(chat);
    final cloud = wordCloud(s);
    expect(cloud.map((w) => '${w.word}:${w.count}:${w.owner.name}'), ['pizza:4:A', 'kino:3:B']);
    expect(wordCloud(computeStats(chat), n: 1).length, 1);
    expect(wordCloud(computeStats(Chat([m('A', d, 'ja ok')]))), isEmpty);
  });

  test('chat year: counts per day, at most 365 days ending on the last chat day', () {
    final chat = Chat([
      m('A', DateTime(2024, 1, 5, 10)),
      m('B', DateTime(2025, 3, 1, 10)),
      m('A', DateTime(2025, 3, 1, 11)),
      m('A', DateTime(2025, 6, 30, 23)),
    ]);
    final s = computeStats(chat);
    expect(s.dayCounts[DateTime(2025, 3, 1)], 2);
    final days = yearDays(s);
    expect(days.length, 365);
    expect(days.last, DateTime(2025, 6, 30));
    expect(days.first, DateTime(2024, 7, 1));
    // a short chat starts on its first day
    final short = yearDays(computeStats(Chat([m('A', d), m('B', d.add(const Duration(days: 9)))])));
    expect(short.length, 10);
    expect(short.first, DateTime(2026, 10, 19));
  });

  test('sample chat fills the cloud and the year band', () {
    final s = computeStats(sampleChat(now: DateTime(2026, 10, 22)));
    expect(wordCloud(s).length, greaterThanOrEqualTo(10));
    expect(wordCloud(s).map((w) => w.owner.name).toSet().length, greaterThanOrEqualTo(2));
    expect(yearDays(s), isNotEmpty);
  });

  test('year band colour levels are quarters of the busiest day', () {
    expect(YearBandBody.level(0, 20), 0);
    expect(YearBandBody.level(1, 20), 1);
    expect(YearBandBody.level(6, 20), 2);
    expect(YearBandBody.level(15, 20), 3);
    expect(YearBandBody.level(20, 20), 4);
  });

  test('day span ignores daylight-saving changes', () {
    expect(dayDiff(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
    expect(dayDiff(DateTime(2026, 3, 1), DateTime(2026, 6, 30)), 121);
  });
}
