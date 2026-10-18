import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @homePointsLabel.
  ///
  /// In en, this message translates to:
  /// **'{points} Points'**
  String homePointsLabel(int points);

  /// No description provided for @homeTop5Title.
  ///
  /// In en, this message translates to:
  /// **'Your Top 5'**
  String get homeTop5Title;

  /// No description provided for @homeTop5Hint.
  ///
  /// In en, this message translates to:
  /// **'Pick five films you love'**
  String get homeTop5Hint;

  /// No description provided for @homeTop5AddLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a film to your Top 5'**
  String get homeTop5AddLabel;

  /// No description provided for @homeRecommendTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommend me'**
  String get homeRecommendTitle;

  /// No description provided for @homeRecommendHint.
  ///
  /// In en, this message translates to:
  /// **'Pick exactly 3 films to generate a recommendation'**
  String get homeRecommendHint;

  /// No description provided for @homePickSlotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty pick slot {index}'**
  String homePickSlotEmpty(int index);

  /// No description provided for @homeGenerateButton.
  ///
  /// In en, this message translates to:
  /// **'GENERATE'**
  String get homeGenerateButton;

  /// No description provided for @homeGenerateDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Pick {remaining} more film(s) to enable'**
  String homeGenerateDisabledHint(int remaining);

  /// No description provided for @homeGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get homeGenerating;

  /// No description provided for @homeGenerateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recommendation ready'**
  String get homeGenerateSuccess;

  /// No description provided for @homeQuickActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActionsLabel;

  /// No description provided for @homeQuickActionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeQuickActionSearch;

  /// No description provided for @homeQuickActionAddFilm.
  ///
  /// In en, this message translates to:
  /// **'Add film'**
  String get homeQuickActionAddFilm;

  /// No description provided for @homeWatchedTitle.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get homeWatchedTitle;

  /// No description provided for @homeWatchlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get homeWatchlistTitle;

  /// No description provided for @homePopularTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular With Friends'**
  String get homePopularTitle;

  /// No description provided for @homeFilmCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 film} other{{count} films}}'**
  String homeFilmCount(int count);

  /// No description provided for @homeAddTileLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to {section}'**
  String homeAddTileLabel(String section);

  /// No description provided for @homeFilmTileSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {section}'**
  String homeFilmTileSemantics(String title, String section);

  /// No description provided for @homeRemoveFilm.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}'**
  String homeRemoveFilm(String title);

  /// No description provided for @homeSectionEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get homeSectionEmptyTitle;

  /// No description provided for @homeSectionEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Add a film'**
  String get homeSectionEmptyAction;

  /// No description provided for @homeSectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this list'**
  String get homeSectionErrorTitle;

  /// No description provided for @homeSectionErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeSectionErrorRetry;

  /// No description provided for @homeRemovedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Removed {title}'**
  String homeRemovedSnackbar(String title);

  /// No description provided for @homeUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get homeUndo;

  /// No description provided for @homeTop5FullSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Your Top 5 is full. Remove a film first.'**
  String get homeTop5FullSnackbar;

  /// No description provided for @homeRecommendFullSnackbar.
  ///
  /// In en, this message translates to:
  /// **'You can pick up to 3 films.'**
  String get homeRecommendFullSnackbar;

  /// No description provided for @homeGenericErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get homeGenericErrorSnackbar;

  /// No description provided for @findTitleTop5.
  ///
  /// In en, this message translates to:
  /// **'Add to Top 5'**
  String get findTitleTop5;

  /// No description provided for @findTitleWatched.
  ///
  /// In en, this message translates to:
  /// **'Add to Watched'**
  String get findTitleWatched;

  /// No description provided for @findTitleWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Add to Watchlist'**
  String get findTitleWatchlist;

  /// No description provided for @findTitleGenerate.
  ///
  /// In en, this message translates to:
  /// **'Pick a film'**
  String get findTitleGenerate;

  /// No description provided for @findTitleSearch.
  ///
  /// In en, this message translates to:
  /// **'Find a film'**
  String get findTitleSearch;

  /// No description provided for @findBodySearch.
  ///
  /// In en, this message translates to:
  /// **'All films'**
  String get findBodySearch;

  /// No description provided for @findSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name of film…'**
  String get findSearchHint;

  /// No description provided for @findSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get findSearchClear;

  /// No description provided for @findSearchSubmit.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get findSearchSubmit;

  /// No description provided for @findMinCharsTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep typing'**
  String get findMinCharsTitle;

  /// No description provided for @findMinCharsBody.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search.'**
  String get findMinCharsBody;

  /// No description provided for @findLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Searching films…'**
  String get findLoadingTitle;

  /// No description provided for @findEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String findEmptyTitle(String query);

  /// No description provided for @findEmptyTip1.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling or try another title.'**
  String get findEmptyTip1;

  /// No description provided for @findEmptyTip2.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter keyword or a director’s name.'**
  String get findEmptyTip2;

  /// No description provided for @findErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t search right now'**
  String get findErrorTitle;

  /// No description provided for @findErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get findErrorRetry;

  /// No description provided for @findOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re offline'**
  String get findOfflineTitle;

  /// No description provided for @findOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Search and adding are disabled while offline.'**
  String get findOfflineBody;

  /// No description provided for @findNoMoreResults.
  ///
  /// In en, this message translates to:
  /// **'End of results'**
  String get findNoMoreResults;

  /// No description provided for @findLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get findLoadMore;

  /// No description provided for @findRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get findRecentTitle;

  /// No description provided for @findRecentClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get findRecentClear;

  /// No description provided for @findRecentSwipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove recent search'**
  String get findRecentSwipeDelete;

  /// No description provided for @findRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent searches yet.'**
  String get findRecentEmpty;

  /// No description provided for @findDirectedBy.
  ///
  /// In en, this message translates to:
  /// **'Directed by'**
  String get findDirectedBy;

  /// No description provided for @findGenreChip.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get findGenreChip;

  /// No description provided for @findAddToTop5.
  ///
  /// In en, this message translates to:
  /// **'Add to Top 5'**
  String get findAddToTop5;

  /// No description provided for @findAddToWatched.
  ///
  /// In en, this message translates to:
  /// **'Add to Watched'**
  String get findAddToWatched;

  /// No description provided for @findAddToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Add to Watchlist'**
  String get findAddToWatchlist;

  /// No description provided for @findAddToPick.
  ///
  /// In en, this message translates to:
  /// **'Add to picks'**
  String get findAddToPick;

  /// No description provided for @findResultSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {year}, directed by {director}. {action}'**
  String findResultSemantics(
      String title, String year, String director, String action);

  /// No description provided for @findAddedSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title} is already in {target}'**
  String findAddedSemantics(String title, String target);

  /// No description provided for @findResultDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Open details for {title}'**
  String findResultDetailsAction(String title);

  /// No description provided for @findViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get findViewDetails;

  /// No description provided for @findSendToFriend.
  ///
  /// In en, this message translates to:
  /// **'Send to a friend'**
  String get findSendToFriend;

  /// No description provided for @findAddedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Added to {target}'**
  String findAddedSnackbar(String target);

  /// No description provided for @findUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get findUndo;

  /// No description provided for @findRemovedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Removed from {target}'**
  String findRemovedSnackbar(String target);

  /// No description provided for @findMovedToWatched.
  ///
  /// In en, this message translates to:
  /// **'Moved to Watched'**
  String get findMovedToWatched;

  /// No description provided for @findReplaceSlotTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace {current}?'**
  String findReplaceSlotTitle(String current);

  /// No description provided for @findReplaceSlotBody.
  ///
  /// In en, this message translates to:
  /// **'This spot is already taken by {current}. Replace it with {replacement}?'**
  String findReplaceSlotBody(String current, String replacement);

  /// No description provided for @findReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get findReplace;

  /// No description provided for @findCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get findCancel;

  /// No description provided for @findTop5FullTitle.
  ///
  /// In en, this message translates to:
  /// **'Top 5 is full'**
  String get findTop5FullTitle;

  /// No description provided for @findTop5FullBody.
  ///
  /// In en, this message translates to:
  /// **'Remove a film before adding to your Top 5.'**
  String get findTop5FullBody;

  /// No description provided for @findAlreadyWatchedTitle.
  ///
  /// In en, this message translates to:
  /// **'Already watched'**
  String get findAlreadyWatchedTitle;

  /// No description provided for @findAlreadyWatchedBody.
  ///
  /// In en, this message translates to:
  /// **'You can’t add an already-watched film to your Watchlist.'**
  String get findAlreadyWatchedBody;

  /// No description provided for @findAlreadyInListTitle.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get findAlreadyInListTitle;

  /// No description provided for @findAlreadyInListBody.
  ///
  /// In en, this message translates to:
  /// **'{title} is already in {target}.'**
  String findAlreadyInListBody(String title, String target);

  /// No description provided for @findGenericErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get findGenericErrorTitle;

  /// No description provided for @findGenericErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get findGenericErrorBody;

  /// No description provided for @findDetailsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load the film'**
  String get findDetailsErrorTitle;

  /// No description provided for @findDetailsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get findDetailsRetry;

  /// No description provided for @findDetailsCast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get findDetailsCast;

  /// No description provided for @findDetailsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get findDetailsOverview;

  /// No description provided for @findDetailsRuntime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String findDetailsRuntime(int minutes);

  /// No description provided for @findDetailsVote.
  ///
  /// In en, this message translates to:
  /// **'{value} stars'**
  String findDetailsVote(String value);

  /// No description provided for @findWatchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch now'**
  String get findWatchNow;

  /// No description provided for @findAttribution.
  ///
  /// In en, this message translates to:
  /// **'Film data and posters via TMDB. Streaming availability via JustWatch.'**
  String get findAttribution;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
