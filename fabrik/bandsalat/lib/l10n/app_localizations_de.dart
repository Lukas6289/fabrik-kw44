// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Bandsalat';

  @override
  String get tabShelf => 'Regal';

  @override
  String get tabCrate => 'Kiste';

  @override
  String get tabMore => 'Mehr';

  @override
  String get shelfTitle => 'Deine Bänder';

  @override
  String shelfSub(int n, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Bänder',
      one: '1 Band',
    );
    return '$_temp0 · $time Musik';
  }

  @override
  String get shelfSubEmpty => 'Noch nichts aufgenommen.';

  @override
  String get newTape => 'Neues Band';

  @override
  String get lastPlayed => 'Zuletzt gehört';

  @override
  String get play => 'Abspielen';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stopp';

  @override
  String get rewind => 'Zurückspulen';

  @override
  String get forward => 'Vorspulen';

  @override
  String get flipTape => 'Band wenden';

  @override
  String tapeSummary(int n, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Titel',
      one: '1 Titel',
    );
    return '$_temp0 · $time';
  }

  @override
  String get allTapes => 'Alle Bänder';

  @override
  String get emptyShelfTitle => 'Das Regal ist leer';

  @override
  String get emptyShelfBody =>
      'Sammle Songs in der Kiste und nimm dein erstes Mixtape auf: 90 Minuten, zwei Seiten, deine Handschrift.';

  @override
  String sideLabel(String side) {
    return 'Seite $side';
  }

  @override
  String get back => 'Zurück';

  @override
  String get close => 'Schließen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get done => 'Fertig';

  @override
  String get delete => 'Löschen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get more => 'Weitere Optionen';

  @override
  String get editTape => 'Band bearbeiten';

  @override
  String get endOfSideFlip =>
      'Seite A ist zu Ende – wende das Band für Seite B.';

  @override
  String get endOfTape => 'Ende des Bands.';

  @override
  String get autoFlip => 'Automatisch wenden';

  @override
  String get autoFlipSub => 'Nach Seite A startet Seite B von selbst.';

  @override
  String get sleepTimer => 'Schlaf-Timer';

  @override
  String get sleepBody =>
      'Das Band läuft aus: die letzten 20 Sekunden blenden aus, dann ist Schluss.';

  @override
  String get sleepEndOfSide => 'Ende der Seite';

  @override
  String get sleepOff => 'Ausschalten';

  @override
  String sleepLeft(int min) {
    return 'noch $min Min';
  }

  @override
  String minutesShort(int m) {
    return '$m Min';
  }

  @override
  String hoursMinutes(int h, int m) {
    return '$h Std $m Min';
  }

  @override
  String get positionOnSide => 'Position auf dieser Seite';

  @override
  String sideEmpty(String side) {
    return 'Seite $side ist leer. Füge im Band-Editor Songs hinzu.';
  }

  @override
  String get jcardShort => 'Hülle';

  @override
  String get jcardTitle => 'Hüllenkarte';

  @override
  String get jcardBody =>
      'Die Hülle deines Bandes, handgeschrieben: beide Seiten, alle Songs, Zeiten. Druck sie aus oder schick sie mit.';

  @override
  String get shareImage => 'Als Bild teilen';

  @override
  String get sharePdf => 'Als PDF zum Drucken teilen';

  @override
  String get sharePdfPro => 'PDF zum Drucken (Pro)';

  @override
  String get stampNote =>
      'Gratis: ein kleiner Stempel auf der Karte. Pro: ohne Stempel, dazu das PDF.';

  @override
  String get stampText => 'gemacht mit Bandsalat';

  @override
  String get untitledTape => 'Ohne Titel';

  @override
  String get tapeNameHint => 'Name des Bands';

  @override
  String get dedicationHint =>
      'Handschriftliche Widmung, z. B. Für Mia, Sommer ’26';

  @override
  String get tapeLength => 'Bandlänge';

  @override
  String get shellColour => 'Kassettenfarbe';

  @override
  String get labelStyle => 'Etikett-Muster';

  @override
  String tapeLeft(String time) {
    return 'noch $time Band frei';
  }

  @override
  String tapeOver(String time) {
    return '$time zu lang';
  }

  @override
  String get sideEmptyHint => 'Noch leer – füge Songs hinzu.';

  @override
  String otherSide(String side) {
    return 'Auf Seite $side verschieben';
  }

  @override
  String get removeFromTape => 'Vom Band nehmen';

  @override
  String get addSongs => 'Songs hinzufügen';

  @override
  String addToSide(String side) {
    return 'Auf Seite $side legen';
  }

  @override
  String get allSongsUsed =>
      'Alle Songs deiner Kiste sind schon auf diesem Band. Hol erst weitere.';

  @override
  String get tooLong => 'zu lang';

  @override
  String get importMore => 'Songs holen';

  @override
  String addCount(int n) {
    return '$n hinzufügen';
  }

  @override
  String didNotFit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Songs passen nicht',
      one: '1 Song passt nicht',
    );
    return '$_temp0 auf diese Seite.';
  }

  @override
  String get fillSides => 'Seiten automatisch füllen';

  @override
  String get deleteTape => 'Dieses Band löschen';

  @override
  String deleteTapeTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get deleteTapeBody =>
      'Das Band wird entfernt. Deine Songs bleiben in der Kiste.';

  @override
  String get crateTitle => 'Kiste';

  @override
  String crateSub(int n, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Songs',
      one: '1 Song',
    );
    return '$_temp0 · $time';
  }

  @override
  String get crateSubEmpty => 'Noch keine Songs.';

  @override
  String get importSongs => 'Songs aus Dateien holen';

  @override
  String get importHint =>
      'MP3, M4A, WAV, AIFF, FLAC … aus der Dateien-App, iCloud Drive oder AirDrop. Sie werden in die App kopiert – deine Originale bleiben unberührt.';

  @override
  String importDone(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Songs',
      one: '1 Song',
    );
    return '$_temp0 hinzugefügt.';
  }

  @override
  String importFailed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Dateien',
      one: '1 Datei',
    );
    return '$_temp0 konnte nicht gelesen werden (geschützt oder kein Audio).';
  }

  @override
  String get emptyCrateTitle => 'Die Kiste ist leer';

  @override
  String get emptyCrateBody =>
      'Hol die Songs, die du als Dateien besitzt. Dann sortierst du sie auf Bänder.';

  @override
  String get allSongs => 'Alle Songs';

  @override
  String onTapes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Bändern',
      one: '1 Band',
    );
    return 'auf $_temp0';
  }

  @override
  String get ownFilesNote =>
      'Bandsalat spielt deine eigenen Audiodateien. Titel aus Streaming-Diensten wie Apple Music sind kopiergeschützt und lassen sich nicht importieren.';

  @override
  String deleteSongTitle(String title) {
    return '„$title“ löschen?';
  }

  @override
  String get deleteSongBody => 'Der Song wird aus der App entfernt.';

  @override
  String deleteSongBodyUsed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Bändern',
      one: '1 Band',
    );
    return 'Der Song wird aus der App und von $_temp0 entfernt.';
  }

  @override
  String get proLead =>
      'Einmal zahlen, für immer: unbegrenzt Bänder, alle Farben, die Hülle ohne Stempel.';

  @override
  String proReasonTapes(int n) {
    return 'Das Gratis-Regal fasst $n Bänder. Mit Pro beliebig viele.';
  }

  @override
  String get proReasonStyles =>
      'Weitere Farben und Etikett-Muster gehören zu Pro.';

  @override
  String get proReasonPdf => 'Das druckbare PDF gehört zu Pro.';

  @override
  String get proFeatTapes => 'Unbegrenzt Bänder';

  @override
  String proFeatTapesSub(int n) {
    return 'Gratis: $n Bänder. Pro: deine ganze Sammlung.';
  }

  @override
  String get proFeatLooks => '8 Farben, 8 Etikett-Muster';

  @override
  String get proFeatLooksSub => 'Gratis: je 3. Pro: alle, beliebig gemischt.';

  @override
  String get proFeatCard => 'Hülle, druckfertig';

  @override
  String get proFeatCardSub =>
      'Ohne Stempel, dazu ein PDF zum Ausdrucken und Ausschneiden.';

  @override
  String get proFreeStays =>
      'Abspielen, Schlaf-Timer, Kiste und beide Seiten bleiben gratis – für immer. Kein Abo, keine Werbung.';

  @override
  String get proOnce => 'einmalig – kein Abo';

  @override
  String proBuy(String price) {
    return 'Pro für $price holen';
  }

  @override
  String get proThanks => 'Danke! Pro ist freigeschaltet.';

  @override
  String get proPending => 'Warte auf Freigabe …';

  @override
  String get proFailed =>
      'Das hat nicht geklappt. Bitte noch einmal versuchen.';

  @override
  String get proNothing => 'Kein Kauf zum Wiederherstellen gefunden.';

  @override
  String get restore => 'Kauf wiederherstellen';

  @override
  String get terms => 'Nutzungsbedingungen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get support => 'Support';

  @override
  String get proActive => 'Pro ist aktiv';

  @override
  String get proCardTitle => 'Bandsalat Pro';

  @override
  String proCardSub(String price) {
    return 'Unbegrenzt Bänder, alle Looks, Hülle als PDF – einmalig $price, kein Abo.';
  }

  @override
  String get playbackTitle => 'Wiedergabe';

  @override
  String get howTitle => 'So geht’s';

  @override
  String get how1 => 'Hol Songs aus der Dateien-App in die Kiste.';

  @override
  String get how2 =>
      'Bau ein Band: wähle eine Länge (C30 bis C120) und fülle Seite A und B – der Balken zeigt, wie viel Band noch frei ist.';

  @override
  String get how3 =>
      'Drück Play. Tippe Zurück oder Vor für den nächsten Song, halte die Tasten zum Spulen.';

  @override
  String get how4 =>
      'Schreib eine Widmung, druck die Hülle aus, verschenk das Band.';

  @override
  String get storageTitle => 'Speicher';

  @override
  String storageText(String mb) {
    return 'Die Songs in der App belegen $mb MB auf diesem iPhone. Löschst du einen Song in der Kiste, wird der Platz frei.';
  }

  @override
  String get aboutTitle => 'Info';

  @override
  String get footer =>
      'Bandsalat · kein Konto, kein Tracking, keine Werbung. Deine Musik bleibt auf deinem iPhone.';

  @override
  String get welcomeTitle => 'Bau ein Mixtape.\nWende es um.';

  @override
  String get welcomeSub =>
      'Such Songs aus deinen eigenen Dateien aus, fülle Seite A und B einer Kassette und spiel sie mit echten Rekorder-Tasten ab.';

  @override
  String get welcomeP1 =>
      '90 Minuten Band, zwei Seiten – ein Balken zeigt, was noch passt';

  @override
  String get welcomeP2 => 'Handgeschriebene Hülle zum Drucken oder Verschicken';

  @override
  String get welcomeP3 =>
      'Deine eigenen Dateien, kein Konto, keine Werbung – Apple-Music-Titel lassen sich nicht importieren';

  @override
  String get welcomeGo => 'Los geht’s';

  @override
  String get sampleTape1 => 'Sommer';

  @override
  String get sampleTape2 => 'Für dich';
}
