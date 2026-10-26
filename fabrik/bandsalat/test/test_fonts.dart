import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the real fonts (Space Grotesk, Rubik Mono One, Gochi Hand, Roboto, Material Icons) so that tests measure
/// text the way a phone does instead of with the square test font.
Future<void> loadFonts() async {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable)
          .parent
          .parent
          .parent
          .parent
          .parent
          .parent
          .path;
  final dir = '$root/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final f in ['Roboto-Regular', 'Roboto-Medium', 'Roboto-Bold']) {
    roboto.addFont(
      Future.value(ByteData.sublistView(File('$dir/$f.ttf').readAsBytesSync())),
    );
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('$dir/MaterialIcons-Regular.otf').readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
  Future<void> fam(String name, List<String> files) async {
    final f = FontLoader(name);
    for (final x in files) {
      f.addFont(
        Future.value(
          ByteData.sublistView(File('assets/fonts/$x.ttf').readAsBytesSync()),
        ),
      );
    }
    await f.load();
  }

  await fam('RubikMono', ['RubikMonoOne-Regular']);
  await fam('GochiHand', ['GochiHand-Regular']);
  await fam('SpaceGrotesk', [
    'SpaceGrotesk-400',
    'SpaceGrotesk-500',
    'SpaceGrotesk-700',
  ]);
}
