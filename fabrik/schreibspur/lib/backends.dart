import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Seam over the file picker and the clipboard, so tests never touch the OS.
abstract class ChatSource {
  /// Bytes of the file the user picked, or null if cancelled.
  Future<Uint8List?> pickFile();

  /// Text on the clipboard, or null if empty.
  Future<String?> paste();
}

class DeviceChatSource implements ChatSource {
  @override
  Future<Uint8List?> pickFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    return r?.files.firstOrNull?.bytes;
  }

  @override
  Future<String?> paste() async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    final t = d?.text;
    return (t == null || t.trim().isEmpty) ? null : t;
  }
}

/// Seam over the share sheet.
abstract class ShareBackend {
  Future<void> shareImage(Uint8List png, {required String text, Rect? origin});
}

class DeviceShareBackend implements ShareBackend {
  @override
  Future<void> shareImage(Uint8List png, {required String text, Rect? origin}) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(png, mimeType: 'image/png', name: 'schreibspur.png')],
      fileNameOverrides: const ['schreibspur.png'],
      text: text,
      sharePositionOrigin: origin,
    ));
  }
}

/// Chat exports handed to the app from the share sheet (WhatsApp → Export chat → Schreibspur).
abstract class IncomingChats {
  /// Emits the bytes of every file that arrives, including one that launched the app.
  Stream<Uint8List> get files;
}

class DeviceIncomingChats implements IncomingChats {
  DeviceIncomingChats([MethodChannel? channel]) : _ch = channel ?? const MethodChannel('schreibspur/files') {
    _ch.setMethodCallHandler((call) async {
      if (call.method == 'open' && call.arguments is Uint8List) _out.add(call.arguments as Uint8List);
    });
    _ch.invokeMethod<Uint8List>('initialFile').then((b) {
      if (b != null) _out.add(b);
    }, onError: (_) {});
  }

  final MethodChannel _ch;
  final _out = StreamController<Uint8List>.broadcast();

  @override
  Stream<Uint8List> get files => _out.stream;
}
