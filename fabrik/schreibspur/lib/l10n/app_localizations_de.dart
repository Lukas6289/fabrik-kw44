// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Schreibspur';

  @override
  String get tagline => 'Dein Chat in Zahlen – zu 100 % auf deinem Handy.';

  @override
  String get loadChat => 'Exportierten Chat wählen';

  @override
  String get pasteChat => 'Aus Zwischenablage einfügen';

  @override
  String get tryExample => 'Beispiel ansehen';

  @override
  String get offlineProof =>
      'Nichts verlässt dein Handy. Probier es aus: Flugmodus an – Schreibspur funktioniert genauso.';

  @override
  String get howToTitle => 'So exportierst du einen Chat';

  @override
  String get howToIos =>
      'WhatsApp → Chat öffnen → oben auf den Namen tippen → Chat exportieren → Ohne Medien → im Teilen-Menü Schreibspur antippen. Fertig, die Auswertung öffnet sich sofort.';

  @override
  String get howToAndroid =>
      'WhatsApp → Chat öffnen → ⋮ → Mehr → Chat exportieren → Ohne Medien → in Dateien speichern.';

  @override
  String get errorNoMessages =>
      'Keine Nachrichten gefunden. Bitte wähle einen aus WhatsApp exportierten Chat (.txt oder .zip).';

  @override
  String get errorRead => 'Die Datei konnte nicht gelesen werden.';

  @override
  String get clipboardEmpty => 'Die Zwischenablage ist leer.';

  @override
  String get newChat => 'Anderer Chat';

  @override
  String get exampleBadge => 'Beispiel – erfundene Personen';

  @override
  String chatPeriod(String from, String to) {
    return '$from – $to';
  }

  @override
  String get labelMessages => 'Nachrichten';

  @override
  String get labelDays => 'Tage';

  @override
  String get labelActiveDays => 'Aktive Tage';

  @override
  String get labelPerDay => 'Pro Tag';

  @override
  String get labelWords => 'Wörter';

  @override
  String get labelWordsPerMessage => 'Wörter pro Nachricht';

  @override
  String get labelPhotosEtc => 'Anhänge';

  @override
  String get cardOverview => 'Überblick';

  @override
  String get cardRhythm => 'Rhythmus';

  @override
  String get cardWords => 'Lieblingswörter';

  @override
  String get cardReplies => 'Antwortzeit';

  @override
  String get cardStarters => 'Wer fängt an?';

  @override
  String get cardEmoji => 'Lieblings-Emoji';

  @override
  String get cardRecords => 'Rekorde';

  @override
  String get cardAwards => 'Auszeichnungen';

  @override
  String get cardCompare => 'Früher vs. jetzt';

  @override
  String rhythmHour(String hour) {
    return 'Aktivste Stunde: $hour';
  }

  @override
  String rhythmDay(String day) {
    return 'Aktivster Wochentag: $day';
  }

  @override
  String hourRange(int from, int to) {
    return '$from–$to Uhr';
  }

  @override
  String get wordsEmpty => 'Noch nicht genug Text.';

  @override
  String get wordsMore => '+ weitere Wörter mit Pro';

  @override
  String timesUsed(int count) {
    return '$count×';
  }

  @override
  String get repliesHint =>
      'Mittlere Zeit, bis die andere Person antwortet (bis 6 Stunden).';

  @override
  String get startersHint =>
      'Beginnt ein neues Gespräch nach mindestens 6 Stunden Pause.';

  @override
  String startsCount(int count) {
    return '$count Gespräche';
  }

  @override
  String get noEmoji => 'Keine Emoji gefunden.';

  @override
  String get recordBusiestDay => 'Aktivster Tag';

  @override
  String recordBusiestDayValue(String date, int count) {
    return '$date · $count Nachrichten';
  }

  @override
  String get recordPause => 'Längste Funkstille';

  @override
  String recordPauseValue(String duration, String date) {
    return '$duration, ab $date';
  }

  @override
  String get recordStreak => 'Längste Serie';

  @override
  String recordStreakValue(int days) {
    return '$days Tage in Folge';
  }

  @override
  String get durUnderMinute => 'unter 1 Min.';

  @override
  String durMinutes(int m) {
    return '$m Min.';
  }

  @override
  String durHours(int h, int m) {
    return '$h Std. $m Min.';
  }

  @override
  String durDays(int d, int h) {
    return '$d T. $h Std.';
  }

  @override
  String get awardMost => 'Quasselstrippe';

  @override
  String get awardMostText => 'Schreibt die meisten Nachrichten';

  @override
  String get awardFast => 'Blitzantwort';

  @override
  String get awardFastText => 'Antwortet am schnellsten';

  @override
  String get awardStarter => 'Eisbrecher';

  @override
  String get awardStarterText => 'Fängt die meisten Gespräche an';

  @override
  String get awardNovel => 'Romanautor';

  @override
  String get awardNovelText => 'Die längsten Nachrichten';

  @override
  String get awardOwl => 'Nachteule';

  @override
  String get awardOwlText => 'Meiste Nachrichten nach Mitternacht';

  @override
  String get compareNeedMore =>
      'Zum Vergleichen braucht es mindestens zwei Wochen Chat.';

  @override
  String get compareBefore => 'Vorher';

  @override
  String get compareNow => 'Jetzt';

  @override
  String compareChange(String percent) {
    return '$percent Nachrichten';
  }

  @override
  String get locked => 'Teil von Pro';

  @override
  String get lockedTap => 'Mit Pro freischalten';

  @override
  String get share => 'Als Bild teilen';

  @override
  String get shareText => 'Erstellt mit Schreibspur';

  @override
  String get shareFailed => 'Teilen hat nicht geklappt.';

  @override
  String get aboutPrivacy =>
      'Dein Chat wird auf diesem Handy gelesen und nicht gespeichert: App schließen, und er ist weg. Kein Konto, kein Internetzugriff, kein Tracking.';

  @override
  String get proTitle => 'Schreibspur Pro';

  @override
  String get proTagline => 'Alle Karten, alle Vergleiche, teilbar.';

  @override
  String get proFeatureCards =>
      'Alle Karten: Antwortzeit, Wer fängt an, Emoji, Rekorde';

  @override
  String get proFeatureAwards =>
      'Auszeichnungen für Gruppen: Quasselstrippe, Nachteule u. a.';

  @override
  String get proFeatureCompare =>
      'Zwei Zeiträume vergleichen – dieses Jahr gegen letztes';

  @override
  String proFeatureWords(int count, int free) {
    return '$count Lieblingswörter statt $free';
  }

  @override
  String get proFeatureShare => 'Jede Karte als Bild teilen';

  @override
  String get proYearly => 'Jährlich';

  @override
  String proYearlyDetail(String price) {
    return '$price pro Jahr · verlängert sich automatisch';
  }

  @override
  String get proLifetime => 'Einmalig';

  @override
  String proLifetimeDetail(String price) {
    return '$price einmalig · kein Abo';
  }

  @override
  String get proBuy => 'Weiter';

  @override
  String get proRestore => 'Käufe wiederherstellen';

  @override
  String get proActive => 'Pro ist aktiv – danke!';

  @override
  String get proPending => 'Dein Kauf wartet auf Freigabe.';

  @override
  String get proFailed =>
      'Der Kauf hat nicht geklappt. Bitte versuche es erneut.';

  @override
  String get proNothingToRestore => 'Kein früherer Kauf gefunden.';

  @override
  String get proStoreUnavailable =>
      'Der App Store ist gerade nicht erreichbar.';

  @override
  String get proSubscriptionNote =>
      'Das Jahresabo verlängert sich automatisch, wenn du nicht mindestens 24 Stunden vor Ende des Zeitraums kündigst. Die Zahlung läuft über deine Apple-ID. Verwalten oder kündigen kannst du es in den Einstellungen deiner Apple-ID.';

  @override
  String get terms => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutz';

  @override
  String get cardCloud => 'Wortwolke';

  @override
  String get cloudHint =>
      'Je größer, desto öfter. Farbe = wer es am meisten schreibt.';

  @override
  String get cardYear => 'Chat-Jahr';

  @override
  String yearSummary(int active, int days) {
    return 'An $active von $days Tagen geschrieben';
  }

  @override
  String get yearLess => 'weniger';

  @override
  String get yearMore => 'mehr';

  @override
  String get posterButton => 'Poster erstellen';

  @override
  String get posterTitle => 'Poster';

  @override
  String get posterShare => 'Poster teilen';

  @override
  String get posterHint =>
      'Alle Karten in einem Bild – teilen oder in Fotos sichern.';

  @override
  String get posterMadeWith => 'Erstellt mit Schreibspur · offline ausgewertet';

  @override
  String get proFeatureImages =>
      'Poster mit allen Karten, Wortwolke und Chat-Jahr';

  @override
  String get storyPlay => 'Rückblick abspielen';

  @override
  String get storyIntroKicker => 'Euer Chat';

  @override
  String storyIntroTitle(int days) {
    return '$days Tage in Nachrichten';
  }

  @override
  String get storyTotalKicker => 'Ihr habt geschrieben';

  @override
  String storyTotalSub(String perDay) {
    return 'Das sind $perDay am Tag.';
  }

  @override
  String get storyWhoKicker => 'Wer schreibt mehr?';

  @override
  String storyWhoTitle(String name, int percent) {
    return '$name schreibt $percent %';
  }

  @override
  String get storyHourKicker => 'Eure Stunde';

  @override
  String storyHourTitle(String hour) {
    return 'Am meisten los: $hour';
  }

  @override
  String get storyWordKicker => 'Euer Wort';

  @override
  String storyWordTitle(int count) {
    return '$count-mal geschrieben';
  }

  @override
  String get storyCloudTitle => 'Das sind eure Wörter.';

  @override
  String storyReplyTitle(String name) {
    return '$name antwortet am schnellsten';
  }

  @override
  String storyStarterTitle(String name) {
    return '$name meldet sich zuerst';
  }

  @override
  String get storyEmojiTitle => 'Euer Lieblings-Emoji';

  @override
  String get storyAwardsTitle => 'Und die Preise gehen an …';

  @override
  String get storyOutroKicker => 'Das war\'s';

  @override
  String get storyOutroTitle => 'Das ist eure Schreibspur.';

  @override
  String get storyRestart => 'Nochmal ansehen';

  @override
  String get storyLockedTitle => 'Das war erst der Anfang.';

  @override
  String get storyLockedText =>
      'Wortwolke, Antwortzeit, Emoji, Chat-Jahr, Auszeichnungen und Rekorde gibt es mit Pro.';

  @override
  String get storyLockedButton => 'Pro ansehen';

  @override
  String get storyShare => 'Folie teilen';

  @override
  String get storyClose => 'Schließen';

  @override
  String get storyTapHint => 'Tippen für weiter';

  @override
  String get heroTitle => 'Dein Chat\nals Rückblick.';

  @override
  String get heroText =>
      'Wer schreibt mehr, wer antwortet schneller, was ist euer Wort? Mach aus jedem WhatsApp-Chat einen Rückblick zum Teilen.';

  @override
  String get stepsTitle => 'In drei Schritten';

  @override
  String get step1 => 'Chat in WhatsApp öffnen, oben auf den Namen tippen.';

  @override
  String get step2 => 'Chat exportieren → Ohne Medien.';

  @override
  String get step3 => 'Im Teilen-Menü Schreibspur antippen – fertig.';

  @override
  String get resultsKicker => 'Euer Rückblick';

  @override
  String get proBest => 'Bester Wert';

  @override
  String get proPopular => 'Flexibel';
}
