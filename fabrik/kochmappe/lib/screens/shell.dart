import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import 'fridge_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'shopping_screen.dart';

/// Four tabs: binder, "what do I have", shopping, more. A dark ink bar with a saffron ribbon;
/// on a tablet the bar moves to the left.
class Shell extends StatefulWidget {
  const Shell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late int _tab = widget.initialTab;

  void _go(int i) {
    tick();
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final p = Pal.of(context);
    final wide = isWide(context);
    final items = [
      (Icons.auto_stories_rounded, l.tabBinder),
      (Icons.kitchen_rounded, l.tabFridge),
      (Icons.shopping_basket_rounded, l.tabShopping),
      (Icons.tune_rounded, l.tabMore),
    ];
    final pages = IndexedStack(index: _tab, children: const [HomeScreen(), FridgeScreen(), ShoppingScreen(), MoreScreen()]);

    Widget item(int i, {required bool vertical}) {
      final sel = _tab == i;
      final fg = sel ? p.accent : const Color(0xFFB8C0D4);
      return Expanded(
        flex: vertical ? 0 : 1,
        child: Semantics(
          button: true,
          selected: sel,
          label: items[i].$2,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _go(i),
            child: SizedBox(
              height: vertical ? 76 : null,
              width: vertical ? 88 : null,
              child: Stack(alignment: Alignment.center, children: [
                Positioned(
                  top: vertical ? 14 : 0,
                  bottom: vertical ? 14 : null,
                  left: vertical ? 0 : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: vertical ? 4 : (sel ? 34 : 0),
                    height: vertical ? (sel ? 48 : 0) : 4,
                    decoration: BoxDecoration(color: p.accent, borderRadius: vertical ? const BorderRadius.horizontal(right: Radius.circular(4)) : const BorderRadius.vertical(bottom: Radius.circular(4))),
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(items[i].$1, size: 25, color: fg),
                  const SizedBox(height: 3),
                  Text(items[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: body(11.5, fg, weight: FontWeight.w700, height: 1.1)),
                ]),
              ]),
            ),
          ),
        ),
      );
    }

    if (wide) {
      return Scaffold(
        body: Row(children: [
          Container(
            width: 88,
            color: p.bar,
            child: SafeArea(
              right: false,
              child: Column(children: [
                const SizedBox(height: 18),
                for (var i = 0; i < items.length; i++) item(i, vertical: true),
              ]),
            ),
          ),
          Expanded(child: pages),
        ]),
      );
    }
    return Scaffold(
      body: pages,
      bottomNavigationBar: Container(
        color: p.bar,
        child: SafeArea(
          top: false,
          child: SizedBox(height: 62, child: Row(children: [for (var i = 0; i < items.length; i++) item(i, vertical: false)])),
        ),
      ),
    );
  }
}
