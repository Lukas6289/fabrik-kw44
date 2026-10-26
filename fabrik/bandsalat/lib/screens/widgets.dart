import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';

/// Turns [builder]'s angle while [active]; stands still (and schedules no frames) otherwise.
class Reeling extends StatefulWidget {
  const Reeling({
    super.key,
    required this.active,
    this.fast = false,
    required this.builder,
  });
  final bool active;
  final bool fast;
  final Widget Function(BuildContext context, double angle) builder;

  @override
  State<Reeling> createState() => _ReelingState();
}

class _ReelingState extends State<Reeling> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  double _angle = 0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.active) _ticker.start();
  }

  void _tick(Duration d) {
    final dt = (d - _last).inMicroseconds / 1e6;
    _last = d;
    setState(() => _angle += dt * (widget.fast ? 16 : 3.2));
  }

  @override
  void didUpdateWidget(Reeling old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!widget.active && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _angle);
}

/// Section heading: small mono caps with a coloured square.
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.text, {
    super.key,
    this.trailing,
    this.color = Pal.tomato,
  });
  final String text;
  final Widget? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: p.ink, width: 1.5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: disp(13, p.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.text,
    this.action,
    this.picture,
  });
  final String title;
  final String text;
  final Widget? action;
  final Widget? picture;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          if (picture != null) ...[picture!, const SizedBox(height: 22)],
          Text(title, textAlign: TextAlign.center, style: disp(22, p.ink)),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: body(16, p.soft, height: 1.45),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

/// Short tick for navigation and toggles.
void tick() => HapticFeedback.selectionClick();

void say(BuildContext context, String text) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(content: Text(text), duration: const Duration(seconds: 3)),
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String yes,
}) async {
  final l = L.of(context);
  final p = Pal.of(context);
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: p.ink, width: 2),
      ),
      title: Text(title, style: disp(18, p.ink)),
      content: Text(message, style: body(16, p.ink)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(
            l.cancel,
            style: body(16, p.ink, weight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(yes, style: body(16, p.red, weight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// "42 min" / "1 h 05 min" for totals.
String span(BuildContext context, int ms) {
  final l = L.of(context);
  final m = (ms / 60000).round();
  if (m < 60) return l.minutesShort(m);
  return l.hoursMinutes(m ~/ 60, m % 60);
}

/// Cassette thumbnail for a tape (no text), used on the shelf, in the mini player and in lists.
Widget tapeThumb(
  Tape t, {
  String side = 'A',
  double progress = 0,
  double reel = 0,
  bool text = false,
  bool shadow = true,
}) => Cassette(
  shell: t.shell,
  label: t.label,
  side: side,
  title: text ? t.name : '',
  subtitle: text ? t.dedication : '',
  progress: progress,
  reel: reel,
  text: text,
  shadow: shadow,
);
