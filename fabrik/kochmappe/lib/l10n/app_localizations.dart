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
  /// **'Kochmappe'**
  String get appTitle;

  /// No description provided for @tabBinder.
  ///
  /// In en, this message translates to:
  /// **'Binder'**
  String get tabBinder;

  /// No description provided for @tabFridge.
  ///
  /// In en, this message translates to:
  /// **'What I have'**
  String get tabFridge;

  /// No description provided for @tabShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get tabShopping;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @binderTitle.
  ///
  /// In en, this message translates to:
  /// **'My binder'**
  String get binderTitle;

  /// No description provided for @recipesWord.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{recipe} other{recipes}}'**
  String recipesWord(int n);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, ingredient, tag …'**
  String get searchHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// No description provided for @tabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tabFavorites;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @editFolder.
  ///
  /// In en, this message translates to:
  /// **'Edit folder'**
  String get editFolder;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get deleteFolder;

  /// No description provided for @folderNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Weeknights'**
  String get folderNameHint;

  /// No description provided for @colorWord.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colorWord;

  /// No description provided for @inFolder.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{No recipes in this folder} =1{1 recipe in this folder} other{{n} recipes in this folder}}'**
  String inFolder(int n);

  /// No description provided for @putInFolder.
  ///
  /// In en, this message translates to:
  /// **'Put in a folder'**
  String get putInFolder;

  /// No description provided for @noFoldersYet.
  ///
  /// In en, this message translates to:
  /// **'No folders yet – create your first one.'**
  String get noFoldersYet;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @ideaToday.
  ///
  /// In en, this message translates to:
  /// **'How about today?'**
  String get ideaToday;

  /// No description provided for @neverCooked.
  ///
  /// In en, this message translates to:
  /// **'Not cooked yet'**
  String get neverCooked;

  /// No description provided for @lastCooked.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Cooked today} =1{Cooked yesterday} other{Cooked {days} days ago}}'**
  String lastCooked(int days);

  /// No description provided for @lastCookedOn.
  ///
  /// In en, this message translates to:
  /// **'Last cooked on {date}'**
  String lastCookedOn(String date);

  /// No description provided for @cookedTimes.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{cooked once} other{cooked {n} times}}'**
  String cookedTimes(int n);

  /// No description provided for @emptyBinderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your binder is empty'**
  String get emptyBinderTitle;

  /// No description provided for @emptyBinderText.
  ///
  /// In en, this message translates to:
  /// **'Save your first recipe from a link, paste a text or write it down yourself.'**
  String get emptyBinderText;

  /// No description provided for @emptyFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyFolderTitle;

  /// No description provided for @emptyFolderText.
  ///
  /// In en, this message translates to:
  /// **'Open a recipe and put it into this folder.'**
  String get emptyFolderText;

  /// No description provided for @noFavTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavTitle;

  /// No description provided for @noFavText.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a recipe to find it here.'**
  String get noFavText;

  /// No description provided for @noHitsTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipe found'**
  String get noHitsTitle;

  /// No description provided for @noHitsText.
  ///
  /// In en, this message translates to:
  /// **'Try another word – the search looks at titles, ingredients, tags and notes.'**
  String get noHitsText;

  /// No description provided for @pickRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a recipe'**
  String get pickRecipeTitle;

  /// No description provided for @pickRecipeText.
  ///
  /// In en, this message translates to:
  /// **'It opens here, next to your list.'**
  String get pickRecipeText;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add recipe'**
  String get addRecipe;

  /// No description provided for @addFromLink.
  ///
  /// In en, this message translates to:
  /// **'From a link'**
  String get addFromLink;

  /// No description provided for @addFromLinkSub.
  ///
  /// In en, this message translates to:
  /// **'Read a recipe from a web page'**
  String get addFromLinkSub;

  /// No description provided for @addFromText.
  ///
  /// In en, this message translates to:
  /// **'From pasted text'**
  String get addFromText;

  /// No description provided for @addFromTextSub.
  ///
  /// In en, this message translates to:
  /// **'Caption, message or note – ingredients are recognised'**
  String get addFromTextSub;

  /// No description provided for @addByHand.
  ///
  /// In en, this message translates to:
  /// **'Write it yourself'**
  String get addByHand;

  /// No description provided for @addByHandSub.
  ///
  /// In en, this message translates to:
  /// **'Your own or a family recipe'**
  String get addByHandSub;

  /// No description provided for @modeLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get modeLink;

  /// No description provided for @modeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get modeText;

  /// No description provided for @linkExplain.
  ///
  /// In en, this message translates to:
  /// **'Paste the address of a recipe page. Kochmappe reads the recipe right on your device and keeps a private copy.'**
  String get linkExplain;

  /// No description provided for @textExplain.
  ///
  /// In en, this message translates to:
  /// **'Paste a recipe from a video caption, a message or a note. Ingredients and steps are recognised; you can correct everything afterwards.'**
  String get textExplain;

  /// No description provided for @linkHint.
  ///
  /// In en, this message translates to:
  /// **'https://…'**
  String get linkHint;

  /// No description provided for @textHint.
  ///
  /// In en, this message translates to:
  /// **'Title\nIngredients\n200 g flour\n2 eggs\nDirections\n1. Mix …'**
  String get textHint;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @fetchRecipe.
  ///
  /// In en, this message translates to:
  /// **'Get recipe'**
  String get fetchRecipe;

  /// No description provided for @recognize.
  ///
  /// In en, this message translates to:
  /// **'Recognise recipe'**
  String get recognize;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading …'**
  String get reading;

  /// No description provided for @errBadLink.
  ///
  /// In en, this message translates to:
  /// **'That does not look like a web address.'**
  String get errBadLink;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'The page could not be loaded. Are you online?'**
  String get errNetwork;

  /// No description provided for @errNoRecipe.
  ///
  /// In en, this message translates to:
  /// **'No recipe found on this page.'**
  String get errNoRecipe;

  /// No description provided for @errNoRecipeText.
  ///
  /// In en, this message translates to:
  /// **'No ingredients or steps found in this text.'**
  String get errNoRecipeText;

  /// No description provided for @errTryText.
  ///
  /// In en, this message translates to:
  /// **'Some pages hide their recipe or need a login. Copy the recipe text from the page and paste it instead.'**
  String get errTryText;

  /// No description provided for @switchToText.
  ///
  /// In en, this message translates to:
  /// **'Paste text instead'**
  String get switchToText;

  /// No description provided for @importPrivacy.
  ///
  /// In en, this message translates to:
  /// **'The page is fetched straight from your device. No account, no server of ours, nothing is sent anywhere else.'**
  String get importPrivacy;

  /// No description provided for @newRecipe.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get newRecipe;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editRecipe;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

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

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dismiss;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @photoFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from photos'**
  String get photoFromLibrary;

  /// No description provided for @photoFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photoFromCamera;

  /// No description provided for @photoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get photoRemove;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grandma\'s plum cake'**
  String get titleHint;

  /// No description provided for @needTitle.
  ///
  /// In en, this message translates to:
  /// **'Please give the recipe a title.'**
  String get needTitle;

  /// No description provided for @prepMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Prep, min'**
  String get prepMinLabel;

  /// No description provided for @cookMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Cook, min'**
  String get cookMinLabel;

  /// No description provided for @ingredientsEditHint.
  ///
  /// In en, this message translates to:
  /// **'One per line, e.g. “2 tbsp olive oil”. A line ending in “:” starts a group.'**
  String get ingredientsEditHint;

  /// No description provided for @ingredientsExample.
  ///
  /// In en, this message translates to:
  /// **'200 g flour\n2 eggs\n1 pinch salt'**
  String get ingredientsExample;

  /// No description provided for @stepsEditHint.
  ///
  /// In en, this message translates to:
  /// **'One step per line.'**
  String get stepsEditHint;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'Separated by commas, e.g. quick, vegetarian'**
  String get tagsHint;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Where it is from, who likes it …'**
  String get notesHint;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep {t}'**
  String prepTime(String t);

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook {t}'**
  String cookTime(String t);

  /// No description provided for @cookMode.
  ///
  /// In en, this message translates to:
  /// **'Cook mode'**
  String get cookMode;

  /// No description provided for @toList.
  ///
  /// In en, this message translates to:
  /// **'To list'**
  String get toList;

  /// No description provided for @addedToList.
  ///
  /// In en, this message translates to:
  /// **'{n} items added to the shopping list'**
  String addedToList(int n);

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get steps;

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'servings'**
  String get servingsLabel;

  /// No description provided for @fewer.
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get fewer;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @unitsMetricShort.
  ///
  /// In en, this message translates to:
  /// **'g · ml'**
  String get unitsMetricShort;

  /// No description provided for @unitsUsShort.
  ///
  /// In en, this message translates to:
  /// **'oz · cup'**
  String get unitsUsShort;

  /// No description provided for @noIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet – tap the menu and choose Edit.'**
  String get noIngredients;

  /// No description provided for @noSteps.
  ///
  /// In en, this message translates to:
  /// **'No steps yet.'**
  String get noSteps;

  /// No description provided for @timerChip.
  ///
  /// In en, this message translates to:
  /// **'Timer {t}'**
  String timerChip(String t);

  /// No description provided for @myTwist.
  ///
  /// In en, this message translates to:
  /// **'My twist'**
  String get myTwist;

  /// No description provided for @twistHint.
  ///
  /// In en, this message translates to:
  /// **'What do you change? Less sugar, more garlic … kept apart from the original.'**
  String get twistHint;

  /// No description provided for @diary.
  ///
  /// In en, this message translates to:
  /// **'Cooking diary'**
  String get diary;

  /// No description provided for @cookedToday.
  ///
  /// In en, this message translates to:
  /// **'Cooked today'**
  String get cookedToday;

  /// No description provided for @diaryHint.
  ///
  /// In en, this message translates to:
  /// **'A note, e.g. “needed more salt”'**
  String get diaryHint;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get shareText;

  /// No description provided for @pdfCard.
  ///
  /// In en, this message translates to:
  /// **'Recipe card (PDF)'**
  String get pdfCard;

  /// No description provided for @deleteRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{t}”?'**
  String deleteRecipeTitle(String t);

  /// No description provided for @deleteRecipeText.
  ///
  /// In en, this message translates to:
  /// **'The recipe is removed from this device. A saved backup keeps it.'**
  String get deleteRecipeText;

  /// No description provided for @smallerText.
  ///
  /// In en, this message translates to:
  /// **'Smaller text'**
  String get smallerText;

  /// No description provided for @biggerText.
  ///
  /// In en, this message translates to:
  /// **'Bigger text'**
  String get biggerText;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'STEP {a} OF {b}'**
  String stepOf(int a, int b);

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start timer {t}'**
  String startTimer(String t);

  /// No description provided for @timerDone.
  ///
  /// In en, this message translates to:
  /// **'Time is up: {t}'**
  String timerDone(String t);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finishCooking.
  ///
  /// In en, this message translates to:
  /// **'Done – log it'**
  String get finishCooking;

  /// No description provided for @ingredientsFor.
  ///
  /// In en, this message translates to:
  /// **'Ingredients for {n}'**
  String ingredientsFor(int n);

  /// No description provided for @fridgeTitle.
  ///
  /// In en, this message translates to:
  /// **'What do I have?'**
  String get fridgeTitle;

  /// No description provided for @fridgeSub.
  ///
  /// In en, this message translates to:
  /// **'Type what is in your kitchen. Your recipes that use it show up – with what is still missing.'**
  String get fridgeSub;

  /// No description provided for @fridgeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. eggs, spinach, rice'**
  String get fridgeHint;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @fridgeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty fridge, full binder'**
  String get fridgeEmptyTitle;

  /// No description provided for @fridgeEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Add two or three ingredients and see what you can cook tonight.'**
  String get fridgeEmptyText;

  /// No description provided for @fridgeNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches yet'**
  String get fridgeNoneTitle;

  /// No description provided for @fridgeNoneText.
  ///
  /// In en, this message translates to:
  /// **'None of your recipes uses these ingredients. Try other words.'**
  String get fridgeNoneText;

  /// No description provided for @fridgeMatches.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 recipe fits} other{{n} recipes fit}}'**
  String fridgeMatches(int n);

  /// No description provided for @haveCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 ingredient at home} other{{n} ingredients at home}}'**
  String haveCount(int n);

  /// No description provided for @allThere.
  ///
  /// In en, this message translates to:
  /// **'All there'**
  String get allThere;

  /// No description provided for @stillMissing.
  ///
  /// In en, this message translates to:
  /// **'Still missing: {t}'**
  String stillMissing(String t);

  /// No description provided for @shoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingTitle;

  /// No description provided for @shoppingAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add an item'**
  String get shoppingAddHint;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to buy'**
  String get shoppingEmptyTitle;

  /// No description provided for @shoppingEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Open a recipe and tap “To list” – equal ingredients are added up.'**
  String get shoppingEmptyText;

  /// No description provided for @shoppingDone.
  ///
  /// In en, this message translates to:
  /// **'In the basket'**
  String get shoppingDone;

  /// No description provided for @removeDone.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeDone;

  /// No description provided for @clearList.
  ///
  /// In en, this message translates to:
  /// **'Empty the list'**
  String get clearList;

  /// No description provided for @unitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsTitle;

  /// No description provided for @unitsText.
  ///
  /// In en, this message translates to:
  /// **'Show amounts in grams and millilitres or in ounces and cups. Works in every recipe.'**
  String get unitsText;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Binder colour'**
  String get themeTitle;

  /// No description provided for @themeProHint.
  ///
  /// In en, this message translates to:
  /// **'Saffron is free – more colours come with Pro.'**
  String get themeProHint;

  /// No description provided for @themeProOn.
  ///
  /// In en, this message translates to:
  /// **'Pick the colour of your binder.'**
  String get themeProOn;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @backupText.
  ///
  /// In en, this message translates to:
  /// **'Your recipes live only on this device. Save a backup file now and then (e.g. to iCloud Drive) – restoring never overwrites anything.'**
  String get backupText;

  /// No description provided for @backupSave.
  ///
  /// In en, this message translates to:
  /// **'Save backup'**
  String get backupSave;

  /// No description provided for @backupLoad.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get backupLoad;

  /// No description provided for @backupWord.
  ///
  /// In en, this message translates to:
  /// **'backup'**
  String get backupWord;

  /// No description provided for @backupBad.
  ///
  /// In en, this message translates to:
  /// **'That file is not a Kochmappe backup.'**
  String get backupBad;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{Nothing new in this backup} =1{1 recipe restored} other{{n} recipes restored}}'**
  String backupRestored(int n);

  /// No description provided for @cookbookTitle.
  ///
  /// In en, this message translates to:
  /// **'Cookbook'**
  String get cookbookTitle;

  /// No description provided for @cookbookMake.
  ///
  /// In en, this message translates to:
  /// **'Make a cookbook (PDF)'**
  String get cookbookMake;

  /// No description provided for @cookbookSub.
  ///
  /// In en, this message translates to:
  /// **'All recipes as one printable document'**
  String get cookbookSub;

  /// No description provided for @pdfContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get pdfContents;

  /// No description provided for @pdfBookTitle.
  ///
  /// In en, this message translates to:
  /// **'My Cookbook'**
  String get pdfBookTitle;

  /// No description provided for @pdfFileWord.
  ///
  /// In en, this message translates to:
  /// **'cookbook'**
  String get pdfFileWord;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

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

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Support & contact'**
  String get contact;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all my data'**
  String get deleteAll;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllText.
  ///
  /// In en, this message translates to:
  /// **'All recipes, folders, photos and the shopping list are removed from this device. This cannot be undone.'**
  String get deleteAllText;

  /// No description provided for @footer.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on your device.\nNo account, no tracking, no ads.'**
  String get footer;

  /// No description provided for @proCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Kochmappe Pro'**
  String get proCardTitle;

  /// No description provided for @proActive.
  ///
  /// In en, this message translates to:
  /// **'Pro is active'**
  String get proActive;

  /// No description provided for @proCardSub.
  ///
  /// In en, this message translates to:
  /// **'Unlimited recipes, PDF, colours – {p} once'**
  String proCardSub(String p);

  /// No description provided for @proTitle.
  ///
  /// In en, this message translates to:
  /// **'Kochmappe Pro'**
  String get proTitle;

  /// No description provided for @proLead.
  ///
  /// In en, this message translates to:
  /// **'One purchase, no subscription. Everything you already use stays free.'**
  String get proLead;

  /// No description provided for @proReasonRecipes.
  ///
  /// In en, this message translates to:
  /// **'Your free binder holds {n} recipes. Pro takes the limit away – for good.'**
  String proReasonRecipes(int n);

  /// No description provided for @proReasonPdf.
  ///
  /// In en, this message translates to:
  /// **'Recipe cards and cookbooks as PDF are part of Pro – one purchase, no subscription.'**
  String get proReasonPdf;

  /// No description provided for @proFeatUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited recipes and folders'**
  String get proFeatUnlimited;

  /// No description provided for @proFeatUnlimitedSub.
  ///
  /// In en, this message translates to:
  /// **'Free holds 25 recipes and 3 folders.'**
  String get proFeatUnlimitedSub;

  /// No description provided for @proFeatPdf.
  ///
  /// In en, this message translates to:
  /// **'Recipe cards & cookbook as PDF'**
  String get proFeatPdf;

  /// No description provided for @proFeatPdfSub.
  ///
  /// In en, this message translates to:
  /// **'Print a card for the fridge or bind all recipes into one book.'**
  String get proFeatPdfSub;

  /// No description provided for @proFeatThemes.
  ///
  /// In en, this message translates to:
  /// **'Four more binder colours'**
  String get proFeatThemes;

  /// No description provided for @proFeatThemesSub.
  ///
  /// In en, this message translates to:
  /// **'Berry, sage, sky and terracotta next to saffron.'**
  String get proFeatThemesSub;

  /// No description provided for @proFreeStays.
  ///
  /// In en, this message translates to:
  /// **'Import, portion calculator, cook mode, timers, search, shopping list and backup stay free.'**
  String get proFreeStays;

  /// No description provided for @proOnce.
  ///
  /// In en, this message translates to:
  /// **'once · no subscription'**
  String get proOnce;

  /// No description provided for @proBuy.
  ///
  /// In en, this message translates to:
  /// **'Get Pro for {p}'**
  String proBuy(String p);

  /// No description provided for @proThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you – Pro is unlocked.'**
  String get proThanks;

  /// No description provided for @proPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval (Ask to Buy).'**
  String get proPending;

  /// No description provided for @proFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Please try again.'**
  String get proFailed;

  /// No description provided for @proNothing.
  ///
  /// In en, this message translates to:
  /// **'No earlier purchase found for this Apple ID.'**
  String get proNothing;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get restore;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your recipes,\nin one binder.'**
  String get welcomeTitle;

  /// No description provided for @welcomeSub.
  ///
  /// In en, this message translates to:
  /// **'Save recipes from the web, scale them, cook step by step – on your phone and your iPad.'**
  String get welcomeSub;

  /// No description provided for @welcomeP1.
  ///
  /// In en, this message translates to:
  /// **'Save from a link or pasted text'**
  String get welcomeP1;

  /// No description provided for @welcomeP2.
  ///
  /// In en, this message translates to:
  /// **'No account – everything stays on your device'**
  String get welcomeP2;

  /// No description provided for @welcomeP3.
  ///
  /// In en, this message translates to:
  /// **'Free to use, Pro once instead of a subscription'**
  String get welcomeP3;

  /// No description provided for @welcomeGo.
  ///
  /// In en, this message translates to:
  /// **'Open my binder'**
  String get welcomeGo;
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
