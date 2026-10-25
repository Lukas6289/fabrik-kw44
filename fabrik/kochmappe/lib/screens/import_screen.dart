import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design.dart';
import '../importer.dart';
import '../l10n/app_localizations.dart';
import '../services.dart';
import 'edit_screen.dart';

enum ImportMode { link, text }

/// Save a recipe from a web link (read on the device) or from pasted text.
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key, required this.mode});
  final ImportMode mode;

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  late ImportMode _mode = widget.mode;
  final _link = TextEditingController();
  final _text = TextEditingController();
  bool _busy = false;
  ImportError? _error;

  @override
  void dispose() {
    _link.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    final t = d?.text ?? '';
    if (t.trim().isEmpty) return;
    setState(() {
      if (_mode == ImportMode.link) {
        _link.text = t.trim();
      } else {
        _text.text = t;
      }
      _error = null;
    });
  }

  Future<void> _go() async {
    final s = ServicesScope.read(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final out = _mode == ImportMode.link ? await s.importer.fromLink(_link.text) : s.importer.fromText(_text.text);
    if (!mounted) return;
    if (out.recipe == null) {
      setState(() {
        _busy = false;
        _error = out.error;
      });
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _busy = false);
    final id = await Navigator.of(context).push<String>(softRoute(EditScreen(draft: out.recipe, imageUrl: out.imageUrl)));
    if (id != null && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final p = Pal.of(context);
    final link = _mode == ImportMode.link;
    return Scaffold(
      appBar: AppBar(title: Text(link ? l.addFromLink : l.addFromText)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 30), children: [
              SegmentedButton<ImportMode>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  minimumSize: const Size(44, 46),
                  selectedBackgroundColor: p.accent,
                  selectedForegroundColor: p.onAccent,
                  foregroundColor: p.ink,
                  textStyle: body(15, p.ink, weight: FontWeight.w800),
                  side: BorderSide(color: p.line),
                ),
                segments: [
                  ButtonSegment(value: ImportMode.link, icon: const Icon(Icons.link_rounded), label: Text(l.modeLink)),
                  ButtonSegment(value: ImportMode.text, icon: const Icon(Icons.content_paste_rounded), label: Text(l.modeText)),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() {
                  _mode = v.first;
                  _error = null;
                }),
              ),
              const SizedBox(height: 18),
              Text(link ? l.linkExplain : l.textExplain, style: body(16, p.soft, height: 1.45)),
              const SizedBox(height: 14),
              if (link)
                TextField(
                  controller: _link,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _go(),
                  decoration: InputDecoration(hintText: l.linkHint, prefixIcon: Icon(Icons.link_rounded, color: p.soft)),
                )
              else
                TextField(controller: _text, minLines: 8, maxLines: 14, keyboardType: TextInputType.multiline, decoration: InputDecoration(hintText: l.textHint)),
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: _paste, icon: const Icon(Icons.content_paste_go_rounded), label: Text(l.pasteFromClipboard))),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFD9352F).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFD9352F)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(switch (_error!) {
                        ImportError.badLink => l.errBadLink,
                        ImportError.network => l.errNetwork,
                        ImportError.noRecipe => link ? l.errNoRecipe : l.errNoRecipeText,
                      }, style: body(15, p.ink, weight: FontWeight.w700))),
                    ]),
                    if (link && _error != ImportError.badLink) ...[
                      const SizedBox(height: 6),
                      Text(l.errTryText, style: body(14, p.soft, height: 1.4)),
                      TextButton(onPressed: () => setState(() { _mode = ImportMode.text; _error = null; }), child: Text(l.switchToText)),
                    ],
                  ]),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _busy ? null : _go,
                icon: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)) : Icon(link ? Icons.download_rounded : Icons.auto_fix_high_rounded),
                label: Text(_busy ? l.reading : (link ? l.fetchRecipe : l.recognize)),
              ),
              const SizedBox(height: 18),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: p.soft),
                const SizedBox(width: 8),
                Expanded(child: Text(l.importPrivacy, style: body(13.5, p.soft, height: 1.4))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
