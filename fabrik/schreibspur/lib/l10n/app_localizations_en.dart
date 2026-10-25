// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Schreibspur';

  @override
  String get tagline => 'Your chat in numbers – 100 % on your phone.';

  @override
  String get loadChat => 'Choose exported chat';

  @override
  String get pasteChat => 'Paste from clipboard';

  @override
  String get tryExample => 'Try an example';

  @override
  String get offlineProof =>
      'Nothing leaves your phone. Try it: switch on airplane mode – Schreibspur works the same.';

  @override
  String get howToTitle => 'How to export a chat';

  @override
  String get howToIos =>
      'WhatsApp → open the chat → tap the name at the top → Export Chat → Without Media → tap Schreibspur in the share sheet. Done – the recap opens right away.';

  @override
  String get howToAndroid =>
      'WhatsApp → open the chat → ⋮ → More → Export chat → Without media → save to Files.';

  @override
  String get errorNoMessages =>
      'No messages found. Please choose a chat exported from WhatsApp (.txt or .zip).';

  @override
  String get errorRead => 'The file could not be read.';

  @override
  String get clipboardEmpty => 'The clipboard is empty.';

  @override
  String get newChat => 'Another chat';

  @override
  String get exampleBadge => 'Example – made-up people';

  @override
  String chatPeriod(String from, String to) {
    return '$from – $to';
  }

  @override
  String get labelMessages => 'Messages';

  @override
  String get labelDays => 'Days';

  @override
  String get labelActiveDays => 'Active days';

  @override
  String get labelPerDay => 'Per day';

  @override
  String get labelWords => 'Words';

  @override
  String get labelWordsPerMessage => 'Words per message';

  @override
  String get labelPhotosEtc => 'Attachments';

  @override
  String get cardOverview => 'Overview';

  @override
  String get cardRhythm => 'Rhythm';

  @override
  String get cardWords => 'Favourite words';

  @override
  String get cardReplies => 'Reply time';

  @override
  String get cardStarters => 'Who starts the talk';

  @override
  String get cardEmoji => 'Favourite emoji';

  @override
  String get cardRecords => 'Records';

  @override
  String get cardAwards => 'Awards';

  @override
  String get cardCompare => 'Then vs. now';

  @override
  String rhythmHour(String hour) {
    return 'Busiest hour: $hour';
  }

  @override
  String rhythmDay(String day) {
    return 'Busiest day of the week: $day';
  }

  @override
  String hourRange(int from, int to) {
    return '$from–$to h';
  }

  @override
  String get wordsEmpty => 'Not enough text yet.';

  @override
  String get wordsMore => '+ more words with Pro';

  @override
  String timesUsed(int count) {
    return '$count×';
  }

  @override
  String get repliesHint =>
      'Median time until the other person answers (up to 6 hours).';

  @override
  String get startersHint =>
      'Opens a new talk after at least 6 hours of silence.';

  @override
  String startsCount(int count) {
    return '$count talks';
  }

  @override
  String get noEmoji => 'No emoji found.';

  @override
  String get recordBusiestDay => 'Busiest day';

  @override
  String recordBusiestDayValue(String date, int count) {
    return '$date · $count messages';
  }

  @override
  String get recordPause => 'Longest silence';

  @override
  String recordPauseValue(String duration, String date) {
    return '$duration, from $date';
  }

  @override
  String get recordStreak => 'Longest streak';

  @override
  String recordStreakValue(int days) {
    return '$days days in a row';
  }

  @override
  String get durUnderMinute => 'under 1 min';

  @override
  String durMinutes(int m) {
    return '$m min';
  }

  @override
  String durHours(int h, int m) {
    return '$h h $m min';
  }

  @override
  String durDays(int d, int h) {
    return '$d d $h h';
  }

  @override
  String get awardMost => 'Chatterbox';

  @override
  String get awardMostText => 'Writes the most messages';

  @override
  String get awardFast => 'Speedy';

  @override
  String get awardFastText => 'Answers fastest';

  @override
  String get awardStarter => 'Ice breaker';

  @override
  String get awardStarterText => 'Starts most talks';

  @override
  String get awardNovel => 'Novelist';

  @override
  String get awardNovelText => 'Longest messages';

  @override
  String get awardOwl => 'Night owl';

  @override
  String get awardOwlText => 'Most messages after midnight';

  @override
  String get compareNeedMore => 'Needs at least two weeks of chat to compare.';

  @override
  String get compareBefore => 'Before';

  @override
  String get compareNow => 'Now';

  @override
  String compareChange(String percent) {
    return '$percent messages';
  }

  @override
  String get locked => 'Part of Pro';

  @override
  String get lockedTap => 'Unlock with Pro';

  @override
  String get share => 'Share as image';

  @override
  String get shareText => 'Made with Schreibspur';

  @override
  String get shareFailed => 'Sharing did not work.';

  @override
  String get aboutPrivacy =>
      'Your chat is read on this phone and not saved: close the app and it is gone. No account, no internet access, no tracking.';

  @override
  String get proTitle => 'Schreibspur Pro';

  @override
  String get proTagline => 'Every card, every comparison, shareable.';

  @override
  String get proFeatureCards =>
      'All cards: reply time, who starts, emoji, records';

  @override
  String get proFeatureAwards =>
      'Awards for groups: chatterbox, speedy, night owl';

  @override
  String get proFeatureCompare =>
      'Compare two periods – this year vs. last year';

  @override
  String proFeatureWords(int count, int free) {
    return '$count favourite words instead of $free';
  }

  @override
  String get proFeatureShare => 'Share every card as an image';

  @override
  String get proYearly => 'Yearly';

  @override
  String proYearlyDetail(String price) {
    return '$price per year · renews automatically';
  }

  @override
  String get proLifetime => 'Lifetime';

  @override
  String proLifetimeDetail(String price) {
    return '$price once · no subscription';
  }

  @override
  String get proBuy => 'Continue';

  @override
  String get proRestore => 'Restore purchases';

  @override
  String get proActive => 'Pro is active – thank you!';

  @override
  String get proPending => 'Your purchase is waiting for approval.';

  @override
  String get proFailed => 'The purchase did not go through. Please try again.';

  @override
  String get proNothingToRestore => 'No previous purchase found.';

  @override
  String get proStoreUnavailable => 'The App Store is not reachable right now.';

  @override
  String get proSubscriptionNote =>
      'The yearly subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Payment is charged to your Apple ID. Manage or cancel it in your Apple ID settings.';

  @override
  String get terms => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get cardCloud => 'Word cloud';

  @override
  String get cloudHint =>
      'The bigger, the more often. Colour = who writes it most.';

  @override
  String get cardYear => 'Chat year';

  @override
  String yearSummary(int active, int days) {
    return '$active of $days days with messages';
  }

  @override
  String get yearLess => 'less';

  @override
  String get yearMore => 'more';

  @override
  String get posterButton => 'Create poster';

  @override
  String get posterTitle => 'Poster';

  @override
  String get posterShare => 'Share poster';

  @override
  String get posterHint =>
      'All cards in one image – share it or save it to Photos.';

  @override
  String get posterMadeWith => 'Made with Schreibspur · analysed offline';

  @override
  String get proFeatureImages =>
      'Poster with all cards, word cloud and chat year';

  @override
  String get storyPlay => 'Play your recap';

  @override
  String get storyIntroKicker => 'Your chat';

  @override
  String storyIntroTitle(int days) {
    return '$days days in messages';
  }

  @override
  String get storyTotalKicker => 'You wrote';

  @override
  String storyTotalSub(String perDay) {
    return 'That\'s $perDay a day.';
  }

  @override
  String get storyWhoKicker => 'Who writes more?';

  @override
  String storyWhoTitle(String name, int percent) {
    return '$name writes $percent %';
  }

  @override
  String get storyHourKicker => 'Your hour';

  @override
  String storyHourTitle(String hour) {
    return 'Busiest: $hour';
  }

  @override
  String get storyWordKicker => 'Your word';

  @override
  String storyWordTitle(int count) {
    return 'used $count times';
  }

  @override
  String get storyCloudTitle => 'These are your words.';

  @override
  String storyReplyTitle(String name) {
    return '$name replies fastest';
  }

  @override
  String storyStarterTitle(String name) {
    return '$name reaches out first';
  }

  @override
  String get storyEmojiTitle => 'Your favourite emoji';

  @override
  String get storyAwardsTitle => 'And the awards go to …';

  @override
  String get storyOutroKicker => 'That\'s a wrap';

  @override
  String get storyOutroTitle => 'This is your Schreibspur.';

  @override
  String get storyRestart => 'Watch again';

  @override
  String get storyLockedTitle => 'That was just the start.';

  @override
  String get storyLockedText =>
      'Word cloud, reply times, emoji, chat year, awards and records come with Pro.';

  @override
  String get storyLockedButton => 'See Pro';

  @override
  String get storyShare => 'Share slide';

  @override
  String get storyClose => 'Close';

  @override
  String get storyTapHint => 'Tap to continue';

  @override
  String get heroTitle => 'Your chat,\nwrapped.';

  @override
  String get heroText =>
      'Who writes more, who replies faster, what\'s your word? Turn any WhatsApp chat into a recap to share.';

  @override
  String get stepsTitle => 'In three steps';

  @override
  String get step1 => 'Open the chat in WhatsApp and tap the name at the top.';

  @override
  String get step2 => 'Export Chat → Without Media.';

  @override
  String get step3 => 'Tap Schreibspur in the share sheet – done.';

  @override
  String get resultsKicker => 'Your recap';

  @override
  String get proBest => 'Best value';

  @override
  String get proPopular => 'Flexible';
}
