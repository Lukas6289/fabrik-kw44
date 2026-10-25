import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'design.dart';
import 'format.dart';
import 'l10n/app_localizations.dart';
import 'parser.dart';
import 'stats.dart';

const personColors = [
  Color(0xFF6C5CE7),
  Color(0xFFE17055),
  Color(0xFF00B894),
  Color(0xFFFDCB6E),
  Color(0xFF0984E3),
  Color(0xFFE84393),
  Color(0xFF636E72),
  Color(0xFF00CEC9),
];

Color colorOf(BuildContext context, Stats s, PersonStats p) {
  final list = ToneScope.maybeOf(context)?.people ?? personColors;
  return list[s.people.indexOf(p) % list.length];
}

/// Frame shared by all cards: a bold gradient tile. The whole tile is what gets
/// shared as an image.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    this.boundaryKey,
    required this.title,
    required this.child,
    this.tone = Tone.violet,
    this.icon = Icons.auto_awesome_rounded,
    this.onShare,
    this.locked = false,
    this.onUnlock,
    this.footer = true,
  });

  final GlobalKey? boundaryKey;
  final String title;
  final Widget child;
  final Tone tone;
  final IconData icon;
  final void Function(Rect origin)? onShare;
  final bool locked;
  final VoidCallback? onUnlock;
  final bool footer;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final shareKey = GlobalKey();
    final fg = tone.fg;
    return RepaintBoundary(
      key: boundaryKey,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: tone.gradient, borderRadius: BorderRadius.circular(28)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(children: [
            Positioned.fill(child: Blobs(tone: tone)),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: locked ? onUnlock : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                  child: toned(
                    context,
                    tone,
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: fg.withValues(alpha: 0.18), shape: BoxShape.circle),
                          child: Icon(icon, size: 19, color: fg),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(title,
                              style: TextStyle(
                                  fontFamily: Brand.display, fontSize: 21, fontWeight: FontWeight.w800, color: fg)),
                        ),
                        if (locked)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.lock_rounded, size: 20, color: fg),
                          )
                        else if (onShare != null)
                          IconButton(
                            key: shareKey,
                            tooltip: l.share,
                            icon: Icon(Icons.ios_share_rounded, color: fg),
                            onPressed: () {
                              final box = shareKey.currentContext?.findRenderObject() as RenderBox?;
                              onShare!(box == null ? Rect.zero : box.localToGlobal(Offset.zero) & box.size);
                            },
                          ),
                      ]),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: locked
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: fg.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text('${l.locked} · ${l.lockedTap}',
                                    style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
                              )
                            : child,
                      ),
                      if (footer) ...[
                        const SizedBox(height: 14),
                        Row(children: [
                          Icon(Icons.gesture_rounded, size: 15, color: tone.soft),
                          const SizedBox(width: 4),
                          Text(l.appTitle,
                              style: TextStyle(
                                  fontFamily: Brand.display, fontSize: 13, fontWeight: FontWeight.w700, color: tone.soft)),
                        ]),
                      ],
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: fraction.clamp(0.0, 1.0),
          minHeight: 10,
          color: color,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(children: [
        FittedBox(child: Text(value, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
        Text(label,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
      ]),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.name, required this.color, required this.fraction, required this.value});
  final String name;
  final Color color;
  final double fraction;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          _Bar(fraction: fraction, color: color),
        ]),
      );
}

class OverviewBody extends StatelessWidget {
  const OverviewBody(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final text = Theme.of(context).textTheme;
    final shown = s.people.take(8).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(number(context, s.total),
          style: text.displayMedium),
      Text(l.labelMessages, style: text.bodyMedium),
      const SizedBox(height: 12),
      Row(children: [
        _Tile(number(context, s.days), l.labelDays),
        _Tile(number(context, s.activeDays), l.labelActiveDays),
        _Tile(decimal(context, s.perDay), l.labelPerDay),
      ]),
      const SizedBox(height: 10),
      for (final p in shown)
        _PersonRow(
          name: p.name,
          color: colorOf(context, s, p),
          fraction: s.share(p),
          value: '${number(context, p.messages)} · ${(s.share(p) * 100).round()} %',
        ),
      if (s.people.length > shown.length)
        Text('+ ${s.people.length - shown.length}', style: text.bodySmall),
    ]);
  }
}

class RhythmBody extends StatelessWidget {
  const RhythmBody(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hourMax = s.byHour.reduce((a, b) => a > b ? a : b);
    final dayMax = s.byWeekday.reduce((a, b) => a > b ? a : b);
    Widget bars(List<int> v, int max, int peak, double height) => SizedBox(
          height: height,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < v.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Container(
                    height: max == 0 ? 2 : 2 + (height - 2) * v[i] / max,
                    decoration: BoxDecoration(
                      color: i == peak ? cs.primary : cs.primary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      bars(s.byHour, hourMax, s.peakHour, 70),
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          for (final h in const [0, 6, 12, 18, 23]) Text('$h', style: text.labelSmall),
        ]),
      ),
      const SizedBox(height: 6),
      Text(l.rhythmHour(hourRange(l, s.peakHour)), style: text.titleSmall),
      const SizedBox(height: 14),
      bars(s.byWeekday, dayMax, s.peakWeekday, 50),
      Row(children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Text(weekdayName(context, i).substring(0, 2),
                textAlign: TextAlign.center, style: text.labelSmall),
          ),
      ]),
      const SizedBox(height: 6),
      Text(l.rhythmDay(weekdayName(context, s.peakWeekday)), style: text.titleSmall),
    ]);
  }
}

class WordsBody extends StatelessWidget {
  const WordsBody(this.s, {super.key, required this.limit});
  final Stats s;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final cs = Theme.of(context).colorScheme;
    if (s.topWords.isEmpty) return Text(l.wordsEmpty);
    final shown = s.topWords.take(limit).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final w in shown)
          Chip(
            label: Text('${w.key}  ${l.timesUsed(w.value)}'),
            backgroundColor: cs.primaryContainer,
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
      ]),
      if (s.topWords.length > shown.length) ...[
        const SizedBox(height: 8),
        Text(l.wordsMore, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.primary)),
      ],
    ]);
  }
}

class RepliesBody extends StatelessWidget {
  const RepliesBody(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final list = s.people.where((p) => p.medianReply != null).toList()
      ..sort((a, b) => a.medianReply!.compareTo(b.medianReply!));
    final slowest = list.isEmpty ? 1 : list.last.medianReply!.inSeconds.clamp(1, 1 << 30);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.repliesHint, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 6),
      for (final p in list.take(8))
        _PersonRow(
          name: p.name,
          color: colorOf(context, s, p),
          fraction: p.medianReply!.inSeconds / slowest,
          value: durationText(l, p.medianReply!),
        ),
    ]);
  }
}

class StartersBody extends StatelessWidget {
  const StartersBody(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final list = [...s.people]..sort((a, b) => b.starts.compareTo(a.starts));
    final top = list.isEmpty || list.first.starts == 0 ? 1 : list.first.starts;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.startersHint, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 6),
      for (final p in list.take(8))
        _PersonRow(
          name: p.name,
          color: colorOf(context, s, p),
          fraction: p.starts / top,
          value: l.startsCount(p.starts),
        ),
    ]);
  }
}

class EmojiBody extends StatelessWidget {
  const EmojiBody(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    if (s.topEmoji.isEmpty) return Text(l.noEmoji);
    return Wrap(spacing: 14, runSpacing: 8, children: [
      for (final e in s.topEmoji)
        Column(children: [
          Text(e.key, style: const TextStyle(fontSize: 32, fontFamilyFallback: ['NotoColorEmoji'])),
          Text(l.timesUsed(e.value), style: Theme.of(context).textTheme.labelMedium),
        ]),
    ]);
  }
}

class RecordsBody extends StatelessWidget {
  const RecordsBody(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    Widget row(IconData icon, String title, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.labelMedium),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ]),
            ),
          ]),
        );
    return Column(children: [
      if (s.busiestDay != null)
        row(Icons.local_fire_department_rounded, l.recordBusiestDay,
            l.recordBusiestDayValue(dateText(context, s.busiestDay!), s.busiestDayCount)),
      if (s.pauseFrom != null)
        row(Icons.hourglass_bottom_rounded, l.recordPause,
            l.recordPauseValue(durationText(l, s.longestPause), dateText(context, s.pauseFrom!))),
      row(Icons.bolt_rounded, l.recordStreak, l.recordStreakValue(s.longestStreak)),
    ]);
  }
}

class AwardsBody extends StatelessWidget {
  const AwardsBody(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final cs = Theme.of(context).colorScheme;
    (IconData, String, String) info(AwardKind k) => switch (k) {
          AwardKind.most => (Icons.forum_rounded, l.awardMost, l.awardMostText),
          AwardKind.fast => (Icons.flash_on_rounded, l.awardFast, l.awardFastText),
          AwardKind.starter => (Icons.waving_hand_rounded, l.awardStarter, l.awardStarterText),
          AwardKind.novel => (Icons.menu_book_rounded, l.awardNovel, l.awardNovelText),
          AwardKind.owl => (Icons.nightlight_round, l.awardOwl, l.awardOwlText),
        };
    return Column(children: [
      for (final (kind, who) in awardsFor(s))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            CircleAvatar(
              backgroundColor: colorOf(context, s, who).withValues(alpha: 0.2),
              child: Icon(info(kind).$1, color: colorOf(context, s, who)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(info(kind).$2, style: Theme.of(context).textTheme.labelLarge),
                Text(info(kind).$3, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline)),
              ]),
            ),
            Flexible(
              child: Text(who.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
    ]);
  }
}

class CompareBody extends StatelessWidget {
  const CompareBody({super.key, required this.chat});
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cmp = defaultComparison(chat);
    if (cmp == null) return Text(l.compareNeedMore);
    final (r1, r2) = cmp;
    final a = computeStats(chat, range: r1);
    final b = computeStats(chat, range: r2);
    String period(DateRange r) =>
        l.chatPeriod(dateText(context, r.from), dateText(context, r.to.subtract(const Duration(days: 1))));

    Widget row(String label, String before, String now, String? change) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Expanded(flex: 4, child: Text(label, style: text.bodyMedium)),
            Expanded(flex: 2, child: Text(before, textAlign: TextAlign.end)),
            Expanded(
                flex: 2,
                child: Text(now, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
            Expanded(
                flex: 2,
                child: Text(change ?? '',
                    textAlign: TextAlign.end,
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600))),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${l.compareBefore}: ${period(r1)}', style: text.bodySmall),
      Text('${l.compareNow}: ${period(r2)}', style: text.bodySmall),
      const SizedBox(height: 6),
      row(l.labelMessages, number(context, a.total), number(context, b.total),
          changeText(context, a.total, b.total)),
      row(l.labelActiveDays, number(context, a.activeDays), number(context, b.activeDays),
          changeText(context, a.activeDays, b.activeDays)),
      row(
          l.labelWords,
          number(context, a.people.fold(0, (x, p) => x + p.words)),
          number(context, b.people.fold(0, (x, p) => x + p.words)),
          changeText(context, a.people.fold(0, (x, p) => x + p.words),
              b.people.fold(0, (x, p) => x + p.words))),
    ]);
  }
}


/// Word cloud of everyone's favourite words; colour shows who writes it most.
class WordCloudBody extends StatelessWidget {
  const WordCloudBody(this.s, {super.key, this.count = 30});
  final Stats s;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final text = Theme.of(context).textTheme;
    final words = wordCloud(s, n: count);
    if (words.isEmpty) return Text(l.wordsEmpty);
    final top = words.first.count;
    // biggest words in the middle, smaller ones towards the edges
    final ordered = <CloudWord>[];
    for (var i = 0; i < words.length; i++) {
      if (i.isEven) {
        ordered.add(words[i]);
      } else {
        ordered.insert(0, words[i]);
      }
    }
    final owners = <PersonStats>{for (final w in words) w.owner}.toList()
      ..sort((a, b) => s.people.indexOf(a).compareTo(s.people.indexOf(b)));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.cloudHint, style: text.bodySmall),
      const SizedBox(height: 12),
      Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 2,
        children: [
          for (final w in ordered)
            Text(
              w.word,
              style: TextStyle(
                fontSize: 13 + 27 * math.sqrt(w.count / top),
                fontWeight: w.count * 2 >= top ? FontWeight.w800 : FontWeight.w600,
                color: colorOf(context, s, w.owner),
                height: 1.15,
              ),
            ),
        ],
      ),
      if (owners.length > 1) ...[
        const SizedBox(height: 12),
        Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 4, children: [
          for (final p in owners.take(8))
            Row(mainAxisSize: MainAxisSize.min, children: [
              CircleAvatar(radius: 5, backgroundColor: colorOf(context, s, p)),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.labelMedium),
              ),
            ]),
        ]),
      ],
    ]);
  }
}

/// One row per month, one strip per day; the stronger the colour, the more messages.
class YearBandBody extends StatelessWidget {
  const YearBandBody(this.s, {super.key});
  final Stats s;

  /// 0 = no messages, 1–4 = quarters of the busiest day.
  static int level(int count, int max) {
    if (count <= 0 || max <= 0) return 0;
    return (count / max * 4).ceil().clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final days = yearDays(s);
    if (days.isEmpty) return Text(l.wordsEmpty);
    final max = s.dayCounts.values.fold(0, math.max);
    Color colorFor(int lv) => lv == 0
        ? cs.surfaceContainerHighest
        : cs.primary.withValues(alpha: const <double>[0, 0.3, 0.55, 0.8, 1.0][lv]);
    final months = <DateTime>[];
    for (final d in days) {
      final m = DateTime(d.year, d.month);
      if (months.isEmpty || months.last != m) months.add(m);
    }
    final first = days.first, last = days.last;
    final active = days.where((d) => (s.dayCounts[d] ?? 0) > 0).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final m in months)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: Row(children: [
            SizedBox(
              width: 44,
              child: Text(
                monthLabel(context, m, withYear: m.month == 1 || m == months.first),
                style: text.labelSmall,
                maxLines: 1,
              ),
            ),
            for (var day = 1; day <= 31; day++)
              Expanded(child: () {
                final d = DateTime(m.year, m.month, day);
                final inside = d.month == m.month && !d.isBefore(first) && !d.isAfter(last);
                return Container(
                  height: 13,
                  margin: const EdgeInsets.symmetric(horizontal: 0.6),
                  decoration: BoxDecoration(
                    color: inside ? colorFor(level(s.dayCounts[d] ?? 0, max)) : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }()),
          ]),
        ),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: Text(l.yearSummary(active, days.length), style: text.bodySmall)),
        Text(l.yearLess, style: text.labelSmall),
        for (var lv = 0; lv <= 4; lv++)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(color: colorFor(lv), borderRadius: BorderRadius.circular(2)),
          ),
        Text(l.yearMore, style: text.labelSmall),
      ]),
    ]);
  }
}

/// Colour and icon of each card, shared by the list, the poster and the story.
const cardStyle = <String, (Tone, IconData)>{
  'overview': (Tone.violet, Icons.forum_rounded),
  'rhythm': (Tone.coral, Icons.schedule_rounded),
  'words': (Tone.sun, Icons.format_quote_rounded),
  'cloud': (Tone.teal, Icons.cloud_rounded),
  'year': (Tone.blue, Icons.calendar_month_rounded),
  'replies': (Tone.pink, Icons.bolt_rounded),
  'starters': (Tone.night, Icons.waving_hand_rounded),
  'emoji': (Tone.coral, Icons.emoji_emotions_rounded),
  'records': (Tone.teal, Icons.emoji_events_rounded),
  'awards': (Tone.sun, Icons.military_tech_rounded),
  'compare': (Tone.blue, Icons.compare_arrows_rounded),
};

/// Share of messages per person (story slide "who writes more").
class OverviewPeople extends StatelessWidget {
  const OverviewPeople(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) => Column(children: [
        for (final p in s.people.take(6))
          _PersonRow(
            name: p.name,
            color: colorOf(context, s, p),
            fraction: s.share(p),
            value: '${number(context, p.messages)} · ${(s.share(p) * 100).round()} %',
          ),
      ]);
}

/// Messages per month over the chat year (story slide "you wrote …").
class MonthBars extends StatelessWidget {
  const MonthBars(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final days = yearDays(s);
    if (days.isEmpty) return const SizedBox.shrink();
    final months = <DateTime, int>{};
    for (final d in days) {
      final m = DateTime(d.year, d.month);
      months[m] = (months[m] ?? 0) + (s.dayCounts[d] ?? 0);
    }
    final top = months.values.fold(1, math.max);
    final best = months.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 150,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (final e in months.entries)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: e.value / top),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => Container(
                    height: 4 + 146 * v,
                    decoration: BoxDecoration(
                      color: e.key == best ? cs.primary : cs.primary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 6),
      Row(children: [
        for (final m in months.keys)
          Expanded(
            child: Text(monthLabel(context, m).substring(0, 1),
                textAlign: TextAlign.center, style: text.labelSmall),
          ),
      ]),
    ]);
  }
}
