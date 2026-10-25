import 'models.dart';

/// Scaling and unit conversion for the portion calculator.

/// Display unit labels for the canonical unit keys.
String unitLabel(String key, String lang, {bool plural = false}) {
  final de = lang == 'de';
  switch (key) {
    case 'tbsp':
      return de ? 'EL' : 'tbsp';
    case 'tsp':
      return de ? 'TL' : 'tsp';
    case 'cup':
      return de ? (plural ? 'Tassen' : 'Tasse') : (plural ? 'cups' : 'cup');
    case 'pc':
      return de ? 'Stück' : (plural ? 'pcs' : 'pc');
    case 'clove':
      return de ? (plural ? 'Zehen' : 'Zehe') : (plural ? 'cloves' : 'clove');
    case 'slice':
      return de ? (plural ? 'Scheiben' : 'Scheibe') : (plural ? 'slices' : 'slice');
    case 'bunch':
      return de ? 'Bund' : 'bunch';
    case 'can':
      return de ? (plural ? 'Dosen' : 'Dose') : (plural ? 'cans' : 'can');
    case 'pack':
      return de ? 'Pck.' : 'pkg';
    case 'pinch':
      return de ? 'Prise' : 'pinch';
    case 'msp':
      return de ? 'Msp.' : 'dash';
    case 'handful':
      return de ? 'Handvoll' : 'handful';
    case 'sprig':
      return de ? (plural ? 'Zweige' : 'Zweig') : (plural ? 'sprigs' : 'sprig');
    case 'stick':
      return de ? (plural ? 'Stangen' : 'Stange') : (plural ? 'sticks' : 'stick');
    case 'pfund':
      return de ? 'Pfund' : 'lb';
    default:
      return key;
  }
}

final _fracs = <double, String>{0.125: '⅛', 0.25: '¼', 1 / 3: '⅓', 0.5: '½', 2 / 3: '⅔', 0.75: '¾'};

/// "1½", "¼", "2,5", "120" – amounts the way a cook reads them.
String formatQty(double v, String lang, {bool fractions = false}) {
  if (v <= 0) return '0';
  if (fractions) {
    final whole = v.floor();
    final frac = v - whole;
    if (frac < 0.06) return whole == 0 ? '⅛' : '$whole';
    for (final e in _fracs.entries) {
      if ((frac - e.key).abs() < 0.06) return '${whole == 0 ? '' : whole}${e.value}';
    }
    if (frac > 0.94) return '${whole + 1}';
  }
  final r = v >= 100 ? v.roundToDouble() : (v >= 10 ? (v * 2).round() / 2 : (v * 10).round() / 10);
  var s = r == r.roundToDouble() ? r.round().toString() : r.toString();
  if (lang == 'de') s = s.replaceAll('.', ',');
  return s;
}

/// Scaled and (maybe) converted amount of one line.
class Shown {
  const Shown(this.qty, this.unit);
  final double? qty;
  final String unit;
}

Shown scaleIng(Ing i, double factor, UnitSystem system) {
  if (i.qty == null) return Shown(null, i.unit);
  var q = i.qty! * factor;
  var u = i.unit;
  if (u == 'pfund') {
    q *= 500;
    u = 'g';
  }
  if (u == 'kg') {
    q *= 1000;
    u = 'g';
  } else if (u == 'l') {
    q *= 1000;
    u = 'ml';
  } else if (u == 'cl') {
    q *= 10;
    u = 'ml';
  } else if (u == 'dl') {
    q *= 100;
    u = 'ml';
  } else if (u == 'mg') {
    q /= 1000;
    u = 'g';
  }
  if (system == UnitSystem.us) {
    if (u == 'g') {
      final oz = q / 28.35;
      return oz >= 16 ? Shown(oz / 16, 'lb') : Shown(oz, 'oz');
    }
    if (u == 'ml') {
      if (q < 15) return Shown(q / 5, 'tsp');
      if (q < 60) return Shown(q / 15, 'tbsp');
      return Shown(q / 240, 'cup');
    }
    return Shown(q, u);
  }
  // metric
  if (u == 'oz') return _metric(q * 28.35, 'g');
  if (u == 'lb') return _metric(q * 453.6, 'g');
  if (u == 'cup') return _metric(q * 240, 'ml');
  if (u == 'g' || u == 'ml') return _metric(q, u);
  return Shown(q, u);
}

Shown _metric(double q, String u) {
  if (q >= 1000) return Shown(q / 1000, u == 'g' ? 'kg' : 'l');
  if (q >= 20) q = (q / 5).round() * 5.0;
  return Shown(q, u);
}

/// One ingredient line as text, e.g. "1½ EL Olivenöl" (name and note follow).
String ingText(Ing i, double factor, UnitSystem system, String lang, {bool withNote = true}) {
  final s = scaleIng(i, factor, system);
  final parts = <String>[];
  if (s.qty != null) {
    final frac = const {'cup', 'tbsp', 'tsp', 'pc', 'lb', 'oz', ''}.contains(s.unit) || s.unit == 'pc';
    parts.add(formatQty(s.qty!, lang, fractions: frac));
    if (s.unit.isNotEmpty) parts.add(unitLabel(s.unit, lang, plural: s.qty! > 1));
  }
  parts.add(i.name);
  var t = parts.join(' ');
  if (withNote && i.note.isNotEmpty) t = '$t, ${i.note}';
  return t;
}

/// Total minutes as "1 h 20 min" / "45 min".
String minutesText(int m, String lang) {
  if (m <= 0) return '';
  final h = m ~/ 60;
  final r = m % 60;
  if (h == 0) return '$r min';
  return r == 0 ? '$h h' : '$h h $r min';
}

/// A shopping-list line, e.g. "300 g Möhren".
String shopLine(ShopItem s, String lang) {
  if (s.qty == null) return s.name;
  final frac = const {'cup', 'tbsp', 'tsp', 'pc', 'lb', 'oz', ''}.contains(s.unit);
  return [formatQty(s.qty!, lang, fractions: frac), if (s.unit.isNotEmpty) unitLabel(s.unit, lang, plural: s.qty! > 1), s.name].join(' ');
}

/// A line the way it is typed in the editor (no unit conversion), so it reads back unchanged.
String ingSource(Ing i, String lang) {
  final parts = <String>[];
  if (i.qty != null) {
    parts.add(formatQty(i.qty!, lang, fractions: true));
    if (i.unit.isNotEmpty) parts.add(unitLabel(i.unit, lang, plural: i.qty! > 1));
  }
  parts.add(i.name);
  final t = parts.join(' ');
  return i.note.isEmpty ? t : '$t, ${i.note}';
}
