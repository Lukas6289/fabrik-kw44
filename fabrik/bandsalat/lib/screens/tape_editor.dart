import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services.dart';
import 'pro_screen.dart';
import 'widgets.dart';

/// Builds a tape: name, length, colours, and two sides with a live "how much tape is left" bar.
/// A new tape is a draft until "Done"; an existing one changes immediately.
class TapeEditor extends StatefulWidget {
  const TapeEditor({super.key, required this.tape, this.isNew = false});
  final Tape tape;
  final bool isNew;

  @override
  State<TapeEditor> createState() => _TapeEditorState();
}

class _TapeEditorState extends State<TapeEditor> {
  late final TextEditingController _name = TextEditingController(
    text: widget.tape.name,
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.tape.dedication,
  );
  Tape get t => widget.tape;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  void _apply() {
    t.name = _name.text;
    t.dedication = _note.text;
    if (!widget.isNew) ServicesScope.read(context).library.commit(t);
    setState(() {});
  }

  Future<void> _done() async {
    final s = ServicesScope.read(context);
    t.name = _name.text;
    t.dedication = _note.text;
    if (!s.library.commit(t)) {
      await Navigator.of(context)
          .push(softRoute(const ProScreen(reason: ProReason.tapes)));
      if (!mounted || !s.library.commit(t)) return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _pickSong(Side side) async {
    final s = ServicesScope.read(context);
    final l = L.of(context);
    final lib = s.library;
    if (lib.songs.isEmpty) {
      final r = await s.importer.run();
      if (!mounted) return;
      if (r.failed > 0) say(context, l.importFailed(r.failed));
      setState(() {});
      if (lib.songs.isEmpty) return;
    }
    if (!mounted) return;
    final picked = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Pal.of(context).card,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Pal.of(context).ink, width: 2),
      ),
      builder: (c) => _SongSheet(tape: t, side: side),
    );
    if (picked == null || !mounted) return;
    var refused = 0;
    for (final id in picked) {
      if (!lib.addToSide(t, side, id)) refused++;
    }
    if (refused > 0) say(context, l.didNotFit(refused));
    HapticFeedback.mediumImpact();
    _apply();
  }

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final l = L.of(context);
    final p = Pal.of(context);
    final lib = s.library;
    return ListenableBuilder(
      listenable: Listenable.merge([lib, s.pro]),
      builder: (context, _) => Scaffold(
        body: PaperBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Key3(
                        width: 44,
                        height: 40,
                        semantics: l.back,
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close_rounded,
                          color: p.ink,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.isNew ? l.newTape : l.editTape,
                          style: disp(18, p.ink),
                        ),
                      ),
                      Key3(
                        width: 84,
                        height: 40,
                        color: Pal.tomato,
                        semantics: l.done,
                        onTap: _done,
                        child: Text(
                          l.done,
                          style: body(
                            16,
                            Colors.white,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Center(
                        child: SizedBox(
                          width: 300,
                          child: Transform.rotate(
                            angle: -0.025,
                            child: Cassette(
                              shell: t.shell,
                              label: t.label,
                              title: _name.text.isEmpty
                                  ? l.untitledTape
                                  : _name.text,
                              subtitle: _note.text,
                              progress: 0.35,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _name,
                        maxLength: 28,
                        textCapitalization: TextCapitalization.sentences,
                        style: body(18, p.ink, weight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: l.tapeNameHint,
                          counterText: '',
                        ),
                        onChanged: (_) => _apply(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _note,
                        maxLength: 40,
                        style: written(22, p.ink),
                        decoration: InputDecoration(
                          hintText: l.dedicationHint,
                          counterText: '',
                        ),
                        onChanged: (_) => _apply(),
                      ),
                      SectionTitle(l.tapeLength),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final m in Tape.lengths)
                            _Pill(
                              label: 'C$m',
                              sub: l.minutesShort(m),
                              selected: t.minutes == m,
                              onTap: () {
                                t.minutes = m;
                                _apply();
                              },
                            ),
                        ],
                      ),
                      SectionTitle(l.shellColour, color: Pal.mustard),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (var i = 0; i < shells.length; i++)
                            _Swatch(
                              selected: t.shell == i,
                              locked: !lib.styleAllowed(i),
                              onTap: () => _style(i, true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: shells[i].body,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: p.ink, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SectionTitle(l.labelStyle, color: Pal.teal),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (var i = 0; i < labelStyleCount; i++)
                            _Swatch(
                              selected: t.label == i,
                              locked: !lib.styleAllowed(i),
                              wide: true,
                              onTap: () => _style(i, false),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CustomPaint(
                                  painter: _LabelThumb(i, t.shell),
                                ),
                              ),
                            ),
                        ],
                      ),
                      for (final side in Side.values) ...[
                        SectionTitle(
                          l.sideLabel(side.letter),
                          color: side == Side.a ? Pal.tomato : Pal.mustard,
                        ),
                        _SideBlock(
                          tape: t,
                          side: side,
                          onAdd: () => _pickSong(side),
                          onChanged: _apply,
                        ),
                      ],
                      const SizedBox(height: 18),
                      if (lib.unused(t).isNotEmpty && lib.songs.isNotEmpty)
                        BigButton(
                          label: l.fillSides,
                          icon: Icons.auto_awesome_rounded,
                          color: Pal.teal,
                          onTap: () {
                            final left = lib.autoFill(t, [
                              for (final x in lib.unused(t)) x.id,
                            ]);
                            HapticFeedback.mediumImpact();
                            if (left > 0) say(context, l.didNotFit(left));
                            _apply();
                          },
                        ),
                      if (!widget.isNew) ...[
                        const SizedBox(height: 22),
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              final ok = await confirm(
                                context,
                                title: l.deleteTapeTitle(t.name),
                                message: l.deleteTapeBody,
                                yes: l.delete,
                              );
                              if (!ok) return;
                              lib.deleteTape(t.id);
                              await s.deck.refresh();
                              nav.pop();
                            },
                            child: Text(
                              l.deleteTape,
                              style: body(16, p.red, weight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _style(int i, bool isShell) async {
    final s = ServicesScope.read(context);
    if (!s.library.styleAllowed(i)) {
      await Navigator.of(context)
          .push(softRoute(const ProScreen(reason: ProReason.styles)));
      if (!mounted || !s.library.styleAllowed(i)) return;
    }
    tick();
    if (isShell) {
      t.shell = i;
    } else {
      t.label = i;
    }
    _apply();
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '$label $sub',
      child: GestureDetector(
        onTap: () {
          tick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 60, minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Pal.tomato : p.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.ink, width: 2),
            boxShadow: selected
                ? [BoxShadow(color: p.hardShadow, offset: const Offset(3, 3))]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: disp(16, selected ? Colors.white : p.ink)),
              Text(
                sub,
                style: body(
                  12,
                  selected ? Colors.white : p.soft,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.child,
    required this.selected,
    required this.locked,
    required this.onTap,
    this.wide = false,
  });
  final Widget child;
  final bool selected;
  final bool locked;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: wide ? 76 : 48,
        height: wide ? 48 : 48,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(wide ? 13 : 24),
          border: Border.all(
            color: selected ? Pal.tomato : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (locked)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Pal.mustard,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.ink, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 12,
                    color: Pal.navy,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LabelThumb extends CustomPainter {
  _LabelThumb(this.style, this.shell);
  final int style;
  final int shell;
  @override
  void paint(Canvas canvas, Size size) {
    final sh = shells[shell];
    canvas.drawRect(Offset.zero & size, Paint()..color = sh.paper);
    paintLabelPattern(
      canvas,
      Rect.fromLTWH(0, 0, size.width, size.height * 0.6),
      style,
      sh,
      size.width * 3,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Pal.navy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_LabelThumb o) => o.style != style || o.shell != shell;
}

/// One side: the tape bar, its songs (drag to reorder), add button.
class _SideBlock extends StatelessWidget {
  const _SideBlock({
    required this.tape,
    required this.side,
    required this.onAdd,
    required this.onChanged,
  });
  final Tape tape;
  final Side side;
  final VoidCallback onAdd;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final lib = s.library;
    final l = L.of(context);
    final p = Pal.of(context);
    final used = lib.sideMs(tape, side);
    final free = tape.sideCapacityMs - used;
    final ids = tape.side(side);
    return Riso(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  free >= 0
                      ? l.tapeLeft(clock(free.clamp(0, 1 << 40)))
                      : l.tapeOver(clock(-free)),
                  style: body(
                    16,
                    free >= 0 ? p.ink : p.red,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${clock(used)} / ${clock(tape.sideCapacityMs)}',
                style: body(13, p.soft, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TapeBar(
            usedMs: used,
            capacityMs: tape.sideCapacityMs,
            color: side == Side.a ? Pal.teal : Pal.mustard,
          ),
          const SizedBox(height: 6),
          if (ids.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(l.sideEmptyHint, style: body(15, p.soft)),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: ids.length,
              onReorderItem: (from, to) {
                lib.reorder(tape, side, from, to);
                onChanged();
              },
              itemBuilder: (c, i) {
                final sg = lib.song(ids[i])!;
                return Container(
                  key: ValueKey('${side.letter}${ids[i]}$i'),
                  constraints: const BoxConstraints(minHeight: 52),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: p.line, width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            color: p.soft,
                            size: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sg.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: body(16, p.ink, weight: FontWeight.w700),
                            ),
                            Text(
                              sg.artist.isEmpty
                                  ? clock(sg.ms)
                                  : '${sg.artist} · ${clock(sg.ms)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: body(13, p.soft),
                            ),
                          ],
                        ),
                      ),
                      _Mini(
                        icon: Icons.swap_vert_rounded,
                        label: l.otherSide(side.other.letter),
                        onTap: () {
                          if (!lib.flipSong(tape, side, i)) {
                            say(context, l.didNotFit(1));
                          } else {
                            tick();
                            onChanged();
                          }
                        },
                      ),
                      _Mini(
                        icon: Icons.close_rounded,
                        label: l.removeFromTape,
                        onTap: () {
                          lib.removeFromSide(tape, side, i);
                          onChanged();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add_circle_rounded, color: p.red),
              label: Text(
                l.addSongs,
                style: body(16, p.red, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 48,
        child: Icon(icon, size: 22, color: Pal.of(context).soft),
      ),
    ),
  );
}

/// Choose songs from the crate for one side; those that do not fit are marked.
class _SongSheet extends StatefulWidget {
  const _SongSheet({required this.tape, required this.side});
  final Tape tape;
  final Side side;
  @override
  State<_SongSheet> createState() => _SongSheetState();
}

class _SongSheetState extends State<_SongSheet> {
  final _chosen = <String>[];

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final lib = s.library;
    final l = L.of(context);
    final p = Pal.of(context);
    final t = widget.tape;
    final songs = lib.unused(t);
    final used =
        lib.sideMs(t, widget.side) +
        _chosen.fold<int>(0, (a, id) => a + (lib.song(id)?.ms ?? 0));
    final free = t.sideCapacityMs - used;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (c, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.addToSide(widget.side.letter),
                    style: disp(18, p.ink),
                  ),
                ),
                Text(
                  free >= 0
                      ? l.tapeLeft(clock(free))
                      : l.tapeOver(clock(-free)),
                  style: body(
                    14,
                    free >= 0 ? p.soft : p.red,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: songs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l.allSongsUsed, style: body(16, p.soft)),
                  )
                : ListView.builder(
                    controller: scroll,
                    itemCount: songs.length,
                    itemBuilder: (c, i) {
                      final sg = songs[i];
                      final on = _chosen.contains(sg.id);
                      final fits = free >= sg.ms || on;
                      return InkWell(
                        onTap: () {
                          tick();
                          setState(
                            () =>
                                on ? _chosen.remove(sg.id) : _chosen.add(sg.id),
                          );
                        },
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 56),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                on
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: on ? Pal.teal : p.soft,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sg.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: body(
                                        16,
                                        p.ink,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                    if (sg.artist.isNotEmpty)
                                      Text(
                                        sg.artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: body(13, p.soft),
                                      ),
                                  ],
                                ),
                              ),
                              if (!fits)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Tag(
                                    l.tooLong,
                                    color: Pal.tomato.withValues(alpha: 0.25),
                                  ),
                                ),
                              Text(
                                clock(sg.ms),
                                style: body(
                                  14,
                                  p.soft,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: BigButton(
                    label: l.importMore,
                    icon: Icons.library_music_rounded,
                    color: p.chip,
                    textColor: p.ink,
                    onTap: () async {
                      await s.importer.run();
                      if (mounted) setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BigButton(
                    label: l.addCount(_chosen.length),
                    onTap: _chosen.isEmpty
                        ? null
                        : () => Navigator.pop(context, _chosen),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
