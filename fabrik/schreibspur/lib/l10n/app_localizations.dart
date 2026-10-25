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
  /// **'Schreibspur'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your chat in numbers – 100 % on your phone.'**
  String get tagline;

  /// No description provided for @loadChat.
  ///
  /// In en, this message translates to:
  /// **'Choose exported chat'**
  String get loadChat;

  /// No description provided for @pasteChat.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteChat;

  /// No description provided for @tryExample.
  ///
  /// In en, this message translates to:
  /// **'Try an example'**
  String get tryExample;

  /// No description provided for @offlineProof.
  ///
  /// In en, this message translates to:
  /// **'Nothing leaves your phone. Try it: switch on airplane mode – Schreibspur works the same.'**
  String get offlineProof;

  /// No description provided for @howToTitle.
  ///
  /// In en, this message translates to:
  /// **'How to export a chat'**
  String get howToTitle;

  /// No description provided for @howToIos.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp → open the chat → tap the name at the top → Export Chat → Without Media → tap Schreibspur in the share sheet. Done – the recap opens right away.'**
  String get howToIos;

  /// No description provided for @howToAndroid.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp → open the chat → ⋮ → More → Export chat → Without media → save to Files.'**
  String get howToAndroid;

  /// No description provided for @errorNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages found. Please choose a chat exported from WhatsApp (.txt or .zip).'**
  String get errorNoMessages;

  /// No description provided for @errorRead.
  ///
  /// In en, this message translates to:
  /// **'The file could not be read.'**
  String get errorRead;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'The clipboard is empty.'**
  String get clipboardEmpty;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'Another chat'**
  String get newChat;

  /// No description provided for @exampleBadge.
  ///
  /// In en, this message translates to:
  /// **'Example – made-up people'**
  String get exampleBadge;

  /// No description provided for @chatPeriod.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String chatPeriod(String from, String to);

  /// No description provided for @labelMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get labelMessages;

  /// No description provided for @labelDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get labelDays;

  /// No description provided for @labelActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get labelActiveDays;

  /// No description provided for @labelPerDay.
  ///
  /// In en, this message translates to:
  /// **'Per day'**
  String get labelPerDay;

  /// No description provided for @labelWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get labelWords;

  /// No description provided for @labelWordsPerMessage.
  ///
  /// In en, this message translates to:
  /// **'Words per message'**
  String get labelWordsPerMessage;

  /// No description provided for @labelPhotosEtc.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get labelPhotosEtc;

  /// No description provided for @cardOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get cardOverview;

  /// No description provided for @cardRhythm.
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get cardRhythm;

  /// No description provided for @cardWords.
  ///
  /// In en, this message translates to:
  /// **'Favourite words'**
  String get cardWords;

  /// No description provided for @cardReplies.
  ///
  /// In en, this message translates to:
  /// **'Reply time'**
  String get cardReplies;

  /// No description provided for @cardStarters.
  ///
  /// In en, this message translates to:
  /// **'Who starts the talk'**
  String get cardStarters;

  /// No description provided for @cardEmoji.
  ///
  /// In en, this message translates to:
  /// **'Favourite emoji'**
  String get cardEmoji;

  /// No description provided for @cardRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get cardRecords;

  /// No description provided for @cardAwards.
  ///
  /// In en, this message translates to:
  /// **'Awards'**
  String get cardAwards;

  /// No description provided for @cardCompare.
  ///
  /// In en, this message translates to:
  /// **'Then vs. now'**
  String get cardCompare;

  /// No description provided for @rhythmHour.
  ///
  /// In en, this message translates to:
  /// **'Busiest hour: {hour}'**
  String rhythmHour(String hour);

  /// No description provided for @rhythmDay.
  ///
  /// In en, this message translates to:
  /// **'Busiest day of the week: {day}'**
  String rhythmDay(String day);

  /// No description provided for @hourRange.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to} h'**
  String hourRange(int from, int to);

  /// No description provided for @wordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not enough text yet.'**
  String get wordsEmpty;

  /// No description provided for @wordsMore.
  ///
  /// In en, this message translates to:
  /// **'+ more words with Pro'**
  String get wordsMore;

  /// No description provided for @timesUsed.
  ///
  /// In en, this message translates to:
  /// **'{count}×'**
  String timesUsed(int count);

  /// No description provided for @repliesHint.
  ///
  /// In en, this message translates to:
  /// **'Median time until the other person answers (up to 6 hours).'**
  String get repliesHint;

  /// No description provided for @startersHint.
  ///
  /// In en, this message translates to:
  /// **'Opens a new talk after at least 6 hours of silence.'**
  String get startersHint;

  /// No description provided for @startsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} talks'**
  String startsCount(int count);

  /// No description provided for @noEmoji.
  ///
  /// In en, this message translates to:
  /// **'No emoji found.'**
  String get noEmoji;

  /// No description provided for @recordBusiestDay.
  ///
  /// In en, this message translates to:
  /// **'Busiest day'**
  String get recordBusiestDay;

  /// No description provided for @recordBusiestDayValue.
  ///
  /// In en, this message translates to:
  /// **'{date} · {count} messages'**
  String recordBusiestDayValue(String date, int count);

  /// No description provided for @recordPause.
  ///
  /// In en, this message translates to:
  /// **'Longest silence'**
  String get recordPause;

  /// No description provided for @recordPauseValue.
  ///
  /// In en, this message translates to:
  /// **'{duration}, from {date}'**
  String recordPauseValue(String duration, String date);

  /// No description provided for @recordStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get recordStreak;

  /// No description provided for @recordStreakValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days in a row'**
  String recordStreakValue(int days);

  /// No description provided for @durUnderMinute.
  ///
  /// In en, this message translates to:
  /// **'under 1 min'**
  String get durUnderMinute;

  /// No description provided for @durMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m} min'**
  String durMinutes(int m);

  /// No description provided for @durHours.
  ///
  /// In en, this message translates to:
  /// **'{h} h {m} min'**
  String durHours(int h, int m);

  /// No description provided for @durDays.
  ///
  /// In en, this message translates to:
  /// **'{d} d {h} h'**
  String durDays(int d, int h);

  /// No description provided for @awardMost.
  ///
  /// In en, this message translates to:
  /// **'Chatterbox'**
  String get awardMost;

  /// No description provided for @awardMostText.
  ///
  /// In en, this message translates to:
  /// **'Writes the most messages'**
  String get awardMostText;

  /// No description provided for @awardFast.
  ///
  /// In en, this message translates to:
  /// **'Speedy'**
  String get awardFast;

  /// No description provided for @awardFastText.
  ///
  /// In en, this message translates to:
  /// **'Answers fastest'**
  String get awardFastText;

  /// No description provided for @awardStarter.
  ///
  /// In en, this message translates to:
  /// **'Ice breaker'**
  String get awardStarter;

  /// No description provided for @awardStarterText.
  ///
  /// In en, this message translates to:
  /// **'Starts most talks'**
  String get awardStarterText;

  /// No description provided for @awardNovel.
  ///
  /// In en, this message translates to:
  /// **'Novelist'**
  String get awardNovel;

  /// No description provided for @awardNovelText.
  ///
  /// In en, this message translates to:
  /// **'Longest messages'**
  String get awardNovelText;

  /// No description provided for @awardOwl.
  ///
  /// In en, this message translates to:
  /// **'Night owl'**
  String get awardOwl;

  /// No description provided for @awardOwlText.
  ///
  /// In en, this message translates to:
  /// **'Most messages after midnight'**
  String get awardOwlText;

  /// No description provided for @compareNeedMore.
  ///
  /// In en, this message translates to:
  /// **'Needs at least two weeks of chat to compare.'**
  String get compareNeedMore;

  /// No description provided for @compareBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get compareBefore;

  /// No description provided for @compareNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get compareNow;

  /// No description provided for @compareChange.
  ///
  /// In en, this message translates to:
  /// **'{percent} messages'**
  String compareChange(String percent);

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Part of Pro'**
  String get locked;

  /// No description provided for @lockedTap.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Pro'**
  String get lockedTap;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share as image'**
  String get share;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Made with Schreibspur'**
  String get shareText;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Sharing did not work.'**
  String get shareFailed;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your chat is read on this phone and not saved: close the app and it is gone. No account, no internet access, no tracking.'**
  String get aboutPrivacy;

  /// No description provided for @proTitle.
  ///
  /// In en, this message translates to:
  /// **'Schreibspur Pro'**
  String get proTitle;

  /// No description provided for @proTagline.
  ///
  /// In en, this message translates to:
  /// **'Every card, every comparison, shareable.'**
  String get proTagline;

  /// No description provided for @proFeatureCards.
  ///
  /// In en, this message translates to:
  /// **'All cards: reply time, who starts, emoji, records'**
  String get proFeatureCards;

  /// No description provided for @proFeatureAwards.
  ///
  /// In en, this message translates to:
  /// **'Awards for groups: chatterbox, speedy, night owl'**
  String get proFeatureAwards;

  /// No description provided for @proFeatureCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare two periods – this year vs. last year'**
  String get proFeatureCompare;

  /// No description provided for @proFeatureWords.
  ///
  /// In en, this message translates to:
  /// **'{count} favourite words instead of {free}'**
  String proFeatureWords(int count, int free);

  /// No description provided for @proFeatureShare.
  ///
  /// In en, this message translates to:
  /// **'Share every card as an image'**
  String get proFeatureShare;

  /// No description provided for @proYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get proYearly;

  /// No description provided for @proYearlyDetail.
  ///
  /// In en, this message translates to:
  /// **'{price} per year · renews automatically'**
  String proYearlyDetail(String price);

  /// No description provided for @proLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get proLifetime;

  /// No description provided for @proLifetimeDetail.
  ///
  /// In en, this message translates to:
  /// **'{price} once · no subscription'**
  String proLifetimeDetail(String price);

  /// No description provided for @proBuy.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get proBuy;

  /// No description provided for @proRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get proRestore;

  /// No description provided for @proActive.
  ///
  /// In en, this message translates to:
  /// **'Pro is active – thank you!'**
  String get proActive;

  /// No description provided for @proPending.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is waiting for approval.'**
  String get proPending;

  /// No description provided for @proFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase did not go through. Please try again.'**
  String get proFailed;

  /// No description provided for @proNothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found.'**
  String get proNothingToRestore;

  /// No description provided for @proStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The App Store is not reachable right now.'**
  String get proStoreUnavailable;

  /// No description provided for @proSubscriptionNote.
  ///
  /// In en, this message translates to:
  /// **'The yearly subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Payment is charged to your Apple ID. Manage or cancel it in your Apple ID settings.'**
  String get proSubscriptionNote;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @cardCloud.
  ///
  /// In en, this message translates to:
  /// **'Word cloud'**
  String get cardCloud;

  /// No description provided for @cloudHint.
  ///
  /// In en, this message translates to:
  /// **'The bigger, the more often. Colour = who writes it most.'**
  String get cloudHint;

  /// No description provided for @cardYear.
  ///
  /// In en, this message translates to:
  /// **'Chat year'**
  String get cardYear;

  /// No description provided for @yearSummary.
  ///
  /// In en, this message translates to:
  /// **'{active} of {days} days with messages'**
  String yearSummary(int active, int days);

  /// No description provided for @yearLess.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get yearLess;

  /// No description provided for @yearMore.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get yearMore;

  /// No description provided for @posterButton.
  ///
  /// In en, this message translates to:
  /// **'Create poster'**
  String get posterButton;

  /// No description provided for @posterTitle.
  ///
  /// In en, this message translates to:
  /// **'Poster'**
  String get posterTitle;

  /// No description provided for @posterShare.
  ///
  /// In en, this message translates to:
  /// **'Share poster'**
  String get posterShare;

  /// No description provided for @posterHint.
  ///
  /// In en, this message translates to:
  /// **'All cards in one image – share it or save it to Photos.'**
  String get posterHint;

  /// No description provided for @posterMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with Schreibspur · analysed offline'**
  String get posterMadeWith;

  /// No description provided for @proFeatureImages.
  ///
  /// In en, this message translates to:
  /// **'Poster with all cards, word cloud and chat year'**
  String get proFeatureImages;

  /// No description provided for @storyPlay.
  ///
  /// In en, this message translates to:
  /// **'Play your recap'**
  String get storyPlay;

  /// No description provided for @storyIntroKicker.
  ///
  /// In en, this message translates to:
  /// **'Your chat'**
  String get storyIntroKicker;

  /// No description provided for @storyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'{days} days in messages'**
  String storyIntroTitle(int days);

  /// No description provided for @storyTotalKicker.
  ///
  /// In en, this message translates to:
  /// **'You wrote'**
  String get storyTotalKicker;

  /// No description provided for @storyTotalSub.
  ///
  /// In en, this message translates to:
  /// **'That\'s {perDay} a day.'**
  String storyTotalSub(String perDay);

  /// No description provided for @storyWhoKicker.
  ///
  /// In en, this message translates to:
  /// **'Who writes more?'**
  String get storyWhoKicker;

  /// No description provided for @storyWhoTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} writes {percent} %'**
  String storyWhoTitle(String name, int percent);

  /// No description provided for @storyHourKicker.
  ///
  /// In en, this message translates to:
  /// **'Your hour'**
  String get storyHourKicker;

  /// No description provided for @storyHourTitle.
  ///
  /// In en, this message translates to:
  /// **'Busiest: {hour}'**
  String storyHourTitle(String hour);

  /// No description provided for @storyWordKicker.
  ///
  /// In en, this message translates to:
  /// **'Your word'**
  String get storyWordKicker;

  /// No description provided for @storyWordTitle.
  ///
  /// In en, this message translates to:
  /// **'used {count} times'**
  String storyWordTitle(int count);

  /// No description provided for @storyCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'These are your words.'**
  String get storyCloudTitle;

  /// No description provided for @storyReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} replies fastest'**
  String storyReplyTitle(String name);

  /// No description provided for @storyStarterTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} reaches out first'**
  String storyStarterTitle(String name);

  /// No description provided for @storyEmojiTitle.
  ///
  /// In en, this message translates to:
  /// **'Your favourite emoji'**
  String get storyEmojiTitle;

  /// No description provided for @storyAwardsTitle.
  ///
  /// In en, this message translates to:
  /// **'And the awards go to …'**
  String get storyAwardsTitle;

  /// No description provided for @storyOutroKicker.
  ///
  /// In en, this message translates to:
  /// **'That\'s a wrap'**
  String get storyOutroKicker;

  /// No description provided for @storyOutroTitle.
  ///
  /// In en, this message translates to:
  /// **'This is your Schreibspur.'**
  String get storyOutroTitle;

  /// No description provided for @storyRestart.
  ///
  /// In en, this message translates to:
  /// **'Watch again'**
  String get storyRestart;

  /// No description provided for @storyLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'That was just the start.'**
  String get storyLockedTitle;

  /// No description provided for @storyLockedText.
  ///
  /// In en, this message translates to:
  /// **'Word cloud, reply times, emoji, chat year, awards and records come with Pro.'**
  String get storyLockedText;

  /// No description provided for @storyLockedButton.
  ///
  /// In en, this message translates to:
  /// **'See Pro'**
  String get storyLockedButton;

  /// No description provided for @storyShare.
  ///
  /// In en, this message translates to:
  /// **'Share slide'**
  String get storyShare;

  /// No description provided for @storyClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get storyClose;

  /// No description provided for @storyTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get storyTapHint;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your chat,\nwrapped.'**
  String get heroTitle;

  /// No description provided for @heroText.
  ///
  /// In en, this message translates to:
  /// **'Who writes more, who replies faster, what\'s your word? Turn any WhatsApp chat into a recap to share.'**
  String get heroText;

  /// No description provided for @stepsTitle.
  ///
  /// In en, this message translates to:
  /// **'In three steps'**
  String get stepsTitle;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'Open the chat in WhatsApp and tap the name at the top.'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'Export Chat → Without Media.'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'Tap Schreibspur in the share sheet – done.'**
  String get step3;

  /// No description provided for @resultsKicker.
  ///
  /// In en, this message translates to:
  /// **'Your recap'**
  String get resultsKicker;

  /// No description provided for @proBest.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get proBest;

  /// No description provided for @proPopular.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get proPopular;
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
