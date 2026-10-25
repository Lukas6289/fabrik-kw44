import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:schreibspur/backends.dart';
import 'package:schreibspur/pro.dart';

class FakeProBackend implements ProBackend {
  List<String> owned = [];
  PurchaseResult next = PurchaseResult.purchased;
  bool storeDown = false;

  @override
  Future<Map<String, String>> prices(List<String> ids) async {
    if (storeDown) throw Exception('no store');
    return {proYearlyId: '4,99 €', proLifetimeId: '12,99 €'};
  }

  @override
  Future<PurchaseResult> purchase(String id) async {
    if (next == PurchaseResult.purchased) owned = [...owned, id];
    return next;
  }

  @override
  Future<List<String>> entitlements() async => owned;

  @override
  Future<List<String>> restore() async => owned;
}

class FakeSource implements ChatSource {
  FakeSource({this.file, this.clipboard});
  Uint8List? file;
  String? clipboard;

  @override
  Future<Uint8List?> pickFile() async => file;

  @override
  Future<String?> paste() async => clipboard;
}

class FakeSharer implements ShareBackend {
  final shared = <Uint8List>[];
  final texts = <String>[];
  bool fail = false;

  @override
  Future<void> shareImage(Uint8List png, {required String text, Rect? origin}) async {
    if (fail) throw Exception('no share sheet');
    shared.add(png);
    texts.add(text);
  }
}

class FakeIncoming implements IncomingChats {
  final controller = StreamController<Uint8List>.broadcast();

  @override
  Stream<Uint8List> get files => controller.stream;
}
