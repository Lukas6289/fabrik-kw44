// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kochmappe';

  @override
  String get tabBinder => 'Mappe';

  @override
  String get tabFridge => 'Vorrat';

  @override
  String get tabShopping => 'Einkauf';

  @override
  String get tabMore => 'Mehr';

  @override
  String get binderTitle => 'Meine Mappe';

  @override
  String recipesWord(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Titel, Zutat, Tag suchen …';

  @override
  String get clear => 'Löschen';

  @override
  String get tabAll => 'Alle';

  @override
  String get tabFavorites => 'Favoriten';

  @override
  String get newFolder => 'Neue Mappe';

  @override
  String get editFolder => 'Mappe ändern';

  @override
  String get deleteFolder => 'Mappe löschen';

  @override
  String get folderNameHint => 'z. B. Unter der Woche';

  @override
  String get colorWord => 'Farbe';

  @override
  String inFolder(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Rezepte in dieser Mappe',
      one: '1 Rezept in dieser Mappe',
      zero: 'Keine Rezepte in dieser Mappe',
    );
    return '$_temp0';
  }

  @override
  String get putInFolder => 'In eine Mappe legen';

  @override
  String get noFoldersYet => 'Noch keine Mappen – leg die erste an.';

  @override
  String get change => 'Ändern';

  @override
  String get ideaToday => 'Wie wäre es heute?';

  @override
  String get neverCooked => 'Noch nie gekocht';

  @override
  String lastCooked(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Vor $days Tagen gekocht',
      one: 'Gestern gekocht',
      zero: 'Heute gekocht',
    );
    return '$_temp0';
  }

  @override
  String lastCookedOn(String date) {
    return 'Zuletzt gekocht am $date';
  }

  @override
  String cookedTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n× gekocht',
      one: '1× gekocht',
    );
    return '$_temp0';
  }

  @override
  String get emptyBinderTitle => 'Deine Mappe ist leer';

  @override
  String get emptyBinderText =>
      'Speichere dein erstes Rezept aus einem Link, füge einen Text ein oder schreib es selbst auf.';

  @override
  String get emptyFolderTitle => 'Hier ist noch nichts';

  @override
  String get emptyFolderText => 'Öffne ein Rezept und leg es in diese Mappe.';

  @override
  String get noFavTitle => 'Noch keine Favoriten';

  @override
  String get noFavText =>
      'Tippe bei einem Rezept auf das Herz, dann findest du es hier.';

  @override
  String get noHitsTitle => 'Kein Rezept gefunden';

  @override
  String get noHitsText =>
      'Versuch ein anderes Wort – die Suche schaut in Titel, Zutaten, Tags und Notizen.';

  @override
  String get pickRecipeTitle => 'Wähle ein Rezept';

  @override
  String get pickRecipeText => 'Es öffnet sich hier neben deiner Liste.';

  @override
  String get addRecipe => 'Rezept hinzufügen';

  @override
  String get addFromLink => 'Aus einem Link';

  @override
  String get addFromLinkSub => 'Rezept von einer Webseite lesen';

  @override
  String get addFromText => 'Aus eingefügtem Text';

  @override
  String get addFromTextSub =>
      'Beschreibung, Nachricht oder Notiz – Zutaten werden erkannt';

  @override
  String get addByHand => 'Selbst schreiben';

  @override
  String get addByHandSub => 'Eigenes oder Familienrezept';

  @override
  String get modeLink => 'Link';

  @override
  String get modeText => 'Text';

  @override
  String get linkExplain =>
      'Füge die Adresse einer Rezeptseite ein. Kochmappe liest das Rezept direkt auf deinem Gerät und legt eine private Kopie an.';

  @override
  String get textExplain =>
      'Füge ein Rezept aus einer Video-Beschreibung, Nachricht oder Notiz ein. Zutaten und Schritte werden erkannt; danach kannst du alles korrigieren.';

  @override
  String get linkHint => 'https://…';

  @override
  String get textHint =>
      'Titel\nZutaten\n200 g Mehl\n2 Eier\nZubereitung\n1. Alles verrühren …';

  @override
  String get pasteFromClipboard => 'Aus der Zwischenablage einfügen';

  @override
  String get fetchRecipe => 'Rezept holen';

  @override
  String get recognize => 'Rezept erkennen';

  @override
  String get reading => 'Lese …';

  @override
  String get errBadLink => 'Das sieht nicht nach einer Webadresse aus.';

  @override
  String get errNetwork => 'Die Seite ließ sich nicht laden. Bist du online?';

  @override
  String get errNoRecipe => 'Auf dieser Seite wurde kein Rezept gefunden.';

  @override
  String get errNoRecipeText =>
      'In diesem Text wurden keine Zutaten oder Schritte gefunden.';

  @override
  String get errTryText =>
      'Manche Seiten verstecken ihr Rezept oder brauchen eine Anmeldung. Kopiere den Rezepttext von der Seite und füge ihn stattdessen ein.';

  @override
  String get switchToText => 'Stattdessen Text einfügen';

  @override
  String get importPrivacy =>
      'Die Seite wird direkt von deinem Gerät geholt. Kein Konto, kein Server von uns, nichts wird woandershin gesendet.';

  @override
  String get newRecipe => 'Neues Rezept';

  @override
  String get editRecipe => 'Rezept bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get back => 'Zurück';

  @override
  String get close => 'Schließen';

  @override
  String get dismiss => 'OK';

  @override
  String get photo => 'Foto';

  @override
  String get photoFromLibrary => 'Aus Fotos wählen';

  @override
  String get photoFromCamera => 'Foto aufnehmen';

  @override
  String get photoRemove => 'Foto entfernen';

  @override
  String get titleLabel => 'Titel';

  @override
  String get titleHint => 'z. B. Omas Pflaumenkuchen';

  @override
  String get needTitle => 'Gib dem Rezept bitte einen Titel.';

  @override
  String get prepMinLabel => 'Vorb., min';

  @override
  String get cookMinLabel => 'Kochen, min';

  @override
  String get ingredientsEditHint =>
      'Eine pro Zeile, z. B. „2 EL Olivenöl“. Eine Zeile mit „:“ am Ende beginnt eine Gruppe.';

  @override
  String get ingredientsExample => '200 g Mehl\n2 Eier\n1 Prise Salz';

  @override
  String get stepsEditHint => 'Ein Schritt pro Zeile.';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagsHint => 'Mit Komma getrennt, z. B. schnell, vegetarisch';

  @override
  String get notesHint => 'Woher es kommt, wer es mag …';

  @override
  String get notes => 'Notizen';

  @override
  String get favorite => 'Favorit';

  @override
  String prepTime(String t) {
    return 'Vorbereiten $t';
  }

  @override
  String cookTime(String t) {
    return 'Kochen $t';
  }

  @override
  String get cookMode => 'Kochmodus';

  @override
  String get toList => 'Zur Liste';

  @override
  String addedToList(int n) {
    return '$n Zutaten auf die Einkaufsliste gelegt';
  }

  @override
  String get ingredients => 'Zutaten';

  @override
  String get steps => 'Zubereitung';

  @override
  String get servingsLabel => 'Portionen';

  @override
  String get fewer => 'Weniger';

  @override
  String get more => 'Mehr';

  @override
  String get unitsMetricShort => 'g · ml';

  @override
  String get unitsUsShort => 'oz · cup';

  @override
  String get noIngredients =>
      'Noch keine Zutaten – tippe auf das Menü und wähle Bearbeiten.';

  @override
  String get noSteps => 'Noch keine Schritte.';

  @override
  String timerChip(String t) {
    return 'Timer $t';
  }

  @override
  String get myTwist => 'Mein Dreh';

  @override
  String get twistHint =>
      'Was änderst du? Weniger Zucker, mehr Knoblauch … getrennt vom Original.';

  @override
  String get diary => 'Koch-Tagebuch';

  @override
  String get cookedToday => 'Heute gekocht';

  @override
  String get diaryHint => 'Eine Notiz, z. B. „mehr Salz nötig“';

  @override
  String get shareText => 'Als Text teilen';

  @override
  String get pdfCard => 'Rezeptkarte (PDF)';

  @override
  String deleteRecipeTitle(String t) {
    return '„$t“ löschen?';
  }

  @override
  String get deleteRecipeText =>
      'Das Rezept wird von diesem Gerät entfernt. Eine gespeicherte Sicherung behält es.';

  @override
  String get smallerText => 'Kleinere Schrift';

  @override
  String get biggerText => 'Größere Schrift';

  @override
  String stepOf(int a, int b) {
    return 'SCHRITT $a VON $b';
  }

  @override
  String startTimer(String t) {
    return 'Timer starten: $t';
  }

  @override
  String timerDone(String t) {
    return 'Zeit ist um: $t';
  }

  @override
  String get previous => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get finishCooking => 'Fertig – eintragen';

  @override
  String ingredientsFor(int n) {
    return 'Zutaten für $n';
  }

  @override
  String get fridgeTitle => 'Was habe ich da?';

  @override
  String get fridgeSub =>
      'Tipp ein, was du in der Küche hast. Deine Rezepte, die es verwenden, erscheinen – mit dem, was noch fehlt.';

  @override
  String get fridgeHint => 'z. B. Eier, Spinat, Reis';

  @override
  String get clearAll => 'Alle entfernen';

  @override
  String get fridgeEmptyTitle => 'Leerer Kühlschrank, volle Mappe';

  @override
  String get fridgeEmptyText =>
      'Gib zwei, drei Zutaten ein und sieh, was du heute kochen kannst.';

  @override
  String get fridgeNoneTitle => 'Noch nichts passt';

  @override
  String get fridgeNoneText =>
      'Keines deiner Rezepte verwendet diese Zutaten. Versuch andere Wörter.';

  @override
  String fridgeMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Rezepte passen',
      one: '1 Rezept passt',
    );
    return '$_temp0';
  }

  @override
  String haveCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Zutaten da',
      one: '1 Zutat da',
    );
    return '$_temp0';
  }

  @override
  String get allThere => 'Alles da';

  @override
  String stillMissing(String t) {
    return 'Fehlt noch: $t';
  }

  @override
  String get shoppingTitle => 'Einkaufsliste';

  @override
  String get shoppingAddHint => 'Etwas hinzufügen';

  @override
  String get shoppingEmptyTitle => 'Nichts zu kaufen';

  @override
  String get shoppingEmptyText =>
      'Öffne ein Rezept und tippe auf „Zur Liste“ – gleiche Zutaten werden zusammengerechnet.';

  @override
  String get shoppingDone => 'Im Korb';

  @override
  String get removeDone => 'Entfernen';

  @override
  String get clearList => 'Liste leeren';

  @override
  String get unitsTitle => 'Maßeinheiten';

  @override
  String get unitsText =>
      'Mengen in Gramm und Millilitern oder in Unzen und Cups zeigen. Gilt für jedes Rezept.';

  @override
  String get themeTitle => 'Mappenfarbe';

  @override
  String get themeProHint =>
      'Safran ist gratis – weitere Farben gibt es mit Pro.';

  @override
  String get themeProOn => 'Wähle die Farbe deiner Mappe.';

  @override
  String get backupTitle => 'Sicherung';

  @override
  String get backupText =>
      'Deine Rezepte liegen nur auf diesem Gerät. Speichere ab und zu eine Sicherungsdatei (z. B. in iCloud Drive) – beim Zurückholen wird nichts überschrieben.';

  @override
  String get backupSave => 'Sicherung speichern';

  @override
  String get backupLoad => 'Sicherung laden';

  @override
  String get backupWord => 'sicherung';

  @override
  String get backupBad => 'Diese Datei ist keine Kochmappe-Sicherung.';

  @override
  String backupRestored(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Rezepte zurückgeholt',
      one: '1 Rezept zurückgeholt',
      zero: 'Nichts Neues in dieser Sicherung',
    );
    return '$_temp0';
  }

  @override
  String get cookbookTitle => 'Kochbuch';

  @override
  String get cookbookMake => 'Kochbuch erstellen (PDF)';

  @override
  String get cookbookSub => 'Alle Rezepte als ein druckbares Dokument';

  @override
  String get pdfContents => 'Inhalt';

  @override
  String get pdfBookTitle => 'Mein Kochbuch';

  @override
  String get pdfFileWord => 'kochbuch';

  @override
  String get aboutTitle => 'Über die App';

  @override
  String get terms => 'Nutzungsbedingungen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get contact => 'Support & Kontakt';

  @override
  String get deleteAll => 'Alle meine Daten löschen';

  @override
  String get deleteAllTitle => 'Alles löschen?';

  @override
  String get deleteAllText =>
      'Alle Rezepte, Mappen, Fotos und die Einkaufsliste werden von diesem Gerät entfernt. Das lässt sich nicht rückgängig machen.';

  @override
  String get footer =>
      'Alles bleibt auf deinem Gerät.\nKein Konto, kein Tracking, keine Werbung.';

  @override
  String get proCardTitle => 'Kochmappe Pro';

  @override
  String get proActive => 'Pro ist aktiv';

  @override
  String proCardSub(String p) {
    return 'Unbegrenzt Rezepte, PDF, Farben – einmalig $p';
  }

  @override
  String get proTitle => 'Kochmappe Pro';

  @override
  String get proLead =>
      'Ein Kauf, kein Abo. Alles, was du schon nutzt, bleibt gratis.';

  @override
  String proReasonRecipes(int n) {
    return 'Deine gratis Mappe fasst $n Rezepte. Mit Pro fällt die Grenze – für immer.';
  }

  @override
  String get proReasonPdf =>
      'Rezeptkarten und Kochbücher als PDF gehören zu Pro – ein Kauf, kein Abo.';

  @override
  String get proFeatUnlimited => 'Unbegrenzt Rezepte und Mappen';

  @override
  String get proFeatUnlimitedSub => 'Gratis sind 25 Rezepte und 3 Mappen.';

  @override
  String get proFeatPdf => 'Rezeptkarten & Kochbuch als PDF';

  @override
  String get proFeatPdfSub =>
      'Drucke eine Karte für den Kühlschrank oder binde alle Rezepte zu einem Buch.';

  @override
  String get proFeatThemes => 'Vier weitere Mappenfarben';

  @override
  String get proFeatThemesSub =>
      'Beere, Salbei, Himmel und Terrakotta neben Safran.';

  @override
  String get proFreeStays =>
      'Import, Portionsrechner, Kochmodus, Timer, Suche, Einkaufsliste und Sicherung bleiben gratis.';

  @override
  String get proOnce => 'einmalig · kein Abo';

  @override
  String proBuy(String p) {
    return 'Pro holen für $p';
  }

  @override
  String get proThanks => 'Danke – Pro ist freigeschaltet.';

  @override
  String get proPending => 'Wartet auf Freigabe („Kaufanfrage“).';

  @override
  String get proFailed =>
      'Das hat nicht geklappt. Bitte versuch es noch einmal.';

  @override
  String get proNothing =>
      'Für diese Apple-ID wurde kein früherer Kauf gefunden.';

  @override
  String get restore => 'Kauf wiederherstellen';

  @override
  String get welcomeTitle => 'Deine Rezepte,\nin einer Mappe.';

  @override
  String get welcomeSub =>
      'Speichere Rezepte aus dem Web, rechne sie um und koch Schritt für Schritt – auf iPhone und iPad.';

  @override
  String get welcomeP1 => 'Aus Link oder Text speichern';

  @override
  String get welcomeP2 => 'Kein Konto – alles bleibt auf deinem Gerät';

  @override
  String get welcomeP3 => 'Gratis nutzbar, Pro einmalig statt Abo';

  @override
  String get welcomeGo => 'Meine Mappe öffnen';
}
