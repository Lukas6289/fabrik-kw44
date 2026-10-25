import 'dart:math';

import 'parser.dart';

class DateRange {
  const DateRange(this.from, this.to);

  /// Inclusive start day, exclusive end day.
  final DateTime from;
  final DateTime to;

  bool contains(DateTime t) => !t.isBefore(from) && t.isBefore(to);
}

class PersonStats {
  PersonStats(this.name);
  final String name;
  int messages = 0;
  int words = 0;
  int media = 0;
  int night = 0; // messages between 0:00 and 4:59
  int starts = 0; // conversations opened
  int replies = 0;
  Duration replyTotal = Duration.zero;
  final List<Duration> replyTimes = [];
  final Map<String, int> wordCounts = {}; // meaningful words only (no fillers)

  double get wordsPerMessage => messages == 0 ? 0 : words / messages;

  /// Median is robust against the night-long pauses.
  Duration? get medianReply {
    if (replyTimes.isEmpty) return null;
    final s = [...replyTimes]..sort();
    return s[s.length ~/ 2];
  }
}

class Stats {
  Stats({
    required this.people,
    required this.total,
    required this.days,
    required this.activeDays,
    required this.byHour,
    required this.byWeekday,
    required this.topWords,
    required this.topEmoji,
    required this.busiestDay,
    required this.busiestDayCount,
    required this.longestPause,
    required this.pauseFrom,
    required this.longestStreak,
    required this.range,
    required this.dayCounts,
  });

  /// Sorted by message count, busiest first.
  final List<PersonStats> people;
  final int total;
  final int days; // calendar span
  final int activeDays;
  final List<int> byHour; // 24
  final List<int> byWeekday; // 7, Monday first
  final List<MapEntry<String, int>> topWords;
  final List<MapEntry<String, int>> topEmoji;
  final DateTime? busiestDay;
  final int busiestDayCount;
  final Duration longestPause;
  final DateTime? pauseFrom;
  final int longestStreak; // consecutive days with messages
  final DateRange? range;

  /// Messages per calendar day (only days with messages).
  final Map<DateTime, int> dayCounts;

  bool get isEmpty => total == 0;
  double get perDay => days == 0 ? 0 : total / days;
  int get peakHour => byHour.indexOf(byHour.reduce(max));
  int get peakWeekday => byWeekday.indexOf(byWeekday.reduce(max)); // 0 = Monday

  double share(PersonStats p) => total == 0 ? 0 : p.messages / total;
}

/// Calendar days between two dates, immune to daylight-saving shifts.
int dayDiff(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

/// A new conversation starts after this much silence.
const conversationGap = Duration(hours: 6);

/// A reply later than this is not counted as a reply.
const replyLimit = Duration(hours: 6);

/// German and English filler words, chat noise included.
final _stopwords = (
    'der die das und ist ich du er sie es wir ihr nicht ein eine einen einem mit auf für '
    'von zu den dem des im in an am auch so wie was wo wer dann noch schon aber oder wenn '
    'als bei nach mal da ja nein doch nur mir mich dir dich uns sich bin bist sind war '
    'hab habe hat haben wird kann ob um aus über mehr sehr gerade heute jetzt hier dass '
    'ok okay denn ne na eh mein meine dein deine man bis vor ganz gut gleich wäre würde '
    'the and you that for are with this have not but what your can all just its it is to '
    'of a i my me we he she they be on at do if or no yes will would been from there then '
    'out got get ill dont thats like how when now too had has her him one about up as by '
    'were them some who did why haha hahaha lol http https www com null '
    'still well way around already almost anytime also into than very much over more any even really '
    'just got going gonna wanna yeah yep nope okay sure our us his its could should '
    'went off until mit uns euch ihr ihm ihn sein seine nochmal schon bitte hatte'
).split(' ').where((w) => w.isNotEmpty).toSet();

final _wordSplit = RegExp(r"[^\p{L}\p{N}']+", unicode: true);
final _emoji = RegExp(
  r'(?:[\u{1F300}-\u{1FAFF}]|[\u{2600}-\u{27BF}]|[\u{1F000}-\u{1F2FF}]|\u{2B50}|\u{2B06}|\u{2764})(?:\u{FE0F})?',
  unicode: true,
);

/// Computes everything the cards show. [range] limits the chat to a period.
Stats computeStats(Chat chat, {DateRange? range}) {
  final msgs = range == null ? chat.messages : chat.messages.where((m) => range.contains(m.time)).toList();
  final people = <String, PersonStats>{};
  final byHour = List.filled(24, 0);
  final byWeekday = List.filled(7, 0);
  final words = <String, int>{};
  final emoji = <String, int>{};
  final perDay = <DateTime, int>{};

  Message? prev;
  var longest = Duration.zero;
  DateTime? pauseFrom;
  for (final m in msgs) {
    final p = people.putIfAbsent(m.sender, () => PersonStats(m.sender));
    p.messages++;
    if (m.media) p.media++;
    if (m.time.hour < 5) p.night++;
    byHour[m.time.hour]++;
    byWeekday[m.time.weekday - 1]++;
    final day = DateTime(m.time.year, m.time.month, m.time.day);
    perDay[day] = (perDay[day] ?? 0) + 1;

    if (!m.media) {
      for (final w in m.text.toLowerCase().split(_wordSplit)) {
        if (w.isEmpty) continue;
        p.words++;
        if (w.length < 3 || _stopwords.contains(w) || RegExp(r'^\d+$').hasMatch(w)) continue;
        words[w] = (words[w] ?? 0) + 1;
        p.wordCounts[w] = (p.wordCounts[w] ?? 0) + 1;
      }
      for (final e in _emoji.allMatches(m.text)) {
        final key = e[0]!.replaceAll('\u{FE0F}', '');
        emoji[key] = (emoji[key] ?? 0) + 1;
      }
    }

    if (prev == null) {
      p.starts++;
    } else {
      final gap = m.time.difference(prev.time);
      if (gap > longest) {
        longest = gap;
        pauseFrom = prev.time;
      }
      if (gap > conversationGap) {
        p.starts++;
      } else if (prev.sender != m.sender && gap <= replyLimit) {
        p.replies++;
        p.replyTotal += gap;
        p.replyTimes.add(gap);
      }
    }
    prev = m;
  }

  final sorted = people.values.toList()..sort((a, b) => b.messages.compareTo(a.messages));
  List<MapEntry<String, int>> top(Map<String, int> m, int n) {
    final l = m.entries.toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    return l.take(n).toList();
  }

  DateTime? busiest;
  var busiestCount = 0;
  perDay.forEach((d, c) {
    if (c > busiestCount || (c == busiestCount && busiest != null && d.isBefore(busiest!))) {
      busiest = d;
      busiestCount = c;
    }
  });

  final dayList = perDay.keys.toList()..sort();
  var streak = 0, best = 0;
  DateTime? lastDay;
  for (final d in dayList) {
    final consecutive = lastDay != null && DateTime(d.year, d.month, d.day - 1) == lastDay;
    streak = consecutive ? streak + 1 : 1;
    best = max(best, streak);
    lastDay = d;
  }

  final span = msgs.isEmpty ? 0 : dayDiff(msgs.first.time, msgs.last.time) + 1;

  return Stats(
    people: sorted,
    total: msgs.length,
    days: span,
    activeDays: perDay.length,
    byHour: byHour,
    byWeekday: byWeekday,
    topWords: top(words, 20),
    topEmoji: top(emoji, 8),
    busiestDay: busiest,
    busiestDayCount: busiestCount,
    longestPause: longest,
    pauseFrom: pauseFrom,
    longestStreak: best,
    range: range,
    dayCounts: perDay,
  );
}

class CloudWord {
  const CloudWord(this.word, this.count, this.owner);
  final String word;
  final int count;

  /// The person who uses the word most.
  final PersonStats owner;
}

/// The most frequent words of everyone, each tagged with whoever uses it most.
List<CloudWord> wordCloud(Stats s, {int n = 30}) {
  final out = <CloudWord>[];
  for (final e in _topWords(s, n)) {
    PersonStats? owner;
    var best = 0;
    for (final p in s.people) {
      final c = p.wordCounts[e.key] ?? 0;
      if (c > best) {
        best = c;
        owner = p;
      }
    }
    if (owner != null) out.add(CloudWord(e.key, e.value, owner));
  }
  return out;
}

Iterable<MapEntry<String, int>> _topWords(Stats s, int n) {
  final all = <String, int>{};
  for (final p in s.people) {
    p.wordCounts.forEach((w, c) => all[w] = (all[w] ?? 0) + c);
  }
  final l = all.entries.toList()
    ..sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
  return l.take(n);
}

/// One year of days for the chat-year band: ends on the last chat day and
/// goes back at most 365 days (or to the first day of the chat).
List<DateTime> yearDays(Stats s) {
  if (s.dayCounts.isEmpty) return const [];
  final days = s.dayCounts.keys.toList()..sort();
  final last = days.last;
  var first = DateTime(last.year, last.month, last.day - 364);
  if (days.first.isAfter(first)) first = days.first;
  final out = <DateTime>[];
  for (var d = first; !d.isAfter(last); d = DateTime(d.year, d.month, d.day + 1)) {
    out.add(d);
  }
  return out;
}

/// Splits the chat into "this year" vs "last year", or, for shorter chats,
/// the last half versus the half before. Null if there is too little data.
(DateRange, DateRange)? defaultComparison(Chat chat) {
  if (chat.isEmpty) return null;
  final end = DateTime(chat.last.year, chat.last.month, chat.last.day + 1);
  final start = DateTime(chat.first.year, chat.first.month, chat.first.day);
  final span = dayDiff(start, end);
  if (span < 14) return null;
  final half = span ~/ 2;
  final mid = DateTime(end.year, end.month, end.day - min(half, 365));
  final before = DateTime(mid.year, mid.month, mid.day - min(half, 365));
  return (DateRange(before, mid), DateRange(mid, end));
}

enum AwardKind { most, fast, starter, novel, owl }

/// Group awards. Only given when there is a clear, meaningful winner.
List<(AwardKind, PersonStats)> awardsFor(Stats s) {
  final p = s.people;
  if (p.length < 2) return const [];
  final out = <(AwardKind, PersonStats)>[];
  out.add((AwardKind.most, p.first));
  final fast = p.where((x) => x.replyTimes.length >= 5).toList()
    ..sort((a, b) => a.medianReply!.compareTo(b.medianReply!));
  if (fast.isNotEmpty) out.add((AwardKind.fast, fast.first));
  final starter = [...p]..sort((a, b) => b.starts.compareTo(a.starts));
  if (starter.first.starts > 0) out.add((AwardKind.starter, starter.first));
  final novel = p.where((x) => x.messages >= 20).toList()
    ..sort((a, b) => b.wordsPerMessage.compareTo(a.wordsPerMessage));
  if (novel.isNotEmpty) out.add((AwardKind.novel, novel.first));
  final owl = [...p]..sort((a, b) => b.night.compareTo(a.night));
  if (owl.first.night > 0) out.add((AwardKind.owl, owl.first));
  return out;
}
