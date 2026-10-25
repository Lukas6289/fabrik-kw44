import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../design.dart';
import '../export.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../parse.dart';
import '../scale.dart';
import '../services.dart';
import 'cook_screen.dart';
import 'edit_screen.dart';
import 'folder_sheet.dart';
import 'pro_screen.dart';
import 'widgets.dart';

/// One recipe: cover, portions, ingredients, steps, "my twist", cooking diary.
class RecipeScreen extends StatefulWidget {
  const RecipeScreen({
    super.key,
    required this.recipeId,
    this.embedded = false,
    this.onGone,
  });
  final String recipeId;

  /// In the tablet's second column: no back button.
  final bool embedded;
  final VoidCallback? onGone;

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  int? _servings;
  final _scroll = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final v = _scroll.hasClients && _scroll.offset > 190;
      if (v != _scrolled) setState(() => _scrolled = v);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }
  final _checked = <int>{};

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final lib = s.library;
    return ListenableBuilder(
      listenable: lib,
      builder: (context, _) {
        final r = lib.byId(widget.recipeId);
        if (r == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (widget.embedded) {
              widget.onGone?.call();
            } else {
              Navigator.of(context).maybePop();
            }
          });
          return const Scaffold(body: SizedBox());
        }
        return _body(context, s, r);
      },
    );
  }

  Widget _body(BuildContext context, Services s, Recipe r) {
    final lib = s.library;
    final l = L.of(context);
    final p = Pal.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final servings = _servings ?? r.servings;
    final factor = r.servings == 0 ? 1.0 : servings / r.servings;
    final units = lib.settings.units;
    final locale = Localizations.localeOf(context).toString();

    Widget meta() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (r.prepMin > 0)
          Pill(
            l.prepTime(minutesText(r.prepMin, lang)),
            icon: Icons.content_cut_rounded,
          ),
        if (r.cookMin > 0)
          Pill(
            l.cookTime(minutesText(r.cookMin, lang)),
            icon: Icons.local_fire_department_rounded,
          ),
        for (final t in r.tags)
          Pill(t, color: p.accent.withValues(alpha: 0.2), fg: p.ink),
      ],
    );

    final list = ListView(
      controller: _scroll,
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 250 + MediaQuery.paddingOf(context).top * 0,
              width: double.infinity,
              child: RecipeCover(r),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: p.bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.title, style: disp(32, p.ink, height: 1.1)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Stars(
                        r.rating,
                        size: 26,
                        onTap: (v) {
                          tick();
                          lib.rate(r, v);
                        },
                      ),
                      const SizedBox(width: 6),
                      if (r.timesCooked > 0)
                        Expanded(
                          child: Text(
                            l.cookedTimes(r.timesCooked),
                            style: body(14, p.soft, weight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  meta(),
                  const SizedBox(height: 14),
                  _folderRow(context, s, r),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: FilledButton.icon(
                          onPressed: r.steps.isEmpty
                              ? null
                              : () => Navigator.of(context).push(
                                  softRoute(
                                    CookScreen(
                                      recipeId: r.id,
                                      servings: servings,
                                    ),
                                  ),
                                ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 26),
                          label: Text(l.cookMode),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: r.ingredients.isEmpty
                              ? null
                              : () {
                                  bump();
                                  lib.addToShopping(r, servings);
                                  ScaffoldMessenger.of(context)
                                    ..clearSnackBars()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l.addedToList(r.ingredients.length),
                                        ),
                                      ),
                                    );
                                },
                          icon: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 20,
                          ),
                          label: Text(l.toList),
                        ),
                      ),
                    ],
                  ),
                  SectionTitle(l.ingredients),
                  _portions(context, r, servings, lib),
                  const SizedBox(height: 12),
                  if (r.ingredients.isEmpty)
                    Text(l.noIngredients, style: body(15, p.soft))
                  else
                    CardBox(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          for (var i = 0; i < r.ingredients.length; i++) ...[
                            if (r.ingredients[i].group.isNotEmpty &&
                                (i == 0 ||
                                    r.ingredients[i - 1].group !=
                                        r.ingredients[i].group))
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  2,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    r.ingredients[i].group,
                                    style: body(
                                      14,
                                      p.accentText,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            _IngRow(
                              ing: r.ingredients[i],
                              factor: factor,
                              units: units,
                              lang: lang,
                              checked: _checked.contains(i),
                              onTap: () {
                                tick();
                                setState(
                                  () => _checked.contains(i)
                                      ? _checked.remove(i)
                                      : _checked.add(i),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  SectionTitle(l.steps),
                  if (r.steps.isEmpty)
                    Text(l.noSteps, style: body(15, p.soft))
                  else
                    for (var i = 0; i < r.steps.length; i++)
                      _StepRow(
                        index: i,
                        text: r.steps[i],
                        onTimer: () => Navigator.of(context).push(
                          softRoute(
                            CookScreen(
                              recipeId: r.id,
                              servings: servings,
                              startStep: i,
                            ),
                          ),
                        ),
                      ),
                  _twistCard(context, s, r),
                  if (r.notes.isNotEmpty) ...[
                    SectionTitle(l.notes),
                    Text(r.notes, style: body(16, p.ink, height: 1.5)),
                  ],
                  SectionTitle(l.diary),
                  CardBox(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.lastCooked == null
                                    ? l.neverCooked
                                    : l.lastCookedOn(
                                        DateFormat.yMMMd(locale)
                                            .format(r.lastCooked!),
                                      ),
                                style: body(15, p.ink, weight: FontWeight.w600),
                              ),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(88, 46),
                              ),
                              onPressed: () => _logCooked(context, s, r),
                              child: Text(l.cookedToday),
                            ),
                          ],
                        ),
                        for (final e
                            in (r.log.toList()
                                  ..sort((a, b) => b.day.compareTo(a.day)))
                                .take(5))
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: Pal.hues[2],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.note.isEmpty
                                        ? DateFormat.yMMMd(locale).format(e.day)
                                        : '${DateFormat.yMMMd(locale).format(e.day)} – ${e.note}',
                                    style: body(
                                      14,
                                      p.soft,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (r.source.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => s.links.open(r.source),
                      child: Row(
                        children: [
                          Icon(Icons.link_rounded, size: 18, color: p.soft),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              Uri.tryParse(r.source)?.host ?? r.source,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: body(
                                14,
                                p.soft,
                                weight: FontWeight.w600,
                              ).copyWith(decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
    final inner = SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: Row(
          children: [
            if (!widget.embedded)
              _RoundBtn(
                icon: Icons.arrow_back_rounded,
                label: l.back,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            const Spacer(),
            _RoundBtn(
              icon: r.favorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: r.favorite ? const Color(0xFFD9352F) : null,
              label: l.favorite,
              onTap: () {
                bump();
                lib.toggleFavorite(r);
              },
            ),
            const SizedBox(width: 8),
            _menu(context, s, r, servings),
          ],
        ),
      ),
    );
    final bar = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _scrolled ? p.bg : Colors.transparent,
        border: Border(bottom: BorderSide(color: _scrolled ? p.line : Colors.transparent)),
      ),
      padding: const EdgeInsets.only(bottom: 6),
      child: inner,
    );
    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(
        children: [
          list,
          Positioned(left: 0, right: 0, top: 0, child: bar),
        ],
      ),
    );
  }

  Widget _folderRow(BuildContext context, Services s, Recipe r) {
    final l = L.of(context);
    final p = Pal.of(context);
    final fs = [
      for (final f in s.library.folders)
        if (r.folders.contains(f.id)) f,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final f in fs)
          Container(
            constraints: const BoxConstraints(minHeight: 32),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Pal.hues[f.hue % Pal.hues.length],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              f.name,
              style: body(13, const Color(0xFF14213D), weight: FontWeight.w800),
            ),
          ),
        GestureDetector(
          onTap: () => pickFolders(context, r),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.create_new_folder_outlined,
                  size: 20,
                  color: p.accentText,
                ),
                const SizedBox(width: 4),
                Text(
                  fs.isEmpty ? l.putInFolder : l.change,
                  style: body(14, p.accentText, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _portions(BuildContext context, Recipe r, int servings, lib) {
    final l = L.of(context);
    final p = Pal.of(context);
    Widget step(IconData icon, String label, VoidCallback? go) => Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: go == null
            ? null
            : () {
                tick();
                go();
              },
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: p.chip,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: go == null ? p.soft.withValues(alpha: 0.4) : p.ink,
          ),
        ),
      ),
    );
    Widget chip(String t, double f) {
      final target = (r.servings * f).round().clamp(1, 99);
      final sel = servings == target;
      return GestureDetector(
        onTap: () {
          tick();
          setState(() => _servings = target);
        },
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: sel ? p.accent : p.chip,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            t,
            style: body(15, sel ? p.onAccent : p.ink, weight: FontWeight.w800),
          ),
        ),
      );
    }

    return CardBox(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              step(
                Icons.remove_rounded,
                l.fewer,
                servings > 1
                    ? () => setState(() => _servings = servings - 1)
                    : null,
              ),
              Expanded(
                child: Column(
                  children: [
                    CountText(servings, style: disp(30, p.ink)),
                    Text(
                      l.servingsLabel,
                      style: body(13, p.soft, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              step(
                Icons.add_rounded,
                l.more,
                servings < 99
                    ? () => setState(() => _servings = servings + 1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chip('½', 0.5),
                  const SizedBox(width: 8),
                  chip('×1', 1),
                  const SizedBox(width: 8),
                  chip('×2', 2),
                  const SizedBox(width: 8),
                  chip('×3', 3),
                ],
              ),
              SegmentedButton<UnitSystem>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  visualDensity: VisualDensity.compact,
                  textStyle: body(13, p.ink, weight: FontWeight.w800),
                  selectedBackgroundColor: p.accent,
                  selectedForegroundColor: p.onAccent,
                  foregroundColor: p.ink,
                  side: BorderSide(color: p.line),
                ),
                segments: [
                  ButtonSegment(
                    value: UnitSystem.metric,
                    label: Text(l.unitsMetricShort),
                  ),
                  ButtonSegment(
                    value: UnitSystem.us,
                    label: Text(l.unitsUsShort),
                  ),
                ],
                selected: {lib.settings.units},
                onSelectionChanged: (v) => lib.setUnits(v.first),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _twistCard(BuildContext context, Services s, Recipe r) {
    final l = L.of(context);
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Container(
        decoration: BoxDecoration(
          color: p.accent.withValues(alpha: p.dark ? 0.12 : 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border(left: BorderSide(color: p.accent, width: 5)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note_rounded, color: p.accentText),
                const SizedBox(width: 6),
                Expanded(child: Text(l.myTwist, style: disp(18, p.ink))),
                TextButton(
                  onPressed: () => _editTwist(context, s, r),
                  child: Text(r.twist.isEmpty ? l.add : l.change),
                ),
              ],
            ),
            Text(
              r.twist.isEmpty ? l.twistHint : r.twist,
              style: body(15.5, r.twist.isEmpty ? p.soft : p.ink, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTwist(BuildContext context, Services s, Recipe r) async {
    final l = L.of(context);
    final ctl = TextEditingController(text: r.twist);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.myTwist),
        content: TextField(
          controller: ctl,
          autofocus: true,
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: l.twistHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (ok == true) {
      r.twist = ctl.text.trim();
      s.library.commit();
    }
  }

  Future<void> _logCooked(BuildContext context, Services s, Recipe r) async {
    final l = L.of(context);
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cookedToday),
        content: TextField(
          controller: ctl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: l.diaryHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (ok == true) {
      bump();
      s.library.logCooked(r, note: ctl.text.trim());
    }
  }

  Widget _menu(BuildContext context, Services s, Recipe r, int servings) {
    final l = L.of(context);
    final p = Pal.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<String>(
      tooltip: l.more,
      color: p.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: p.card.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_horiz_rounded, color: p.ink),
      ),
      onSelected: (v) async {
        switch (v) {
          case 'edit':
            Navigator.of(context).push(softRoute(EditScreen(recipeId: r.id)));
          case 'share':
            await s.sharer.shareText(
              s.library.recipeText(
                r,
                servings,
                lang,
                ingredientsHead: l.ingredients,
                stepsHead: l.steps,
                servingsLabel: l.servingsLabel,
              ),
            );
          case 'pdf':
            if (!s.pro.isPro) {
              Navigator.of(context)
                  .push(softRoute(const ProScreen(reason: ProReason.pdf)));
            } else {
              await shareRecipePdf(context, s, r, servings);
            }
          case 'delete':
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l.deleteRecipeTitle(r.title)),
                content: Text(l.deleteRecipeText),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(l.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      l.delete,
                      style: const TextStyle(color: Color(0xFFD9352F)),
                    ),
                  ),
                ],
              ),
            );
            if (ok == true) {
              HapticFeedback.mediumImpact();
              await s.library.remove(r.id);
            }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: _MenuRow(Icons.edit_outlined, l.edit),
        ),
        PopupMenuItem(
          value: 'share',
          child: _MenuRow(Icons.ios_share_rounded, l.shareText),
        ),
        PopupMenuItem(
          value: 'pdf',
          child: _MenuRow(
            Icons.picture_as_pdf_outlined,
            l.pdfCard + (s.pro.isPro ? '' : '  Pro'),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: _MenuRow(
            Icons.delete_outline_rounded,
            l.delete,
            color: const Color(0xFFD9352F),
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.text, {this.color});
  final IconData icon;
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = color ?? Pal.of(context).ink;
    return Row(
      children: [
        Icon(icon, size: 22, color: c),
        const SizedBox(width: 12),
        Text(text, style: body(16, c, weight: FontWeight.w600)),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: p.card.withValues(alpha: 0.92),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color ?? p.ink),
        ),
      ),
    );
  }
}

class _IngRow extends StatelessWidget {
  const _IngRow({
    required this.ing,
    required this.factor,
    required this.units,
    required this.lang,
    required this.checked,
    required this.onTap,
  });
  final Ing ing;
  final double factor;
  final UnitSystem units;
  final String lang;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final shown = scaleIng(ing, factor, units);
    final frac = const {
      'cup',
      'tbsp',
      'tsp',
      'pc',
      'lb',
      'oz',
      '',
    }.contains(shown.unit);
    final amount = shown.qty == null
        ? ''
        : [
            formatQty(shown.qty!, lang, fractions: frac),
            if (shown.unit.isNotEmpty)
              unitLabel(shown.unit, lang, plural: shown.qty! > 1),
          ].join(' ');
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: checked ? p.accent : Colors.transparent,
                  border: Border.all(
                    color: checked ? p.accent : p.soft.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: checked
                    ? Icon(Icons.check_rounded, size: 16, color: p.onAccent)
                    : null,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 104,
                child: Text(
                  amount,
                  style:
                      body(
                        16,
                        checked ? p.soft : p.ink,
                        weight: FontWeight.w800,
                      ).copyWith(
                        decoration: checked ? TextDecoration.lineThrough : null,
                      ),
                ),
              ),
              Expanded(
                child: Text(
                  ing.note.isEmpty ? ing.name : '${ing.name}, ${ing.note}',
                  style: body(16, checked ? p.soft : p.ink).copyWith(
                    decoration: checked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.text,
    required this.onTimer,
  });
  final int index;
  final String text;
  final VoidCallback onTimer;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final l = L.of(context);
    final timers = timersIn(text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.ink, shape: BoxShape.circle),
            child: Text(
              '${index + 1}',
              style: disp(
                16,
                p.dark ? p.bg : const Color(0xFFF4EEDF),
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(text, style: body(16.5, p.ink, height: 1.5)),
                ),
                if (timers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final t in timers.take(2))
                          GestureDetector(
                            onTap: onTimer,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: p.accent.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 18,
                                    color: p.ink,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l.timerChip(t.label),
                                    style: body(
                                      14,
                                      p.ink,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
