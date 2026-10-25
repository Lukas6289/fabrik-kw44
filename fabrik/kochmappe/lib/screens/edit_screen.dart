import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../parse.dart';
import '../scale.dart';
import '../services.dart';
import 'pro_screen.dart';
import 'widgets.dart';

/// Write or correct a recipe. Ingredients and steps are typed one per line and read on save.
/// For a freshly imported recipe ([draft]) it is the "check and save" page.
class EditScreen extends StatefulWidget {
  const EditScreen({super.key, this.recipeId, this.draft, this.imageUrl = ''});
  final String? recipeId;
  final Recipe? draft;
  final String imageUrl;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late Recipe _r;
  late bool _isNew;
  bool _ready = false;
  late final TextEditingController _title, _ings, _steps, _tags, _notes, _prep, _cook;
  late int _servings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    final s = ServicesScope.read(context);
    final lang = Localizations.localeOf(context).languageCode;
    final existing = widget.recipeId == null ? null : s.library.byId(widget.recipeId!);
    _isNew = existing == null;
    _r = existing?.copy() ?? widget.draft ?? s.library.blank();
    _title = TextEditingController(text: _r.title);
    _ings = TextEditingController(text: _r.ingredients.map((i) => ingSource(i, lang)).join('\n'));
    _steps = TextEditingController(text: _r.steps.join('\n'));
    _tags = TextEditingController(text: _r.tags.join(', '));
    _notes = TextEditingController(text: _r.notes);
    _prep = TextEditingController(text: _r.prepMin == 0 ? '' : '${_r.prepMin}');
    _cook = TextEditingController(text: _r.cookMin == 0 ? '' : '${_r.cookMin}');
    _servings = _r.servings;
  }

  @override
  void dispose() {
    for (final c in [_title, _ings, _steps, _tags, _notes, _prep, _cook]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _photo(bool camera) async {
    final s = ServicesScope.read(context);
    final b = await s.picker.pick(camera: camera);
    if (b == null) return;
    final name = await s.library.photos.save(b);
    if (_r.photo.isNotEmpty && _r.photo != name) await s.library.photos.delete(_r.photo);
    if (mounted) setState(() => _r.photo = name);
  }

  void _save() {
    final s = ServicesScope.read(context);
    final l = L.of(context);
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.needTitle)));
      return;
    }
    _r
      ..title = _title.text.trim()
      ..servings = _servings
      ..prepMin = int.tryParse(_prep.text.trim()) ?? 0
      ..cookMin = int.tryParse(_cook.text.trim()) ?? 0
      ..notes = _notes.text.trim()
      ..tags = [for (final t in _tags.text.split(RegExp(r'[,;]'))) if (t.trim().isNotEmpty) t.trim()]
      ..steps = [for (final t in _steps.text.split('\n')) if (t.trim().isNotEmpty) t.trim()];
    final group = <Ing>[];
    var heading = '';
    for (final raw in _ings.text.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      // "Teig:" on its own line starts a group
      if (line.endsWith(':') && line.length < 40 && parseAmount(line).qty == null) {
        heading = line.substring(0, line.length - 1);
        continue;
      }
      group.add(parseIngredient(line, group: heading));
    }
    _r.ingredients = group;
    if (_isNew) {
      if (!s.library.add(_r)) {
        Navigator.of(context).push(softRoute(const ProScreen(reason: ProReason.recipes)));
        return;
      }
      if (widget.imageUrl.isNotEmpty && _r.photo.isEmpty) s.importer.attachPhoto(_r, widget.imageUrl);
    } else {
      s.library.update(_r);
    }
    bump();
    Navigator.of(context).pop(_r.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final p = Pal.of(context);
    final hasHint = _ings.text.isEmpty && _steps.text.isEmpty;
    Widget label(String t, {String? sub}) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: disp(18, p.ink)),
            if (sub != null) Text(sub, style: body(13, p.soft)),
          ]),
        );
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.newRecipe : l.editRecipe),
        actions: [TextButton(onPressed: _save, child: Text(l.save))],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              children: [
                GestureDetector(
                  onTap: () => _photoSheet(context),
                  child: SizedBox(height: 170, child: Stack(fit: StackFit.expand, children: [
                    RecipeCover(_r, radius: 22),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        constraints: const BoxConstraints(minHeight: 44),
                        decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(14)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.photo_camera_outlined, size: 20, color: p.ink),
                          const SizedBox(width: 6),
                          Text(l.photo, style: body(14, p.ink, weight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ])),
                ),
                label(l.titleLabel),
                TextField(controller: _title, textCapitalization: TextCapitalization.sentences, decoration: InputDecoration(hintText: l.titleHint)),
                label(l.servingsLabel[0].toUpperCase() + l.servingsLabel.substring(1)),
                Wrap(spacing: 10, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    _Stepper(icon: Icons.remove_rounded, label: l.fewer, onTap: _servings > 1 ? () => setState(() => _servings--) : null),
                    SizedBox(width: 52, child: Center(child: Text('$_servings', style: disp(26, p.ink)))),
                    _Stepper(icon: Icons.add_rounded, label: l.more, onTap: _servings < 99 ? () => setState(() => _servings++) : null),
                  ]),
                  SizedBox(width: 118, child: TextField(controller: _prep, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.prepMinLabel))),
                  SizedBox(width: 118, child: TextField(controller: _cook, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.cookMinLabel))),
                ]),
                label(l.ingredients, sub: l.ingredientsEditHint),
                TextField(controller: _ings, minLines: 5, maxLines: 20, keyboardType: TextInputType.multiline, textCapitalization: TextCapitalization.sentences, decoration: InputDecoration(hintText: hasHint ? l.ingredientsExample : null)),
                label(l.steps, sub: l.stepsEditHint),
                TextField(controller: _steps, minLines: 5, maxLines: 30, keyboardType: TextInputType.multiline, textCapitalization: TextCapitalization.sentences),
                label(l.tagsLabel, sub: l.tagsHint),
                TextField(controller: _tags, textCapitalization: TextCapitalization.sentences),
                label(l.notes),
                TextField(controller: _notes, minLines: 2, maxLines: 6, textCapitalization: TextCapitalization.sentences, decoration: InputDecoration(hintText: l.notesHint)),
                const SizedBox(height: 24),
                FilledButton(onPressed: _save, child: Text(l.save)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _photoSheet(BuildContext context) {
    final l = L.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: Text(l.photoFromLibrary), onTap: () { Navigator.pop(ctx); _photo(false); }),
          ListTile(leading: const Icon(Icons.photo_camera_outlined), title: Text(l.photoFromCamera), onTap: () { Navigator.pop(ctx); _photo(true); }),
          if (_r.photo.isNotEmpty)
            ListTile(leading: const Icon(Icons.delete_outline_rounded), title: Text(l.photoRemove), onTap: () { Navigator.pop(ctx); setState(() => _r.photo = ''); }),
        ]),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: p.chip, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: onTap == null ? p.soft.withValues(alpha: 0.4) : p.ink),
        ),
      ),
    );
  }
}
