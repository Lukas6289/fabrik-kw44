import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'importer.dart';
import 'library.dart';
import 'pro.dart';

/// Share sheet for text and files (the recipe, the shopping list, the PDF, the backup).
abstract class ShareBackend {
  Future<void> shareText(String text, {Rect? origin});
  Future<void> shareFile(Uint8List bytes, {required String name, required String mime, Rect? origin});
}

class DeviceShareBackend implements ShareBackend {
  @override
  Future<void> shareText(String text, {Rect? origin}) async {
    await SharePlus.instance.share(ShareParams(text: text, sharePositionOrigin: origin));
  }

  @override
  Future<void> shareFile(Uint8List bytes, {required String name, required String mime, Rect? origin}) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, mimeType: mime, name: name)],
      fileNameOverrides: [name],
      sharePositionOrigin: origin,
    ));
  }
}

abstract class LinkBackend {
  Future<void> open(String url);
}

class DeviceLinkBackend implements LinkBackend {
  @override
  Future<void> open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

/// Keeps the screen awake while cooking (UIApplication.isIdleTimerDisabled, see AppDelegate.swift).
abstract class AwakeBackend {
  Future<void> keepAwake(bool on);
}

class DeviceAwakeBackend implements AwakeBackend {
  static const _ch = MethodChannel('kochmappe/apple');
  @override
  Future<void> keepAwake(bool on) async {
    try {
      await _ch.invokeMethod<void>('keepAwake', {'on': on});
    } catch (_) {}
  }
}

/// Picks a photo from the library or the camera. Returns JPEG bytes, or null when cancelled.
abstract class PhotoPicker {
  Future<Uint8List?> pick({required bool camera});
}

class DevicePhotoPicker implements PhotoPicker {
  @override
  Future<Uint8List?> pick({required bool camera}) async {
    final f = await ImagePicker().pickImage(source: camera ? ImageSource.camera : ImageSource.gallery, maxWidth: 1600, imageQuality: 82);
    return f?.readAsBytes();
  }
}

/// Lets the user choose a backup file; returns its text.
abstract class TextFilePicker {
  Future<String?> pickText();
}

class DeviceFilePicker implements TextFilePicker {
  @override
  Future<String?> pickText() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    final b = r?.files.single.bytes;
    return b == null ? null : utf8.decode(b, allowMalformed: true);
  }
}

/// Photos in a folder inside the app's documents.
class DevicePhotoStore implements PhotoStore {
  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/photos');
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  @override
  Future<String> save(Uint8List bytes) async {
    final name = 'p${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File('${(await _dir()).path}/$name').writeAsBytes(bytes);
    return name;
  }

  @override
  Future<Uint8List?> load(String name) async {
    final f = File('${(await _dir()).path}/$name');
    return f.existsSync() ? f.readAsBytes() : null;
  }

  @override
  Future<void> delete(String name) async {
    final f = File('${(await _dir()).path}/$name');
    if (f.existsSync()) await f.delete();
  }
}

/// Reads the bytes of an asset font for the PDF; tests give it their own.
typedef FontLoaderFn = Future<ByteData?> Function(String asset);

/// Everything the screens need, in one place. Tests put fakes in here.
class Services {
  const Services({
    required this.library,
    required this.pro,
    required this.sharer,
    required this.links,
    required this.fonts,
    required this.web,
    required this.awake,
    required this.picker,
    required this.files,
  });
  final Library library;
  final Pro pro;
  final ShareBackend sharer;
  final LinkBackend links;
  final FontLoaderFn fonts;
  final WebBackend web;
  final AwakeBackend awake;
  final PhotoPicker picker;
  final TextFilePicker files;

  Importer get importer => Importer(library, web);
}

class ServicesScope extends InheritedWidget {
  const ServicesScope({super.key, required this.services, required super.child});
  final Services services;

  static Services of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ServicesScope>()!.services;

  /// For initState, where subscribing to changes is not allowed.
  static Services read(BuildContext context) => context.getInheritedWidgetOfExactType<ServicesScope>()!.services;

  @override
  bool updateShouldNotify(ServicesScope old) => old.services != services;
}
