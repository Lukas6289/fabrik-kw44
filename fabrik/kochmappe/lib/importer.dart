import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'library.dart';
import 'models.dart';
import 'parse.dart';

/// Fetches a page the user typed in. Direct from the device – no service in between.
abstract class WebBackend {
  Future<String> page(Uri url);
  Future<Uint8List> bytes(Uri url);
}

class DeviceWebBackend implements WebBackend {
  static const _headers = {
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    'Accept-Language': 'de,en;q=0.8',
  };

  @override
  Future<String> page(Uri url) async {
    final r = await http.get(url, headers: _headers).timeout(const Duration(seconds: 20));
    if (r.statusCode >= 400) throw http.ClientException('HTTP ${r.statusCode}', url);
    return utf8.decode(r.bodyBytes, allowMalformed: true);
  }

  @override
  Future<Uint8List> bytes(Uri url) async {
    final r = await http.get(url, headers: _headers).timeout(const Duration(seconds: 20));
    if (r.statusCode >= 400) throw http.ClientException('HTTP ${r.statusCode}', url);
    return r.bodyBytes;
  }
}

enum ImportError { badLink, network, noRecipe }

class ImportOutcome {
  const ImportOutcome.ok(this.recipe, {this.imageUrl = ''}) : error = null, pageTitle = '';
  const ImportOutcome.fail(this.error, {this.pageTitle = ''})
      : recipe = null,
        imageUrl = '';
  final Recipe? recipe;
  final String imageUrl;
  final ImportError? error;

  /// For a "no recipe found" page: its title, so the user can still paste the text.
  final String pageTitle;
}

class Importer {
  Importer(this.lib, this.web);
  final Library lib;
  final WebBackend web;

  /// Turns whatever the user pasted into a link: "https://…", "www…" or text containing a link.
  static Uri? linkFrom(String input) {
    final m = RegExp(r'(https?://[^\s<>"]+|www\.[^\s<>"]+)', caseSensitive: false).firstMatch(input.trim());
    if (m == null) return null;
    var s = m[0]!.replaceAll(RegExp(r'[.,;)]+$'), '');
    if (!s.startsWith('http')) s = 'https://$s';
    final u = Uri.tryParse(s);
    return (u == null || u.host.isEmpty || !u.host.contains('.')) ? null : u;
  }

  Future<ImportOutcome> fromLink(String input) async {
    final url = linkFrom(input);
    if (url == null) return const ImportOutcome.fail(ImportError.badLink);
    String html;
    try {
      html = await web.page(url);
    } catch (_) {
      return const ImportOutcome.fail(ImportError.network);
    }
    final p = recipeFromHtml(html);
    if (p == null) return ImportOutcome.fail(ImportError.noRecipe, pageTitle: titleFromHtml(html));
    final r = lib.fromParsed(p, source: url.toString());
    return ImportOutcome.ok(r, imageUrl: p.imageUrl.isEmpty ? '' : url.resolve(p.imageUrl).toString());
  }

  /// Downloads the photo of an imported recipe to the device (best effort).
  Future<void> attachPhoto(Recipe r, String imageUrl) async {
    if (imageUrl.isEmpty) return;
    try {
      final b = await web.bytes(Uri.parse(imageUrl));
      if (b.length < 500 || b.length > 6 * 1024 * 1024) return;
      r.photo = await lib.photos.save(b);
      lib.update(r);
    } catch (_) {}
  }

  ImportOutcome fromText(String text) {
    final p = parseRecipeText(text);
    if (!p.usable) return const ImportOutcome.fail(ImportError.noRecipe);
    return ImportOutcome.ok(lib.fromParsed(p));
  }
}
