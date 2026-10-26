import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../pro.dart';
import '../services.dart';
import 'pro_screen.dart';
import 'widgets.dart';

/// Pro card, playback setting, how it works, storage, legal.
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
        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                children: [
                  Text(l.tabMore, style: disp(30, p.ink)),
                  const SizedBox(height: 18),
                  Riso(
                    color: Pal.mustard,
                    radius: 20,
                    offset: 5,
                    onTap: pro
                        ? null
                        : () =>
                              Navigator.of(context)
                                  .push(softRoute(const ProScreen())),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Pal.tomato,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Pal.navy, width: 2),
                          ),
                          child: Icon(
                            pro
                                ? Icons.verified_rounded
                                : Icons.workspace_premium_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pro ? l.proActive : l.proCardTitle,
                                style: body(
                                  18,
                                  Pal.navy,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pro
                                    ? l.proThanks
                                    : l.proCardSub(s.pro.lifetimePrice),
                                style: body(
                                  14.5,
                                  Pal.navy.withValues(alpha: 0.8),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!pro)
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Pal.navy,
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                  SectionTitle(l.playbackTitle),
                  Riso(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.autoFlip,
                                style: body(16, p.ink, weight: FontWeight.w700),
                              ),
                              Text(
                                l.autoFlipSub,
                                style: body(13.5, p.soft, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: lib.settings.autoFlip,
                          onChanged: (v) => lib.setAutoFlip(v),
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(l.howTitle, color: Pal.teal),
                  Riso(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (i, t) in [
                          l.how1,
                          l.how2,
                          l.how3,
                          l.how4,
                        ].indexed)
                          Padding(
                            padding: EdgeInsets.only(bottom: i == 3 ? 0 : 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Pal.mustard,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: p.ink, width: 2),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: disp(12, Pal.navy, height: 1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t,
                                    style: body(15, p.ink, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  SectionTitle(l.storageTitle, color: Pal.pink),
                  Riso(
                    child: FutureBuilder<int>(
                      future: s.songFiles.bytes(),
                      builder: (context, snap) => Text(
                        l.storageText(
                          ((snap.data ?? 0) / 1048576).toStringAsFixed(1),
                        ),
                        style: body(15, p.ink, height: 1.4),
                      ),
                    ),
                  ),
                  SectionTitle(l.aboutTitle),
                  Riso(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _Row(
                          Icons.privacy_tip_outlined,
                          l.privacy,
                          () => s.links.open(privacyUrl),
                        ),
                        _Row(
                          Icons.description_outlined,
                          l.terms,
                          () => s.links.open(termsUrl),
                        ),
                        _Row(
                          Icons.help_outline_rounded,
                          l.support,
                          () => s.links.open(
                            'https://lukas6289.github.io/bandsalat/',
                          ),
                          last: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      l.footer,
                      textAlign: TextAlign.center,
                      style: body(13, p.soft, height: 1.4),
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
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.text, this.onTap, {this.last = false});
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: p.line, width: 1.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: p.ink, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: body(16, p.ink, weight: FontWeight.w600),
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: p.soft, size: 18),
          ],
        ),
      ),
    );
  }
}
