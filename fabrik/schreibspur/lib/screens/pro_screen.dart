import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../pro.dart';

/// Paywall: yearly subscription or lifetime purchase.
class ProScreen extends StatefulWidget {
  const ProScreen({super.key, required this.pro});
  final Pro pro;

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  String _choice = proLifetimeId;

  Pro get pro => widget.pro;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const SizedBox.shrink()),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: pro,
          builder: (context, _) {
            final busy = pro.state == ProState.busy;
            final message = switch (pro.state) {
              ProState.pending => l.proPending,
              ProState.failed => l.proFailed,
              ProState.nothingToRestore => l.proNothingToRestore,
              _ => pro.isPro
                  ? l.proActive
                  : (pro.storeReady ? null : l.proStoreUnavailable),
            };
            final text = theme.textTheme;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  decoration: BoxDecoration(gradient: Tone.violet.gradient, borderRadius: BorderRadius.circular(32)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(children: [
                    const Positioned.fill(child: Blobs(tone: Tone.violet)),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(color: Color(0x33FFFFFF), shape: BoxShape.circle),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 14),
                      Text(l.proTitle,
                          style: const TextStyle(
                              fontFamily: Brand.display, fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(l.proTagline, style: const TextStyle(fontSize: 16, color: Color(0xE6FFFFFF))),
                      const SizedBox(height: 18),
                      const Row(children: [
                        _Mini(Tone.teal, Icons.cloud_rounded),
                        SizedBox(width: 8),
                        _Mini(Tone.coral, Icons.auto_awesome_mosaic_rounded),
                        SizedBox(width: 8),
                        _Mini(Tone.sun, Icons.military_tech_rounded),
                        SizedBox(width: 8),
                        _Mini(Tone.blue, Icons.calendar_month_rounded),
                      ]),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                _Feature(Icons.auto_awesome_mosaic_rounded, l.proFeatureImages, Tone.coral),
                _Feature(Icons.dashboard_rounded, l.proFeatureCards, Tone.pink),
                _Feature(Icons.emoji_events_rounded, l.proFeatureAwards, Tone.sun),
                _Feature(Icons.compare_arrows_rounded, l.proFeatureCompare, Tone.blue),
                _Feature(Icons.format_quote_rounded, l.proFeatureWords(proWords, freeWords), Tone.teal),
                _Feature(Icons.ios_share_rounded, l.proFeatureShare, Tone.violet),
                const SizedBox(height: 18),
                if (!pro.isPro) ...[
                  _Option(
                    selected: _choice == proLifetimeId,
                    title: l.proLifetime,
                    detail: l.proLifetimeDetail(pro.lifetimePrice),
                    badge: l.proBest,
                    onTap: () => setState(() => _choice = proLifetimeId),
                  ),
                  const SizedBox(height: 10),
                  _Option(
                    selected: _choice == proYearlyId,
                    title: l.proYearly,
                    detail: l.proYearlyDetail(pro.yearlyPrice),
                    badge: l.proPopular,
                    onTap: () => setState(() => _choice = proYearlyId),
                  ),
                  const SizedBox(height: 18),
                  busy
                      ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      : GradientButton(
                          label: l.proBuy,
                          icon: Icons.lock_open_rounded,
                          tone: Tone.violet,
                          onPressed: !pro.storeReady ? null : () => pro.buy(_choice),
                        ),
                ],
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center, style: text.titleLarge),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: busy ? null : pro.restore,
                  child: Text(l.proRestore),
                ),
                const SizedBox(height: 4),
                Text(l.proSubscriptionNote,
                    style: text.bodySmall?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Wrap(alignment: WrapAlignment.center, children: [
                  TextButton(onPressed: () => launchUrl(Uri.parse(termsUrl)), child: Text(l.terms)),
                  TextButton(onPressed: () => launchUrl(Uri.parse(privacyUrl)), child: Text(l.privacyPolicy)),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini(this.tone, this.icon);
  final Tone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: tone.gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x55FFFFFF), width: 1.5),
        ),
        child: Icon(icon, color: tone.fg),
      );
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.text, this.tone);
  final IconData icon;
  final String text;
  final Tone tone;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(gradient: tone.gradient, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: tone.fg),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ]),
      );
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.title,
    required this.detail,
    required this.badge,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String detail;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final violet = Tone.violet.a;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? violet : cs.outline.withValues(alpha: 0.2), width: selected ? 2.5 : 1.5),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? Tone.violet.gradient : null,
                border: selected ? null : Border.all(color: cs.outline, width: 2),
              ),
              child: selected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: selected ? Tone.coral.gradient : null,
                color: selected ? null : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : cs.onSurface)),
            ),
          ]),
        ),
      ),
    );
  }
}
