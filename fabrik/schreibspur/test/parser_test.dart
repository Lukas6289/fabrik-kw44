import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schreibspur/parser.dart';

const iosDe = '''
‎[22.10.26, 14:03:12] Anna: ‎Verschlüsselung: Nachrichten sind Ende-zu-Ende verschlüsselt.
[22.10.26, 14:03:12] Anna: Hallo Ben!
[22.10.26, 14:04:30] Ben: Hi Anna
zweite Zeile
[23.10.26, 08:15:00] Ben: ‎<Medien ausgeschlossen>
[23.10.26, 08:16:00] Ben hat die Gruppe verlassen
''';

const androidEn = '''
10/22/26, 2:03 PM - Messages and calls are end-to-end encrypted.
10/22/26, 2:03 PM - Anna: Hello there
10/22/26, 11:59 PM - Ben: Late one
10/23/26, 12:05 AM - Ben: <Media omitted>
''';

void main() {
  test('iOS German export: messages, continuation lines, media, system lines', () {
    final chat = parseChat(iosDe);
    expect(chat.messages.length, 4);
    expect(chat.people, ['Anna', 'Ben']);
    expect(chat.messages[0].time, DateTime(2026, 10, 22, 14, 3, 12));
    expect(chat.messages[2].text, 'Hi Anna\nzweite Zeile');
    expect(chat.messages[3].media, isTrue);
    expect(chat.messages[3].text, '');
  });

  test('Android English export with AM/PM and month-first dates', () {
    final chat = parseChat(androidEn);
    expect(chat.messages.length, 3);
    expect(chat.messages[0].time, DateTime(2026, 10, 22, 14, 3));
    expect(chat.messages[1].time, DateTime(2026, 10, 22, 23, 59));
    expect(chat.messages[2].time, DateTime(2026, 10, 23, 0, 5), reason: '12:05 AM is just after midnight');
    expect(chat.messages[2].media, isTrue);
  });

  test('Android German export with 4-digit year', () {
    final chat = parseChat('''
05.03.2025, 18:20 - Anna: Moin
06.03.2025, 07:00 - Ben: Guten Morgen
''');
    expect(chat.first, DateTime(2025, 3, 5, 18, 20));
    expect(chat.last, DateTime(2025, 3, 6, 7));
  });

  test('day-first is detected from a day above 12', () {
    final chat = parseChat('''
[03/04/26, 10:00:00] A: x
[25/04/26, 10:00:00] B: y
''');
    expect(chat.first, DateTime(2026, 4, 3, 10));
    expect(chat.last, DateTime(2026, 4, 25, 10));
  });

  test('windows line endings and name with colon-free spaces', () {
    final chat = parseChat('[01.01.26, 10:00:00] Max Muster: Hi\r\n[01.01.26, 10:01:00] Erika: Ho\r\n');
    expect(chat.people, ['Erika', 'Max Muster']);
  });

  test('nonsense is rejected', () {
    expect(() => parseChat('hello world\nnothing here'), throwsA(isA<ChatParseException>()));
    expect(() => parseChat('[01.01.26, 10:00:00] Only a system line'), throwsA(isA<ChatParseException>()));
  });

  test('plain bytes and zip files both give the chat text', () {
    final bytes = utf8.encode(iosDe);
    expect(chatTextFromBytes(bytes), iosDe);
    final zip = Archive()
      ..addFile(ArchiveFile('__MACOSX/x.txt', 3, [1, 2, 3]))
      ..addFile(ArchiveFile('_chat.txt', bytes.length, bytes))
      ..addFile(ArchiveFile('IMG-1.jpg', 3, [1, 2, 3]));
    final zipped = ZipEncoder().encode(zip);
    expect(parseChat(chatTextFromBytes(zipped)).messages.length, 4);
    final noText = ZipEncoder().encode(Archive()..addFile(ArchiveFile('a.jpg', 1, [1])));
    expect(() => chatTextFromBytes(noText), throwsA(isA<ChatParseException>()));
  });

  test('Spanish Android export with "p. m." and Spanish placeholders', () {
    final chat = parseChat("""
22/10/26, 2:03 p. m. - Ana: Hola, ¿qué tal?
22/10/26, 2:05 p. m. - Beto: <Multimedia omitido>
22/10/26, 2:06 p. m. - Beto: Se eliminó este mensaje
22/10/26, 2:07 p. m. - Ana: Vale <Se editó este mensaje.>
""");
    expect(chat.messages.length, 4);
    expect(chat.messages[0].time, DateTime(2026, 10, 22, 14, 3));
    expect(chat.messages[1].media, isTrue);
    expect(chat.messages[2].media, isTrue, reason: 'deleted messages have no text');
    expect(chat.messages[3].text, 'Vale');
  });

  test('French iOS export and edited marker in German', () {
    final chat = parseChat("""
[22/10/2026 14:03:12] Chloé: Salut !
[22/10/2026 14:04:00] Hugo: image absente
[22/10/2026 14:05:00] Hugo: Bis gleich <Diese Nachricht wurde bearbeitet.>
""");
    expect(chat.messages.length, 3);
    expect(chat.messages[1].media, isTrue);
    expect(chat.messages[2].text, 'Bis gleich');
  });
}

