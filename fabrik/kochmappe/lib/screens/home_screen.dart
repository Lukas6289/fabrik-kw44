import 'package:flutter/material.dart';

import '../design.dart';
import '../l10n/app_localizations.dart';
import '../library.dart';
import '../models.dart';
import '../services.dart';
import 'add_sheet.dart';
import 'folder_sheet.dart';
import 'pro_screen.dart';
import 'recipe_screen.dart';
import 'widgets.dart';

/// "Meine Mappe": search, index tabs for the folders, today's idea, the recipe cards.
/// On a tablet the chosen recipe opens in a second column instead of a new page.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  String _query = '';

  /// null = all, '_fav' = favourites, else a folder id
  String? _tab;
  String? _selected;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// A daily pick: the recipe that was cooked longest ago (or never), changing with the day.
  Recipe? _idea(Library lib) {
    if (lib.recipes.isEmpty) return null;
    final sorted = [...lib.recipes]..sort((a, b) {
        final x = a.lastCooked ?? DateTime(2000), y = b.lastCooked ?? DateTime(2000);
        return x.compareTo(y);
      });
    final top = sorted.take(3).toList();
    return top[lib.now.day % top.length];
  }

  void _open(Recipe r) {
    tick();
    if (isWide(context)) {
      setState(() => _selected = r.id);
    } else {
      Navigator.of(context).push(softRoute(RecipeScreen(recipeId: r.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ServicesScope.of(context);
    final lib = s.library;
    final l = L.of(context);
    final p = Pal.of(context);
    final wide = isWide(context);
    return ListenableBuilder(
      listenable: lib,
      builder: (context, _) {
        final folder = lib.folders.where((f) => f.id == _tab).firstOrNull;
        if (_tab != null && _tab != '_fav' && folder == null) _tab = null;
        final list = lib.search(_query, folderId: folder?.id, favorites: _tab == '_fav');
        final idea = (_query.isEmpty && _tab == null) ? _idea(lib) : null;
        final sel = lib.byId(_selected ?? '');
        final listPane = Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddSheet(context),
            backgroundColor: p.accent,
            foregroundColor: p.onAccent,
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: Text(l.addRecipe, style: body(16, p.onAccent, weight: FontWeight.w800)),
          ),
          body: SafeArea(
            bottom: false,
            child: lib.recipes.isEmpty
                ? EmptyState(
                    motif: 0,
                    title: l.emptyBinderTitle,
                    text: l.emptyBinderText,
                    action: FilledButton.icon(onPressed: () => showAddSheet(context), icon: const Icon(Icons.add_rounded), label: Text(l.addRecipe)),
                  )
                : CustomScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l.binderTitle, style: disp(36, p.ink)),
                            const SizedBox(height: 4),
                            Row(children: [
                              CountText(lib.recipes.length, style: body(15, p.accentText, weight: FontWeight.w800)),
                              const SizedBox(width: 5),
                              Text(l.recipesWord(lib.recipes.length), style: body(15, p.soft, weight: FontWeight.w600)),
                            ]),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _search,
                              onChanged: (v) => setState(() => _query = v),
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: l.searchHint,
                                prefixIcon: Icon(Icons.search_rounded, color: p.soft),
                                suffixIcon: _query.isEmpty
                                    ? null
                                    : IconButton(
                                        tooltip: l.clear,
                                        icon: const Icon(Icons.close_rounded),
                                        onPressed: () => setState(() {
                                          _search.clear();
                                          _query = '';
                                        }),
                                      ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: SizedBox(
                            height: 48,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                RegisterTab(label: l.tabAll, selected: _tab == null, color: p.accent, onTap: () => setState(() => _tab = null)),
                                RegisterTab(label: l.tabFavorites, icon: Icons.favorite_rounded, selected: _tab == '_fav', color: const Color(0xFFE9798E), onTap: () => setState(() => _tab = '_fav')),
                                for (final f in lib.folders)
                                  RegisterTab(label: f.name, selected: _tab == f.id, color: Pal.hues[f.hue % Pal.hues.length], onTap: () => setState(() => _tab = f.id)),
                                RegisterTab(
                                  label: l.newFolder,
                                  icon: Icons.add_rounded,
                                  selected: false,
                                  color: p.line,
                                  onTap: () => lib.canAddFolder ? editFolder(context) : Navigator.of(context).push(softRoute(const ProScreen())),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 20), color: folder == null ? (_tab == '_fav' ? const Color(0xFFE9798E) : p.accent) : Pal.hues[folder.hue % Pal.hues.length])),
                      if (folder != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 6, 12, 0),
                            child: Row(children: [
                              Expanded(child: Text(l.inFolder(lib.countIn(folder)), style: body(14, p.soft, weight: FontWeight.w600))),
                              TextButton(onPressed: () => editFolder(context, folder: folder), child: Text(l.editFolder)),
                            ]),
                          ),
                        ),
                      if (idea != null)
                        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), child: _IdeaCard(recipe: idea, onTap: () => _open(idea)))),
                      if (list.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(
                            motif: 4,
                            title: _query.isNotEmpty ? l.noHitsTitle : (_tab == '_fav' ? l.noFavTitle : l.emptyFolderTitle),
                            text: _query.isNotEmpty ? l.noHitsText : (_tab == '_fav' ? l.noFavText : l.emptyFolderText),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                          sliver: SliverLayoutBuilder(
                            builder: (context, c) {
                              final w = c.crossAxisExtent;
                              final cols = w >= 760 ? 3 : (w >= 540 ? 3 : 2);
                              return SliverGrid.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: wide ? 2 : cols,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  mainAxisExtent: (w - 14 * ((wide ? 2 : cols) - 1)) / (wide ? 2 : cols) / 1.35 + 98 * MediaQuery.textScalerOf(context).scale(1),
                                ),
                                itemCount: list.length,
                                itemBuilder: (_, i) => RecipeCard(recipe: list[i], selected: wide && list[i].id == _selected, onTap: () => _open(list[i])),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
          ),
        );
        if (!wide) return listPane;
        return Row(children: [
          SizedBox(width: 470, child: listPane),
          VerticalDivider(width: 1, color: p.line),
          Expanded(
            child: sel == null
                ? ColoredBox(color: p.bg, child: EmptyState(motif: 6, title: l.pickRecipeTitle, text: l.pickRecipeText))
                : RecipeScreen(key: ValueKey(sel.id), recipeId: sel.id, embedded: true, onGone: () => setState(() => _selected = null)),
          ),
        ]);
      },
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.recipe, required this.onTap});
  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final l = L.of(context);
    final lib = ServicesScope.of(context).library;
    final last = recipe.lastCooked;
    final days = last == null ? null : lib.now.difference(last).inDays;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: p.dark ? const [Color(0xFF1F2D4A), Color(0xFF17223A)] : const [Color(0xFF14213D), Color(0xFF263A66)]),
        boxShadow: [BoxShadow(color: const Color(0xFF14213D).withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(children: [
            SizedBox(width: 104, height: 112, child: RecipeCover(recipe)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.ideaToday.toUpperCase(), style: body(11.5, p.accent, weight: FontWeight.w800, height: 1.1).copyWith(letterSpacing: 1.2)),
                  const SizedBox(height: 5),
                  Text(recipe.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: disp(19, const Color(0xFFF4EEDF), height: 1.15)),
                  const SizedBox(height: 5),
                  Text(days == null ? l.neverCooked : l.lastCooked(days), maxLines: 1, overflow: TextOverflow.ellipsis, style: body(13, const Color(0xFFB8C0D4), weight: FontWeight.w600)),
                ]),
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFF2A516))),
          ]),
        ),
      ),
    );
  }
}
