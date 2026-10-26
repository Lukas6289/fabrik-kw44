import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services.dart';
import 'widgets.dart';

/// The crate: every song you imported, once, no matter on how many tapes.
class CrateScreen extends StatelessWidget {
  const CrateScreen({super.key});

  Future<void> _import(BuildContext context) async {
    final s = ServicesScope.read(context);
    final l = L.of(context);
    final r = await s.importer.run();
    if (!context.mounted) return;
    if (r.failed > 0) {
      say(context, l.importFailed(r.failed));
    } else if (r.added > 0) {
      say(context, l.importDone(r.added));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final l = L.of(context);
    final p = Pal.of(context);
    return ListenableBuilder(
      listenable: s.library,
      builder: (context, _) {
        final lib = s.library;
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              Text(l.crateTitle, style: disp(30, p.ink)),
              const SizedBox(height: 6),
              Text(
                lib.songs.isEmpty
                    ? l.crateSubEmpty
                    : l.crateSub(lib.songs.length, span(context, lib.totalMs)),
                style: body(15, p.soft),
              ),
              const SizedBox(height: 18),
              BigButton(
                label: l.importSongs,
                icon: Icons.library_add_rounded,
                onTap: () => _import(context),
              ),
              const SizedBox(height: 10),
              Text(l.importHint, style: body(14, p.soft, height: 1.4)),
              if (lib.songs.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: EmptyState(
                    picture: const SizedBox(
                      width: 200,
                      child: Cassette(shell: 2, label: 4, title: '♪ ♫ ♪'),
                    ),
                    title: l.emptyCrateTitle,
                    text: l.emptyCrateBody,
                  ),
                )
              else ...[
                SectionTitle(l.allSongs, color: Pal.mustard),
                Riso(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (var i = 0; i < lib.songs.length; i++)
                        _SongRow(
                          song: lib.songs[i],
                          last: i == lib.songs.length - 1,
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Riso(
                color: Pal.teal.withValues(alpha: p.dark ? 0.25 : 0.16),
                radius: 16,
                offset: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: p.ink, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.ownFilesNote,
                        style: body(14, p.ink, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SongRow extends StatelessWidget {
  const _SongRow({required this.song, required this.last});
  final Song song;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final l = L.of(context);
    final p = Pal.of(context);
    final n = s.library.tapesWith(song.id);
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: p.line, width: 1.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: body(16, p.ink, weight: FontWeight.w700),
                ),
                Text(
                  [
                    if (song.artist.isNotEmpty) song.artist,
                    clock(song.ms),
                    if (n > 0) l.onTapes(n),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: body(13, p.soft),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: l.more,
            icon: Icon(Icons.more_horiz_rounded, color: p.soft),
            color: p.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: p.ink, width: 2),
            ),
            onSelected: (v) async {
              if (v == 'rename') {
                final c = TextEditingController(text: song.title);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    backgroundColor: p.card,
                    title: Text(l.rename, style: disp(18, p.ink)),
                    content: TextField(
                      controller: c,
                      autofocus: true,
                      maxLength: 60,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(d, false),
                        child: Text(
                          l.cancel,
                          style: body(16, p.ink, weight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(d, true),
                        child: Text(
                          l.done,
                          style: body(16, p.red, weight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  s.library.renameSong(song.id, c.text);
                  await s.deck.refresh();
                }
                c.dispose();
              } else {
                final ok = await confirm(
                  context,
                  title: l.deleteSongTitle(song.title),
                  message: n > 0 ? l.deleteSongBodyUsed(n) : l.deleteSongBody,
                  yes: l.delete,
                );
                if (ok) {
                  await s.importer.remove(song.id);
                  await s.deck.refresh();
                }
              }
            },
            itemBuilder: (c) => [
              PopupMenuItem(
                value: 'rename',
                child: Text(
                  l.rename,
                  style: body(16, p.ink, weight: FontWeight.w600),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  l.delete,
                  style: body(16, p.red, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
