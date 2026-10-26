// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bandsalat';

  @override
  String get tabShelf => 'Shelf';

  @override
  String get tabCrate => 'Crate';

  @override
  String get tabMore => 'More';

  @override
  String get shelfTitle => 'Your tapes';

  @override
  String shelfSub(int n, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tapes',
      one: '1 tape',
    );
    return '$_temp0 · $time of music';
  }

  @override
  String get shelfSubEmpty => 'Nothing recorded yet.';

  @override
  String get newTape => 'New tape';

  @override
  String get lastPlayed => 'Last played';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stop';

  @override
  String get rewind => 'Rewind';

  @override
  String get forward => 'Fast forward';

  @override
  String get flipTape => 'Flip the tape';

  @override
  String tapeSummary(int n, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n songs',
      one: '1 song',
    );
    return '$_temp0 · $time';
  }

  @override
  String get allTapes => 'All tapes';

  @override
  String get emptyShelfTitle => 'The shelf is empty';

  @override
  String get emptyShelfBody =>
      'Collect songs in the crate, then record your first mixtape: 90 minutes, two sides, your handwriting.';

  @override
  String sideLabel(String side) {
    return 'Side $side';
  }

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get delete => 'Delete';

  @override
  String get rename => 'Rename';

  @override
  String get more => 'More options';

  @override
  String get editTape => 'Edit tape';

  @override
  String get endOfSideFlip => 'Side A is over – flip the tape for side B.';

  @override
  String get endOfTape => 'End of the tape.';

  @override
  String get autoFlip => 'Flip automatically';

  @override
  String get autoFlipSub => 'After side A, side B starts by itself.';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get sleepBody =>
      'The tape runs out: the last 20 seconds fade away, then it stops.';

  @override
  String get sleepEndOfSide => 'End of side';

  @override
  String get sleepOff => 'Switch off';

  @override
  String sleepLeft(int min) {
    return '$min min left';
  }

  @override
  String minutesShort(int m) {
    return '$m min';
  }

  @override
  String hoursMinutes(int h, int m) {
    return '$h h $m min';
  }

  @override
  String get positionOnSide => 'Position on this side';

  @override
  String sideEmpty(String side) {
    return 'Side $side is empty. Add songs in the tape editor.';
  }

  @override
  String get jcardShort => 'Case card';

  @override
  String get jcardTitle => 'Case card';

  @override
  String get jcardBody =>
      'The inlay of your tape, hand-lettered: both sides, all songs, times. Print it or send it along with the tape.';

  @override
  String get shareImage => 'Share as picture';

  @override
  String get sharePdf => 'Share as PDF to print';

  @override
  String get sharePdfPro => 'PDF to print (Pro)';

  @override
  String get stampNote =>
      'Free: a small stamp on the card. Pro: no stamp, plus the PDF.';

  @override
  String get stampText => 'made with Bandsalat';

  @override
  String get untitledTape => 'Untitled';

  @override
  String get tapeNameHint => 'Name of the tape';

  @override
  String get dedicationHint =>
      'Handwritten dedication, e.g. For Mia, summer ’26';

  @override
  String get tapeLength => 'Tape length';

  @override
  String get shellColour => 'Shell colour';

  @override
  String get labelStyle => 'Label design';

  @override
  String tapeLeft(String time) {
    return '$time of tape left';
  }

  @override
  String tapeOver(String time) {
    return '$time too long';
  }

  @override
  String get sideEmptyHint => 'Nothing here yet – add songs.';

  @override
  String otherSide(String side) {
    return 'Move to side $side';
  }

  @override
  String get removeFromTape => 'Remove from tape';

  @override
  String get addSongs => 'Add songs';

  @override
  String addToSide(String side) {
    return 'Add to side $side';
  }

  @override
  String get allSongsUsed =>
      'All songs of your crate are already on this tape. Get more first.';

  @override
  String get tooLong => 'too long';

  @override
  String get importMore => 'More songs';

  @override
  String addCount(int n) {
    return 'Add $n';
  }

  @override
  String didNotFit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n songs don’t fit',
      one: '1 song doesn’t fit',
    );
    return '$_temp0 on this side.';
  }

  @override
  String get fillSides => 'Fill the sides automatically';

  @override
  String get deleteTape => 'Delete this tape';

  @override
  String deleteTapeTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get deleteTapeBody =>
      'The tape is removed. Your songs stay in the crate.';

  @override
  String get crateTitle => 'Crate';

  @override
  String crateSub(int n, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n songs',
      one: '1 song',
    );
    return '$_temp0 · $time';
  }

  @override
  String get crateSubEmpty => 'No songs yet.';

  @override
  String get importSongs => 'Get songs from Files';

  @override
  String get importHint =>
      'MP3, M4A, WAV, AIFF, FLAC … from the Files app, iCloud Drive or AirDrop. They are copied into the app – your originals stay untouched.';

  @override
  String importDone(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n songs',
      one: '1 song',
    );
    return '$_temp0 added.';
  }

  @override
  String importFailed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n files',
      one: '1 file',
    );
    return '$_temp0 could not be read (copy-protected or not audio).';
  }

  @override
  String get emptyCrateTitle => 'The crate is empty';

  @override
  String get emptyCrateBody =>
      'Bring in the songs you own as files. Then you sort them onto tapes.';

  @override
  String get allSongs => 'All songs';

  @override
  String onTapes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tapes',
      one: '1 tape',
    );
    return 'on $_temp0';
  }

  @override
  String get ownFilesNote =>
      'Bandsalat plays your own audio files. Songs from streaming services such as Apple Music are copy-protected and cannot be imported.';

  @override
  String deleteSongTitle(String title) {
    return 'Delete “$title”?';
  }

  @override
  String get deleteSongBody => 'The song is removed from the app.';

  @override
  String deleteSongBodyUsed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tapes',
      one: '1 tape',
    );
    return 'The song is removed from the app and from $_temp0.';
  }

  @override
  String get proLead =>
      'One purchase, yours for good: unlimited tapes, every colour, the case card without stamp.';

  @override
  String proReasonTapes(int n) {
    return 'The free shelf holds $n tapes. With Pro it holds as many as you like.';
  }

  @override
  String get proReasonStyles =>
      'More colours and label designs are part of Pro.';

  @override
  String get proReasonPdf => 'The printable PDF is part of Pro.';

  @override
  String get proFeatTapes => 'Unlimited tapes';

  @override
  String proFeatTapesSub(int n) {
    return 'Free: $n tapes. Pro: your whole record collection.';
  }

  @override
  String get proFeatLooks => '8 colours, 8 label designs';

  @override
  String get proFeatLooksSub =>
      'Free: 3 of each. Pro: all of them, mixed as you like.';

  @override
  String get proFeatCard => 'Case card, print-ready';

  @override
  String get proFeatCardSub =>
      'No stamp, plus a PDF you can print and cut out.';

  @override
  String get proFreeStays =>
      'Playing, sleep timer, crate and both sides stay free – always. No subscription, no ads.';

  @override
  String get proOnce => 'once – no subscription';

  @override
  String proBuy(String price) {
    return 'Get Pro for $price';
  }

  @override
  String get proThanks => 'Thank you! Pro is unlocked.';

  @override
  String get proPending => 'Waiting for approval …';

  @override
  String get proFailed => 'That did not work. Please try again.';

  @override
  String get proNothing => 'No purchase found to restore.';

  @override
  String get restore => 'Restore purchase';

  @override
  String get terms => 'Terms of Use';

  @override
  String get privacy => 'Privacy';

  @override
  String get support => 'Support';

  @override
  String get proActive => 'Pro is active';

  @override
  String get proCardTitle => 'Bandsalat Pro';

  @override
  String proCardSub(String price) {
    return 'Unlimited tapes, all looks, case card as PDF – $price once, no subscription.';
  }

  @override
  String get playbackTitle => 'Playback';

  @override
  String get howTitle => 'How it works';

  @override
  String get how1 => 'Get songs from the Files app into the crate.';

  @override
  String get how2 =>
      'Make a tape: pick a length (C30 to C120) and fill sides A and B – the bar shows how much tape is left.';

  @override
  String get how3 =>
      'Press play. Tap rewind or forward to skip songs, hold them to spool.';

  @override
  String get how4 =>
      'Write a dedication, print the case card, give the tape away.';

  @override
  String get storageTitle => 'Storage';

  @override
  String storageText(String mb) {
    return 'The songs in the app take $mb MB on this iPhone. Deleting a song in the crate frees the space.';
  }

  @override
  String get aboutTitle => 'About';

  @override
  String get footer =>
      'Bandsalat · no account, no tracking, no ads. Your music stays on your iPhone.';

  @override
  String get welcomeTitle => 'Build a mixtape.\nFlip it over.';

  @override
  String get welcomeSub =>
      'Pick songs from your own files, fill side A and B of a cassette and play it with real tape-deck keys.';

  @override
  String get welcomeP1 =>
      '90 minutes of tape, two sides – a bar shows what still fits';

  @override
  String get welcomeP2 => 'Hand-lettered case card to print or send';

  @override
  String get welcomeP3 =>
      'Your own files, no account, no ads – Apple Music tracks cannot be imported';

  @override
  String get welcomeGo => 'Let’s go';

  @override
  String get sampleTape1 => 'Summer';

  @override
  String get sampleTape2 => 'For you';
}
