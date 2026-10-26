import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bandsalat'**
  String get appTitle;

  /// No description provided for @tabShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get tabShelf;

  /// No description provided for @tabCrate.
  ///
  /// In en, this message translates to:
  /// **'Crate'**
  String get tabCrate;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @shelfTitle.
  ///
  /// In en, this message translates to:
  /// **'Your tapes'**
  String get shelfTitle;

  /// No description provided for @shelfSub.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 tape} other{{n} tapes}} · {time} of music'**
  String shelfSub(int n, String time);

  /// No description provided for @shelfSubEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet.'**
  String get shelfSubEmpty;

  /// No description provided for @newTape.
  ///
  /// In en, this message translates to:
  /// **'New tape'**
  String get newTape;

  /// No description provided for @lastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last played'**
  String get lastPlayed;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @rewind.
  ///
  /// In en, this message translates to:
  /// **'Rewind'**
  String get rewind;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Fast forward'**
  String get forward;

  /// No description provided for @flipTape.
  ///
  /// In en, this message translates to:
  /// **'Flip the tape'**
  String get flipTape;

  /// No description provided for @tapeSummary.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 song} other{{n} songs}} · {time}'**
  String tapeSummary(int n, String time);

  /// No description provided for @allTapes.
  ///
  /// In en, this message translates to:
  /// **'All tapes'**
  String get allTapes;

  /// No description provided for @emptyShelfTitle.
  ///
  /// In en, this message translates to:
  /// **'The shelf is empty'**
  String get emptyShelfTitle;

  /// No description provided for @emptyShelfBody.
  ///
  /// In en, this message translates to:
  /// **'Collect songs in the crate, then record your first mixtape: 90 minutes, two sides, your handwriting.'**
  String get emptyShelfBody;

  /// No description provided for @sideLabel.
  ///
  /// In en, this message translates to:
  /// **'Side {side}'**
  String sideLabel(String side);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get more;

  /// No description provided for @editTape.
  ///
  /// In en, this message translates to:
  /// **'Edit tape'**
  String get editTape;

  /// No description provided for @endOfSideFlip.
  ///
  /// In en, this message translates to:
  /// **'Side A is over – flip the tape for side B.'**
  String get endOfSideFlip;

  /// No description provided for @endOfTape.
  ///
  /// In en, this message translates to:
  /// **'End of the tape.'**
  String get endOfTape;

  /// No description provided for @autoFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip automatically'**
  String get autoFlip;

  /// No description provided for @autoFlipSub.
  ///
  /// In en, this message translates to:
  /// **'After side A, side B starts by itself.'**
  String get autoFlipSub;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @sleepBody.
  ///
  /// In en, this message translates to:
  /// **'The tape runs out: the last 20 seconds fade away, then it stops.'**
  String get sleepBody;

  /// No description provided for @sleepEndOfSide.
  ///
  /// In en, this message translates to:
  /// **'End of side'**
  String get sleepEndOfSide;

  /// No description provided for @sleepOff.
  ///
  /// In en, this message translates to:
  /// **'Switch off'**
  String get sleepOff;

  /// No description provided for @sleepLeft.
  ///
  /// In en, this message translates to:
  /// **'{min} min left'**
  String sleepLeft(int min);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{m} min'**
  String minutesShort(int m);

  /// No description provided for @hoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{h} h {m} min'**
  String hoursMinutes(int h, int m);

  /// No description provided for @positionOnSide.
  ///
  /// In en, this message translates to:
  /// **'Position on this side'**
  String get positionOnSide;

  /// No description provided for @sideEmpty.
  ///
  /// In en, this message translates to:
  /// **'Side {side} is empty. Add songs in the tape editor.'**
  String sideEmpty(String side);

  /// No description provided for @jcardShort.
  ///
  /// In en, this message translates to:
  /// **'Case card'**
  String get jcardShort;

  /// No description provided for @jcardTitle.
  ///
  /// In en, this message translates to:
  /// **'Case card'**
  String get jcardTitle;

  /// No description provided for @jcardBody.
  ///
  /// In en, this message translates to:
  /// **'The inlay of your tape, hand-lettered: both sides, all songs, times. Print it or send it along with the tape.'**
  String get jcardBody;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share as picture'**
  String get shareImage;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share as PDF to print'**
  String get sharePdf;

  /// No description provided for @sharePdfPro.
  ///
  /// In en, this message translates to:
  /// **'PDF to print (Pro)'**
  String get sharePdfPro;

  /// No description provided for @stampNote.
  ///
  /// In en, this message translates to:
  /// **'Free: a small stamp on the card. Pro: no stamp, plus the PDF.'**
  String get stampNote;

  /// No description provided for @stampText.
  ///
  /// In en, this message translates to:
  /// **'made with Bandsalat'**
  String get stampText;

  /// No description provided for @untitledTape.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitledTape;

  /// No description provided for @tapeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name of the tape'**
  String get tapeNameHint;

  /// No description provided for @dedicationHint.
  ///
  /// In en, this message translates to:
  /// **'Handwritten dedication, e.g. For Mia, summer ’26'**
  String get dedicationHint;

  /// No description provided for @tapeLength.
  ///
  /// In en, this message translates to:
  /// **'Tape length'**
  String get tapeLength;

  /// No description provided for @shellColour.
  ///
  /// In en, this message translates to:
  /// **'Shell colour'**
  String get shellColour;

  /// No description provided for @labelStyle.
  ///
  /// In en, this message translates to:
  /// **'Label design'**
  String get labelStyle;

  /// No description provided for @tapeLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} of tape left'**
  String tapeLeft(String time);

  /// No description provided for @tapeOver.
  ///
  /// In en, this message translates to:
  /// **'{time} too long'**
  String tapeOver(String time);

  /// No description provided for @sideEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet – add songs.'**
  String get sideEmptyHint;

  /// No description provided for @otherSide.
  ///
  /// In en, this message translates to:
  /// **'Move to side {side}'**
  String otherSide(String side);

  /// No description provided for @removeFromTape.
  ///
  /// In en, this message translates to:
  /// **'Remove from tape'**
  String get removeFromTape;

  /// No description provided for @addSongs.
  ///
  /// In en, this message translates to:
  /// **'Add songs'**
  String get addSongs;

  /// No description provided for @addToSide.
  ///
  /// In en, this message translates to:
  /// **'Add to side {side}'**
  String addToSide(String side);

  /// No description provided for @allSongsUsed.
  ///
  /// In en, this message translates to:
  /// **'All songs of your crate are already on this tape. Get more first.'**
  String get allSongsUsed;

  /// No description provided for @tooLong.
  ///
  /// In en, this message translates to:
  /// **'too long'**
  String get tooLong;

  /// No description provided for @importMore.
  ///
  /// In en, this message translates to:
  /// **'More songs'**
  String get importMore;

  /// No description provided for @addCount.
  ///
  /// In en, this message translates to:
  /// **'Add {n}'**
  String addCount(int n);

  /// No description provided for @didNotFit.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 song doesn’t fit} other{{n} songs don’t fit}} on this side.'**
  String didNotFit(int n);

  /// No description provided for @fillSides.
  ///
  /// In en, this message translates to:
  /// **'Fill the sides automatically'**
  String get fillSides;

  /// No description provided for @deleteTape.
  ///
  /// In en, this message translates to:
  /// **'Delete this tape'**
  String get deleteTape;

  /// No description provided for @deleteTapeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteTapeTitle(String name);

  /// No description provided for @deleteTapeBody.
  ///
  /// In en, this message translates to:
  /// **'The tape is removed. Your songs stay in the crate.'**
  String get deleteTapeBody;

  /// No description provided for @crateTitle.
  ///
  /// In en, this message translates to:
  /// **'Crate'**
  String get crateTitle;

  /// No description provided for @crateSub.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 song} other{{n} songs}} · {time}'**
  String crateSub(int n, String time);

  /// No description provided for @crateSubEmpty.
  ///
  /// In en, this message translates to:
  /// **'No songs yet.'**
  String get crateSubEmpty;

  /// No description provided for @importSongs.
  ///
  /// In en, this message translates to:
  /// **'Get songs from Files'**
  String get importSongs;

  /// No description provided for @importHint.
  ///
  /// In en, this message translates to:
  /// **'MP3, M4A, WAV, AIFF, FLAC … from the Files app, iCloud Drive or AirDrop. They are copied into the app – your originals stay untouched.'**
  String get importHint;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 song} other{{n} songs}} added.'**
  String importDone(int n);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 file} other{{n} files}} could not be read (copy-protected or not audio).'**
  String importFailed(int n);

  /// No description provided for @emptyCrateTitle.
  ///
  /// In en, this message translates to:
  /// **'The crate is empty'**
  String get emptyCrateTitle;

  /// No description provided for @emptyCrateBody.
  ///
  /// In en, this message translates to:
  /// **'Bring in the songs you own as files. Then you sort them onto tapes.'**
  String get emptyCrateBody;

  /// No description provided for @allSongs.
  ///
  /// In en, this message translates to:
  /// **'All songs'**
  String get allSongs;

  /// No description provided for @onTapes.
  ///
  /// In en, this message translates to:
  /// **'on {n, plural, =1{1 tape} other{{n} tapes}}'**
  String onTapes(int n);

  /// No description provided for @ownFilesNote.
  ///
  /// In en, this message translates to:
  /// **'Bandsalat plays your own audio files. Songs from streaming services such as Apple Music are copy-protected and cannot be imported.'**
  String get ownFilesNote;

  /// No description provided for @deleteSongTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”?'**
  String deleteSongTitle(String title);

  /// No description provided for @deleteSongBody.
  ///
  /// In en, this message translates to:
  /// **'The song is removed from the app.'**
  String get deleteSongBody;

  /// No description provided for @deleteSongBodyUsed.
  ///
  /// In en, this message translates to:
  /// **'The song is removed from the app and from {n, plural, =1{1 tape} other{{n} tapes}}.'**
  String deleteSongBodyUsed(int n);

  /// No description provided for @proLead.
  ///
  /// In en, this message translates to:
  /// **'One purchase, yours for good: unlimited tapes, every colour, the case card without stamp.'**
  String get proLead;

  /// No description provided for @proReasonTapes.
  ///
  /// In en, this message translates to:
  /// **'The free shelf holds {n} tapes. With Pro it holds as many as you like.'**
  String proReasonTapes(int n);

  /// No description provided for @proReasonStyles.
  ///
  /// In en, this message translates to:
  /// **'More colours and label designs are part of Pro.'**
  String get proReasonStyles;

  /// No description provided for @proReasonPdf.
  ///
  /// In en, this message translates to:
  /// **'The printable PDF is part of Pro.'**
  String get proReasonPdf;

  /// No description provided for @proFeatTapes.
  ///
  /// In en, this message translates to:
  /// **'Unlimited tapes'**
  String get proFeatTapes;

  /// No description provided for @proFeatTapesSub.
  ///
  /// In en, this message translates to:
  /// **'Free: {n} tapes. Pro: your whole record collection.'**
  String proFeatTapesSub(int n);

  /// No description provided for @proFeatLooks.
  ///
  /// In en, this message translates to:
  /// **'8 colours, 8 label designs'**
  String get proFeatLooks;

  /// No description provided for @proFeatLooksSub.
  ///
  /// In en, this message translates to:
  /// **'Free: 3 of each. Pro: all of them, mixed as you like.'**
  String get proFeatLooksSub;

  /// No description provided for @proFeatCard.
  ///
  /// In en, this message translates to:
  /// **'Case card, print-ready'**
  String get proFeatCard;

  /// No description provided for @proFeatCardSub.
  ///
  /// In en, this message translates to:
  /// **'No stamp, plus a PDF you can print and cut out.'**
  String get proFeatCardSub;

  /// No description provided for @proFreeStays.
  ///
  /// In en, this message translates to:
  /// **'Playing, sleep timer, crate and both sides stay free – always. No subscription, no ads.'**
  String get proFreeStays;

  /// No description provided for @proOnce.
  ///
  /// In en, this message translates to:
  /// **'once – no subscription'**
  String get proOnce;

  /// No description provided for @proBuy.
  ///
  /// In en, this message translates to:
  /// **'Get Pro for {price}'**
  String proBuy(String price);

  /// No description provided for @proThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Pro is unlocked.'**
  String get proThanks;

  /// No description provided for @proPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval …'**
  String get proPending;

  /// No description provided for @proFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Please try again.'**
  String get proFailed;

  /// No description provided for @proNothing.
  ///
  /// In en, this message translates to:
  /// **'No purchase found to restore.'**
  String get proNothing;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get restore;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @proActive.
  ///
  /// In en, this message translates to:
  /// **'Pro is active'**
  String get proActive;

  /// No description provided for @proCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Bandsalat Pro'**
  String get proCardTitle;

  /// No description provided for @proCardSub.
  ///
  /// In en, this message translates to:
  /// **'Unlimited tapes, all looks, case card as PDF – {price} once, no subscription.'**
  String proCardSub(String price);

  /// No description provided for @playbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playbackTitle;

  /// No description provided for @howTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howTitle;

  /// No description provided for @how1.
  ///
  /// In en, this message translates to:
  /// **'Get songs from the Files app into the crate.'**
  String get how1;

  /// No description provided for @how2.
  ///
  /// In en, this message translates to:
  /// **'Make a tape: pick a length (C30 to C120) and fill sides A and B – the bar shows how much tape is left.'**
  String get how2;

  /// No description provided for @how3.
  ///
  /// In en, this message translates to:
  /// **'Press play. Tap rewind or forward to skip songs, hold them to spool.'**
  String get how3;

  /// No description provided for @how4.
  ///
  /// In en, this message translates to:
  /// **'Write a dedication, print the case card, give the tape away.'**
  String get how4;

  /// No description provided for @storageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageTitle;

  /// No description provided for @storageText.
  ///
  /// In en, this message translates to:
  /// **'The songs in the app take {mb} MB on this iPhone. Deleting a song in the crate frees the space.'**
  String storageText(String mb);

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @footer.
  ///
  /// In en, this message translates to:
  /// **'Bandsalat · no account, no tracking, no ads. Your music stays on your iPhone.'**
  String get footer;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Build a mixtape.\nFlip it over.'**
  String get welcomeTitle;

  /// No description provided for @welcomeSub.
  ///
  /// In en, this message translates to:
  /// **'Pick songs from your own files, fill side A and B of a cassette and play it with real tape-deck keys.'**
  String get welcomeSub;

  /// No description provided for @welcomeP1.
  ///
  /// In en, this message translates to:
  /// **'90 minutes of tape, two sides – a bar shows what still fits'**
  String get welcomeP1;

  /// No description provided for @welcomeP2.
  ///
  /// In en, this message translates to:
  /// **'Hand-lettered case card to print or send'**
  String get welcomeP2;

  /// No description provided for @welcomeP3.
  ///
  /// In en, this message translates to:
  /// **'Your own files, no account, no ads – Apple Music tracks cannot be imported'**
  String get welcomeP3;

  /// No description provided for @welcomeGo.
  ///
  /// In en, this message translates to:
  /// **'Let’s go'**
  String get welcomeGo;

  /// No description provided for @sampleTape1.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get sampleTape1;

  /// No description provided for @sampleTape2.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get sampleTape2;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return LDe();
    case 'en':
      return LEn();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
