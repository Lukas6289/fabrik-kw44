import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services.dart';
import 'deck_screen.dart';
import 'pro_screen.dart';
import 'tape_editor.dart';
import 'widgets.dart';

/// Home: the featured tape (instantly playable) and every tape as a card.
class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final l = L.of(context);
    final p = Pal.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([s.library, s.pro]),
      builder: (context, _) {
        final lib = s.library;
        final feat = lib.featured;
        final others = [
          for (final t in lib.tapes)
            if (t != feat) t,
        ];
        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverList.list(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  for (final c in [
                                    Pal.tomato,
                                    Pal.mustard,
                                    Pal.teal,
                                  ])
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: c,
                                        border: Border.all(
                                          color: p.ink,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 6),
                                  Text('BANDSALAT', style: disp(12, p.soft)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(l.shelfTitle, style: disp(30, p.ink)),
                              const SizedBox(height: 6),
                              Text(
                                lib.tapes.isEmpty
                                    ? l.shelfSubEmpty
                                    : l.shelfSub(
                                        lib.tapes.length,
                                        span(context, lib.totalMs),
                                      ),
                                style: body(15, p.soft),
                              ),
                            ],
                          ),
                        ),
                        Key3(
                          width: 52,
                          height: 44,
                          color: Pal.tomato,
                          semantics: l.newTape,
                          onTap: () => newTape(context),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (feat != null) _Hero(tape: feat),
                    if (lib.tapes.isEmpty)
                      EmptyState(
                        picture: const SizedBox(
                          width: 220,
                          child: Cassette(shell: 1, label: 3, title: '???'),
                        ),
                        title: l.emptyShelfTitle,
                        text: l.emptyShelfBody,
                        action: BigButton(
                          label: l.newTape,
                          icon: Icons.add_rounded,
                          onTap: () => newTape(context),
                        ),
                      ),
                  ],
                ),
              ),
              if (others.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: SectionTitle(l.allTapes, color: Pal.teal),
                  ),
                ),
              if (others.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverLayoutBuilder(
                    builder: (context, c) {
                      final cols = (c.crossAxisExtent / 180).floor().clamp(
                        2,
                        4,
                      );
                      final cardW =
                          (c.crossAxisExtent - (cols - 1) * 18) / cols;
                      final scale = MediaQuery.textScalerOf(context).scale(1);
                      final extent =
                          cardW / CassettePainter.aspect + 12 + 66 * scale + 24;
                      return SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          mainAxisExtent: extent,
                        ),
                        itemCount: others.length,
                        itemBuilder: (c, i) => _TapeCard(tape: others[i]),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}

/// Creates a tape (or sends free users who hit the limit to the paywall).
Future<void> newTape(BuildContext context) async {
  final s = ServicesScope.read(context);
  if (!s.library.canAddTape) {
    await Navigator.of(context)
        .push(softRoute(const ProScreen(reason: ProReason.tapes)));
    return;
  }
  await Navigator.of(context)
      .push(softRoute(TapeEditor(tape: s.library.draft(), isNew: true)));
}

class _Hero extends StatelessWidget {
  const _Hero({required this.tape});
  final Tape tape;

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final l = L.of(context);
    final lib = s.library;
    final deck = s.deck;
    final p = Pal.of(context);
    final sh = shells[tape.shell];
    final tint = Color.lerp(
      sh.body,
      p.dark ? Pal.navy : Pal.paper,
      p.dark ? 0.55 : 0.62,
    )!;
    final side = tape.a.isEmpty && tape.b.isNotEmpty ? Side.b : Side.a;
    return ListenableBuilder(
      listenable: deck,
      builder: (context, _) {
        final playingThis = deck.tape?.id == tape.id && deck.playing;
        return Riso(
          color: tint,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          radius: 22,
          offset: 6,
          onTap: () => openTape(context, tape),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Tag(l.lastPlayed, color: Pal.mustard, textColor: Pal.navy),
                  const Spacer(),
                  Text('C${tape.minutes}', style: disp(13, p.ink)),
                ],
              ),
              const SizedBox(height: 14),
              Transform.rotate(
                angle: -0.03,
                child: Reeling(
                  active: playingThis,
                  builder: (c, a) => Cassette(
                    shell: tape.shell,
                    label: tape.label,
                    side: (deck.tape?.id == tape.id ? deck.side : side).letter,
                    title: tape.name,
                    subtitle: tape.dedication,
                    reel: a,
                    progress: deck.tape?.id == tape.id ? deck.progress : 0,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                tape.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: disp(20, Pal.navy),
              ),
              const SizedBox(height: 4),
              Text(
                l.tapeSummary(
                  tape.a.length + tape.b.length,
                  span(
                    context,
                    lib.sideMs(tape, Side.a) + lib.sideMs(tape, Side.b),
                  ),
                ),
                style: body(15, Pal.navy.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 14),
              BigButton(
                label: playingThis ? l.pause : l.play,
                icon: playingThis
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                onTap: () async {
                  if (deck.tape?.id == tape.id) {
                    await deck.toggle();
                  } else {
                    await deck.load(tape, play: true);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TapeCard extends StatelessWidget {
  const _TapeCard({required this.tape});
  final Tape tape;

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final lib = s.library;
    final p = Pal.of(context);
    final l = L.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openTape(context, tape),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Cassette(shell: tape.shell, label: tape.label, title: tape.name),
          const SizedBox(height: 12),
          Text(
            tape.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: body(16, p.ink, weight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            l.tapeSummary(
              tape.a.length + tape.b.length,
              span(
                context,
                lib.sideMs(tape, Side.a) + lib.sideMs(tape, Side.b),
              ),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: body(13, p.soft),
          ),
          const SizedBox(height: 8),
          TapeBar(
            usedMs: lib.sideMs(tape, Side.a),
            capacityMs: tape.sideCapacityMs,
            height: 9,
          ),
          const SizedBox(height: 4),
          TapeBar(
            usedMs: lib.sideMs(tape, Side.b),
            capacityMs: tape.sideCapacityMs,
            height: 9,
            color: Pal.mustard,
          ),
        ],
      ),
    );
  }
}
