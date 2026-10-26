import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services.dart';
import 'pro_screen.dart';

/// The inlay card for the case: hand-lettered, with both sides' songs and times. Share it as a picture
/// (small stamp for free users) or, with Pro, without stamp and as a printable PDF.
class JCardScreen extends StatefulWidget {
  const JCardScreen({super.key, required this.tape});
  final Tape tape;

  @override
  State<JCardScreen> createState() => _JCardScreenState();
}

class _JCardScreenState extends State<JCardScreen> {
  final _key = GlobalKey();
  bool _busy = false;

  Future<Uint8List?> _png() async {
    final b = _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (b == null) return null;
    final img = await b.toImage(pixelRatio: 3);
    final d = await img.toByteData(format: ui.ImageByteFormat.png);
    return d?.buffer.asUint8List();
  }

  Future<void> _sharePng() async {
    final s = ServicesScope.read(context);
    setState(() => _busy = true);
    try {
      final bytes = await _png();
      if (bytes != null) {
        await s.sharer.shareFile(
          bytes,
          name: '${_safe(widget.tape.name)}.png',
          mime: 'image/png',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sharePdf() async {
    final s = ServicesScope.read(context);
    if (!s.pro.isPro) {
      await Navigator.of(context)
          .push(softRoute(const ProScreen(reason: ProReason.pdf)));
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = await _png();
      if (bytes == null) return;
      final doc = pw.Document();
      final image = pw.MemoryImage(bytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (c) => pw.Align(
            alignment: pw.Alignment.topCenter,
            child: pw.Image(image, width: 330, fit: pw.BoxFit.contain),
          ),
        ),
      );
      await s.sharer.shareFile(
        await doc.save(),
        name: '${_safe(widget.tape.name)}.pdf',
        mime: 'application/pdf',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _safe(String n) => n.replaceAll(RegExp(r'[^\w\- ]'), '').trim().isEmpty
      ? 'Bandsalat'
      : n.replaceAll(RegExp(r'[^\w\- ]'), '').trim();

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final l = L.of(context);
    final p = Pal.of(context);
    return ListenableBuilder(
      listenable: s.pro,
      builder: (context, _) => Scaffold(
        body: PaperBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                Row(
                  children: [
                    Key3(
                      width: 44,
                      height: 40,
                      semantics: l.back,
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: p.ink,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(l.jcardTitle, style: disp(18, p.ink))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l.jcardBody, style: body(15, p.soft)),
                const SizedBox(height: 20),
                Center(
                  child: RepaintBoundary(
                    key: _key,
                    child: JCard(
                      tape: widget.tape,
                      library: s.library,
                      stamp: !s.pro.isPro,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BigButton(
                  label: l.shareImage,
                  icon: Icons.ios_share_rounded,
                  onTap: _busy ? null : _sharePng,
                ),
                const SizedBox(height: 14),
                BigButton(
                  label: s.pro.isPro ? l.sharePdf : l.sharePdfPro,
                  icon: s.pro.isPro
                      ? Icons.picture_as_pdf_rounded
                      : Icons.lock_rounded,
                  color: Pal.mustard,
                  textColor: Pal.navy,
                  onTap: _busy ? null : _sharePdf,
                ),
                if (!s.pro.isPro)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      l.stampNote,
                      textAlign: TextAlign.center,
                      style: body(13, p.soft),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The card itself. Always light (it is a picture), independent of dark mode.
class JCard extends StatelessWidget {
  const JCard({
    super.key,
    required this.tape,
    required this.library,
    this.stamp = false,
  });
  final Tape tape;
  final dynamic library;
  final bool stamp;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final sh = shells[tape.shell];
    final lib = library;
    const ink = Pal.navy;
    Widget column(Side side) {
      final ids = tape.side(side);
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sh.body,
                    shape: BoxShape.circle,
                    border: Border.all(color: ink, width: 2),
                  ),
                  child: Text(
                    side.letter,
                    style: disp(
                      13,
                      side == Side.a && tape.shell == 5 ? ink : ink,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  clock(lib.sideMs(tape, side) as int),
                  style: body(
                    13,
                    ink.withValues(alpha: 0.7),
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (ids.isEmpty)
              Text('–', style: body(14, ink.withValues(alpha: 0.5))),
            for (var i = 0; i < ids.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${i + 1}',
                        style: body(
                          12,
                          ink.withValues(alpha: 0.55),
                          weight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        lib.song(ids[i])?.title ?? '',
                        style: written(17, ink),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: sh.paper,
        border: Border.all(color: ink, width: 2.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 96,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _Band(tape.label, tape.shell)),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: sh.paper,
                      border: Border.all(color: ink, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tape.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: written(34, ink),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 2, color: ink),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            child: Column(
              children: [
                if (tape.dedication.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Transform.rotate(
                        angle: -0.025,
                        child: Text(
                          tape.dedication,
                          style: written(
                            24,
                            sh.body == const Color(0xFFEFE8D6)
                                ? ink
                                : Color.lerp(sh.body, ink, 0.35)!,
                          ),
                        ),
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    column(Side.a),
                    const SizedBox(width: 16),
                    column(Side.b),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 2, color: ink),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: Row(
              children: [
                Text('C${tape.minutes}', style: disp(12, ink)),
                const Spacer(),
                if (stamp)
                  Transform.rotate(
                    angle: -0.05,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Pal.tomato, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l.stampText,
                        style: body(11, Pal.tomato, weight: FontWeight.w700),
                      ),
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

class _Band extends CustomPainter {
  _Band(this.style, this.shell);
  final int style;
  final int shell;
  @override
  void paint(Canvas canvas, Size size) => paintLabelPattern(
    canvas,
    Offset.zero & size,
    style,
    shells[shell],
    size.width * 0.9,
  );
  @override
  bool shouldRepaint(_Band o) => o.style != style || o.shell != shell;
}
