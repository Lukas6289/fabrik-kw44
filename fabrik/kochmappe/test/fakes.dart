import 'dart:io';
import 'dart:math';

import 'package:kochmappe/importer.dart';
import 'package:kochmappe/library.dart';
import 'package:kochmappe/pro.dart';
import 'package:kochmappe/services.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeProBackend implements ProBackend {
  List<String> owned = [];
  PurchaseResult next = PurchaseResult.purchased;
  bool storeDown = false;

  @override
  Future<Map<String, String>> prices(List<String> ids) async {
    if (storeDown) throw Exception('no store');
    return {proLifetimeId: '6,99 €'};
  }

  @override
  Future<PurchaseResult> purchase(String id) async {
    if (next == PurchaseResult.purchased) owned = [...owned, id];
    return next;
  }

  @override
  Future<List<String>> entitlements() async {
    if (storeDown) throw Exception('no store');
    return owned;
  }

  @override
  Future<List<String>> restore() async => owned;
}

class FakeSharer implements ShareBackend {
  final texts = <String>[];
  final files = <String, Uint8List>{};

  @override
  Future<void> shareText(String text, {Rect? origin}) async => texts.add(text);

  @override
  Future<void> shareFile(Uint8List bytes, {required String name, required String mime, Rect? origin}) async {
    files[name] = bytes;
  }
}

class FakeLinks implements LinkBackend {
  final opened = <String>[];
  @override
  Future<void> open(String url) async => opened.add(url);
}

class FakeAwake implements AwakeBackend {
  final calls = <bool>[];
  @override
  Future<void> keepAwake(bool on) async => calls.add(on);
}

class FakePicker implements PhotoPicker {
  Uint8List? next;
  @override
  Future<Uint8List?> pick({required bool camera}) async => next;
}

class FakeFiles implements TextFilePicker {
  String? next;
  @override
  Future<String?> pickText() async => next;
}

/// Web pages by address; anything else is "offline".
class FakeWeb implements WebBackend {
  final pages = <String, String>{};
  final images = <String, Uint8List>{};
  final asked = <String>[];

  @override
  Future<String> page(Uri url) async {
    asked.add(url.toString());
    final p = pages[url.toString()];
    if (p == null) throw Exception('offline');
    return p;
  }

  @override
  Future<Uint8List> bytes(Uri url) async {
    final b = images[url.toString()];
    if (b == null) throw Exception('no image');
    return b;
  }
}

/// A whole app without a network, a store or a phone: fakes for every seam.
class Rig {
  Rig._(this.prefs, this.services, this.backend, this.sharer, this.links, this.web, this.awake, this.picker, this.files);
  final SharedPreferences prefs;
  final Services services;
  final FakeProBackend backend;
  final FakeSharer sharer;
  final FakeLinks links;
  final FakeWeb web;
  final FakeAwake awake;
  final FakePicker picker;
  final FakeFiles files;

  Library get lib => services.library;
  Pro get pro => services.pro;

  static final today = DateTime(2026, 10, 25, 18);

  static Future<Rig> create({Map<String, Object> prefs = const {}, bool pro = false, int seed = 7, DateTime? now}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final p = await SharedPreferences.getInstance();
    final backend = FakeProBackend();
    if (pro) backend.owned = [proLifetimeId];
    final proObj = Pro(p, backend);
    await proObj.start();
    final sharer = FakeSharer();
    final links = FakeLinks();
    final web = FakeWeb();
    final awake = FakeAwake();
    final picker = FakePicker();
    final files = FakeFiles();
    final services = Services(
      library: Library(p, proObj, clock: () => now ?? today, random: Random(seed)),
      pro: proObj,
      sharer: sharer,
      links: links,
      fonts: (asset) async => ByteData.sublistView(File(asset).readAsBytesSync()),
      web: web,
      awake: awake,
      picker: picker,
      files: files,
    );
    return Rig._(p, services, backend, sharer, links, web, awake, picker, files);
  }
}
