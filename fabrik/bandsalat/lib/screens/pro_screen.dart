import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../pro.dart';
import '../services.dart';

enum ProReason { general, tapes, styles, pdf }

/// Paywall: loud tomato-red, a fan of tapes in every colour, three reasons, one price, no subscription.
class ProScreen extends StatelessWidget {
  const ProScreen({super.key, this.reason = ProReason.general});
  final ProReason reason;

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final l = L.of(context);
    const paper = Pal.paper;
    const navy = Pal.navy;
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
          ProReason.tapes => l.proReasonTapes(freeTapes),
          ProReason.styles => l.proReasonStyles,
          ProReason.pdf => l.proReasonPdf,
          ProReason.general => l.proLead,
        };
        return Scaffold(
          backgroundColor: Pal.tomato,
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(
              24,
              14,
              24,
              8 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: paper,
              border: Border(top: BorderSide(color: navy, width: 2.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pro.isPro)
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Pal.teal,
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(l.proThanks, style: disp(18, navy))),
                    ],
                  )
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        pro.lifetimePrice,
                        style: body(
                          34,
                          navy,
                          weight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            l.proOnce,
                            style: body(
                              14,
                              const Color(0xFFD73A2B),
                              weight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BigButton(
                    label: pro.state == ProState.busy
                        ? '…'
                        : l.proBuy(pro.lifetimePrice),
                    onTap: pro.state == ProState.busy
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            pro.buy(proLifetimeId);
                          },
                  ),
                  if (msg != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: body(
                          14,
                          const Color(0xFFD73A2B),
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 2),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    _Link(l.restore, () => pro.restore()),
                    _Link(l.terms, () => s.links.open(termsUrl)),
                    _Link(l.privacy, () => s.links.open(privacyUrl)),
                  ],
                ),
              ],
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                  children: [
                    const SizedBox(height: 30),
                    const SizedBox(height: 150, child: _Fan()),
                    const SizedBox(height: 10),
                    Text(
                      'BANDSALAT PRO',
                      textAlign: TextAlign.center,
                      style: disp(24, paper, height: 1.05),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lead,
                      textAlign: TextAlign.center,
                      style: body(
                        15.5,
                        paper,
                        weight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Feature(
                      Icons.all_inclusive_rounded,
                      l.proFeatTapes,
                      l.proFeatTapesSub(freeTapes),
                      Pal.mustard,
                    ),
                    _Feature(
                      Icons.palette_rounded,
                      l.proFeatLooks,
                      l.proFeatLooksSub,
                      Pal.teal,
                      trailing: const _Swatches(),
                    ),
                    _Feature(
                      Icons.print_rounded,
                      l.proFeatCard,
                      l.proFeatCardSub,
                      Pal.pink,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: navy,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: Pal.pink),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l.proFreeStays,
                              style: body(
                                14.5,
                                paper,
                                weight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 4,
                  left: 10,
                  child: Key3(
                    width: 44,
                    height: 40,
                    semantics: l.close,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.close_rounded,
                      color: navy,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
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
    const angles = [-0.22, 0.0, 0.22];
    const shellIdx = [3, 4, 1];
    return Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 0; i < 3; i++)
          Transform.translate(
            offset: Offset((i - 1) * 62.0, (i - 1).abs() * 10.0 + 6),
            child: Transform.rotate(
              angle: angles[i],
              child: SizedBox(
                width: 150,
                child: Cassette(
                  shell: shellIdx[i],
                  label: 3 + i * 2,
                  title: [
                    L.of(context).sampleTape1,
                    L.of(context).sampleTape2,
                    '♪ ♫',
                  ][i],
                  side: 'AAB'[i],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches();
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 5,
    runSpacing: 5,
    children: [
      for (final s in shells)
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: s.body,
            shape: BoxShape.circle,
            border: Border.all(color: Pal.navy, width: 1.5),
          ),
        ),
    ],
  );
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.title, this.sub, this.color, {this.trailing});
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Pal.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Pal.navy, width: 2),
        boxShadow: const [BoxShadow(color: Pal.navy, offset: Offset(4, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Pal.navy, width: 2),
            ),
            child: Icon(icon, color: Pal.navy),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: body(17, Pal.navy, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: body(14.5, const Color(0xFF55596F), height: 1.4),
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: trailing,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Link extends StatelessWidget {
  const _Link(this.text, this.onTap);
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    child: Text(
      text,
      style: body(
        13.5,
        Pal.navy.withValues(alpha: 0.75),
        weight: FontWeight.w700,
      ),
    ),
  );
}
