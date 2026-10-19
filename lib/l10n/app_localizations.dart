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

  /// No description provided for @overviewBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get overviewBack;

  /// No description provided for @overviewRating.
  ///
  /// In en, this message translates to:
  /// **'{value} / 10'**
  String overviewRating(String value);

  /// No description provided for @overviewNoRating.
  ///
  /// In en, this message translates to:
  /// **'No rating yet'**
  String get overviewNoRating;

  /// No description provided for @overviewWhereToWatch.
  ///
  /// In en, this message translates to:
  /// **'Where to watch?'**
  String get overviewWhereToWatch;

  /// No description provided for @overviewNoStreaming.
  ///
  /// In en, this message translates to:
  /// **'No streaming providers found'**
  String get overviewNoStreaming;

  /// No description provided for @overviewRatingsCount.
  ///
  /// In en, this message translates to:
  /// **'Ratings: {count} filmwiser'**
  String overviewRatingsCount(int count);

  /// No description provided for @overviewStarsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} out of 5 stars'**
  String overviewStarsValue(String value);

  /// No description provided for @overviewTrailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get overviewTrailer;

  /// No description provided for @overviewStreamLabel.
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get overviewStreamLabel;

  /// No description provided for @overviewRentLabel.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get overviewRentLabel;

  /// No description provided for @overviewBuyLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get overviewBuyLabel;

  /// No description provided for @overviewNoGenres.
  ///
  /// In en, this message translates to:
  /// **'No genres listed'**
  String get overviewNoGenres;

  /// No description provided for @overviewTabGenres.
  ///
  /// In en, this message translates to:
  /// **'GENRES'**
  String get overviewTabGenres;

  /// No description provided for @overviewTabCast.
  ///
  /// In en, this message translates to:
  /// **'CAST'**
  String get overviewTabCast;

  /// No description provided for @overviewTabCrew.
  ///
  /// In en, this message translates to:
  /// **'CREW'**
  String get overviewTabCrew;

  /// No description provided for @overviewTabProd.
  ///
  /// In en, this message translates to:
  /// **'PROD'**
  String get overviewTabProd;

  /// No description provided for @overviewActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity From Friends'**
  String get overviewActivityTitle;

  /// No description provided for @overviewWantsToWatch.
  ///
  /// In en, this message translates to:
  /// **'Wants to watch'**
  String get overviewWantsToWatch;

  /// No description provided for @overviewReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get overviewReviewsTitle;

  /// No description provided for @overviewAddReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Add a review...'**
  String get overviewAddReviewHint;

  /// No description provided for @overviewYourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get overviewYourReview;

  /// No description provided for @overviewFriendsReviews.
  ///
  /// In en, this message translates to:
  /// **'Friends Reviews'**
  String get overviewFriendsReviews;

  /// No description provided for @overviewPopularReviews.
  ///
  /// In en, this message translates to:
  /// **'Popular Reviews'**
  String get overviewPopularReviews;

  /// No description provided for @overviewSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get overviewSeeAll;

  /// No description provided for @overviewReviewBy.
  ///
  /// In en, this message translates to:
  /// **'Review by {name} on {date}'**
  String overviewReviewBy(String name, String date);

  /// No description provided for @homeOpenProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get homeOpenProfile;

  /// No description provided for @profileBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get profileBack;

  /// No description provided for @profileSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get profileSearchTooltip;

  /// No description provided for @profileMoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get profileMoreTooltip;

  /// No description provided for @profileFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profileFollowers;

  /// No description provided for @profileFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileFollowing;

  /// No description provided for @profileBioHint.
  ///
  /// In en, this message translates to:
  /// **'Edit your bio..'**
  String get profileBioHint;

  /// No description provided for @profileChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get profileChat;

  /// No description provided for @profileFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get profileFollow;

  /// No description provided for @profileSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get profileSend;

  /// No description provided for @profileAchievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profileAchievementsTitle;

  /// No description provided for @profileAchievementRookie.
  ///
  /// In en, this message translates to:
  /// **'CINEPHILE ROOKIE'**
  String get profileAchievementRookie;

  /// No description provided for @profileAchievementMaster.
  ///
  /// In en, this message translates to:
  /// **'CINEPHILE MASTER'**
  String get profileAchievementMaster;

  /// No description provided for @profileAchievementLegend.
  ///
  /// In en, this message translates to:
  /// **'CINEPHILE LEGEND'**
  String get profileAchievementLegend;

  /// No description provided for @profileAchievementFilms.
  ///
  /// In en, this message translates to:
  /// **'{count} films'**
  String profileAchievementFilms(int count);

  /// No description provided for @profileClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get profileClaim;

  /// No description provided for @profileStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get profileStatisticsTitle;

  /// No description provided for @profileStatWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get profileStatWatched;

  /// No description provided for @profileStatWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get profileStatWatchlist;

  /// No description provided for @profileStatReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get profileStatReviews;

  /// No description provided for @profileStatRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get profileStatRewards;

  /// No description provided for @profileBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'You want to block this user?'**
  String get profileBlockTitle;

  /// No description provided for @profileBlockReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why?..'**
  String get profileBlockReasonHint;

  /// No description provided for @profileBlockYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get profileBlockYes;

  /// No description provided for @profileBlockNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get profileBlockNo;

  /// No description provided for @profileErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your profile.'**
  String get profileErrorTitle;

  /// No description provided for @profileRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get profileRetry;

  /// No description provided for @onboardingFinishLater.
  ///
  /// In en, this message translates to:
  /// **'Finish later'**
  String get onboardingFinishLater;

  /// No description provided for @onboardingStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepCounter(int current, int total);

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkip;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that. Check your connection and try again.'**
  String get onboardingSaveFailed;

  /// No description provided for @onboardingAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo'**
  String get onboardingAvatarTitle;

  /// No description provided for @onboardingAvatarBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a picture so people can recognise you. JPG, PNG or WebP, up to 5 MB.'**
  String get onboardingAvatarBody;

  /// No description provided for @onboardingChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get onboardingChoosePhoto;

  /// No description provided for @onboardingPhotoSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile photo saved'**
  String get onboardingPhotoSaved;

  /// No description provided for @onboardingCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a cover photo'**
  String get onboardingCoverTitle;

  /// No description provided for @onboardingCoverBody.
  ///
  /// In en, this message translates to:
  /// **'A wide image behind your profile header.'**
  String get onboardingCoverBody;

  /// No description provided for @onboardingChooseCover.
  ///
  /// In en, this message translates to:
  /// **'Choose cover'**
  String get onboardingChooseCover;

  /// No description provided for @onboardingCoverSaved.
  ///
  /// In en, this message translates to:
  /// **'Cover saved'**
  String get onboardingCoverSaved;

  /// No description provided for @onboardingBioTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a short bio'**
  String get onboardingBioTitle;

  /// No description provided for @onboardingBioBody.
  ///
  /// In en, this message translates to:
  /// **'Tell people what kind of films you love.'**
  String get onboardingBioBody;

  /// No description provided for @onboardingBioHint.
  ///
  /// In en, this message translates to:
  /// **'A few words about your taste in film'**
  String get onboardingBioHint;

  /// No description provided for @onboardingTop5Title.
  ///
  /// In en, this message translates to:
  /// **'Choose your top 5 movies'**
  String get onboardingTop5Title;

  /// No description provided for @onboardingTop5Body.
  ///
  /// In en, this message translates to:
  /// **'Your favourite films, shown first on your profile.'**
  String get onboardingTop5Body;

  /// No description provided for @onboardingTop5Progress.
  ///
  /// In en, this message translates to:
  /// **'{count} of 5 chosen'**
  String onboardingTop5Progress(int count);

  /// No description provided for @onboardingWatchedTitle.
  ///
  /// In en, this message translates to:
  /// **'Add movies you\'ve watched'**
  String get onboardingWatchedTitle;

  /// No description provided for @onboardingWatchedBody.
  ///
  /// In en, this message translates to:
  /// **'Log the films you have already seen.'**
  String get onboardingWatchedBody;

  /// No description provided for @onboardingWatchlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Add movies to watch'**
  String get onboardingWatchlistTitle;

  /// No description provided for @onboardingWatchlistBody.
  ///
  /// In en, this message translates to:
  /// **'Save the films you plan to watch next.'**
  String get onboardingWatchlistBody;

  /// No description provided for @onboardingFilmsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 film added} other{{count} films added}}'**
  String onboardingFilmsAdded(int count);

  /// No description provided for @onboardingSearchFilms.
  ///
  /// In en, this message translates to:
  /// **'Search films'**
  String get onboardingSearchFilms;

  /// No description provided for @profileNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsTooltip;

  /// No description provided for @profileEditPhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get profileEditPhoto;

  /// No description provided for @profileEditCover.
  ///
  /// In en, this message translates to:
  /// **'Edit cover'**
  String get profileEditCover;

  /// No description provided for @profileEditBio.
  ///
  /// In en, this message translates to:
  /// **'Edit bio'**
  String get profileEditBio;

  /// No description provided for @profileEditBioTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your bio'**
  String get profileEditBioTitle;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that. Try again.'**
  String get profileSaveFailed;

  /// No description provided for @profileNoConnections.
  ///
  /// In en, this message translates to:
  /// **'No one here yet.'**
  String get profileNoConnections;

  /// No description provided for @friendAdd.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get friendAdd;

  /// No description provided for @friendCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get friendCancelRequest;

  /// No description provided for @friendAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friendAccept;

  /// No description provided for @friendDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get friendDecline;

  /// No description provided for @friendFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendFriends;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent.'**
  String get friendRequestSent;

  /// No description provided for @friendActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the friend request. Try again.'**
  String get friendActionFailed;

  /// No description provided for @friendRequestGone.
  ///
  /// In en, this message translates to:
  /// **'This request is no longer available.'**
  String get friendRequestGone;

  /// No description provided for @friendAlreadyConnected.
  ///
  /// In en, this message translates to:
  /// **'You\'re already friends or have a pending request.'**
  String get friendAlreadyConnected;

  /// No description provided for @searchPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Find people'**
  String get searchPeopleTitle;

  /// No description provided for @searchPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'Search by username'**
  String get searchPeopleHint;

  /// No description provided for @searchPeopleMinChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters.'**
  String get searchPeopleMinChars;

  /// No description provided for @searchPeopleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get searchPeopleEmpty;

  /// No description provided for @searchPeopleFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search right now. Try again.'**
  String get searchPeopleFailed;

  /// No description provided for @suggestMovieAction.
  ///
  /// In en, this message translates to:
  /// **'Suggest a movie'**
  String get suggestMovieAction;

  /// No description provided for @suggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggest a movie'**
  String get suggestionTitle;

  /// No description provided for @suggestionSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a movie title'**
  String get suggestionSearchHint;

  /// No description provided for @suggestionSearchMinChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters.'**
  String get suggestionSearchMinChars;

  /// No description provided for @suggestionSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No movies found.'**
  String get suggestionSearchEmpty;

  /// No description provided for @suggestionSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search right now. Try again.'**
  String get suggestionSearchFailed;

  /// No description provided for @suggestionMovieSection.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get suggestionMovieSection;

  /// No description provided for @suggestionPickMovie.
  ///
  /// In en, this message translates to:
  /// **'Pick a movie to suggest.'**
  String get suggestionPickMovie;

  /// No description provided for @suggestionChangeMovie.
  ///
  /// In en, this message translates to:
  /// **'Change movie'**
  String get suggestionChangeMovie;

  /// No description provided for @suggestionRecipientsSection.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get suggestionRecipientsSection;

  /// No description provided for @suggestionSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get suggestionSelectAll;

  /// No description provided for @suggestionNoFriends.
  ///
  /// In en, this message translates to:
  /// **'Add friends first to send them suggestions.'**
  String get suggestionNoFriends;

  /// No description provided for @suggestionFriendsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your friends.'**
  String get suggestionFriendsFailed;

  /// No description provided for @suggestionCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment (optional)'**
  String get suggestionCommentHint;

  /// No description provided for @suggestionSend.
  ///
  /// In en, this message translates to:
  /// **'Send suggestion'**
  String get suggestionSend;

  /// No description provided for @suggestionSent.
  ///
  /// In en, this message translates to:
  /// **'Suggestion sent.'**
  String get suggestionSent;

  /// No description provided for @suggestionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the suggestion. Try again.'**
  String get suggestionFailed;

  /// No description provided for @suggestionNotFriends.
  ///
  /// In en, this message translates to:
  /// **'You can only suggest movies to friends. Update your selection and try again.'**
  String get suggestionNotFriends;

  /// No description provided for @notificationMovieSuggestion.
  ///
  /// In en, this message translates to:
  /// **'{name} suggested {title} to you.'**
  String notificationMovieSuggestion(String name, String title);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load notifications.'**
  String get notificationsFailed;

  /// No description provided for @notificationFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a friend request.'**
  String notificationFriendRequest(String name);

  /// No description provided for @notificationFriendAccepted.
  ///
  /// In en, this message translates to:
  /// **'{name} accepted your friend request.'**
  String notificationFriendAccepted(String name);
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
