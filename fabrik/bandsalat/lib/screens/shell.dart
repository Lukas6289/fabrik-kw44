import 'package:flutter/material.dart';

import '../deck.dart';
import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services.dart';
import 'crate_screen.dart';
import 'deck_screen.dart';
import 'more_screen.dart';
import 'shelf_screen.dart';
import 'widgets.dart';

/// Three tabs (shelf, crate, more) on a paper bar, and a mini player above it while a tape is in the deck.
class Shell extends StatefulWidget {
  const Shell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final p = Pal.of(context);
    final s = ServicesScope.of(context);
    final items = [
      (Icons.view_week_rounded, l.tabShelf),
      (Icons.inventory_2_rounded, l.tabCrate),
      (Icons.tune_rounded, l.tabMore),
    ];
    return Scaffold(
      body: PaperBackground(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [ShelfScreen(), CrateScreen(), MoreScreen()],
              ),
            ),
            ListenableBuilder(
              listenable: s.deck,
              builder: (context, _) => s.deck.tape == null
                  ? const SizedBox.shrink()
                  : const MiniPlayer(),
            ),
            Container(
              decoration: BoxDecoration(
                color: p.card,
                border: Border(top: BorderSide(color: p.ink, width: 2)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: Semantics(
                            button: true,
                            selected: _tab == i,
                            label: items[i].$2,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                tick();
                                setState(() => _tab = i);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    width: 52,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: _tab == i
                                          ? Pal.mustard
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: _tab == i
                                            ? p.ink
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      items[i].$1,
                                      size: 22,
                                      color: _tab == i ? Pal.navy : p.soft,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    items[i].$2,
                                    maxLines: 1,
                                    style: body(
                                      11.5,
                                      _tab == i ? p.ink : p.soft,
                                      weight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Strip above the tab bar: tiny cassette, what plays, play/pause. Tap opens the deck.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final d = s.deck;
    final p = Pal.of(context);
    final l = L.of(context);
    return ListenableBuilder(
      listenable: d,
      builder: (context, _) =>
          d.tape == null ? const SizedBox.shrink() : _strip(context, d, p, l),
    );
  }

  Widget _strip(BuildContext context, Deck d, Pal p, L l) {
    final t = d.tape!;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(softRoute(const DeckScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: Pal.mustard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.ink, width: 2),
          boxShadow: [
            BoxShadow(color: p.hardShadow, offset: const Offset(3, 3)),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Reeling(
                active: d.playing,
                builder: (c, a) => Cassette(
                  shell: t.shell,
                  label: t.label,
                  side: d.side.letter,
                  reel: a,
                  progress: d.progress,
                  text: false,
                  shadow: false,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.current?.title ?? t.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: body(15, Pal.navy, weight: FontWeight.w700),
                  ),
                  Text(
                    '${t.name} · ${l.sideLabel(d.side.letter)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: body(13, Pal.navy.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Key3(
              width: 48,
              height: 40,
              color: Pal.tomato,
              semantics: d.playing ? l.pause : l.play,
              onTap: d.toggle,
              child: Icon(
                d.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
