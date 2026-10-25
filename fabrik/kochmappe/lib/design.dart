import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Mappe": linen paper, deep ink-blue, saffron. Recipe cards with a drawn motif, index tabs.
class Pal {
  const Pal({
    required this.bg,
    required this.card,
    required this.ink,
    required this.soft,
    required this.line,
    required this.chip,
    required this.accent,
    required this.onAccent,
    required this.bar,
    required this.dark,
  });

  final Color bg;
  final Color card;
  final Color ink;
  final Color soft;
  final Color line;
  final Color chip;
  final Color accent;
  final Color onAccent;
  final Color bar;
  final bool dark;

  /// Card / folder colours (index = Recipe.hue, Folder.hue).
  static const hues = [
    Color(0xFFF2A516), // saffron
    Color(0xFFB8335A), // berry
    Color(0xFF5F8F6B), // sage
    Color(0xFF4C86C6), // sky
    Color(0xFFD9683B), // terracotta
    Color(0xFF7A55A3), // plum
  ];

  /// Accent colours of the binder (0 is free, the others are Pro).
  static const themes = [
    Color(0xFFF2A516),
    Color(0xFFE0557E),
    Color(0xFF6FB07E),
    Color(0xFF5CA0E6),
    Color(0xFFE8794A),
  ];

  static Pal build(Brightness b, int theme) {
    final a = themes[theme.clamp(0, themes.length - 1)];
    if (b == Brightness.dark) {
      return Pal(
        bg: const Color(0xFF0D1524),
        card: const Color(0xFF17223A),
        ink: const Color(0xFFF4EEDF),
        soft: const Color(0xFF9FAAC0),
        line: const Color(0xFF27365A),
        chip: const Color(0xFF1F2D4A),
        accent: a,
        onAccent: const Color(0xFF14213D),
        bar: const Color(0xFF0A101C),
        dark: true,
      );
    }
    return Pal(
      bg: const Color(0xFFF5F0E6),
      card: const Color(0xFFFFFDF8),
      ink: const Color(0xFF14213D),
      soft: const Color(0xFF5F6A80),
      line: const Color(0xFFE6DDCB),
      chip: const Color(0xFFEDE5D4),
      accent: a,
      onAccent: const Color(0xFF14213D),
      bar: const Color(0xFF14213D),
      dark: false,
    );
  }

  static Pal of(BuildContext c) => Theme.of(c).extension<PalExt>()!.pal;

  /// Readable accent text on the page background (saffron on linen is too pale for text).
  Color get accentText => dark ? accent : Color.lerp(accent, const Color(0xFF14213D), 0.45)!;
}

class PalExt extends ThemeExtension<PalExt> {
  const PalExt(this.pal);
  final Pal pal;
  @override
  PalExt copyWith({Pal? pal}) => PalExt(pal ?? this.pal);
  @override
  PalExt lerp(PalExt? other, double t) => this;
}

const serif = 'YoungSerif';
const sans = 'Figtree';

TextStyle disp(double size, Color color, {double height = 1.12}) =>
    TextStyle(fontFamily: serif, fontSize: size, color: color, height: height, letterSpacing: size > 30 ? -0.4 : 0);

TextStyle body(double size, Color color, {FontWeight weight = FontWeight.w500, double height = 1.35}) =>
    TextStyle(fontFamily: sans, fontSize: size, fontWeight: weight, color: color, height: height);

ThemeData mappeTheme(Brightness b, int themeIndex) {
  final p = Pal.build(b, themeIndex);
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: b,
    primary: p.accent,
    onPrimary: p.onAccent,
    surface: p.card,
    onSurface: p.ink,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    fontFamily: sans,
    splashFactory: InkRipple.splashFactory,
    extensions: [PalExt(p)],
    textTheme: Typography.material2021().black.apply(fontFamily: sans, bodyColor: p.ink, displayColor: p.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: disp(21, p.ink),
      systemOverlayStyle: b == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    dividerColor: p.line,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.onAccent : p.soft),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.chip),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        minimumSize: const Size(88, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: body(17, p.onAccent, weight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        minimumSize: const Size(88, 48),
        side: BorderSide(color: p.line, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: body(15, p.ink, weight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.accentText,
        minimumSize: const Size(44, 44),
        textStyle: body(15, p.accentText, weight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: body(16, p.soft),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.accent, width: 2)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.card,
      modalBackgroundColor: p.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    ),
    dialogTheme: DialogThemeData(backgroundColor: p.card, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.dark ? p.chip : const Color(0xFF14213D),
      contentTextStyle: body(15, const Color(0xFFF4EEDF), weight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

bool isDe(BuildContext c) => Localizations.localeOf(c).languageCode == 'de';

/// Phone vs. tablet layout.
bool isWide(BuildContext c) => MediaQuery.sizeOf(c).width >= 840;

Route<T> softRoute<T>(Widget page) => PageRouteBuilder<T>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, a, _, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: c, child: SlideTransition(position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(c), child: child));
      },
    );

// ------------------------------------------------------------------ widgets

/// A white card with a soft shadow – the "index card".
class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.radius = 20, this.color});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      decoration: BoxDecoration(
        color: color ?? p.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.line),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: p.dark ? 0.35 : 0.06), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.icon, this.color, this.fg});
  final String text;
  final IconData? icon;
  final Color? color;
  final Color? fg;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final f = fg ?? p.soft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color ?? p.chip, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: f), const SizedBox(width: 4)],
        Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(12.5, f, weight: FontWeight.w700, height: 1.1))),
      ]),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Row(children: [
        Expanded(child: Text(text, style: disp(20, p.ink))),
        ?trailing,
      ]),
    );
  }
}

/// Number that counts to its new value.
class CountText extends StatelessWidget {
  const CountText(this.value, {super.key, required this.style, this.suffix = ''});
  final int value;
  final TextStyle style;
  final String suffix;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: value.toDouble()),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => Text('${v.round()}$suffix', style: style),
      );
}

class Stars extends StatelessWidget {
  const Stars(this.value, {super.key, this.size = 16, this.onTap});
  final int value;
  final double size;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 1; i <= 5; i++)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap == null ? null : () => onTap!(i),
          child: Padding(
            padding: EdgeInsets.all(onTap == null ? 0 : 6),
            child: Icon(i <= value ? Icons.star_rounded : Icons.star_outline_rounded, size: size, color: i <= value ? p.accent : p.soft.withValues(alpha: 0.6)),
          ),
        ),
    ]);
  }
}

// ------------------------------------------------------------------ drawn cover art

/// The drawn motif of a recipe card: a soft disc in the card colour with a simple dish on it.
class MotifPainter extends CustomPainter {
  MotifPainter({required this.motif, required this.hue, required this.dark});
  final int motif;
  final Color hue;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bg = Paint()..color = Color.lerp(hue, dark ? const Color(0xFF0D1524) : const Color(0xFFFFF8E8), dark ? 0.62 : 0.74)!;
    canvas.drawRect(Offset.zero & size, bg);
    // soft discs
    canvas.drawCircle(Offset(w * 0.86, h * 0.14), min(w, h) * 0.32, Paint()..color = hue.withValues(alpha: 0.16));
    canvas.drawCircle(Offset(w * 0.1, h * 0.92), min(w, h) * 0.26, Paint()..color = hue.withValues(alpha: 0.14));
    final s = min(w, h) * 0.5;
    canvas.save();
    canvas.translate(w / 2, h / 2 + s * 0.06);
    final main = Paint()..color = hue;
    final dk = Paint()..color = Color.lerp(hue, const Color(0xFF14213D), 0.55)!;
    final light = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final cream = Paint()..color = const Color(0xFFFFF4DC);
    final ink = Paint()
      ..color = Color.lerp(hue, const Color(0xFF14213D), 0.7)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.05
      ..strokeCap = StrokeCap.round;
    switch (motif % motifTotal) {
      case 0: // bowl with steam
        canvas.drawPath(Path()..moveTo(-s, -s * 0.05)..lineTo(s, -s * 0.05)..quadraticBezierTo(s * 0.9, s * 0.85, 0, s * 0.85)..quadraticBezierTo(-s * 0.9, s * 0.85, -s, -s * 0.05)..close(), main);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-s * 1.05, -s * 0.16, s * 1.05, s * 0.06), Radius.circular(s * 0.1)), dk);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-s * 0.5, s * 0.82, s * 0.5, s * 0.96), Radius.circular(s * 0.07)), dk);
        for (final dx in [-0.4, 0.0, 0.4]) {
          canvas.drawPath(Path()..moveTo(s * dx, -s * 0.35)..cubicTo(s * (dx + 0.18), -s * 0.55, s * (dx - 0.18), -s * 0.7, s * dx, -s * 0.95), ink);
        }
        canvas.drawCircle(Offset(-s * 0.35, s * 0.3), s * 0.09, light);
      case 1: // pan
        canvas.drawCircle(Offset(-s * 0.2, 0), s * 0.8, dk);
        canvas.drawCircle(Offset(-s * 0.2, 0), s * 0.64, main);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(s * 0.55, -s * 0.09, s * 1.4, s * 0.09), Radius.circular(s * 0.09)), dk);
        canvas.drawCircle(Offset(-s * 0.4, -s * 0.15), s * 0.2, cream);
        canvas.drawCircle(Offset(-s * 0.4, -s * 0.15), s * 0.09, Paint()..color = const Color(0xFFF2A516));
        canvas.drawCircle(Offset(-s * 0.05, s * 0.25), s * 0.13, cream);
        canvas.drawCircle(Offset(-s * 0.05, s * 0.25), s * 0.06, Paint()..color = const Color(0xFFF2A516));
      case 2: // cake slice
        canvas.drawPath(Path()..moveTo(-s, s * 0.55)..lineTo(-s * 0.7, -s * 0.35)..lineTo(s, -s * 0.05)..lineTo(s, s * 0.55)..close(), main);
        canvas.drawPath(Path()..moveTo(-s, s * 0.1)..lineTo(s, s * 0.1)..lineTo(s, s * 0.22)..lineTo(-s, s * 0.22)..close(), cream);
        canvas.drawPath(Path()..moveTo(-s * 0.7, -s * 0.35)..lineTo(s, -s * 0.05)..lineTo(s, s * 0.08)..lineTo(-s * 0.78, -s * 0.18)..close(), dk);
        canvas.drawCircle(Offset(-s * 0.1, -s * 0.52), s * 0.17, Paint()..color = const Color(0xFFD9352F));
        canvas.drawLine(Offset(-s * 0.1, -s * 0.66), Offset(s * 0.02, -s * 0.86), ink);
      case 3: // bread loaf
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-s, -s * 0.35, s, s * 0.6), Radius.circular(s * 0.5)), main);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-s * 0.85, -s * 0.25, s * 0.85, s * 0.5), Radius.circular(s * 0.4)), Paint()..color = Color.lerp(hue, Colors.white, 0.22)!);
        for (final dx in [-0.45, 0.0, 0.45]) {
          canvas.drawLine(Offset(s * (dx - 0.1), -s * 0.1), Offset(s * (dx + 0.1), s * 0.25), ink);
        }
      case 4: // glass
        canvas.drawPath(Path()..moveTo(-s * 0.55, -s * 0.8)..lineTo(s * 0.55, -s * 0.8)..lineTo(s * 0.4, s * 0.8)..lineTo(-s * 0.4, s * 0.8)..close(), light);
        canvas.drawPath(Path()..moveTo(-s * 0.5, -s * 0.2)..lineTo(s * 0.5, -s * 0.2)..lineTo(s * 0.4, s * 0.8)..lineTo(-s * 0.4, s * 0.8)..close(), main);
        canvas.drawCircle(Offset(-s * 0.1, s * 0.2), s * 0.08, light);
        canvas.drawCircle(Offset(s * 0.15, s * 0.45), s * 0.06, light);
        canvas.drawLine(Offset(s * 0.2, -s * 1.0), Offset(s * 0.05, -s * 0.2), ink);
      case 5: // pot
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-s * 0.8, -s * 0.3, s * 0.8, s * 0.75), Radius.circular(s * 0.16)), main);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-s * 0.9, -s * 0.5, s * 0.9, -s * 0.28), Radius.circular(s * 0.1)), dk);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-s * 1.2, -s * 0.05, -s * 0.8, s * 0.07), Radius.circular(s * 0.06)), dk);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(s * 0.8, -s * 0.05, s * 1.2, s * 0.07), Radius.circular(s * 0.06)), dk);
        canvas.drawCircle(Offset(0, -s * 0.62), s * 0.1, dk);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-s * 0.55, s * 0.0, -s * 0.35, s * 0.6), Radius.circular(s * 0.1)), light);
      case 6: // plate with cutlery
        canvas.drawCircle(Offset.zero, s * 0.78, light);
        canvas.drawCircle(Offset.zero, s * 0.78, Paint()..color = dk.color..style = PaintingStyle.stroke..strokeWidth = s * 0.05);
        canvas.drawCircle(Offset.zero, s * 0.48, main);
        canvas.drawCircle(Offset(-s * 0.12, -s * 0.1), s * 0.14, cream);
        canvas.drawCircle(Offset(s * 0.14, s * 0.1), s * 0.1, Paint()..color = const Color(0xFF6FA35B));
        canvas.drawLine(Offset(-s * 1.15, -s * 0.7), Offset(-s * 1.15, s * 0.75), ink);
        canvas.drawLine(Offset(s * 1.15, -s * 0.7), Offset(s * 1.15, s * 0.75), ink);
      default: // lemon + leaf
        canvas.drawOval(Rect.fromCenter(center: Offset(-s * 0.1, s * 0.05), width: s * 1.6, height: s * 1.2), main);
        canvas.drawOval(Rect.fromCenter(center: Offset(-s * 0.1, s * 0.05), width: s * 1.2, height: s * 0.85), Paint()..color = Color.lerp(hue, Colors.white, 0.45)!);
        for (var i = 0; i < 6; i++) {
          final a = i * pi / 3;
          canvas.drawLine(Offset(-s * 0.1, s * 0.05), Offset(-s * 0.1 + cos(a) * s * 0.52, s * 0.05 + sin(a) * s * 0.36), Paint()..color = main.color..strokeWidth = s * 0.05);
        }
        canvas.drawPath(Path()..moveTo(s * 0.55, -s * 0.5)..quadraticBezierTo(s * 1.0, -s * 0.95, s * 1.25, -s * 0.4)..quadraticBezierTo(s * 0.9, -s * 0.2, s * 0.55, -s * 0.5)..close(), Paint()..color = const Color(0xFF5F8F6B));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MotifPainter o) => o.motif != motif || o.hue != hue || o.dark != dark;
}

const motifTotal = 8;

/// The picture of a recipe card: its own photo if it has one, else the drawn motif.
class Cover extends StatelessWidget {
  const Cover({super.key, required this.motif, required this.hue, this.photo, this.radius = 0});
  final int motif;
  final int hue;
  final ImageProvider? photo;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final art = CustomPaint(
      painter: MotifPainter(motif: motif, hue: Pal.hues[hue % Pal.hues.length], dark: p.dark),
      child: const SizedBox.expand(),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: photo == null
          ? art
          : Image(image: photo!, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, _, _) => art),
    );
  }
}

/// Ring that empties while a timer runs.
class RingPainter extends CustomPainter {
  RingPainter({required this.value, required this.color, required this.track, this.width = 8});
  final double value;
  final Color color;
  final Color track;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (min(size.width, size.height) - width) / 2;
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, r, Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = width);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi * value.clamp(0.0, 1.0), false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = width..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(RingPainter o) => o.value != value || o.color != color;
}

void tick() => HapticFeedback.selectionClick();
void bump() => HapticFeedback.mediumImpact();
