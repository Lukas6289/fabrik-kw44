import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../scale.dart';
import '../services.dart';
import 'widgets.dart';

/// Shopping list built from recipes; equal items are added up.
class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final lib = s.library;
    final l = L.of(context);
    final p = Pal.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return ListenableBuilder(
      listenable: lib,
      builder: (context, _) {
        final open = [for (final i in lib.shopping) if (!i.done) i];
        final done = [for (final i in lib.shopping) if (i.done) i];
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                  children: [
                    Row(children: [
                      Expanded(child: Text(l.shoppingTitle, style: disp(34, p.ink))),
                      if (open.isNotEmpty)
                        IconButton.filledTonal(
                          tooltip: l.shareText,
                          onPressed: () => s.sharer.shareText(lib.shoppingText(l.shoppingTitle, lang)),
                          icon: const Icon(Icons.ios_share_rounded),
                        ),
                    ]),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _ctl,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (v) {
                        lib.addShopText(v);
                        _ctl.clear();
                      },
                      decoration: InputDecoration(
                        hintText: l.shoppingAddHint,
                        prefixIcon: Icon(Icons.add_rounded, color: p.soft),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (lib.shopping.isEmpty)
                      Padding(padding: const EdgeInsets.only(top: 24), child: EmptyState(motif: 7, title: l.shoppingEmptyTitle, text: l.shoppingEmptyText))
                    else ...[
                      CardBox(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(children: [for (final i in open) _Line(item: i, lang: lang)]),
                      ),
                      if (done.isNotEmpty) ...[
                        SectionTitle(l.shoppingDone, trailing: TextButton(onPressed: lib.clearDone, child: Text(l.removeDone))),
                        CardBox(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: [for (final i in done) _Line(item: i, lang: lang)])),
                      ],
                      const SizedBox(height: 16),
                      Center(child: TextButton(onPressed: lib.clearShopping, child: Text(l.clearList))),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.item, required this.lang});
  final dynamic item;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final lib = ServicesScope.of(context).library;
    return Dismissible(
      key: ObjectKey(item),
      direction: DismissDirection.endToStart,
      background: Container(color: const Color(0xFFD9352F), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete_outline_rounded, color: Colors.white)),
      onDismissed: (_) {
        lib.shopping.remove(item);
        lib.commit();
      },
      child: InkWell(
        onTap: () {
          tick();
          lib.toggleShop(item);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(shape: BoxShape.circle, color: item.done ? p.accent : Colors.transparent, border: Border.all(color: item.done ? p.accent : p.soft.withValues(alpha: 0.6), width: 2)),
                child: item.done ? Icon(Icons.check_rounded, size: 17, color: p.onAccent) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(shopLine(item, lang), style: body(17, item.done ? p.soft : p.ink, weight: FontWeight.w700).copyWith(decoration: item.done ? TextDecoration.lineThrough : null)),
                  if (item.from.isNotEmpty) Text(item.from, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(12.5, p.soft)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
