// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kochmappe';

  @override
  String get tabBinder => 'Binder';

  @override
  String get tabFridge => 'What I have';

  @override
  String get tabShopping => 'Shopping';

  @override
  String get tabMore => 'More';

  @override
  String get binderTitle => 'My binder';

  @override
  String recipesWord(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search title, ingredient, tag …';

  @override
  String get clear => 'Clear';

  @override
  String get tabAll => 'All';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get newFolder => 'New folder';

  @override
  String get editFolder => 'Edit folder';

  @override
  String get deleteFolder => 'Delete folder';

  @override
  String get folderNameHint => 'e.g. Weeknights';

  @override
  String get colorWord => 'Colour';

  @override
  String inFolder(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n recipes in this folder',
      one: '1 recipe in this folder',
      zero: 'No recipes in this folder',
    );
    return '$_temp0';
  }

  @override
  String get putInFolder => 'Put in a folder';

  @override
  String get noFoldersYet => 'No folders yet – create your first one.';

  @override
  String get change => 'Change';

  @override
  String get ideaToday => 'How about today?';

  @override
  String get neverCooked => 'Not cooked yet';

  @override
  String lastCooked(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Cooked $days days ago',
      one: 'Cooked yesterday',
      zero: 'Cooked today',
    );
    return '$_temp0';
  }

  @override
  String lastCookedOn(String date) {
    return 'Last cooked on $date';
  }

  @override
  String cookedTimes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'cooked $n times',
      one: 'cooked once',
    );
    return '$_temp0';
  }

  @override
  String get emptyBinderTitle => 'Your binder is empty';

  @override
  String get emptyBinderText =>
      'Save your first recipe from a link, paste a text or write it down yourself.';

  @override
  String get emptyFolderTitle => 'Nothing here yet';

  @override
  String get emptyFolderText => 'Open a recipe and put it into this folder.';

  @override
  String get noFavTitle => 'No favorites yet';

  @override
  String get noFavText => 'Tap the heart on a recipe to find it here.';

  @override
  String get noHitsTitle => 'No recipe found';

  @override
  String get noHitsText =>
      'Try another word – the search looks at titles, ingredients, tags and notes.';

  @override
  String get pickRecipeTitle => 'Pick a recipe';

  @override
  String get pickRecipeText => 'It opens here, next to your list.';

  @override
  String get addRecipe => 'Add recipe';

  @override
  String get addFromLink => 'From a link';

  @override
  String get addFromLinkSub => 'Read a recipe from a web page';

  @override
  String get addFromText => 'From pasted text';

  @override
  String get addFromTextSub =>
      'Caption, message or note – ingredients are recognised';

  @override
  String get addByHand => 'Write it yourself';

  @override
  String get addByHandSub => 'Your own or a family recipe';

  @override
  String get modeLink => 'Link';

  @override
  String get modeText => 'Text';

  @override
  String get linkExplain =>
      'Paste the address of a recipe page. Kochmappe reads the recipe right on your device and keeps a private copy.';

  @override
  String get textExplain =>
      'Paste a recipe from a video caption, a message or a note. Ingredients and steps are recognised; you can correct everything afterwards.';

  @override
  String get linkHint => 'https://…';

  @override
  String get textHint =>
      'Title\nIngredients\n200 g flour\n2 eggs\nDirections\n1. Mix …';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get fetchRecipe => 'Get recipe';

  @override
  String get recognize => 'Recognise recipe';

  @override
  String get reading => 'Reading …';

  @override
  String get errBadLink => 'That does not look like a web address.';

  @override
  String get errNetwork => 'The page could not be loaded. Are you online?';

  @override
  String get errNoRecipe => 'No recipe found on this page.';

  @override
  String get errNoRecipeText => 'No ingredients or steps found in this text.';

  @override
  String get errTryText =>
      'Some pages hide their recipe or need a login. Copy the recipe text from the page and paste it instead.';

  @override
  String get switchToText => 'Paste text instead';

  @override
  String get importPrivacy =>
      'The page is fetched straight from your device. No account, no server of ours, nothing is sent anywhere else.';

  @override
  String get newRecipe => 'New recipe';

  @override
  String get editRecipe => 'Edit recipe';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get dismiss => 'OK';

  @override
  String get photo => 'Photo';

  @override
  String get photoFromLibrary => 'Choose from photos';

  @override
  String get photoFromCamera => 'Take a photo';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleHint => 'e.g. Grandma\'s plum cake';

  @override
  String get needTitle => 'Please give the recipe a title.';

  @override
  String get prepMinLabel => 'Prep, min';

  @override
  String get cookMinLabel => 'Cook, min';

  @override
  String get ingredientsEditHint =>
      'One per line, e.g. “2 tbsp olive oil”. A line ending in “:” starts a group.';

  @override
  String get ingredientsExample => '200 g flour\n2 eggs\n1 pinch salt';

  @override
  String get stepsEditHint => 'One step per line.';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagsHint => 'Separated by commas, e.g. quick, vegetarian';

  @override
  String get notesHint => 'Where it is from, who likes it …';

  @override
  String get notes => 'Notes';

  @override
  String get favorite => 'Favorite';

  @override
  String prepTime(String t) {
    return 'Prep $t';
  }

  @override
  String cookTime(String t) {
    return 'Cook $t';
  }

  @override
  String get cookMode => 'Cook mode';

  @override
  String get toList => 'To list';

  @override
  String addedToList(int n) {
    return '$n items added to the shopping list';
  }

  @override
  String get ingredients => 'Ingredients';

  @override
  String get steps => 'Directions';

  @override
  String get servingsLabel => 'servings';

  @override
  String get fewer => 'Fewer';

  @override
  String get more => 'More';

  @override
  String get unitsMetricShort => 'g · ml';

  @override
  String get unitsUsShort => 'oz · cup';

  @override
  String get noIngredients =>
      'No ingredients yet – tap the menu and choose Edit.';

  @override
  String get noSteps => 'No steps yet.';

  @override
  String timerChip(String t) {
    return 'Timer $t';
  }

  @override
  String get myTwist => 'My twist';

  @override
  String get twistHint =>
      'What do you change? Less sugar, more garlic … kept apart from the original.';

  @override
  String get diary => 'Cooking diary';

  @override
  String get cookedToday => 'Cooked today';

  @override
  String get diaryHint => 'A note, e.g. “needed more salt”';

  @override
  String get shareText => 'Share as text';

  @override
  String get pdfCard => 'Recipe card (PDF)';

  @override
  String deleteRecipeTitle(String t) {
    return 'Delete “$t”?';
  }

  @override
  String get deleteRecipeText =>
      'The recipe is removed from this device. A saved backup keeps it.';

  @override
  String get smallerText => 'Smaller text';

  @override
  String get biggerText => 'Bigger text';

  @override
  String stepOf(int a, int b) {
    return 'STEP $a OF $b';
  }

  @override
  String startTimer(String t) {
    return 'Start timer $t';
  }

  @override
  String timerDone(String t) {
    return 'Time is up: $t';
  }

  @override
  String get previous => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finishCooking => 'Done – log it';

  @override
  String ingredientsFor(int n) {
    return 'Ingredients for $n';
  }

  @override
  String get fridgeTitle => 'What do I have?';

  @override
  String get fridgeSub =>
      'Type what is in your kitchen. Your recipes that use it show up – with what is still missing.';

  @override
  String get fridgeHint => 'e.g. eggs, spinach, rice';

  @override
  String get clearAll => 'Clear all';

  @override
  String get fridgeEmptyTitle => 'Empty fridge, full binder';

  @override
  String get fridgeEmptyText =>
      'Add two or three ingredients and see what you can cook tonight.';

  @override
  String get fridgeNoneTitle => 'Nothing matches yet';

  @override
  String get fridgeNoneText =>
      'None of your recipes uses these ingredients. Try other words.';

  @override
  String fridgeMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n recipes fit',
      one: '1 recipe fits',
    );
    return '$_temp0';
  }

  @override
  String haveCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ingredients at home',
      one: '1 ingredient at home',
    );
    return '$_temp0';
  }

  @override
  String get allThere => 'All there';

  @override
  String stillMissing(String t) {
    return 'Still missing: $t';
  }

  @override
  String get shoppingTitle => 'Shopping list';

  @override
  String get shoppingAddHint => 'Add an item';

  @override
  String get shoppingEmptyTitle => 'Nothing to buy';

  @override
  String get shoppingEmptyText =>
      'Open a recipe and tap “To list” – equal ingredients are added up.';

  @override
  String get shoppingDone => 'In the basket';

  @override
  String get removeDone => 'Remove';

  @override
  String get clearList => 'Empty the list';

  @override
  String get unitsTitle => 'Units';

  @override
  String get unitsText =>
      'Show amounts in grams and millilitres or in ounces and cups. Works in every recipe.';

  @override
  String get themeTitle => 'Binder colour';

  @override
  String get themeProHint => 'Saffron is free – more colours come with Pro.';

  @override
  String get themeProOn => 'Pick the colour of your binder.';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupText =>
      'Your recipes live only on this device. Save a backup file now and then (e.g. to iCloud Drive) – restoring never overwrites anything.';

  @override
  String get backupSave => 'Save backup';

  @override
  String get backupLoad => 'Restore backup';

  @override
  String get backupWord => 'backup';

  @override
  String get backupBad => 'That file is not a Kochmappe backup.';

  @override
  String backupRestored(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n recipes restored',
      one: '1 recipe restored',
      zero: 'Nothing new in this backup',
    );
    return '$_temp0';
  }

  @override
  String get cookbookTitle => 'Cookbook';

  @override
  String get cookbookMake => 'Make a cookbook (PDF)';

  @override
  String get cookbookSub => 'All recipes as one printable document';

  @override
  String get pdfContents => 'Contents';

  @override
  String get pdfBookTitle => 'My Cookbook';

  @override
  String get pdfFileWord => 'cookbook';

  @override
  String get aboutTitle => 'About';

  @override
  String get terms => 'Terms of Use';

  @override
  String get privacy => 'Privacy';

  @override
  String get contact => 'Support & contact';

  @override
  String get deleteAll => 'Delete all my data';

  @override
  String get deleteAllTitle => 'Delete everything?';

  @override
  String get deleteAllText =>
      'All recipes, folders, photos and the shopping list are removed from this device. This cannot be undone.';

  @override
  String get footer =>
      'Everything stays on your device.\nNo account, no tracking, no ads.';

  @override
  String get proCardTitle => 'Kochmappe Pro';

  @override
  String get proActive => 'Pro is active';

  @override
  String proCardSub(String p) {
    return 'Unlimited recipes, PDF, colours – $p once';
  }

  @override
  String get proTitle => 'Kochmappe Pro';

  @override
  String get proLead =>
      'One purchase, no subscription. Everything you already use stays free.';

  @override
  String proReasonRecipes(int n) {
    return 'Your free binder holds $n recipes. Pro takes the limit away – for good.';
  }

  @override
  String get proReasonPdf =>
      'Recipe cards and cookbooks as PDF are part of Pro – one purchase, no subscription.';

  @override
  String get proFeatUnlimited => 'Unlimited recipes and folders';

  @override
  String get proFeatUnlimitedSub => 'Free holds 25 recipes and 3 folders.';

  @override
  String get proFeatPdf => 'Recipe cards & cookbook as PDF';

  @override
  String get proFeatPdfSub =>
      'Print a card for the fridge or bind all recipes into one book.';

  @override
  String get proFeatThemes => 'Four more binder colours';

  @override
  String get proFeatThemesSub =>
      'Berry, sage, sky and terracotta next to saffron.';

  @override
  String get proFreeStays =>
      'Import, portion calculator, cook mode, timers, search, shopping list and backup stay free.';

  @override
  String get proOnce => 'once · no subscription';

  @override
  String proBuy(String p) {
    return 'Get Pro for $p';
  }

  @override
  String get proThanks => 'Thank you – Pro is unlocked.';

  @override
  String get proPending => 'Waiting for approval (Ask to Buy).';

  @override
  String get proFailed => 'That did not work. Please try again.';

  @override
  String get proNothing => 'No earlier purchase found for this Apple ID.';

  @override
  String get restore => 'Restore purchase';

  @override
  String get welcomeTitle => 'Your recipes,\nin one binder.';

  @override
  String get welcomeSub =>
      'Save recipes from the web, scale them, cook step by step – on your phone and your iPad.';

  @override
  String get welcomeP1 => 'Save from a link or pasted text';

  @override
  String get welcomeP2 => 'No account – everything stays on your device';

  @override
  String get welcomeP3 => 'Free to use, Pro once instead of a subscription';

  @override
  String get welcomeGo => 'Open my binder';
}
