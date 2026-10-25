import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../parse.dart';
import '../scale.dart';
import '../services.dart';
import '../timers.dart';

/// Cooking mode: one step per page in big type, timers found in the text, ingredients one tap away,
/// the screen stays on.
class CookScreen extends StatefulWidget {
  const CookScreen({super.key, required this.recipeId, required this.servings, this.startStep = 0});
  final String recipeId;
  final int servings;
  final int startStep;

  @override
  State<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends State<CookScreen> {
  late final PageController _pages = PageController(initialPage: widget.startStep);
  late int _page = widget.startStep;
  late final CookTimers _timers = CookTimers(onDone: _alarm);
  Timer? _ticker;
  double _scale = 1;
  late final AwakeBackend _awake = ServicesScope.read(context).awake;
  String? _alarmText;

  @override
  void initState() {
    super.initState();
    _awake.keepAwake(true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _timers.tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _awake.keepAwake(false);
    _pages.dispose();
    _timers.dispose();
    super.dispose();
  }

  void _alarm(CookTimer t) {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    if (mounted) setState(() => _alarmText = t.label);
  }

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final r = s.library.byId(widget.recipeId);
    final l = L.of(context);
    final p = Pal.of(context);
    if (r == null) return const Scaffold(body: SizedBox());
    final steps = r.steps;
    final lang = Localizations.localeOf(context).languageCode;
    final f = r.servings == 0 ? 1.0 : widget.servings / r.servings;
    final last = _page == steps.length - 1;
    const paper = Color(0xFFF4EEDF);
    return Scaffold(
      backgroundColor: p.bar,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Row(children: [
              IconButton(tooltip: l.close, iconSize: 28, color: paper, onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.close_rounded)),
              Expanded(child: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(16, const Color(0xFFB8C0D4), weight: FontWeight.w700))),
              IconButton(tooltip: l.smallerText, color: paper, onPressed: _scale > 0.85 ? () => setState(() => _scale -= 0.15) : null, icon: const Icon(Icons.text_decrease_rounded)),
              IconButton(tooltip: l.biggerText, color: paper, onPressed: _scale < 1.6 ? () => setState(() => _scale += 0.15) : null, icon: const Icon(Icons.text_increase_rounded)),
              IconButton(tooltip: l.ingredients, color: p.accent, onPressed: () => _ingredients(context, r, f, lang), icon: const Icon(Icons.format_list_bulleted_rounded)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(children: [
              for (var i = 0; i < steps.length; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(color: i <= _page ? p.accent : const Color(0xFF2E3D63), borderRadius: BorderRadius.circular(3)),
                  ),
                ),
            ]),
          ),
          if (_alarmText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Material(
                color: const Color(0xFFD9352F),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _alarmText = null),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      const Icon(Icons.alarm_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.timerDone(_alarmText!), style: body(18, Colors.white, weight: FontWeight.w800))),
                      Text(l.dismiss, style: body(14, Colors.white, weight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ),
            ),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: steps.length,
              onPageChanged: (v) {
                tick();
                setState(() => _page = v);
              },
              itemBuilder: (_, i) {
                final ts = timersIn(steps[i]);
                return LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 12, 26, 12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight - 24, maxWidth: 760),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(l.stepOf(i + 1, steps.length), style: body(15, p.accent, weight: FontWeight.w800).copyWith(letterSpacing: 1)),
                        const SizedBox(height: 14),
                        Text(steps[i], style: disp(30 * _scale, paper, height: 1.28)),
                        const SizedBox(height: 22),
                        Wrap(spacing: 10, runSpacing: 10, children: [
                          for (final t in ts)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: paper,
                                side: BorderSide(color: p.accent, width: 2),
                                minimumSize: const Size(88, 52),
                              ),
                              onPressed: () {
                                bump();
                                _timers.start(t.seconds, t.label);
                              },
                              icon: Icon(Icons.timer_outlined, color: p.accent),
                              label: Text(l.startTimer(t.label)),
                            ),
                        ]),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
          ListenableBuilder(
            listenable: _timers,
            builder: (context, _) => _timers.timers.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 84,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [for (final t in _timers.timers) _TimerTile(timers: _timers, timer: t)],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: paper, side: const BorderSide(color: Color(0xFF3A4A72), width: 1.5), minimumSize: const Size(60, 60), padding: const EdgeInsets.symmetric(horizontal: 10)),
                  onPressed: _page == 0 ? null : () => _pages.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.arrow_back_rounded), const SizedBox(width: 4), Flexible(child: Text(l.previous, maxLines: 1, overflow: TextOverflow.ellipsis))]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(88, 60)),
                  onPressed: last
                      ? () {
                          bump();
                          s.library.logCooked(r);
                          Navigator.of(context).maybePop();
                        }
                      : () => _pages.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Flexible(child: Text(last ? l.finishCooking : l.next, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Icon(last ? Icons.check_rounded : Icons.arrow_forward_rounded),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void _ingredients(BuildContext context, r, double f, String lang) {
    final l = L.of(context);
    final units = ServicesScope.read(context).library.settings.units;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final p = Pal.of(ctx);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.92,
          builder: (_, ctl) => ListView(controller: ctl, padding: const EdgeInsets.fromLTRB(22, 0, 22, 30), children: [
            Text(l.ingredientsFor(widget.servings), style: disp(24, p.ink)),
            const SizedBox(height: 12),
            for (final i in r.ingredients)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Text(ingText(i, f, units, lang), style: body(19, p.ink, height: 1.35)),
              ),
          ]),
        );
      },
    );
  }
}

class _TimerTile extends StatelessWidget {
  const _TimerTile({required this.timers, required this.timer});
  final CookTimers timers;
  final CookTimer timer;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final rem = timers.remaining(timer);
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 10, bottom: 6, top: 6),
      padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
      decoration: BoxDecoration(color: timer.done ? const Color(0xFFD9352F) : const Color(0xFF1F2D4A), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        SizedBox(
          width: 52,
          height: 52,
          child: CustomPaint(
            painter: RingPainter(value: timers.fraction(timer), color: p.accent, track: const Color(0xFF3A4A72), width: 6),
            child: Center(child: Icon(timer.done ? Icons.alarm_on_rounded : Icons.timer_outlined, size: 20, color: const Color(0xFFF4EEDF))),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(clockText(rem), style: disp(22, const Color(0xFFF4EEDF), height: 1.1)),
            Text(timer.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(12.5, const Color(0xFFB8C0D4), weight: FontWeight.w600)),
          ]),
        ),
        IconButton(color: const Color(0xFFF4EEDF), onPressed: () => timers.cancel(timer), icon: const Icon(Icons.close_rounded, size: 20)),
      ]),
    );
  }
}
