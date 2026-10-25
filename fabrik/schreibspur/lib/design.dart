import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Schreibspur's look: warm paper, ink-dark text and bold "wrapped" gradients.
/// Every card and story slide gets its own [Tone].
abstract final class Brand {
  static const ink = Color(0xFF1C1530);
  static const paper = Color(0xFFFFF6EC);
  static const paperDeep = Color(0xFFF6E7D6);
  static const night = Color(0xFF120E1C);
  static const nightCard = Color(0xFF1E1830);

  static const text = 'BricolageText';
  static const display = 'BricolageDisplay';
}

class Tone {
  const Tone(this.a, this.b, {this.dark = false});

  /// Gradient from top left [a] to bottom right [b].
  final Color a, b;

  /// True for light tones that need ink-coloured text.
  final bool dark;

  Color get fg => dark ? Brand.ink : Colors.white;
  Color get soft => fg.withValues(alpha: 0.72);
  Color get track => fg.withValues(alpha: dark ? 0.14 : 0.22);

  LinearGradient get gradient =>
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a, b]);

  /// Colours for people on this tone, busiest first.
  List<Color> get people => dark
      ? const [Brand.ink, Colors.white, Color(0xFF6B3DF5), Color(0xFFD9336F), Color(0xFF0A8F82)]
      : const [Colors.white, Brand.ink, Color(0xFFFFE27A), Color(0xFFA6F5E8), Color(0xFFFFC4D8)];

  static const violet = Tone(Color(0xFF5B3DF5), Color(0xFF9F6BFF));
  static const coral = Tone(Color(0xFFFF5A5F), Color(0xFFFF9A62));
  static const teal = Tone(Color(0xFF0A9E91), Color(0xFF3FD6A8));
  static const sun = Tone(Color(0xFFFFB321), Color(0xFFFFDD66), dark: true);
  static const pink = Tone(Color(0xFFE23C78), Color(0xFFFF8BB0));
  static const blue = Tone(Color(0xFF2360EB), Color(0xFF5AB0FF));
  static const night = Tone(Color(0xFF261C55), Color(0xFF5643B0));
}

/// Gives the widgets below a tone: colours, text and people palette.
class ToneScope extends InheritedWidget {
  const ToneScope({super.key, required this.tone, required super.child});
  final Tone tone;

  static Tone? maybeOf(BuildContext c) => c.dependOnInheritedWidgetOfExactType<ToneScope>()?.tone;

  @override
  bool updateShouldNotify(ToneScope old) => old.tone != tone;
}

/// Wraps [child] so Material widgets and text use [tone]'s foreground colours.
Widget toned(BuildContext context, Tone tone, Widget child) {
  final theme = Theme.of(context);
  final fg = tone.fg;
  final cs = theme.colorScheme.copyWith(
    primary: fg,
    onPrimary: tone.a,
    onSurface: fg,
    onSurfaceVariant: tone.soft,
    outline: tone.soft,
    surfaceContainerHighest: tone.track,
    primaryContainer: fg.withValues(alpha: 0.16),
    onPrimaryContainer: fg,
  );
  return ToneScope(
    tone: tone,
    child: Theme(
      data: theme.copyWith(
        colorScheme: cs,
        textTheme: theme.textTheme.apply(bodyColor: fg, displayColor: fg),
        iconTheme: IconThemeData(color: fg),
        chipTheme: theme.chipTheme.copyWith(
          backgroundColor: fg.withValues(alpha: 0.16),
          labelStyle: TextStyle(color: fg, fontFamily: Brand.text, fontWeight: FontWeight.w600),
        ),
      ),
      child: DefaultTextStyle.merge(style: TextStyle(color: fg), child: child),
    ),
  );
}

ThemeData brandTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final bg = dark ? Brand.night : Brand.paper;
  final fg = dark ? Brand.paper : Brand.ink;
  final scheme = ColorScheme.fromSeed(seedColor: Tone.violet.a, brightness: b).copyWith(
    primary: dark ? const Color(0xFFB9A6FF) : Tone.violet.a,
    surface: bg,
    onSurface: fg,
    surfaceContainerHigh: dark ? Brand.nightCard : Colors.white,
    surfaceContainerHighest: dark ? const Color(0xFF2A2340) : Brand.paperDeep,
    outline: fg.withValues(alpha: 0.55),
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, fontFamily: Brand.text, brightness: b);
  TextStyle d(double size, [FontWeight w = FontWeight.w800]) =>
      TextStyle(fontFamily: Brand.display, fontSize: size, fontWeight: w, height: 1.05, letterSpacing: -0.5);
  return base.copyWith(
    scaffoldBackgroundColor: bg,
    textTheme: base.textTheme.copyWith(
      displayLarge: d(64),
      displayMedium: d(48),
      displaySmall: d(40),
      headlineLarge: d(34),
      headlineMedium: d(28),
      headlineSmall: d(24, FontWeight.w700),
      titleLarge: d(21, FontWeight.w700),
    ).apply(bodyColor: fg, displayColor: fg),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: fg,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(fontFamily: Brand.display, fontSize: 24, fontWeight: FontWeight.w800, color: fg),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: fg,
        foregroundColor: bg,
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontFamily: Brand.text, fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        side: BorderSide(color: fg.withValues(alpha: 0.25), width: 1.5),
        textStyle: const TextStyle(fontFamily: Brand.text, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: fg,
        textStyle: const TextStyle(fontFamily: Brand.text, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: fg,
      contentTextStyle: TextStyle(fontFamily: Brand.text, color: bg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

/// Big pill button with a gradient, used for the main action on a screen.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.tone = Tone.coral,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Tone tone;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: tone.gradient,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [BoxShadow(color: tone.a.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: onPressed == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onPressed!();
                    },
              child: SizedBox(
                height: 58,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, color: tone.fg),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: Brand.text, fontSize: 17, fontWeight: FontWeight.w700, color: tone.fg)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}

/// Soft decorative circles behind hero areas.
class Blobs extends StatelessWidget {
  const Blobs({super.key, required this.tone});
  final Tone tone;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(painter: _BlobPainter(tone), size: Size.infinite),
      );
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.tone);
  final Tone tone;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = tone.fg.withValues(alpha: 0.10);
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.12), size.width * 0.32, p);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.95), size.width * 0.22, p);
    p.color = tone.fg.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.9), size.width * 0.12, p);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.tone != tone;
}
