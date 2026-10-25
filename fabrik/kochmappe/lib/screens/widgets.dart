import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../scale.dart';
import '../services.dart';

/// Cover of a recipe: its photo (from the device) or the drawn motif.
class RecipeCover extends StatelessWidget {
  const RecipeCover(this.r, {super.key, this.radius = 0});
  final Recipe r;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (r.photo.isEmpty) return Cover(motif: r.motif, hue: r.hue, radius: radius);
    final lib = ServicesScope.of(context).library;
    return FutureBuilder(
      key: ValueKey('${r.id}${r.photo}'),
      future: lib.photoBytes(r.photo),
      builder: (_, snap) => Cover(
        motif: r.motif,
        hue: r.hue,
        radius: radius,
        photo: snap.data == null ? null : MemoryImage(snap.data!),
      ),
    );
  }
}

/// Index card in the grid.
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.onTap, this.selected = false});
  final Recipe recipe;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final l = L.of(context);
    final r = recipe;
    final hue = Pal.hues[r.hue % Pal.hues.length];
    return Semantics(
      button: true,
      label: r.title,
      child: Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? p.accent : p.line, width: selected ? 2.5 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: p.dark ? 0.35 : 0.07), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AspectRatio(
                aspectRatio: 1.35,
                child: Stack(fit: StackFit.expand, children: [
                  RecipeCover(r),
                  Positioned(left: 0, right: 0, bottom: 0, child: Container(height: 5, color: hue)),
                  if (r.favorite)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: p.card, shape: BoxShape.circle),
                        child: Icon(Icons.favorite_rounded, size: 17, color: const Color(0xFFD9352F)),
                      ),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: disp(16, p.ink, height: 1.18)),
                  const SizedBox(height: 6),
                  Row(children: [
                    if (r.totalMin > 0) ...[
                      Icon(Icons.schedule_rounded, size: 14, color: p.soft),
                      const SizedBox(width: 3),
                      Flexible(child: Text(minutesText(r.totalMin, Localizations.localeOf(context).languageCode), maxLines: 1, style: body(12.5, p.soft, weight: FontWeight.w600))),
                      const SizedBox(width: 8),
                    ],
                    if (r.rating > 0) ...[
                      Icon(Icons.star_rounded, size: 15, color: p.accent),
                      const SizedBox(width: 2),
                      Text('${r.rating}', style: body(12.5, p.soft, weight: FontWeight.w700)),
                    ] else if (r.timesCooked > 0)
                      Flexible(child: Text(l.cookedTimes(r.timesCooked), maxLines: 1, overflow: TextOverflow.ellipsis, style: body(12.5, p.soft, weight: FontWeight.w600))),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Soft empty page with a drawn motif.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.motif, required this.title, required this.text, this.action});
  final int motif;
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 150, height: 150, child: Cover(motif: motif, hue: motif % Pal.hues.length, radius: 75)),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: disp(24, p.ink)),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: body(16, p.soft, height: 1.45)),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ]),
      ),
    );
  }
}

/// Index tab (folder register).
class RegisterTab extends StatelessWidget {
  const RegisterTab({super.key, required this.label, required this.selected, required this.color, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          tick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 44),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? color : p.chip,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14), bottom: Radius.circular(8)),
            border: Border(top: BorderSide(color: color, width: 4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 17, color: selected ? const Color(0xFF14213D) : p.soft), const SizedBox(width: 6)],
            Text(label, style: body(14.5, selected ? const Color(0xFF14213D) : p.ink, weight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}
