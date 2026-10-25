import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services.dart';
import 'pro_screen.dart';

/// Create or rename (and delete) a folder.
Future<void> editFolder(BuildContext context, {Folder? folder}) {
  final s = ServicesScope.of(context);
  final l = L.of(context);
  final ctl = TextEditingController(text: folder?.name ?? '');
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final p = Pal.of(ctx);
      var hue = folder?.hue ?? s.library.folders.length % Pal.hues.length;
      return StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(ctx).bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(folder == null ? l.newFolder : l.editFolder, style: disp(24, p.ink)),
            const SizedBox(height: 14),
            TextField(controller: ctl, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: InputDecoration(hintText: l.folderNameHint)),
            const SizedBox(height: 14),
            Wrap(spacing: 12, children: [
              for (var i = 0; i < Pal.hues.length; i++)
                Semantics(
                  button: true,
                  selected: hue == i,
                  label: '${l.colorWord} ${i + 1}',
                  child: GestureDetector(
                    onTap: () => set(() => hue = i),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: Pal.hues[i], shape: BoxShape.circle, border: Border.all(color: hue == i ? p.ink : Colors.transparent, width: 3)),
                      child: hue == i ? Icon(Icons.check_rounded, color: const Color(0xFF14213D)) : null,
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              if (folder != null)
                TextButton(
                  onPressed: () {
                    s.library.removeFolder(folder);
                    Navigator.pop(ctx);
                  },
                  child: Text(l.deleteFolder, style: body(15, const Color(0xFFD9352F), weight: FontWeight.w700)),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  if (ctl.text.trim().isEmpty) return;
                  if (folder == null) {
                    final f = s.library.addFolder(ctl.text);
                    f?.hue = hue;
                  } else {
                    s.library.renameFolder(folder, ctl.text);
                    folder.hue = hue;
                  }
                  s.library.commit();
                  Navigator.pop(ctx);
                },
                child: Text(l.save),
              ),
            ]),
          ]),
        ),
      );
    },
  );
}

/// Choose which folders a recipe is in.
Future<void> pickFolders(BuildContext context, Recipe r) {
  final s = ServicesScope.of(context);
  final l = L.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final p = Pal.of(ctx);
      return ListenableBuilder(
        listenable: s.library,
        builder: (ctx, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.putInFolder, style: disp(24, p.ink)),
              const SizedBox(height: 10),
              for (final f in s.library.folders)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: r.folders.contains(f.id),
                  activeColor: Pal.hues[f.hue % Pal.hues.length],
                  checkColor: const Color(0xFF14213D),
                  onChanged: (v) => s.library.setInFolder(r, f, v ?? false),
                  title: Text(f.name, style: body(17, p.ink, weight: FontWeight.w600)),
                  secondary: Container(width: 14, height: 36, decoration: BoxDecoration(color: Pal.hues[f.hue % Pal.hues.length], borderRadius: BorderRadius.circular(5))),
                ),
              if (s.library.folders.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l.noFoldersYet, style: body(15, p.soft))),
              TextButton.icon(
                onPressed: () => s.library.canAddFolder ? editFolder(ctx) : Navigator.of(ctx).push(softRoute(const ProScreen())),
                icon: const Icon(Icons.add_rounded),
                label: Text(l.newFolder),
              ),
            ]),
          ),
        ),
      );
    },
  );
}
