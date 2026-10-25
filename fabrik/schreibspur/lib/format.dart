import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';

String _tag(BuildContext c) => Localizations.localeOf(c).toLanguageTag();

String dateText(BuildContext c, DateTime d) => DateFormat.yMMMd(_tag(c)).format(d);

String weekdayName(BuildContext c, int mondayIndex) =>
    DateFormat.EEEE(_tag(c)).format(DateTime(2024, 1, 1 + mondayIndex)); // 2024-01-01 was a Monday

String number(BuildContext c, num n) => NumberFormat.decimalPattern(_tag(c)).format(n);

String decimal(BuildContext c, double n) =>
    NumberFormat('#,##0.0', _tag(c)).format(n);

String hourRange(L l, int h) => l.hourRange(h, (h + 1) % 24);

String durationText(L l, Duration d) {
  final minutes = d.inMinutes;
  if (minutes < 1) return l.durUnderMinute;
  if (minutes < 60) return l.durMinutes(minutes);
  if (d.inHours < 48) return l.durHours(d.inHours, minutes % 60);
  return l.durDays(d.inDays, d.inHours % 24);
}

/// "+34 %" / "−12 %"; null when there is nothing to compare against.
String? changeText(BuildContext c, num before, num now) {
  if (before == 0) return null;
  final p = ((now - before) / before * 100).round();
  final s = NumberFormat.decimalPattern(_tag(c)).format(p.abs());
  return p >= 0 ? '+$s %' : '−$s %';
}

/// "Jan" / "Jan 2026" (German: "Jan." / "Jan. 26").
String monthLabel(BuildContext c, DateTime d, {bool withYear = false}) {
  final m = DateFormat.MMM(_tag(c)).format(d);
  return withYear ? "$m '${(d.year % 100).toString().padLeft(2, '0')}" : m;
}
