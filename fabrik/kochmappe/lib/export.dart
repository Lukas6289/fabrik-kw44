import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'l10n/app_localizations.dart';
import 'models.dart';
import 'scale.dart';
import 'services.dart';

/// PDF pages for one recipe or the whole binder (Pro). Plain data in, bytes out.
class PdfStrings {
  const PdfStrings({required this.ingredients, required this.steps, required this.servings, required this.myTwist, required this.contents, required this.bookTitle});
  final String ingredients;
  final String steps;
  final String servings;
  final String myTwist;
  final String contents;
  final String bookTitle;
}

pw.ThemeData _theme(ByteData? regular, ByteData? bold, ByteData? serif) => regular != null && bold != null
    ? pw.ThemeData.withFont(base: pw.Font.ttf(regular), bold: pw.Font.ttf(bold))
    : pw.ThemeData();

const _ink = PdfColor.fromInt(0xFF14213D);
const _soft = PdfColor.fromInt(0xFF5F6A80);
const _saffron = PdfColor.fromInt(0xFFF2A516);
const _line = PdfColor.fromInt(0xFFE6DDCB);

List<pw.Widget> _recipePage(Recipe r, int servings, UnitSystem units, String lang, PdfStrings t, pw.Font? serif) {
  final f = r.servings == 0 ? 1.0 : servings / r.servings;
  final head = pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _ink);
  return [
    pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _saffron, width: 3))),
      child: pw.Text(r.title, style: pw.TextStyle(font: serif, fontSize: 26, color: _ink)),
    ),
    pw.Text([
      '${t.servings}: $servings',
      if (r.prepMin > 0) minutesText(r.prepMin, lang),
      if (r.cookMin > 0) minutesText(r.cookMin, lang),
      if (r.tags.isNotEmpty) r.tags.join(' · '),
    ].join('   |   '), style: const pw.TextStyle(fontSize: 10.5, color: _soft)),
    pw.SizedBox(height: 14),
    pw.Text(t.ingredients, style: head),
    pw.SizedBox(height: 4),
    for (final i in r.ingredients)
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _line, width: 0.5))),
        child: pw.Text(ingText(i, f, units, lang), style: const pw.TextStyle(fontSize: 11.5, color: _ink)),
      ),
    pw.SizedBox(height: 14),
    pw.Text(t.steps, style: head),
    pw.SizedBox(height: 4),
    for (var k = 0; k < r.steps.length; k++)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.SizedBox(width: 22, child: pw.Text('${k + 1}.', style: pw.TextStyle(fontSize: 11.5, fontWeight: pw.FontWeight.bold, color: _ink))),
          pw.Expanded(child: pw.Text(r.steps[k], style: const pw.TextStyle(fontSize: 11.5, color: _ink, lineSpacing: 2))),
        ]),
      ),
    if (r.twist.isNotEmpty) ...[
      pw.SizedBox(height: 10),
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFBEBC8), borderRadius: pw.BorderRadius.all(pw.Radius.circular(6))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(t.myTwist, style: head),
          pw.SizedBox(height: 3),
          pw.Text(r.twist, style: const pw.TextStyle(fontSize: 11, color: _ink)),
        ]),
      ),
    ],
    if (r.source.isNotEmpty) ...[pw.SizedBox(height: 10), pw.Text(r.source, style: const pw.TextStyle(fontSize: 8.5, color: _soft))],
  ];
}

Future<Uint8List> buildRecipesPdf(List<Recipe> recipes, {required int? servings, required UnitSystem units, required String lang, required PdfStrings strings, ByteData? regular, ByteData? bold, ByteData? serif, bool cover = false}) async {
  final doc = pw.Document(theme: _theme(regular, bold, serif), title: recipes.length == 1 ? recipes.first.title : strings.bookTitle, author: 'Kochmappe');
  final sf = serif == null ? null : pw.Font.ttf(serif);
  if (cover) {
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.SizedBox(height: 120),
        pw.Text(strings.bookTitle, style: pw.TextStyle(font: sf, fontSize: 44, color: _ink)),
        pw.Container(margin: const pw.EdgeInsets.symmetric(vertical: 14), height: 4, width: 90, color: _saffron),
        pw.Text(strings.contents, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _ink)),
        pw.SizedBox(height: 8),
        for (final r in recipes) pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 2), child: pw.Text(r.title, style: const pw.TextStyle(fontSize: 12, color: _ink))),
      ]),
    ));
  }
  for (final r in recipes) {
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(42),
      build: (_) => _recipePage(r, servings ?? r.servings, units, lang, strings, sf),
    ));
  }
  return doc.save();
}

PdfStrings pdfStrings(L l) => PdfStrings(ingredients: l.ingredients, steps: l.steps, servings: l.servingsLabel, myTwist: l.myTwist, contents: l.pdfContents, bookTitle: l.pdfBookTitle);

Future<void> shareRecipePdf(BuildContext context, Services s, Recipe r, int servings) async {
  final l = L.of(context);
  final lang = Localizations.localeOf(context).languageCode;
  final bytes = await buildRecipesPdf([r], servings: servings, units: s.library.settings.units, lang: lang, strings: pdfStrings(l), regular: await s.fonts('assets/fonts/Figtree-400.ttf'), bold: await s.fonts('assets/fonts/Figtree-700.ttf'), serif: await s.fonts('assets/fonts/YoungSerif-Regular.ttf'));
  await s.sharer.shareFile(bytes, name: '${_fileName(r.title)}.pdf', mime: 'application/pdf');
}

Future<void> shareCookbookPdf(BuildContext context, Services s) async {
  final l = L.of(context);
  final lang = Localizations.localeOf(context).languageCode;
  final list = [...s.library.recipes]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  final bytes = await buildRecipesPdf(list, servings: null, units: s.library.settings.units, lang: lang, strings: pdfStrings(l), cover: true, regular: await s.fonts('assets/fonts/Figtree-400.ttf'), bold: await s.fonts('assets/fonts/Figtree-700.ttf'), serif: await s.fonts('assets/fonts/YoungSerif-Regular.ttf'));
  await s.sharer.shareFile(bytes, name: 'kochmappe-${l.pdfFileWord}.pdf', mime: 'application/pdf');
}

String _fileName(String t) {
  final c = t.toLowerCase().replaceAll(RegExp(r'[^a-z0-9äöüß]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  return c.isEmpty ? 'rezept' : c;
}
