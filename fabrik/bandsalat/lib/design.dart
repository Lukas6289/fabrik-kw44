import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Risograph craft room": warm paper, navy ink, a few loud inks printed slightly off-register,
/// hard offset shadows instead of blur, hand-lettered labels.
class Pal {
  const Pal({
    required this.bg,
    required this.card,
    required this.ink,
    required this.soft,
    required this.line,
    required this.chip,
    required this.dark,
  });

  final Color bg;
  final Color card;
  final Color ink;
  final Color soft;
  final Color line;
  final Color chip;
  final bool dark;

  static const tomato = Color(0xFFEF4A3A);
  static const mustard = Color(0xFFF4B323);
  static const teal = Color(0xFF1E9E8F);
  static const pink = Color(0xFFF28DB2);
  static const navy = Color(0xFF1B2140);
  static const paper = Color(0xFFF3ECDD);

  static const light = Pal(
    bg: paper,
    card: Color(0xFFFCF8EE),
    ink: navy,
    soft: Color(0xFF666A80),
    line: Color(0xFFD8CDB4),
    chip: Color(0xFFE9DFC8),
    dark: false,
  );

  static const night = Pal(
    bg: Color(0xFF14172A),
    card: Color(0xFF1F2442),
    ink: Color(0xFFF3ECDD),
    soft: Color(0xFFA6A9C4),
    line: Color(0xFF353B68),
    chip: Color(0xFF2A3057),
    dark: true,
  );

  static Pal of(BuildContext c) => Theme.of(c).extension<PalExt>()!.pal;

  /// Text colour for the red accent on the page background.
  Color get red => dark ? const Color(0xFFFF7A6A) : const Color(0xFFD73A2B);
  Color get hardShadow => dark ? const Color(0xFF000000) : navy;
}

class PalExt extends ThemeExtension<PalExt> {
  const PalExt(this.pal);
  final Pal pal;
  @override
  PalExt copyWith({Pal? pal}) => PalExt(pal ?? this.pal);
  @override
  PalExt lerp(PalExt? other, double t) => this;
}

const mono = 'RubikMono';
const hand = 'GochiHand';
const sans = 'SpaceGrotesk';

TextStyle disp(double size, Color color, {double height = 1.1}) => TextStyle(
  fontFamily: mono,
  fontSize: size,
  color: color,
  height: height,
  letterSpacing: -0.5,
);

TextStyle body(
  double size,
  Color color, {
  FontWeight weight = FontWeight.w500,
  double height = 1.35,
}) => TextStyle(
  fontFamily: sans,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

TextStyle written(double size, Color color) =>
    TextStyle(fontFamily: hand, fontSize: size, color: color, height: 1.15);

ThemeData bandTheme(Brightness b) {
  final p = b == Brightness.dark ? Pal.night : Pal.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: Pal.tomato,
    brightness: b,
    primary: Pal.tomato,
    onPrimary: Colors.white,
    surface: p.card,
    onSurface: p.ink,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    fontFamily: sans,
    extensions: [PalExt(p)],
    splashFactory: NoSplash.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerColor: p.line,
    textSelectionTheme: const TextSelectionThemeData(cursorColor: Pal.tomato),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.ink, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.ink, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Pal.tomato, width: 2.5),
      ),
      hintStyle: body(16, p.soft),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.ink,
      contentTextStyle: body(15, p.bg, weight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : p.ink,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Pal.teal : p.chip,
      ),
      trackOutlineColor: WidgetStateProperty.all(p.ink),
    ),
  );
}

/// Page route: the new page slides up a little while fading in.
Route<T> softRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 260),
  reverseTransitionDuration: const Duration(milliseconds: 200),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, a, _, child) => FadeTransition(
    opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ),
);

// ---------------------------------------------------------------- cassette looks

class TapeShell {
  const TapeShell(this.body, this.paper, this.ink1, this.ink2);
  final Color body;
  final Color paper;
  final Color ink1;
  final Color ink2;
}

/// Shell colours (0–2 free, the rest Pro).
const shells = [
  TapeShell(
    Color(0xFFEF4A3A),
    Color(0xFFFFF6E0),
    Color(0xFF1B2140),
    Color(0xFFF4B323),
  ), // tomato
  TapeShell(
    Color(0xFFF4B323),
    Color(0xFFFFF6E0),
    Color(0xFFEF4A3A),
    Color(0xFF1B2140),
  ), // mustard
  TapeShell(
    Color(0xFF1E9E8F),
    Color(0xFFFFF6E0),
    Color(0xFFF4B323),
    Color(0xFF1B2140),
  ), // teal
  TapeShell(
    Color(0xFFF28DB2),
    Color(0xFFFFF6E0),
    Color(0xFF2A3B8F),
    Color(0xFFEF4A3A),
  ), // pink
  TapeShell(
    Color(0xFF2A3B8F),
    Color(0xFFF3ECDD),
    Color(0xFFEF4A3A),
    Color(0xFFF4B323),
  ), // navy
  TapeShell(
    Color(0xFFEFE8D6),
    Color(0xFFFFFFFF),
    Color(0xFF1E9E8F),
    Color(0xFFEF4A3A),
  ), // milk
  TapeShell(
    Color(0xFF2B2B33),
    Color(0xFFF3ECDD),
    Color(0xFFF4B323),
    Color(0xFFF28DB2),
  ), // coal
  TapeShell(
    Color(0xFF9B8AE0),
    Color(0xFFFFF6E0),
    Color(0xFF1B2140),
    Color(0xFFF28DB2),
  ), // lilac
];

const labelStyleCount = 8;

/// Draws label pattern [label] (0 … 7) into [r] with the inks of [s]. [w] is the cassette width for line weights.
void paintLabelPattern(
  Canvas canvas,
  Rect r,
  int label,
  TapeShell s,
  double w,
) {
  canvas.save();
  canvas.clipRect(r);
  final p1 = Paint()..color = s.ink1;
  final p2 = Paint()..color = s.ink2;
  switch (label % labelStyleCount) {
    case 0: // stripes
      final n = 4;
      final hh = r.height / n;
      for (var i = 0; i < n; i++) {
        canvas.drawRect(
          Rect.fromLTWH(r.left, r.top + i * hh, r.width, hh),
          i.isEven ? p1 : p2,
        );
      }
    case 1: // ruled paper
      canvas.drawRect(r, Paint()..color = s.ink2.withValues(alpha: 0.35));
      final step = max(3.0, w * 0.018);
      for (var y = r.top + step; y < r.bottom; y += step) {
        canvas.drawLine(
          Offset(r.left, y),
          Offset(r.right, y),
          Paint()
            ..color = s.ink1.withValues(alpha: 0.55)
            ..strokeWidth = w * 0.004,
        );
      }
    case 2: // halftone dots
      canvas.drawRect(r, p2);
      final step = max(4.0, w * 0.026);
      var row = 0;
      for (var y = r.top + step / 2; y < r.bottom + step; y += step * 0.86) {
        for (
          var x = r.left + (row.isEven ? step / 2 : 0);
          x < r.right + step;
          x += step
        ) {
          canvas.drawCircle(Offset(x, y), step * 0.32, p1);
        }
        row++;
      }
    case 3: // sun
      canvas.drawRect(r, p2);
      final c = Offset(r.center.dx, r.bottom + r.height * 0.1);
      for (var i = 5; i >= 1; i--) {
        canvas.drawCircle(c, r.height * 0.28 * i, i.isOdd ? p1 : p2);
      }
    case 4: // waves
      canvas.drawRect(r, p2);
      final path = Path();
      final amp = r.height * 0.18;
      for (var k = 0; k < 3; k++) {
        path.reset();
        final y0 = r.top + r.height * (0.25 + 0.25 * k);
        path.moveTo(r.left, y0);
        for (var x = 0.0; x <= r.width; x += 2) {
          path.lineTo(r.left + x, y0 + sin(x / w * 28) * amp);
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = s.ink1
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1.5, r.height * 0.1),
        );
      }
    case 5: // checker
      final sq = r.height / 2;
      for (var i = 0; i * sq < r.width; i++) {
        for (var j = 0; j < 2; j++) {
          canvas.drawRect(
            Rect.fromLTWH(r.left + i * sq, r.top + j * sq, sq, sq),
            (i + j).isEven ? p1 : p2,
          );
        }
      }
    case 6: // zigzag
      canvas.drawRect(r, p2);
      final path = Path()..moveTo(r.left, r.bottom);
      final tooth = r.height * 0.9;
      var up = true;
      for (var x = r.left; x < r.right + tooth; x += tooth / 2) {
        path.lineTo(x, up ? r.top + r.height * 0.1 : r.bottom - r.height * 0.1);
        up = !up;
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = s.ink1
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(2, r.height * 0.22)
          ..strokeJoin = StrokeJoin.miter,
      );
    default: // blocks
      canvas.drawRect(r, p2);
      const widths = [0.16, 0.08, 0.22, 0.1, 0.18, 0.12, 0.14];
      var x = r.left;
      var i = 0;
      while (x < r.right) {
        final bw = r.width * widths[i % widths.length];
        if (i.isEven) {
          canvas.drawRect(Rect.fromLTWH(x, r.top, bw, r.height), p1);
        }
        x += bw;
        i++;
      }
  }
  canvas.restore();
}

/// A drawn compact cassette. [reel] turns the hubs, [progress] moves tape from the left to the right reel.
class CassettePainter extends CustomPainter {
  const CassettePainter({
    required this.shell,
    required this.label,
    this.side = 'A',
    this.title = '',
    this.subtitle = '',
    this.reel = 0,
    this.progress = 0,
    this.text = true,
    this.shadow = true,
  });

  final int shell;
  final int label;
  final String side;
  final String title;
  final String subtitle;
  final double reel;
  final double progress;
  final bool text;
  final bool shadow;

  static const aspect = 1.586;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sh = shells[shell.clamp(0, shells.length - 1)];
    final ink = Pal.navy;
    final stroke = max(1.5, w * 0.008);

    // hard offset shadow, printed slightly off-register
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.045),
    );
    if (shadow) {
      canvas.drawRRect(
        body.shift(Offset(w * 0.025, w * 0.025)),
        Paint()..color = ink.withValues(alpha: 0.9),
      );
    }
    canvas.drawRRect(body, Paint()..color = sh.body);
    canvas.drawRRect(
      body,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // screws
    for (final o in [
      Offset(0.045 * w, 0.07 * h),
      Offset(0.955 * w, 0.07 * h),
      Offset(0.045 * w, 0.93 * h),
      Offset(0.955 * w, 0.93 * h),
    ]) {
      canvas.drawCircle(
        o,
        w * 0.016,
        Paint()..color = ink.withValues(alpha: 0.25),
      );
      canvas.drawLine(
        o.translate(-w * 0.009, 0),
        o.translate(w * 0.009, 0),
        Paint()
          ..color = ink.withValues(alpha: 0.7)
          ..strokeWidth = stroke * 0.7,
      );
    }

    // label paper
    final labelRect = Rect.fromLTRB(w * 0.075, h * 0.075, w * 0.925, h * 0.665);
    final lr = RRect.fromRectAndRadius(labelRect, Radius.circular(w * 0.022));
    canvas.drawRRect(lr, Paint()..color = sh.paper);
    canvas.save();
    canvas.clipRRect(lr);
    paintLabelPattern(
      canvas,
      Rect.fromLTRB(labelRect.left, labelRect.top, labelRect.right, h * 0.205),
      label,
      sh,
      w,
    );
    paintLabelPattern(
      canvas,
      Rect.fromLTRB(
        labelRect.left,
        h * 0.60,
        labelRect.right,
        labelRect.bottom,
      ),
      label,
      sh,
      w,
    );
    canvas.restore();
    canvas.drawRRect(
      lr,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // side badge
    final badge = Offset(labelRect.left + w * 0.075, h * 0.1425);
    canvas.drawCircle(badge, w * 0.05, Paint()..color = sh.paper);
    canvas.drawCircle(
      badge,
      w * 0.05,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    _text(canvas, side, badge, w * 0.065, ink, font: mono, center: true);

    if (text) {
      final tw = labelRect.width - w * 0.06;
      if (title.isNotEmpty) {
        _fit(
          canvas,
          title,
          Offset(labelRect.left + w * 0.03, h * 0.215),
          tw,
          w * 0.082,
          ink,
          font: hand,
        );
      }
    }

    // window with the reels
    final win = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.17, h * 0.335, w * 0.83, h * 0.60),
      Radius.circular(w * 0.035),
    );
    canvas.drawRRect(win, Paint()..color = const Color(0xFF15121A));
    final cy = h * 0.4675;
    final lx = w * 0.335;
    final rx = w * 0.665;
    final minR = w * 0.052;
    final maxR = min(w * 0.092, (h * 0.265) / 2 - w * 0.004);
    final p = progress.clamp(0.0, 1.0);
    canvas.save();
    canvas.clipRRect(win);
    _reel(canvas, Offset(lx, cy), minR + (maxR - minR) * (1 - p), w, reel);
    _reel(canvas, Offset(rx, cy), minR + (maxR - minR) * p, w, -reel);
    // glass glint
    canvas.drawRect(
      Rect.fromLTWH(win.left, win.top, win.width, win.height * 0.28),
      Paint()..color = Colors.white.withValues(alpha: 0.07),
    );
    canvas.restore();
    canvas.drawRRect(
      win,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // bottom plate
    final plate = Path()
      ..moveTo(w * 0.15, h)
      ..lineTo(w * 0.215, h * 0.725)
      ..lineTo(w * 0.785, h * 0.725)
      ..lineTo(w * 0.85, h)
      ..close();
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawPath(plate, Paint()..color = Color.lerp(sh.body, ink, 0.28)!);
    canvas.drawPath(
      plate,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    for (final x in [0.315, 0.685]) {
      canvas.drawCircle(
        Offset(w * x, h * 0.865),
        w * 0.026,
        Paint()..color = const Color(0xFF15121A),
      );
    }
    final slot = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.865),
        width: w * 0.16,
        height: h * 0.075,
      ),
      Radius.circular(w * 0.01),
    );
    canvas.drawRRect(slot, Paint()..color = const Color(0xFF15121A));
    canvas.restore();
  }

  void _reel(Canvas canvas, Offset c, double r, double w, double angle) {
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF4A3329));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.006,
    );
    canvas.drawCircle(
      c,
      r * 0.72,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.004,
    );
    final hub = w * 0.044;
    canvas.drawCircle(c, hub, Paint()..color = const Color(0xFFEDE6D3));
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    for (var i = 0; i < 6; i++) {
      canvas.rotate(pi / 3);
      canvas.drawRect(
        Rect.fromLTWH(hub * 0.38, -hub * 0.13, hub * 0.62, hub * 0.26),
        Paint()..color = const Color(0xFF15121A),
      );
    }
    canvas.restore();
    canvas.drawCircle(c, hub * 0.4, Paint()..color = const Color(0xFF15121A));
  }

  void _text(
    Canvas canvas,
    String t,
    Offset at,
    double size,
    Color color, {
    String font = sans,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
          fontFamily: font,
          fontSize: size,
          color: color,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center ? at - Offset(tp.width / 2, tp.height / 2) : at);
  }

  void _fit(
    Canvas canvas,
    String t,
    Offset at,
    double maxW,
    double size,
    Color color, {
    String font = sans,
  }) {
    var s = size;
    TextPainter tp;
    do {
      tp = TextPainter(
        text: TextSpan(
          text: t,
          style: TextStyle(
            fontFamily: font,
            fontSize: s,
            color: color,
            height: 1.05,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: maxW);
      s *= 0.92;
    } while (tp.didExceedMaxLines && s > size * 0.55);
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(CassettePainter o) =>
      o.shell != shell ||
      o.label != label ||
      o.side != side ||
      o.title != title ||
      o.subtitle != subtitle ||
      o.reel != reel ||
      o.progress != progress ||
      o.text != text;
}

class Cassette extends StatelessWidget {
  const Cassette({
    super.key,
    required this.shell,
    required this.label,
    this.side = 'A',
    this.title = '',
    this.subtitle = '',
    this.reel = 0,
    this.progress = 0,
    this.text = true,
    this.shadow = true,
  });
  final int shell;
  final int label;
  final String side;
  final String title;
  final String subtitle;
  final double reel;
  final double progress;
  final bool text;
  final bool shadow;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: CassettePainter.aspect,
    child: CustomPaint(
      painter: CassettePainter(
        shell: shell,
        label: label,
        side: side,
        title: title,
        subtitle: subtitle,
        reel: reel,
        progress: progress,
        text: text,
        shadow: shadow,
      ),
    ),
  );
}

// ---------------------------------------------------------------- building blocks

/// Paper speckles: tiny ink dots, fixed pattern, very light.
class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return ColoredBox(
      color: p.bg,
      child: CustomPaint(painter: _Speckle(p.dark), child: child),
    );
  }
}

class _Speckle extends CustomPainter {
  _Speckle(this.dark);
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final r = Random(11);
    final paint = Paint()
      ..color = (dark ? Colors.white : Pal.navy).withValues(
        alpha: dark ? 0.05 : 0.06,
      );
    for (var i = 0; i < 140; i++) {
      canvas.drawCircle(
        Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
        0.6 + r.nextDouble() * 1.1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_Speckle o) => o.dark != dark;
}

/// A card with a thick outline and a hard offset shadow.
class Riso extends StatelessWidget {
  const Riso({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.offset = 4,
    this.onTap,
  });
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final double radius;
  final double offset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.ink, width: 2),
        boxShadow: [
          BoxShadow(color: p.hardShadow, offset: Offset(offset, offset)),
        ],
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: box,
    );
  }
}

/// A chunky key that sinks into its shadow when pressed.
class Key3 extends StatefulWidget {
  const Key3({
    super.key,
    required this.child,
    required this.onTap,
    this.color,
    this.width = 64,
    this.height = 56,
    this.onHoldStart,
    this.onHoldEnd,
    this.semantics,
    this.active = false,
  });
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double width;
  final double height;
  final VoidCallback? onHoldStart;
  final VoidCallback? onHoldEnd;
  final String? semantics;
  final bool active;

  @override
  State<Key3> createState() => _Key3State();
}

class _Key3State extends State<Key3> {
  bool _down = false;
  bool _held = false;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final c = widget.color ?? p.card;
    final depth = (_down || widget.active) ? 1.0 : 5.0;
    return Semantics(
      button: true,
      label: widget.semantics,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          if (_held) {
            _held = false;
            return;
          }
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        onLongPressStart: widget.onHoldStart == null
            ? null
            : (_) {
                _held = true;
                widget.onHoldStart!();
              },
        onLongPressEnd: widget.onHoldStart == null
            ? null
            : (_) {
                widget.onHoldEnd?.call();
                setState(() => _down = false);
                Future.delayed(
                  const Duration(milliseconds: 50),
                  () => _held = false,
                );
              },
        child: SizedBox(
          width: widget.width,
          height: widget.height + 5,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                height: widget.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.hardShadow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                left: 0,
                right: 0,
                top: 5 - depth,
                height: widget.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.ink, width: 2),
                  ),
                  child: Center(child: widget.child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big filled button (tomato by default).
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = Pal.tomato,
    this.textColor = Colors.white,
    this.expand = true,
  });
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final btn = Key3(
      width: expand ? double.infinity : 200,
      height: 52,
      color: onTap == null ? Pal.of(context).chip : color,
      onTap: onTap,
      semantics: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: body(17, textColor, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Small capsule label.
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color, this.textColor});
  final String text;
  final Color? color;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? p.chip,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: p.ink, width: 1.5),
      ),
      child: Text(
        text,
        style: body(12, textColor ?? p.ink, weight: FontWeight.w700),
      ),
    );
  }
}

/// How full one side of the tape is: a row of blocks, one per 3 minutes.
class TapeBar extends StatelessWidget {
  const TapeBar({
    super.key,
    required this.usedMs,
    required this.capacityMs,
    this.height = 18,
    this.color = Pal.teal,
  });
  final int usedMs;
  final int capacityMs;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BarPainter(
          usedMs,
          capacityMs,
          color,
          p.ink,
          p.chip,
          Pal.tomato,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.used, this.cap, this.color, this.ink, this.empty, this.over);
  final int used;
  final int cap;
  final Color color;
  final Color ink;
  final Color empty;
  final Color over;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2.4),
    );
    canvas.drawRRect(r, Paint()..color = empty);
    canvas.save();
    canvas.clipRRect(r);
    final frac = cap == 0 ? 0.0 : used / cap;
    final w = size.width * frac.clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, size.height),
      Paint()..color = frac > 1 ? over : color,
    );
    // ticks every 5 minutes of the side
    final tick = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    final steps = max(1, (cap / 300000).round());
    for (var i = 1; i < steps; i++) {
      final x = size.width * i / steps;
      canvas.drawLine(
        Offset(x, size.height * 0.55),
        Offset(x, size.height),
        tick,
      );
    }
    canvas.restore();
    canvas.drawRRect(
      r,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_BarPainter o) =>
      o.used != used || o.cap != cap || o.color != color || o.ink != ink;
}
