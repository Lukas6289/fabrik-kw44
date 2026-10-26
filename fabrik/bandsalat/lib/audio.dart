import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// One song handed to the player.
class EngineItem {
  const EngineItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.source,
  });
  final String id;
  final String title;
  final String artist;
  final String album;

  /// A file path, or `asset:<path>` for a bundled sample.
  final String source;
}

/// Seam over the audio player (just_audio). Tests use a fake that advances time by hand.
abstract class AudioEngine {
  Stream<int> get indexStream;
  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;
  Stream<void> get completedStream;
  Future<void> open(
    List<EngineItem> items, {
    int index = 0,
    Duration position = Duration.zero,
  });
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position, {int? index});
  Future<void> setVolume(double v);
}

class JustAudioEngine implements AudioEngine {
  final AudioPlayer _p = AudioPlayer();

  @override
  Stream<int> get indexStream =>
      _p.currentIndexStream.where((i) => i != null).cast<int>();

  @override
  Stream<Duration> get positionStream => _p.positionStream;

  @override
  Stream<bool> get playingStream => _p.playingStream;

  @override
  Stream<void> get completedStream =>
      _p.processingStateStream.where((s) => s == ProcessingState.completed);

  @override
  Future<void> open(
    List<EngineItem> items, {
    int index = 0,
    Duration position = Duration.zero,
  }) async {
    await _p.setAudioSources(
      [
        for (final i in items)
          i.source.startsWith('asset:')
              ? AudioSource.asset(i.source.substring(6), tag: _tag(i))
              : AudioSource.file(i.source, tag: _tag(i)),
      ],
      initialIndex: index,
      initialPosition: position,
    );
  }

  MediaItem _tag(EngineItem i) => MediaItem(
    id: i.id,
    title: i.title,
    artist: i.artist.isEmpty ? null : i.artist,
    album: i.album,
  );

  @override
  Future<void> play() => _p.play();

  @override
  Future<void> pause() => _p.pause();

  @override
  Future<void> seek(Duration position, {int? index}) =>
      _p.seek(position, index: index);

  @override
  Future<void> setVolume(double v) => _p.setVolume(v);
}
