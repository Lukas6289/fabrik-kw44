import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../pro.dart';
import '../services.dart';

enum ProReason { general, recipes, pdf }

/// Paywall: a fan of recipe cards on ink-blue, a look at what Pro adds, one price, no subscription.
class ProScreen extends StatelessWidget {
  const ProScreen({super.key, this.reason = ProReason.general});
  final ProReason reason;

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final l = L.of(context);
    const bg = Color(0xFF111C33);
    const paper = Color(0xFFF4EEDF);
    const saffron = Color(0xFFF2A516);
    return ListenableBuilder(
      listenable: s.pro,
      builder: (context, _) {
        final pro = s.pro;
        final msg = switch (pro.state) {
          ProState.pending => l.proPending,
          ProState.failed => l.proFailed,
          ProState.nothingToRestore => l.proNothing,
          _ => null,
        };
        final lead = switch (reason) {
          ProReason.recipes => l.proReasonRecipes(freeRecipes),
          ProReason.pdf => l.proReasonPdf,
          ProReason.general => l.proLead,
        };
        return Scaffold(
          backgroundColor: bg,
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(24, 14, 24, 8 + MediaQuery.paddingOf(context).bottom),
            decoration: const BoxDecoration(color: bg, border: Border(top: BorderSide(color: Color(0x33FFFFFF)))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (pro.isPro)
                Row(children: [
                  const Icon(Icons.verified_rounded, color: Color(0xFF8BE09B), size: 30),
                  const SizedBox(width: 14),
                  Expanded(child: Text(l.proThanks, style: disp(22, paper))),
                ])
              else ...[
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(pro.lifetimePrice, style: disp(40, paper)),
                  const SizedBox(width: 12),
                  Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(l.proOnce, style: body(14, saffron, weight: FontWeight.w800)))),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: pro.state == ProState.busy
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            pro.buy(proLifetimeId);
                          },
                    child: pro.state == ProState.busy
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF14213D)))
                        : Text(l.proBuy(pro.lifetimePrice)),
                  ),
                ),
                if (msg != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(msg, textAlign: TextAlign.center, style: body(14, saffron, weight: FontWeight.w700))),
              ],
              const SizedBox(height: 4),
              Wrap(alignment: WrapAlignment.center, children: [
                _Link(l.restore, () => pro.restore()),
                _Link(l.terms, () => s.links.open(termsUrl)),
                _Link(l.privacy, () => s.links.open(privacyUrl)),
              ]),
            ]),
          ),
          body: SafeArea(
            bottom: false,
            child: Stack(children: [
              ListView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 24), children: [
                const SizedBox(height: 28),
                const SizedBox(height: 205, child: _Fan()),
                const SizedBox(height: 14),
                Text(l.proTitle, textAlign: TextAlign.center, style: disp(36, paper)),
                const SizedBox(height: 8),
                Text(lead, textAlign: TextAlign.center, style: body(16.5, const Color(0xFFB8C0D4), height: 1.45)),
                const SizedBox(height: 22),
                _Feature(Icons.all_inclusive_rounded, l.proFeatUnlimited, l.proFeatUnlimitedSub),
                _Feature(Icons.picture_as_pdf_rounded, l.proFeatPdf, l.proFeatPdfSub),
                _Feature(Icons.palette_rounded, l.proFeatThemes, l.proFeatThemesSub, trailing: const _Swatches()),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1B2A4A), borderRadius: BorderRadius.circular(18)),
                  child: Row(children: [
                    const Icon(Icons.favorite_rounded, color: Color(0xFFE9798E)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.proFreeStays, style: body(14.5, paper, weight: FontWeight.w600, height: 1.4))),
                  ]),
                ),
                const SizedBox(height: 10),
              ]),
              Positioned(
                top: 4,
                left: 8,
                child: IconButton(tooltip: l.close, iconSize: 28, color: paper, onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.close_rounded)),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _Fan extends StatelessWidget {
  const _Fan();

  @override
  Widget build(BuildContext context) {
    const motifs = [3, 0, 2, 5, 4];
    const angles = [-0.34, -0.17, 0.0, 0.17, 0.34];
    return LayoutBuilder(
      builder: (context, c) => Stack(alignment: Alignment.center, children: [
        for (var i = 0; i < 5; i++)
          Transform.translate(
            offset: Offset((i - 2) * 46.0, (i - 2).abs() * 10.0 + 6),
            child: Transform.rotate(
              angle: angles[i],
              child: Container(
                width: 112,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 6))],
                ),
                padding: const EdgeInsets.all(5),
                child: Column(children: [
                  Expanded(child: Cover(motif: motifs[i], hue: (i + 1) % Pal.hues.length, radius: 12)),
                  const SizedBox(height: 7),
                  Container(height: 5, width: 60 + (i % 2) * 14, decoration: BoxDecoration(color: const Color(0xFF14213D), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(height: 4),
                  Container(height: 4, width: 40, decoration: BoxDecoration(color: const Color(0xFFD7CDB8), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(height: 3),
                ]),
              ),
            ),
          ),
        Positioned(
          top: 0,
          child: Transform.rotate(angle: -pi / 14, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF2A516), borderRadius: BorderRadius.circular(10)),
            child: Text('PRO', style: disp(18, const Color(0xFF14213D), height: 1.1).copyWith(letterSpacing: 2)),
          )),
        ),
      ]),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches();
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (final c in Pal.themes) Container(width: 16, height: 16, margin: const EdgeInsets.only(left: 4), decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      ]);
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.title, this.sub, {this.trailing});
  final IconData icon;
  final String title;
  final String sub;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0x26F2A516), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFFF2A516))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: body(17.5, const Color(0xFFF4EEDF), weight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(sub, style: body(14.5, const Color(0xFFB8C0D4), height: 1.4)),
              if (trailing != null) Padding(padding: const EdgeInsets.only(top: 8), child: trailing),
            ]),
          ),
        ]),
      );
}

class _Link extends StatelessWidget {
  const _Link(this.text, this.onTap);
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFB8C0D4), minimumSize: const Size(44, 44), padding: const EdgeInsets.symmetric(horizontal: 12)),
        child: Text(text, style: body(13.5, const Color(0xFFB8C0D4), weight: FontWeight.w700)),
      );
}
