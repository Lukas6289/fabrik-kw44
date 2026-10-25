import 'dart:convert';

import 'package:archive/archive.dart';

/// One message of an exported chat. Only what the statistics need.
class Message {
  const Message(this.time, this.sender, this.text, {this.media = false});
  final DateTime time;
  final String sender;
  final String text;

  /// An attachment placeholder ("Media omitted" and friends), no real text.
  final bool media;
}

class Chat {
  const Chat(this.messages);
  final List<Message> messages;

  bool get isEmpty => messages.isEmpty;
  List<String> get people => ({for (final m in messages) m.sender}).toList()..sort();
  DateTime get first => messages.first.time;
  DateTime get last => messages.last.time;
}

class ChatParseException implements Exception {
  const ChatParseException(this.reason);
  final String reason;
  @override
  String toString() => 'ChatParseException($reason)';
}

// iOS:     [22.10.26, 14:03:12] Anna: Hallo     [10/22/26, 2:03:12 PM] Anna: Hi
// Android: 22.10.2026, 14:03 - Anna: Hallo      10/22/26, 2:03 PM - Anna: Hi
final _ios = RegExp(
    r'^\[(\d{1,4})[./-](\d{1,2})[./-](\d{1,4}),?\s+(\d{1,2})[:.](\d{2})(?:[:.](\d{2}))?\s*([AaPp]\.?\s?[Mm]\.?)?\]\s(.*)$');
final _android = RegExp(
    r'^(\d{1,4})[./-](\d{1,2})[./-](\d{1,4}),?\s+(\d{1,2})[:.](\d{2})(?:[:.](\d{2}))?\s*([AaPp]\.?\s?[Mm]\.?)?\s-\s(.*)$');

/// Invisible marks WhatsApp puts around names and placeholders.
final _invisible = RegExp(r'[\u200e\u200f\u202a-\u202e\u202f\u00a0\ufeff]');

/// Attachment placeholders and deleted messages in the export languages
/// WhatsApp uses most (de, en, es, fr, it, pt, nl, tr).
final _mediaMarks = RegExp(
  r'^(<[^>]*(medien|media|médias|multimedia|mídia|medya|anhang|attached|omitid|omis|omess|ocultad|weggelaten|dahil)[^>]*>'
  r'|[\p{L} ]{2,30}\s(omitted|weggelassen|ausgeschlossen|omitid[oa]|omise?|absente?|omess[oa]|ocultad[oa]|weggelaten|dahil edilmedi)'
  r'|.*\((file attached|datei angehängt|archivo adjunto|fichier joint|file allegato|arquivo anexado|bestand bijgevoegd|dosya ekli)\)'
  r'|(this message was deleted|you deleted this message|diese nachricht wurde gelöscht|du hast diese nachricht gelöscht'
  r'|se eliminó este mensaje|eliminaste este mensaje|ce message a été supprimé|vous avez supprimé ce message'
  r'|questo messaggio è stato eliminato|hai eliminato questo messaggio|esta mensagem foi apagada|você apagou esta mensagem'
  r'|dit bericht is verwijderd|je hebt dit bericht verwijderd|bu mesaj silindi|bu mesajı sildiniz))$',
  caseSensitive: false,
  unicode: true,
);

/// The "This message was edited" marker in angle brackets at the end of edited messages.
final _edited = RegExp(r'\s*<[^<>]{6,60}>\s*$');

class _Raw {
  _Raw(this.a, this.b, this.c, this.h, this.min, this.sec, this.ampm, this.rest);
  final int a, b, c, h, min, sec;
  final String? ampm;
  String rest;
}

/// Parses an exported WhatsApp chat (iOS or Android, German or English).
/// Everything stays on the device. Lines that do not start with a time stamp
/// continue the previous message. System lines (no "Name:") are dropped.
Chat parseChat(String raw) {
  final lines = const LineSplitter().convert(raw.replaceAll(_invisible, ' ').replaceAll('\r', ''));
  final raws = <_Raw>[];
  for (final line in lines) {
    final m = _ios.firstMatch(line.trimLeft()) ?? _android.firstMatch(line.trimLeft());
    if (m != null) {
      raws.add(_Raw(
        int.parse(m[1]!),
        int.parse(m[2]!),
        int.parse(m[3]!),
        int.parse(m[4]!),
        int.parse(m[5]!),
        m[6] == null ? 0 : int.parse(m[6]!),
        m[7],
        m[8]!,
      ));
    } else if (raws.isNotEmpty) {
      raws.last.rest += '\n$line';
    }
  }
  if (raws.isEmpty) throw const ChatParseException('no-messages');

  final order = _detectOrder(raws);
  final out = <Message>[];
  for (final r in raws) {
    final colon = r.rest.indexOf(': ');
    if (colon <= 0 || colon > 60) continue; // system message
    final sender = r.rest.substring(0, colon).trim();
    var text = r.rest.substring(colon + 2).trim();
    if (!text.startsWith('<')) text = text.replaceFirst(_edited, '');
    if (sender.isEmpty) continue;
    final time = _time(r, order);
    if (time == null) continue;
    final media = _mediaMarks.hasMatch(text.replaceAll('\n', ' ').trim());
    if (media) text = '';
    out.add(Message(time, sender, text, media: media));
  }
  if (out.isEmpty) throw const ChatParseException('no-messages');
  out.sort((x, y) => x.time.compareTo(y.time));
  return Chat(out);
}

enum _Order { dmy, mdy, ymd }

_Order _detectOrder(List<_Raw> raws) {
  if (raws.any((r) => r.a > 31)) return _Order.ymd;
  if (raws.any((r) => r.a > 12)) return _Order.dmy;
  if (raws.any((r) => r.b > 12)) return _Order.mdy;
  // Ambiguous: dots are German style, otherwise assume day first.
  return _Order.dmy;
}

DateTime? _time(_Raw r, _Order order) {
  final (int y, int mo, int d) = switch (order) {
    _Order.ymd => (r.a, r.b, r.c),
    _Order.dmy => (r.c, r.b, r.a),
    _Order.mdy => (r.c, r.a, r.b),
  };
  final year = y < 100 ? 2000 + y : y;
  var hour = r.h;
  final ap = r.ampm?.toLowerCase().replaceAll(RegExp(r'[^ap]'), '');
  if (ap == 'p' && hour < 12) hour += 12;
  if (ap == 'a' && hour == 12) hour = 0;
  if (mo < 1 || mo > 12 || d < 1 || d > 31 || hour > 23 || r.min > 59) return null;
  return DateTime(year, mo, d, hour, r.min, r.sec);
}

/// Reads the bytes of a picked file: plain text, or the zip WhatsApp makes
/// when media is included (the chat is the single .txt inside).
String chatTextFromBytes(List<int> bytes) {
  if (bytes.length > 3 && bytes[0] == 0x50 && bytes[1] == 0x4b) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final txt = archive.files.where((f) => f.isFile && f.name.toLowerCase().endsWith('.txt')).toList();
    if (txt.isEmpty) throw const ChatParseException('no-txt-in-zip');
    txt.sort((a, b) => b.size.compareTo(a.size));
    return utf8.decode(txt.first.content as List<int>, allowMalformed: true);
  }
  return utf8.decode(bytes, allowMalformed: true);
}
