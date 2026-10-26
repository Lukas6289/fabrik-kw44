import 'dart:math';

import 'package:flutter/material.dart';

import '../deck.dart';
import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services.dart';
import 'jcard_screen.dart';
import 'tape_editor.dart';
import 'widgets.dart';

/// Puts [tape] into the deck (unless it is in already) and shows the deck.
Future<void> openTape(
  BuildContext context,
  Tape tape, {
  bool play = false,
}) async {
  final s = ServicesScope.read(context);
  final nav = Navigator.of(context);
  if (s.deck.tape?.id != tape.id) {
    final side = s.library.settings.lastTape == tape.id
        ? s.library.settings.lastSide
        : null;
    await s.deck.load(tape, side: side, play: play);
  }
  await nav.push(softRoute(const DeckScreen()));
}

/// The deck: a big cassette with turning reels, a counter, five keys, the side's songs, sleep timer.
class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final l = L.of(context);
    final p = Pal.of(context);
    final deck = s.deck;
    return ListenableBuilder(
      listenable: deck,
      builder: (context, _) {
        final t = deck.tape;
        if (t == null) {
          return Scaffold(
            body: PaperBackground(
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: BackButton(color: p.ink),
                ),
              ),
            ),
          );
        }
        final sh = shells[t.shell];
        final tint = Color.lerp(
          sh.body,
          p.dark ? Pal.navy : Pal.paper,
          p.dark ? 0.6 : 0.66,
        )!;
        return Scaffold(
          body: PaperBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                children: [
                  Row(
                    children: [
                      Key3(
                        width: 44,
                        height: 40,
                        semantics: l.back,
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.expand_more_rounded,
                          color: p.ink,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: disp(16, p.ink),
                            ),
                            Text(
                              'C${t.minutes} · ${l.sideLabel(deck.side.letter)}',
                              style: body(13, p.soft, weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Key3(
                        width: 44,
                        height: 40,
                        semantics: l.editTape,
                        onTap: () async {
                          await Navigator.of(context)
                              .push(softRoute(TapeEditor(tape: t)));
                          await deck.refresh();
                        },
                        child: Icon(Icons.edit_rounded, color: p.ink, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Riso(
                    color: tint,
                    radius: 24,
                    offset: 6,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      children: [
                        _Flipper(
                          key: ValueKey('flip${deck.flips}'),
                          child: Reeling(
                            active: deck.playing || deck.scan != 0,
                            fast: deck.scan != 0,
                            builder: (c, a) => Cassette(
                              shell: t.shell,
                              label: t.label,
                              side: deck.side.letter,
                              title: t.name,
                              subtitle: t.dedication,
                              reel: deck.scan < 0 ? -a : a,
                              progress: deck.progress,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _Counter(deck: deck),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Keys(deck: deck),
                  if (deck.ended)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        deck.side == Side.a && t.b.isNotEmpty
                            ? l.endOfSideFlip
                            : l.endOfTape,
                        textAlign: TextAlign.center,
                        style: body(15, p.red, weight: FontWeight.w700),
                      ),
                    ),
                  const SizedBox(height: 22),
                  _Queue(deck: deck),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _Chip(
                          icon: Icons.bedtime_rounded,
                          label: _sleepLabel(context, deck),
                          active: deck.sleep != SleepMode.off,
                          onTap: () => showSleepSheet(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Chip(
                          icon: Icons.menu_book_rounded,
                          label: l.jcardShort,
                          onTap: () =>
                              Navigator.of(context)
                                  .push(softRoute(JCardScreen(tape: t))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Riso(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    radius: 16,
                    offset: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.autoFlip,
                            style: body(16, p.ink, weight: FontWeight.w700),
                          ),
                        ),
                        Switch(
                          value: s.library.settings.autoFlip,
                          onChanged: (v) => s.library.setAutoFlip(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _sleepLabel(BuildContext context, Deck d) {
    final l = L.of(context);
    switch (d.sleep) {
      case SleepMode.off:
        return l.sleepTimer;
      case SleepMode.endOfSide:
        return l.sleepEndOfSide;
      case SleepMode.timer:
        final left = d.sleepLeft ?? Duration.zero;
        return l.sleepLeft(max(1, (left.inSeconds / 60).ceil()));
    }
  }
}

class _Flipper extends StatelessWidget {
  const _Flipper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 520),
    curve: Curves.easeOutBack,
    child: child,
    builder: (context, t, child) => Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY((1 - t.clamp(0.0, 1.2)) * (pi / 2))
        ..scaleByDouble(max(0.001, t.clamp(0.0, 1.05)), 1, 1, 1),
      child: child,
    ),
  );
}

/// Amber counter on dark glass: three digits, time on the side, side letter.
class _Counter extends StatelessWidget {
  const _Counter({required this.deck});
  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    const amber = Color(0xFFFFB84D);
    final cur = deck.current;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15121A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Pal.navy, width: 2),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                deck.counter.toString().padLeft(3, '0'),
                style: disp(34, amber, height: 1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${clock(deck.doneMs)} / ${clock(deck.sideMs)}',
                      style: const TextStyle(
                        fontFamily: mono,
                        fontSize: 15,
                        color: amber,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cur == null ? '–' : cur.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: body(
                        14,
                        amber.withValues(alpha: 0.85),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: amber, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  deck.side.letter,
                  style: disp(18, amber, height: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            label: l.positionOnSide,
            child: _Playhead(deck: deck),
          ),
        ],
      ),
    );
  }
}

class _Playhead extends StatelessWidget {
  const _Playhead({required this.deck});
  final Deck deck;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        void seek(double dx) => deck.seekTo((dx / c.maxWidth).clamp(0.0, 1.0));
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => seek(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => seek(d.localPosition.dx),
          child: SizedBox(
            height: 22,
            child: CustomPaint(
              size: Size.infinite,
              painter: _HeadPainter(
                deck.progress,
                deck.queue.map((s) => s.ms).toList(),
                deck.index,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeadPainter extends CustomPainter {
  _HeadPainter(this.progress, this.lengths, this.index);
  final double progress;
  final List<int> lengths;
  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    const amber = Color(0xFFFFB84D);
    final y = size.height / 2;
    final total = lengths.fold(0, (a, b) => a + b);
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = amber.withValues(alpha: 0.25)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width * progress, y),
      Paint()
        ..color = amber
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    var acc = 0;
    for (var i = 0; i < lengths.length - 1; i++) {
      acc += lengths[i];
      final x = size.width * acc / max(1, total);
      canvas.drawLine(
        Offset(x, y - 6),
        Offset(x, y + 6),
        Paint()
          ..color = amber.withValues(alpha: 0.6)
          ..strokeWidth = 2,
      );
    }
    canvas.drawCircle(
      Offset(size.width * progress, y),
      7,
      Paint()..color = amber,
    );
    canvas.drawCircle(
      Offset(size.width * progress, y),
      7,
      Paint()
        ..color = const Color(0xFF15121A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_HeadPainter o) =>
      o.progress != progress ||
      o.index != index ||
      o.lengths.length != lengths.length;
}

class _Keys extends StatelessWidget {
  const _Keys({required this.deck});
  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final p = Pal.of(context);
    Widget ic(IconData i, [Color? c]) => Icon(i, color: c ?? p.ink, size: 26);
    return LayoutBuilder(
      builder: (context, c) {
        final u = ((c.maxWidth - 12) / 5.3).clamp(40.0, 58.0);
        final w = u;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Key3(
              width: w,
              semantics: l.rewind,
              active: deck.scan < 0,
              onTap: deck.previous,
              onHoldStart: () => deck.startScan(-1),
              onHoldEnd: deck.endScan,
              child: ic(Icons.fast_rewind_rounded),
            ),
            Key3(
              width: u * 1.3,
              semantics: deck.playing ? l.pause : l.play,
              color: Pal.tomato,
              active: deck.playing,
              onTap: deck.toggle,
              child: ic(
                deck.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                Colors.white,
              ),
            ),
            Key3(
              width: w,
              semantics: l.stop,
              onTap: deck.stop,
              child: ic(Icons.stop_rounded),
            ),
            Key3(
              width: w,
              semantics: l.forward,
              active: deck.scan > 0,
              onTap: deck.next,
              onHoldStart: () => deck.startScan(1),
              onHoldEnd: deck.endScan,
              child: ic(Icons.fast_forward_rounded),
            ),
            Key3(
              width: w,
              semantics: l.flipTape,
              color: Pal.mustard,
              onTap: () => deck.flip(),
              child: Icon(Icons.flip_rounded, color: Pal.navy, size: 26),
            ),
          ],
        );
      },
    );
  }
}

class _Queue extends StatelessWidget {
  const _Queue({required this.deck});
  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final p = Pal.of(context);
    final q = deck.queue;
    if (q.isEmpty) {
      return Riso(
        child: Text(l.sideEmpty(deck.side.letter), style: body(16, p.soft)),
      );
    }
    return Riso(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < q.length; i++)
            InkWell(
              onTap: () {
                tick();
                deck.jumpTo(i);
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: i == deck.index
                      ? Pal.mustard.withValues(alpha: p.dark ? 0.9 : 1)
                      : null,
                  border: i == q.length - 1
                      ? null
                      : Border(bottom: BorderSide(color: p.line, width: 1.5)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: i == deck.index && deck.playing
                          ? const Icon(
                              Icons.graphic_eq_rounded,
                              size: 22,
                              color: Pal.navy,
                            )
                          : Text(
                              '${i + 1}',
                              style: disp(
                                14,
                                i == deck.index ? Pal.navy : p.soft,
                              ),
                            ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q[i].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: body(
                              16,
                              i == deck.index ? Pal.navy : p.ink,
                              weight: FontWeight.w700,
                            ),
                          ),
                          if (q[i].artist.isNotEmpty)
                            Text(
                              q[i].artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: body(
                                13,
                                i == deck.index
                                    ? Pal.navy.withValues(alpha: 0.7)
                                    : p.soft,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      clock(q[i].ms),
                      style: body(
                        14,
                        i == deck.index ? Pal.navy : p.soft,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Riso(
      color: active ? Pal.teal : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      radius: 16,
      offset: 3,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: active ? Colors.white : p.ink),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: body(
                15,
                active ? Colors.white : p.ink,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sleep timer: the tape runs out after a while (the last seconds fade) or at the end of the side.
Future<void> showSleepSheet(BuildContext context) {
  final s = ServicesScope.read(context);
  final l = L.of(context);
  final p = Pal.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.card,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: p.ink, width: 2),
    ),
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.sleepTimer, style: disp(20, p.ink)),
            const SizedBox(height: 6),
            Text(l.sleepBody, style: body(15, p.soft)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final m in [15, 30, 45, 60])
                  _SleepOption(
                    label: l.minutesShort(m),
                    onTap: () {
                      s.deck.setSleep(Duration(minutes: m));
                      Navigator.pop(c);
                    },
                  ),
                _SleepOption(
                  label: l.sleepEndOfSide,
                  onTap: () {
                    s.deck.setSleep(null, endOfSide: true);
                    Navigator.pop(c);
                  },
                ),
                if (s.deck.sleep != SleepMode.off)
                  _SleepOption(
                    label: l.sleepOff,
                    color: Pal.tomato,
                    onTap: () {
                      s.deck.cancelSleep();
                      Navigator.pop(c);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

class _SleepOption extends StatelessWidget {
  const _SleepOption({required this.label, required this.onTap, this.color});
  final String label;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? Pal.mustard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.ink, width: 2),
        ),
        child: Text(
          label,
          style: body(
            16,
            color == null ? Pal.navy : Colors.white,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
