import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../backends.dart';
import '../cards.dart';
import '../design.dart';
import '../format.dart';
import '../l10n/app_localizations.dart';
import '../parser.dart';
import '../stats.dart';

class _Slide {
  const _Slide(this.tone, this.kicker, this.title, {this.big, this.count, this.body, this.sub, this.action});
  final Tone tone;
  final String kicker;
  final String title;

  /// A huge piece of text (emoji, word) shown above the title.
  final String? big;

  /// A number that counts up from zero.
  final num? count;
  final Widget? body;
  final String? sub;
  final Widget? action;
}

/// The chat as full-screen story slides, like a year-in-review.
class StoryScreen extends StatefulWidget {
  const StoryScreen({
    super.key,
    required this.chat,
    required this.stats,
    required this.sharer,
    required this.isPro,
    required this.onUnlock,
    required this.onPoster,
    this.autoPlay = true,
    this.initialIndex = 0,
  });

  final Chat chat;
  final Stats stats;
  final ShareBackend sharer;
  final bool isPro;
  final VoidCallback onUnlock;
  final VoidCallback onPoster;
  final bool autoPlay;
  final int initialIndex;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _timer =
      AnimationController(vsync: this, duration: const Duration(seconds: 7))..addStatusListener(_onTick);
  final _boundary = GlobalKey();
  late int _index = widget.initialIndex;
  int _count = 1;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) _timer.forward();
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  void _onTick(AnimationStatus s) {
    if (s == AnimationStatus.completed && _index < _count - 1) _go(_index + 1);
  }

  void _go(int i) {
    if (i < 0 || i >= _count) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    _timer.forward(from: 0);
    if (!widget.autoPlay) _timer.stop();
  }

  Future<void> _share() async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    _timer.stop();
    HapticFeedback.lightImpact();
    try {
      await WidgetsBinding.instance.endOfFrame;
      final b = _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await b.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await widget.sharer.shareImage(data!.buffer.asUint8List(), text: l.shareText);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.shareFailed)));
    }
  }

  List<_Slide> _slides(BuildContext context) {
    final l = L.of(context);
    final s = widget.stats;
    final chat = widget.chat;
    final top = s.people.isEmpty ? null : s.people.first;
    final slides = <_Slide>[
      _Slide(Tone.violet, l.storyIntroKicker, l.storyIntroTitle(s.days),
          sub: '${s.people.take(4).map((p) => p.name).join(' · ')}\n'
              '${l.chatPeriod(dateText(context, chat.first), dateText(context, chat.last))}'),
      _Slide(Tone.coral, l.storyTotalKicker, l.labelMessages,
          count: s.total, sub: l.storyTotalSub(decimal(context, s.perDay)), body: MonthBars(s)),
      if (top != null && s.people.length > 1)
        _Slide(Tone.pink, l.storyWhoKicker, l.storyWhoTitle(top.name, (s.share(top) * 100).round()),
            body: OverviewPeople(s)),
      _Slide(Tone.blue, l.storyHourKicker, l.storyHourTitle(hourRange(l, s.peakHour)), body: RhythmBody(s)),
      if (s.topWords.isNotEmpty)
        _Slide(Tone.sun, l.storyWordKicker, l.storyWordTitle(s.topWords.first.value),
            big: '„${s.topWords.first.key}“', body: WordsBody(s, limit: widget.isPro ? 12 : 3)),
    ];
    if (!widget.isPro) {
      slides.add(_Slide(Tone.night, l.locked, l.storyLockedTitle,
          sub: l.storyLockedText,
          action: GradientButton(
              label: l.storyLockedButton, icon: Icons.lock_open_rounded, onPressed: widget.onUnlock)));
      return slides;
    }
    final fastest = (s.people.where((p) => p.medianReply != null).toList()
          ..sort((a, b) => a.medianReply!.compareTo(b.medianReply!)))
        .firstOrNull;
    final starter = s.people.isEmpty ? null : ([...s.people]..sort((a, b) => b.starts.compareTo(a.starts))).first;
    final active = yearDays(s).where((d) => (s.dayCounts[d] ?? 0) > 0).length;
    slides.addAll([
      _Slide(Tone.teal, l.cardCloud, l.storyCloudTitle, body: WordCloudBody(s, count: 24)),
      if (fastest != null && s.people.length > 1)
        _Slide(Tone.pink, l.cardReplies, l.storyReplyTitle(fastest.name), body: RepliesBody(s)),
      if (starter != null && s.people.length > 1)
        _Slide(Tone.night, l.cardStarters, l.storyStarterTitle(starter.name), body: StartersBody(s)),
      if (s.topEmoji.isNotEmpty)
        _Slide(Tone.coral, l.cardEmoji, l.storyEmojiTitle, big: s.topEmoji.first.key, body: EmojiBody(s)),
      _Slide(Tone.blue, l.cardYear, l.yearSummary(active, yearDays(s).length), body: YearBandBody(s)),
      if (s.people.length >= 2) _Slide(Tone.sun, l.cardAwards, l.storyAwardsTitle, body: AwardsBody(s)),
      _Slide(Tone.teal, l.cardRecords, l.recordStreakValue(s.longestStreak), body: RecordsBody(s)),
      _Slide(Tone.violet, l.storyOutroKicker, l.storyOutroTitle,
          action: Column(children: [
            GradientButton(
                label: l.posterButton, icon: Icons.auto_awesome_mosaic_rounded, tone: Tone.coral, onPressed: widget.onPoster),
            const SizedBox(height: 8),
            TextButton(onPressed: () => _go(0), child: Text(l.storyRestart, style: const TextStyle(color: Colors.white))),
          ])),
    ]);
    return slides;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final slides = _slides(context);
    _count = slides.length;
    final i = math.min(_index, slides.length - 1);
    final slide = slides[i];
    final fg = slide.tone.fg;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: slide.tone.dark ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: slide.tone.a,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            final w = MediaQuery.sizeOf(context).width;
            _go(d.localPosition.dx < w * 0.3 ? i - 1 : i + 1);
          },
          onLongPressStart: (_) => _timer.stop(),
          onLongPressEnd: (_) {
            if (widget.autoPlay) _timer.forward();
          },
          child: Stack(children: [
            Positioned.fill(
              child: RepaintBoundary(
                key: _boundary,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  child: _SlideView(key: ValueKey(i), slide: slide),
                ),
              ),
            ),
            SafeArea(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(children: [
                    for (var k = 0; k < slides.length; k++)
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                              color: fg.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                          alignment: Alignment.centerLeft,
                          child: k < i
                              ? Container(decoration: BoxDecoration(color: fg, borderRadius: BorderRadius.circular(2)))
                              : k == i
                                  ? AnimatedBuilder(
                                      animation: _timer,
                                      builder: (_, _) => FractionallySizedBox(
                                        widthFactor: widget.autoPlay ? _timer.value : 1,
                                        child: Container(
                                            decoration:
                                                BoxDecoration(color: fg, borderRadius: BorderRadius.circular(2))),
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                  ]),
                ),
                Row(children: [
                  const Spacer(),
                  IconButton(
                    tooltip: l.storyShare,
                    icon: Icon(Icons.ios_share_rounded, color: fg),
                    onPressed: _share,
                  ),
                  IconButton(
                    tooltip: l.storyClose,
                    icon: Icon(Icons.close_rounded, color: fg),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({super.key, required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = slide.tone;
    final fg = t.fg;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: t.gradient),
      child: Stack(children: [
        Positioned.fill(child: Blobs(tone: t)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 72, 26, 22),
            child: toned(
              context,
              t,
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(slide.kicker.toUpperCase(),
                    style: TextStyle(
                        fontFamily: Brand.text, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2, color: t.soft)),
                const SizedBox(height: 14),
                if (slide.big != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(slide.big!,
                        style: const TextStyle(
                            fontFamily: Brand.display,
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            fontFamilyFallback: ['NotoColorEmoji'])),
                  ),
                if (slide.count != null)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: slide.count!.toDouble()),
                    duration: const Duration(milliseconds: 1400),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(number(context, v.round()),
                          style: TextStyle(
                              fontFamily: Brand.display, fontSize: 104, fontWeight: FontWeight.w800, height: 1, color: fg)),
                    ),
                  ),
                Text(slide.title,
                    style: TextStyle(
                        fontFamily: Brand.display, fontSize: 38, fontWeight: FontWeight.w800, height: 1.08, color: fg)),
                if (slide.sub != null) ...[
                  const SizedBox(height: 14),
                  Text(slide.sub!, style: TextStyle(fontSize: 18, height: 1.35, color: t.soft)),
                ],
                const SizedBox(height: 24),
                if (slide.body != null)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: fg.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.2)),
                          child: slide.body!,
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (slide.action != null) ...[const SizedBox(height: 12), slide.action!],
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.gesture_rounded, size: 16, color: t.soft),
                  const SizedBox(width: 6),
                  Text(l.appTitle,
                      style: TextStyle(
                          fontFamily: Brand.display, fontSize: 15, fontWeight: FontWeight.w700, color: t.soft)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.storyTapHint,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: t.soft)),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
