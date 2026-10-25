import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../services.dart';
import 'edit_screen.dart';
import 'import_screen.dart';
import 'pro_screen.dart';

/// "Add a recipe": from a link, from pasted text, or write it yourself.
Future<void> showAddSheet(BuildContext context) {
  final s = ServicesScope.of(context);
  final l = L.of(context);
  final nav = Navigator.of(context);
  if (!s.library.canAddRecipe) {
    nav.push(softRoute(const ProScreen(reason: ProReason.recipes)));
    return Future.value();
  }
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final p = Pal.of(ctx);
      Widget row(IconData icon, String title, String sub, VoidCallback go, Color c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CardBox(
              onTap: () {
                Navigator.pop(ctx);
                go();
              },
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: c.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: p.ink)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: body(17, p.ink, weight: FontWeight.w800)),
                  Text(sub, style: body(13.5, p.soft)),
                ])),
                Icon(Icons.chevron_right_rounded, color: p.soft),
              ]),
            ),
          );
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.addRecipe, style: disp(24, p.ink)),
            const SizedBox(height: 14),
            row(Icons.link_rounded, l.addFromLink, l.addFromLinkSub, () => nav.push(softRoute(const ImportScreen(mode: ImportMode.link))), Pal.hues[3]),
            row(Icons.content_paste_rounded, l.addFromText, l.addFromTextSub, () => nav.push(softRoute(const ImportScreen(mode: ImportMode.text))), Pal.hues[1]),
            row(Icons.edit_rounded, l.addByHand, l.addByHandSub, () => nav.push(softRoute(const EditScreen())), Pal.hues[0]),
          ]),
        ),
      );
    },
  );
}
