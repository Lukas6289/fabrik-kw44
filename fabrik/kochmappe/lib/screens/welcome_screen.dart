import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../samples.dart';
import '../services.dart';

/// The one start page: what the app is, three promises, a button.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final s = ServicesScope.of(context);
    const paper = Color(0xFFF4EEDF);
    const bg = Color(0xFF111C33);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Spacer(),
                SizedBox(
                  height: 170,
                  child: Stack(alignment: Alignment.center, children: [
                    for (var i = 0; i < 3; i++)
                      Transform.translate(
                        offset: Offset((i - 1) * 78.0, 0),
                        child: Transform.rotate(
                          angle: (i - 1) * 0.14,
                          child: Container(
                            width: 120,
                            height: 150,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 8))]),
                            child: Cover(motif: const [3, 0, 2][i], hue: const [0, 4, 2][i], radius: 13),
                          ),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 28),
                Text(l.welcomeTitle, style: disp(42, paper, height: 1.05)),
                const SizedBox(height: 12),
                Text(l.welcomeSub, style: body(17, const Color(0xFFB8C0D4), height: 1.45)),
                const SizedBox(height: 24),
                _Point(Icons.link_rounded, l.welcomeP1),
                _Point(Icons.lock_outline_rounded, l.welcomeP2),
                _Point(Icons.workspace_premium_outlined, l.welcomeP3),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      seedSamples(s.library, lang);
                      s.library.finishOnboarding();
                    },
                    child: Text(l.welcomeGo),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Icon(icon, color: const Color(0xFFF2A516), size: 26),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: body(16.5, const Color(0xFFF4EEDF), weight: FontWeight.w600, height: 1.35))),
        ]),
      );
}
