import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design.dart';
import '../export.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../pro.dart';
import '../services.dart';
import 'pro_screen.dart';

/// Pro card, units, colour theme, backup, legal, delete.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final lib = s.library;
    final l = L.of(context);
    final p = Pal.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([lib, s.pro]),
      builder: (context, _) {
        final pro = s.pro.isPro;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 40), children: [
                  Text(l.tabMore, style: disp(34, p.ink)),
                  const SizedBox(height: 16),
                  _ProCard(pro: pro, price: s.pro.lifetimePrice),
                  SectionTitle(l.unitsTitle),
                  CardBox(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Expanded(child: Text(l.unitsText, style: body(15, p.soft, height: 1.35))),
                      const SizedBox(width: 12),
                      SegmentedButton<UnitSystem>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(minimumSize: const Size(44, 44), selectedBackgroundColor: p.accent, selectedForegroundColor: p.onAccent, foregroundColor: p.ink, side: BorderSide(color: p.line), textStyle: body(14, p.ink, weight: FontWeight.w800)),
                        segments: [ButtonSegment(value: UnitSystem.metric, label: Text(l.unitsMetricShort)), ButtonSegment(value: UnitSystem.us, label: Text(l.unitsUsShort))],
                        selected: {lib.settings.units},
                        onSelectionChanged: (v) => lib.setUnits(v.first),
                      ),
                    ]),
                  ),
                  SectionTitle(l.themeTitle),
                  CardBox(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Wrap(spacing: 14, runSpacing: 10, children: [
                        for (var i = 0; i < Pal.themes.length; i++)
                          Semantics(
                            button: true,
                            selected: (pro ? lib.settings.theme : 0) == i,
                            label: '${l.colorWord} ${i + 1}',
                            child: GestureDetector(
                              onTap: () {
                                tick();
                                if (i != 0 && !pro) {
                                  Navigator.of(context).push(softRoute(const ProScreen()));
                                } else {
                                  lib.setTheme(i);
                                }
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(color: Pal.themes[i], shape: BoxShape.circle, border: Border.all(color: (pro ? lib.settings.theme : 0) == i ? p.ink : Colors.transparent, width: 3)),
                                child: i != 0 && !pro ? const Icon(Icons.lock_rounded, size: 18, color: Color(0xFF14213D)) : ((pro ? lib.settings.theme : 0) == i ? const Icon(Icons.check_rounded, color: Color(0xFF14213D)) : null),
                              ),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 8),
                      Text(pro ? l.themeProOn : l.themeProHint, style: body(13.5, p.soft)),
                    ]),
                  ),
                  SectionTitle(l.backupTitle),
                  CardBox(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.backupText, style: body(15, p.soft, height: 1.4)),
                      const SizedBox(height: 12),
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
                          onPressed: () async {
                            final text = await lib.exportBackup();
                            await s.sharer.shareFile(Uint8List.fromList(utf8.encode(text)), name: 'kochmappe-${l.backupWord}.json', mime: 'application/json');
                          },
                          icon: const Icon(Icons.upload_rounded),
                          label: Text(l.backupSave),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final text = await s.files.pickText();
                            if (text == null || !context.mounted) return;
                            final n = await lib.importBackup(text);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(SnackBar(content: Text(n < 0 ? l.backupBad : l.backupRestored(n))));
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: Text(l.backupLoad),
                        ),
                      ]),
                    ]),
                  ),
                  SectionTitle(l.cookbookTitle),
                  CardBox(
                    onTap: () {
                      if (!pro) {
                        Navigator.of(context).push(softRoute(const ProScreen(reason: ProReason.pdf)));
                      } else if (lib.recipes.isNotEmpty) {
                        shareCookbookPdf(context, s);
                      }
                    },
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Icon(Icons.menu_book_rounded, color: p.accentText, size: 28),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.cookbookMake, style: body(16.5, p.ink, weight: FontWeight.w800)),
                        Text(l.cookbookSub, style: body(13.5, p.soft)),
                      ])),
                      if (!pro) const Pill('Pro'),
                    ]),
                  ),
                  SectionTitle(l.aboutTitle),
                  _Tile(Icons.description_outlined, l.terms, () => s.links.open(termsUrl)),
                  _Tile(Icons.privacy_tip_outlined, l.privacy, () => s.links.open(privacyUrl)),
                  _Tile(Icons.mail_outline_rounded, l.contact, () => s.links.open('https://lukas6289.github.io/kochmappe/')),
                  _Tile(Icons.delete_outline_rounded, l.deleteAll, () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(l.deleteAllTitle),
                        content: Text(l.deleteAllText),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
                          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l.delete, style: const TextStyle(color: Color(0xFFD9352F)))),
                        ],
                      ),
                    );
                    if (ok == true) {
                      HapticFeedback.mediumImpact();
                      await lib.deleteAll();
                    }
                  }, color: const Color(0xFFD9352F)),
                  const SizedBox(height: 14),
                  Center(child: Text(l.footer, textAlign: TextAlign.center, style: body(13, p.soft))),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProCard extends StatelessWidget {
  const _ProCard({required this.pro, required this.price});
  final bool pro;
  final String price;
  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    const paper = Color(0xFFF4EEDF);
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFF14213D), Color(0xFF2B3F70)])),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.of(context).push(softRoute(const ProScreen())),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFF2A516), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF14213D), size: 30)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pro ? l.proActive : l.proCardTitle, style: disp(20, paper)),
                const SizedBox(height: 2),
                Text(pro ? l.proThanks : l.proCardSub(price), style: body(14, const Color(0xFFB8C0D4), height: 1.35)),
              ])),
              const Icon(Icons.chevron_right_rounded, color: paper),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.title, this.onTap, {this.color});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CardBox(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Icon(icon, color: color ?? p.soft),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: body(16, color ?? p.ink, weight: FontWeight.w700))),
          Icon(Icons.chevron_right_rounded, color: p.soft),
        ]),
      ),
    );
  }
}
