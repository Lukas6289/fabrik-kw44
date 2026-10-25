import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../backends.dart';
import '../cards.dart';
import '../design.dart';
import '../l10n/app_localizations.dart';
import '../format.dart';
import '../parser.dart';
import '../pro.dart';
import '../sample.dart';
import '../stats.dart';
import 'poster_screen.dart';
import 'pro_screen.dart';
import 'story_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.pro,
    required this.source,
    required this.sharer,
    this.initialChat,
    this.incoming,
  });

  final IncomingChats? incoming;
  final Pro pro;
  final ChatSource source;
  final ShareBackend sharer;
  final Chat? initialChat;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _Error { none, noMessages, read, clipboard }

class _HomeScreenState extends State<HomeScreen> {
  Chat? _chat;
  Stats? _stats;
  bool _example = false;
  bool _busy = false;
  _Error _error = _Error.none;
  final _keys = <String, GlobalKey>{};

  Pro get pro => widget.pro;

  GlobalKey _key(String id) => _keys.putIfAbsent(id, GlobalKey.new);

  StreamSubscription<Uint8List>? _incoming;

  @override
  void initState() {
    super.initState();
    if (widget.initialChat != null) _setChat(widget.initialChat!, example: true);
    _incoming = widget.incoming?.files.listen(_received);
  }

  @override
  void dispose() {
    _incoming?.cancel();
    super.dispose();
  }

  /// A chat export shared to the app: back to the main screen and analyse it.
  void _received(Uint8List bytes) {
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    try {
      _setChat(parseChat(chatTextFromBytes(bytes)));
    } on ChatParseException {
      setState(() {
        _chat = null;
        _stats = null;
      });
      _fail(_Error.noMessages);
    } catch (_) {
      setState(() {
        _chat = null;
        _stats = null;
      });
      _fail(_Error.read);
    }
  }

  void _setChat(Chat chat, {bool example = false}) {
    setState(() {
      _chat = chat;
      _stats = computeStats(chat);
      _example = example;
      _error = _Error.none;
      _busy = false;
    });
  }

  void _fail(_Error e) => setState(() {
        _error = e;
        _busy = false;
      });

  Future<void> _pick() async {
    setState(() => _busy = true);
    try {
      final bytes = await widget.source.pickFile();
      if (bytes == null) return setState(() => _busy = false);
      _setChat(parseChat(chatTextFromBytes(bytes)));
    } on ChatParseException {
      _fail(_Error.noMessages);
    } catch (_) {
      _fail(_Error.read);
    }
  }

  Future<void> _paste() async {
    setState(() => _busy = true);
    try {
      final text = await widget.source.paste();
      if (text == null) return _fail(_Error.clipboard);
      _setChat(parseChat(text));
    } on ChatParseException {
      _fail(_Error.noMessages);
    } catch (_) {
      _fail(_Error.read);
    }
  }

  void _openPro() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProScreen(pro: pro)));

  Future<void> _share(String id, Rect origin) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await WidgetsBinding.instance.endOfFrame; // the tap's ripple must be painted first
      final boundary = _key(id).currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await widget.sharer.shareImage(data!.buffer.asUint8List(), text: l.shareText, origin: origin);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.shareFailed)));
    }
  }

  void _openPoster() => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PosterScreen(chat: _chat!, stats: _stats!, sharer: widget.sharer)));

  void _openStory() => Navigator.of(context).push(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => StoryScreen(
          chat: _chat!,
          stats: _stats!,
          sharer: widget.sharer,
          isPro: pro.isPro,
          onUnlock: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ProScreen(pro: pro))),
          onPoster: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => PosterScreen(chat: _chat!, stats: _stats!, sharer: widget.sharer))),
        ),
        transitionsBuilder: (_, a, _, child) => FadeTransition(
          opacity: a,
          child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(a), child: child),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.gesture_rounded, size: 26),
          const SizedBox(width: 6),
          Text(l.appTitle),
        ]),
        actions: [
          if (_chat != null)
            IconButton(
              tooltip: l.newChat,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => setState(() {
                _chat = null;
                _stats = null;
              }),
            ),
          IconButton(
            tooltip: l.proTitle,
            icon: const Icon(Icons.workspace_premium_rounded),
            onPressed: _openPro,
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _chat == null
              ? KeyedSubtree(key: const ValueKey('landing'), child: _landing(context))
              : KeyedSubtree(key: const ValueKey('results'), child: _results(context)),
        ),
      ),
    );
  }

  Widget _landing(BuildContext context) {
    final l = L.of(context);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final error = switch (_error) {
      _Error.none => null,
      _Error.noMessages => l.errorNoMessages,
      _Error.read => l.errorRead,
      _Error.clipboard => l.clipboardEmpty,
    };
    Widget step(int n, String t, Tone tone) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(gradient: tone.gradient, shape: BoxShape.circle),
              child: Text('$n',
                  style: TextStyle(fontFamily: Brand.display, fontWeight: FontWeight.w800, color: tone.fg)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 4), child: Text(t, style: text.bodyLarge))),
          ]),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _Hero(title: l.heroTitle, text: l.heroText),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _busy ? null : _pick,
          icon: const Icon(Icons.folder_open_rounded),
          label: Text(l.loadChat),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _paste,
              icon: const Icon(Icons.content_paste_rounded, size: 20),
              label: FittedBox(child: Text(l.pasteChat)),
            ),
          ),
        ]),
        TextButton(
          onPressed: _busy ? null : () => _setChat(sampleChat(lang: Localizations.localeOf(context).languageCode), example: true),
          child: Text(l.tryExample),
        ),
        if (_busy) const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator())),
        if (error != null)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(18)),
            child: Text(error, textAlign: TextAlign.center, style: TextStyle(color: cs.onErrorContainer)),
          ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: BorderRadius.circular(28)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.stepsTitle, style: text.titleLarge),
            const SizedBox(height: 6),
            step(1, l.step1, Tone.violet),
            step(2, l.step2, Tone.coral),
            step(3, l.step3, Tone.teal),
            const SizedBox(height: 4),
            Text('Android: ${l.howToAndroid}', style: text.bodySmall?.copyWith(color: cs.outline)),
          ]),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: Tone.teal.gradient, borderRadius: BorderRadius.circular(28)),
          child: Row(children: [
            const Icon(Icons.airplanemode_active_rounded, color: Colors.white, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Text(l.offlineProof,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.35, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _results(BuildContext context) {
    final l = L.of(context);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final chat = _chat!;
    final s = _stats!;
    return ListenableBuilder(
      listenable: pro,
      builder: (context, _) {
        final isPro = pro.isPro;
        Widget card(String id, String title, Widget Function() body, {bool proOnly = false, bool freeShare = false}) {
          final locked = proOnly && !isPro;
          final (tone, icon) = cardStyle[id]!;
          return StatCard(
            boundaryKey: _key(id),
            title: title,
            tone: tone,
            icon: icon,
            locked: locked,
            onUnlock: _openPro,
            onShare: (isPro || freeShare) ? (origin) => _share(id, origin) : null,
            child: locked ? const SizedBox.shrink() : body(),
          );
        }

        final cards = <Widget>[
          card('overview', l.cardOverview, () => OverviewBody(s), freeShare: true),
          card('rhythm', l.cardRhythm, () => RhythmBody(s)),
          card('words', l.cardWords, () => WordsBody(s, limit: pro.wordLimit)),
          card('cloud', l.cardCloud, () => WordCloudBody(s), proOnly: true),
          card('year', l.cardYear, () => YearBandBody(s), proOnly: true),
          card('replies', l.cardReplies, () => RepliesBody(s), proOnly: true),
          card('starters', l.cardStarters, () => StartersBody(s), proOnly: true),
          card('emoji', l.cardEmoji, () => EmojiBody(s), proOnly: true),
          card('records', l.cardRecords, () => RecordsBody(s), proOnly: true),
          if (s.people.length >= 2) card('awards', l.cardAwards, () => AwardsBody(s), proOnly: true),
          card('compare', l.cardCompare, () => CompareBody(chat: chat), proOnly: true),
        ];
        final names = s.people.take(3).map((p) => p.name).join(' · ') +
            (s.people.length > 3 ? ' +${s.people.length - 3}' : '');
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Text(l.resultsKicker.toUpperCase(),
                style: text.labelLarge?.copyWith(letterSpacing: 2, color: cs.outline, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(names, style: text.headlineLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              l.chatPeriod(dateText(context, chat.first), dateText(context, chat.last)) +
                  (_example ? ' · ${l.exampleBadge}' : ''),
              style: text.bodyMedium?.copyWith(color: cs.outline),
            ),
            const SizedBox(height: 16),
            GradientButton(label: l.storyPlay, icon: Icons.play_arrow_rounded, onPressed: _openStory),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: isPro ? _openPoster : _openPro,
              icon: Icon(isPro ? Icons.auto_awesome_mosaic_rounded : Icons.lock_rounded, size: 20),
              label: Text(l.posterButton),
            ),
            const SizedBox(height: 18),
            for (final c in cards) ...[c, const SizedBox(height: 14)],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(l.aboutPrivacy,
                  textAlign: TextAlign.center, style: text.bodySmall?.copyWith(color: cs.outline)),
            ),
          ],
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    const tone = Tone.violet;
    return Container(
      decoration: BoxDecoration(gradient: tone.gradient, borderRadius: BorderRadius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        const Positioned.fill(child: Blobs(tone: tone)),
        Positioned(right: 18, top: 22, child: _Bubble(Tone.coral, number(context, 4632), 0.06)),
        const Positioned(right: 70, top: 92, child: _Bubble(Tone.sun, '😂', -0.08)),
        const Positioned(right: 16, top: 140, child: _Bubble(Tone.teal, '22:00', 0.04)),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 150),
            Text(title,
                style: const TextStyle(
                    fontFamily: Brand.display, fontSize: 40, fontWeight: FontWeight.w800, height: 1.02, color: Colors.white)),
            const SizedBox(height: 10),
            Text(text, style: const TextStyle(fontSize: 15.5, height: 1.35, color: Color(0xE6FFFFFF))),
          ]),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.tone, this.label, this.turn);
  final Tone tone;
  final String label;
  final double turn;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: turn,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: tone.gradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
          ),
          child: Text(label,
              style: TextStyle(
                  fontFamily: Brand.display,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: tone.fg,
                  fontFamilyFallback: const ['NotoColorEmoji'])),
        ),
      );
}
