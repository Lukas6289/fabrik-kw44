import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../library.dart';
import '../services.dart';
import 'recipe_screen.dart';
import 'widgets.dart';

/// "What do I have?": type what is in the kitchen, see which of your recipes use it and what is still missing.
class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final _ctl = TextEditingController();
  final _have = <String>[];

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _add(String v) {
    for (final part in v.split(RegExp(r'[,;\n]'))) {
      final t = part.trim();
      if (t.length >= 2 && !_have.contains(t)) _have.add(t);
    }
    _ctl.clear();
    tick();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final lib = s.library;
    final l = L.of(context);
    final p = Pal.of(context);
    return ListenableBuilder(
      listenable: lib,
      builder: (context, _) {
        final matches = lib.byIngredients(_have);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                  children: [
                    Text(l.fridgeTitle, style: disp(34, p.ink)),
                    const SizedBox(height: 6),
                    Text(l.fridgeSub, style: body(16, p.soft, height: 1.4)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ctl,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _add,
                      decoration: InputDecoration(
                        hintText: l.fridgeHint,
                        prefixIcon: Icon(Icons.kitchen_rounded, color: p.soft),
                        suffixIcon: IconButton(tooltip: l.add, onPressed: () => _add(_ctl.text), icon: Icon(Icons.add_circle_rounded, color: p.accent, size: 30)),
                      ),
                    ),
                    if (_have.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 4, children: [
                        for (final h in _have)
                          InputChip(
                            label: Text(h, style: body(14.5, p.onAccent, weight: FontWeight.w800)),
                            backgroundColor: p.accent,
                            side: BorderSide.none,
                            deleteIconColor: p.onAccent,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            onDeleted: () => setState(() => _have.remove(h)),
                          ),
                        TextButton(onPressed: () => setState(_have.clear), child: Text(l.clearAll)),
                      ]),
                    ],
                    const SizedBox(height: 14),
                    if (_have.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: EmptyState(motif: 7, title: l.fridgeEmptyTitle, text: l.fridgeEmptyText),
                      )
                    else if (matches.isEmpty)
                      Padding(padding: const EdgeInsets.only(top: 24), child: EmptyState(motif: 4, title: l.fridgeNoneTitle, text: l.fridgeNoneText))
                    else ...[
                      SectionTitle(l.fridgeMatches(matches.length)),
                      for (final m in matches) _MatchCard(match: m),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final FridgeMatch match;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final l = L.of(context);
    final r = match.recipe;
    final complete = match.missing.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CardBox(
        padding: EdgeInsets.zero,
        onTap: () {
          tick();
          Navigator.of(context).push(softRoute(RecipeScreen(recipeId: r.id)));
        },
        child: Row(children: [
          SizedBox(width: 92, height: 104, child: RecipeCover(r)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: disp(17, p.ink, height: 1.18)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  Pill(l.haveCount(match.have.length), icon: Icons.check_rounded, color: Pal.hues[2].withValues(alpha: 0.25), fg: p.ink),
                  if (complete) Pill(l.allThere, icon: Icons.celebration_rounded, color: p.accent.withValues(alpha: 0.3), fg: p.ink),
                ]),
                if (!complete) ...[
                  const SizedBox(height: 6),
                  Text(l.stillMissing(match.missing.take(4).join(', ') + (match.missing.length > 4 ? ' …' : '')), maxLines: 2, overflow: TextOverflow.ellipsis, style: body(13.5, p.soft, weight: FontWeight.w600)),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
