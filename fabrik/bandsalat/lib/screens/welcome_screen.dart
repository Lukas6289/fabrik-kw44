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
    final p = Pal.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 16, 26, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    SizedBox(
                      height: 190,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(-40, -12),
                            child: Transform.rotate(
                              angle: -0.2,
                              child: SizedBox(
                                width: 190,
                                child: Cassette(
                                  shell: 2,
                                  label: 4,
                                  title: l.sampleTape1,
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(36, 18),
                            child: Transform.rotate(
                              angle: 0.1,
                              child: SizedBox(
                                width: 200,
                                child: Cassette(
                                  shell: 0,
                                  label: 0,
                                  title: l.sampleTape2,
                                  side: 'B',
                                  progress: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(l.welcomeTitle, style: disp(32, p.ink, height: 1.08)),
                    const SizedBox(height: 12),
                    Text(l.welcomeSub, style: body(17, p.soft, height: 1.45)),
                    const SizedBox(height: 22),
                    _Point(Icons.straighten_rounded, l.welcomeP1, Pal.mustard),
                    _Point(Icons.menu_book_rounded, l.welcomeP2, Pal.teal),
                    _Point(Icons.folder_open_rounded, l.welcomeP3, Pal.pink),
                    const Spacer(),
                    BigButton(
                      label: l.welcomeGo,
                      onTap: () {
                        seedSample(s.library, lang);
                        s.library.finishOnboarding();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point(this.icon, this.text, this.color);
  final IconData icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.ink, width: 2),
            ),
            child: Icon(icon, color: Pal.navy, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: body(16, p.ink, weight: FontWeight.w600, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
