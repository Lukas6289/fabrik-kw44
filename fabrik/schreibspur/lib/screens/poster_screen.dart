import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../backends.dart';
import '../cards.dart';
import '../design.dart';
import '../format.dart';
import '../l10n/app_localizations.dart';
import '../parser.dart';
import '../stats.dart';

/// All cards stacked into one tall image (Pro).
class Poster extends StatelessWidget {
  const Poster({super.key, required this.chat, required this.stats});
  final Chat chat;
  final Stats stats;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final s = stats;
    final names = s.people.take(3).map((p) => p.name).join(' · ') +
        (s.people.length > 3 ? ' +${s.people.length - 3}' : '');
    Widget card(String id, String title, Widget body) {
      final (tone, icon) = cardStyle[id]!;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: StatCard(title: title, tone: tone, icon: icon, footer: false, child: body),
      );
    }

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(14, 22, 14, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.gesture_rounded, color: cs.onSurface, size: 28),
          const SizedBox(width: 6),
          Text(l.appTitle, style: text.headlineSmall),
        ]),
        const SizedBox(height: 8),
        Text(names, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.headlineLarge),
        const SizedBox(height: 4),
        Text(l.chatPeriod(dateText(context, chat.first), dateText(context, chat.last)),
            textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: cs.outline)),
        const SizedBox(height: 16),
        card('overview', l.cardOverview, OverviewBody(s)),
        card('cloud', l.cardCloud, WordCloudBody(s)),
        card('year', l.cardYear, YearBandBody(s)),
        card('rhythm', l.cardRhythm, RhythmBody(s)),
        card('replies', l.cardReplies, RepliesBody(s)),
        card('starters', l.cardStarters, StartersBody(s)),
        card('emoji', l.cardEmoji, EmojiBody(s)),
        card('records', l.cardRecords, RecordsBody(s)),
        if (s.people.length >= 2) card('awards', l.cardAwards, AwardsBody(s)),
        card('compare', l.cardCompare, CompareBody(chat: chat)),
        const SizedBox(height: 6),
        Text(l.posterMadeWith,
            textAlign: TextAlign.center, style: text.labelLarge?.copyWith(color: cs.outline)),
      ]),
    );
  }
}

class PosterScreen extends StatefulWidget {
  const PosterScreen({super.key, required this.chat, required this.stats, required this.sharer});
  final Chat chat;
  final Stats stats;
  final ShareBackend sharer;

  @override
  State<PosterScreen> createState() => _PosterScreenState();
}

class _PosterScreenState extends State<PosterScreen> {
  final _boundary = GlobalKey();
  final _button = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final box = _button.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null ? Rect.zero : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final b = _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // tall posters: stay below ~12 000 px so the image fits in memory
      final ratio = math.min(3.0, 12000 / math.max(b.size.height, 1));
      final image = await b.toImage(pixelRatio: ratio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await widget.sharer.shareImage(data!.buffer.asUint8List(), text: l.shareText, origin: origin);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.shareFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.posterTitle)),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: RepaintBoundary(
                    key: _boundary,
                    child: Poster(chat: widget.chat, stats: widget.stats),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(children: [
              Text(l.posterHint, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              KeyedSubtree(
                key: _button,
                child: GradientButton(
                  label: l.posterShare,
                  icon: Icons.ios_share_rounded,
                  onPressed: _busy ? null : _share,
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
