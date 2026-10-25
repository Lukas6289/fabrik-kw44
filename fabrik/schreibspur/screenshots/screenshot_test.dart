// ignore_for_file: invalid_use_of_visible_for_testing_member
// Renders App Store screenshots (6.9" iPhone, 1290 × 2796) with real fonts:
// a headline on top, the app screen below in a rounded frame.
// Run: flutter test screenshots
// Output: screenshots/out/<lang>_<n>.png
import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schreibspur/design.dart';
import 'package:schreibspur/main.dart';
import 'package:schreibspur/pro.dart';
import 'package:schreibspur/sample.dart';
import 'package:schreibspur/screens/poster_screen.dart';
import 'package:schreibspur/screens/pro_screen.dart';
import 'package:schreibspur/screens/story_screen.dart';
import 'package:schreibspur/stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/fakes.dart';

Future<void> _font(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await loader.load();
}

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final dir = '$root/bin/cache/artifacts/material_fonts';
  await _font('Roboto', [for (final f in ['Regular', 'Medium', 'Bold']) '$dir/Roboto-$f.ttf']);
  await _font('MaterialIcons', ['$dir/MaterialIcons-Regular.otf']);
  await _font(Brand.text, [for (final w in [400, 600, 700]) 'assets/fonts/BricolageText-$w.ttf']);
  await _font(Brand.display, [for (final w in [700, 800]) 'assets/fonts/BricolageDisplay-$w.ttf']);
  const emoji = '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf';
  if (File(emoji).existsSync()) await _font('NotoColorEmoji', [emoji]);
}

/// Headline + framed app screen.
class _Frame extends StatelessWidget {
  const _Frame({required this.caption, required this.child});
  final ValueNotifier<(String, Tone)> caption;
  final Widget child;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder(
          valueListenable: caption,
          builder: (context, c, _) => Container(
            decoration: BoxDecoration(gradient: c.$2.gradient),
            child: Stack(children: [
              Positioned.fill(child: Blobs(tone: c.$2)),
              Column(children: [
                const SizedBox(height: 50),
                Container(
                  height: 140,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(c.$1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: Brand.display,
                          fontSize: 40,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          color: c.$2.fg,
                          letterSpacing: -0.5)),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      widthFactor: 0.84,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(44),
                          border: Border.all(color: Brand.ink, width: 9),
                          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 40, offset: Offset(0, 18))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter,
                            child: SizedBox(width: 430, height: 932, child: child),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      );
}

Future<void> _shot(WidgetTester t, String name) async {
  await t.pumpAndSettle();
  final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
  await t.runAsync(() async {
    final img = await boundary.toImage(pixelRatio: 3);
    final bytes = await img.toByteData(format: ImageByteFormat.png);
    File('screenshots/out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _show(WidgetTester t, String title, {double offset = 0}) async {
  await t.scrollUntilVisible(find.text(title), 300, scrollable: find.byType(Scrollable).first);
  Scrollable.ensureVisible(t.element(find.text(title)), alignment: offset);
  await t.pumpAndSettle();
}

void main() {
  setUpAll(_loadFonts);

  for (final lang in ['en', 'de']) {
    testWidgets('screenshots $lang', (t) async {
      final de = lang == 'de';
      t.view.physicalSize = const Size(1290, 2796);
      t.view.devicePixelRatio = 3;
      t.platformDispatcher.localesTestValue = [Locale(lang)];
      addTearDown(() {
        t.view.reset();
        t.platformDispatcher.clearLocalesTestValue();
      });

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final pro = Pro(prefs, FakeProBackend()..owned = [proLifetimeId]);
      final key = GlobalKey<NavigatorState>();
      final chat = sampleChat(now: DateTime(2026, 10, 22), lang: lang);
      final stats = computeStats(chat);
      final caption = ValueNotifier((de ? 'Dein Chat\nals Rückblick' : 'Your chat,\nwrapped', Tone.violet));
      await t.runAsync(pro.start);
      await t.pumpWidget(RepaintBoundary(
        key: const ValueKey('shot'),
        child: _Frame(
          caption: caption,
          child: SchreibspurApp(
            pro: pro,
            source: FakeSource(),
            sharer: FakeSharer(),
            navigatorKey: key,
            initialChat: chat,
          ),
        ),
      ));
      await t.pumpAndSettle();

      Future<void> story(int index) async {
        key.currentState!.push(MaterialPageRoute(
            builder: (_) => StoryScreen(
                  chat: chat,
                  stats: stats,
                  sharer: FakeSharer(),
                  isPro: true,
                  autoPlay: false,
                  initialIndex: index,
                  onUnlock: () {},
                  onPoster: () {},
                )));
        await t.pumpAndSettle();
      }

      // 1: story – the big number
      await story(1);
      await _shot(t, '${lang}_1');
      key.currentState!.pop();
      await t.pumpAndSettle();

      // 2: results
      caption.value = (de ? 'Wer schreibt\nam meisten?' : 'Who writes\nthe most?', Tone.coral);
      await _shot(t, '${lang}_2');

      // 3: word cloud
      caption.value = (de ? 'Eure Wörter\nals Wolke' : 'Your words\nas a cloud', Tone.teal);
      await _show(t, de ? 'Wortwolke' : 'Word cloud', offset: 0.05);
      await _shot(t, '${lang}_3');

      // 5 is captured first because the year band sits right below the cloud
      caption.value = (de ? 'Jeder Tag\nein Streifen' : 'Every day\na stripe', Tone.blue);
      await _show(t, de ? 'Chat-Jahr' : 'Chat year', offset: 0.05);
      await _shot(t, '${lang}_5');

      // 4: story – awards
      caption.value = (de ? 'Auszeichnungen\nfür die Gruppe' : 'Awards for\nyour group', Tone.sun);
      await story(10);
      await _shot(t, '${lang}_4');
      key.currentState!.pop();
      await t.pumpAndSettle();

      // 6: poster
      caption.value = (de ? 'Alles auf\neinem Poster' : 'Everything\non one poster', Tone.pink);
      key.currentState!.push(MaterialPageRoute(
          builder: (_) => PosterScreen(chat: chat, stats: stats, sharer: FakeSharer())));
      await _shot(t, '${lang}_6');
      key.currentState!.pop();
      await t.pumpAndSettle();

      // 7: landing with the offline promise
      caption.value = (de ? '100 % offline.\nOhne Upload.' : '100 % offline.\nNo upload.', Tone.night);
      await t.tap(find.byIcon(Icons.refresh_rounded));
      await t.pumpAndSettle();
      await _shot(t, '${lang}_7');

      // 8: paywall (also the review screenshot)
      caption.value = (de ? 'Einmal zahlen\noder Jahresabo' : 'Pay once\nor yearly', Tone.violet);
      SharedPreferences.setMockInitialValues({});
      final free = Pro(await SharedPreferences.getInstance(), FakeProBackend());
      await t.runAsync(free.start);
      key.currentState!.push(MaterialPageRoute(builder: (_) => ProScreen(pro: free)));
      await _shot(t, '${lang}_8');
    });
  }
}
