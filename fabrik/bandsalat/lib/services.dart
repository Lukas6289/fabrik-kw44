import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'deck.dart';
import 'library.dart';
import 'models.dart';
import 'pro.dart';

/// Share sheet for text and files (the recipe, the shopping list, the PDF, the backup).
abstract class ShareBackend {
  Future<void> shareText(String text, {Rect? origin});
  Future<void> shareFile(
    Uint8List bytes, {
    required String name,
    required String mime,
    Rect? origin,
  });
}

class DeviceShareBackend implements ShareBackend {
  @override
  Future<void> shareText(String text, {Rect? origin}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, sharePositionOrigin: origin),
    );
  }

  @override
  Future<void> shareFile(
    Uint8List bytes, {
    required String name,
    required String mime,
    Rect? origin,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: mime, name: name)],
        fileNameOverrides: [name],
        sharePositionOrigin: origin,
      ),
    );
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

/// A file the user picked, still in the picker's temporary place.
class PickedFile {
  const PickedFile(this.path, this.name);
  final String path;
  final String name;
}

abstract class AudioPicker {
  Future<List<PickedFile>> pick();
}

class DeviceAudioPicker implements AudioPicker {
  @override
  Future<List<PickedFile>> pick() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'mp3',
        'm4a',
        'aac',
        'wav',
        'aif',
        'aiff',
        'caf',
        'flac',
        'mp4',
      ],
      allowMultiple: true,
    );
    if (r == null) return const [];
    return [
      for (final f in r.files)
        if (f.path != null) PickedFile(f.path!, f.name),
    ];
  }
}

/// Length and tags of an audio file (AVURLAsset, see AppDelegate.swift). Null when it cannot be played.
class AudioInfo {
  const AudioInfo(this.ms, {this.title = '', this.artist = ''});
  final int ms;
  final String title;
  final String artist;
}

abstract class AudioInfoBackend {
  Future<AudioInfo?> info(String path);
}

class DeviceAudioInfo implements AudioInfoBackend {
  static const _ch = MethodChannel('bandsalat/apple');
  @override
  Future<AudioInfo?> info(String path) async {
    try {
      final r = await _ch.invokeMapMethod<String, Object?>('info', {
        'path': path,
      });
      final ms = (r?['ms'] as num?)?.toInt() ?? 0;
      if (ms <= 0) return null;
      return AudioInfo(
        ms,
        title: r?['title'] as String? ?? '',
        artist: r?['artist'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

/// The app's own copies of the songs (inside Documents, so nothing depends on the picker's temp files).
abstract class SongFiles {
  Future<String> store(String sourcePath, String ext);
  String pathOf(String file);
  Future<void> delete(String file);
  Future<int> bytes();
}

class DeviceSongFiles implements SongFiles {
  DeviceSongFiles(String documents) : _dir = Directory('$documents/songs');
  final Directory _dir;

  @override
  Future<String> store(String sourcePath, String ext) async {
    if (!_dir.existsSync()) _dir.createSync(recursive: true);
    final name = 'f${DateTime.now().microsecondsSinceEpoch}.$ext';
    await File(sourcePath).copy('${_dir.path}/$name');
    return name;
  }

  @override
  String pathOf(String file) => '${_dir.path}/$file';

  @override
  Future<void> delete(String file) async {
    final f = File(pathOf(file));
    if (f.existsSync()) await f.delete();
  }

  @override
  Future<int> bytes() async {
    if (!_dir.existsSync()) return 0;
    var n = 0;
    for (final e in _dir.listSync()) {
      if (e is File) n += e.lengthSync();
    }
    return n;
  }
}

class ImportResult {
  const ImportResult(this.added, this.failed);
  final int added;
  final int failed;
}

/// Picks audio files, keeps a copy in the app, measures them and puts them into the crate.
class SongImporter {
  SongImporter(this.library, this.picker, this.info, this.files);
  final Library library;
  final AudioPicker picker;
  final AudioInfoBackend info;
  final SongFiles files;

  Future<ImportResult> run() async => add(await picker.pick());

  Future<ImportResult> add(List<PickedFile> picked) async {
    var added = 0;
    var failed = 0;
    for (final p in picked) {
      final i = await info.info(p.path);
      if (i == null) {
        failed++;
        continue;
      }
      final dot = p.name.lastIndexOf('.');
      final ext = dot > 0 ? p.name.substring(dot + 1).toLowerCase() : 'm4a';
      try {
        final stored = await files.store(p.path, ext);
        library.addSong(
          title: i.title.trim().isNotEmpty
              ? i.title.trim()
              : titleFromFile(p.name),
          artist: i.artist.trim(),
          file: stored,
          ms: i.ms,
        );
        added++;
      } catch (_) {
        failed++;
      }
    }
    return ImportResult(added, failed);
  }

  /// Deletes the song everywhere, including its file.
  Future<void> remove(String songId) async {
    final f = library.removeSong(songId);
    if (f != null) await files.delete(f);
  }
}

typedef FontLoaderFn = Future<ByteData?> Function(String asset);

/// Everything the screens need, in one place. Tests put fakes in here.
class Services {
  const Services({
    required this.library,
    required this.pro,
    required this.deck,
    required this.sharer,
    required this.links,
    required this.fonts,
    required this.importer,
    required this.songFiles,
  });
  final Library library;
  final Pro pro;
  final Deck deck;
  final ShareBackend sharer;
  final LinkBackend links;
  final FontLoaderFn fonts;
  final SongImporter importer;
  final SongFiles songFiles;
}

class ServicesScope extends InheritedWidget {
  const ServicesScope({
    super.key,
    required this.services,
    required super.child,
  });
  final Services services;

  static Services of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ServicesScope>()!.services;

  /// For initState, where subscribing to changes is not allowed.
  static Services read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ServicesScope>()!.services;

  @override
  bool updateShouldNotify(ServicesScope old) => old.services != services;
}
