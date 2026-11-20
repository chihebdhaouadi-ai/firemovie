import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('ru')
  ];

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

  /// No description provided for @homeCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get homeCollectionsTitle;

  /// No description provided for @homeTabYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get homeTabYou;

  /// No description provided for @homeTabFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get homeTabFriends;

  /// No description provided for @homeTabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeTabExplore;

  /// No description provided for @homeTabFilms.
  ///
  /// In en, this message translates to:
  /// **'Films'**
  String get homeTabFilms;

  /// No description provided for @homePopularTakesTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular takes'**
  String get homePopularTakesTitle;

  /// No description provided for @homeTrendingTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending topics'**
  String get homeTrendingTopicsTitle;

  /// No description provided for @homeTrendingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No questions or discussions this week yet.'**
  String get homeTrendingEmpty;

  /// No description provided for @homeLatestArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest articles'**
  String get homeLatestArticlesTitle;

  /// No description provided for @homeUpcomingThisMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Films'**
  String get homeUpcomingThisMonthTitle;

  /// No description provided for @upcomingNotOutYet.
  ///
  /// In en, this message translates to:
  /// **'{title} is not out yet. It releases on {date}.'**
  String upcomingNotOutYet(String title, String date);

  /// No description provided for @homePopularThisWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular Films'**
  String get homePopularThisWeekTitle;

  /// No description provided for @homeFriendsFilmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular with Friends'**
  String get homeFriendsFilmsTitle;

  /// No description provided for @homeFriendsReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends\' latest takes'**
  String get homeFriendsReviewsTitle;

  /// No description provided for @homeMyTakesTitle.
  ///
  /// In en, this message translates to:
  /// **'My takes'**
  String get homeMyTakesTitle;

  /// No description provided for @homeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get homeComingSoon;

  /// Friends tab heading for the messaging inbox
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get homeInboxTitle;

  /// Shown while messaging is not built yet
  ///
  /// In en, this message translates to:
  /// **'Under construction'**
  String get homeInboxSoonTitle;

  /// No description provided for @homeInboxSoonBody.
  ///
  /// In en, this message translates to:
  /// **'Messages with your friends will land here soon.'**
  String get homeInboxSoonBody;

  /// No description provided for @homeFriendsReviewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your friends haven\'t posted any takes yet.'**
  String get homeFriendsReviewsEmpty;

  /// No description provided for @homeMyTakesEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t shared any takes yet.'**
  String get homeMyTakesEmpty;

  /// No description provided for @homeUnderConstruction.
  ///
  /// In en, this message translates to:
  /// **'This section is under construction.'**
  String get homeUnderConstruction;

  /// No description provided for @exploreSkipStamp.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get exploreSkipStamp;

  /// No description provided for @exploreOpenStamp.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get exploreOpenStamp;

  /// No description provided for @exploreCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up'**
  String get exploreCaughtUp;

  /// No description provided for @exploreReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Take'**
  String get exploreReviewButton;

  /// No description provided for @exploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover takes, conversations and questions about films.'**
  String get exploreSubtitle;

  /// No description provided for @createSceneMovieHint.
  ///
  /// In en, this message translates to:
  /// **'Your scene appears in that movie\'s discussion.'**
  String get createSceneMovieHint;

  /// No description provided for @createPollQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to ask?'**
  String get createPollQuestionHint;

  /// No description provided for @exploreFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exploreFilterAll;

  /// No description provided for @exploreFilterConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get exploreFilterConversations;

  /// No description provided for @exploreFilterPolls.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get exploreFilterPolls;

  /// No description provided for @exploreFilterScenes.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get exploreFilterScenes;

  /// No description provided for @exploreFilterQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get exploreFilterQuestions;

  /// No description provided for @exploreFilterReviews.
  ///
  /// In en, this message translates to:
  /// **'Takes'**
  String get exploreFilterReviews;

  /// No description provided for @exploreSpoilerReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get exploreSpoilerReveal;

  /// No description provided for @topicTagPoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get topicTagPoll;

  /// No description provided for @topicTagScene.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get topicTagScene;

  /// No description provided for @topicSpoilerLabel.
  ///
  /// In en, this message translates to:
  /// **'Contains spoilers'**
  String get topicSpoilerLabel;

  /// No description provided for @pollVoteHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an option to vote'**
  String get pollVoteHint;

  /// No description provided for @pollChangeVoteHint.
  ///
  /// In en, this message translates to:
  /// **'Tap another option to change your vote'**
  String get pollChangeVoteHint;

  /// No description provided for @pollVoteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 vote} other{{count} votes}}'**
  String pollVoteCount(int count);

  /// No description provided for @createTypePollSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let people vote between 2 and 4 options.'**
  String get createTypePollSubtitle;

  /// No description provided for @createTypeSceneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one moment from a film and explain why it works.'**
  String get createTypeSceneSubtitle;

  /// No description provided for @createWritePollTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your poll question'**
  String get createWritePollTitle;

  /// No description provided for @createPollOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add the options'**
  String get createPollOptionsTitle;

  /// No description provided for @createPollOptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Give 2 to 4 choices. People pick one.'**
  String get createPollOptionsHint;

  /// No description provided for @createPollOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String createPollOptionLabel(int number);

  /// No description provided for @createPollAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get createPollAddOption;

  /// No description provided for @createPollRemoveOption.
  ///
  /// In en, this message translates to:
  /// **'Remove option'**
  String get createPollRemoveOption;

  /// No description provided for @createSceneTitle.
  ///
  /// In en, this message translates to:
  /// **'Describe the scene'**
  String get createSceneTitle;

  /// No description provided for @createSceneNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get createSceneNameLabel;

  /// No description provided for @createSceneNameHint.
  ///
  /// In en, this message translates to:
  /// **'The interrogation room'**
  String get createSceneNameHint;

  /// No description provided for @createSceneTimecodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Timecode (optional)'**
  String get createSceneTimecodeLabel;

  /// No description provided for @createSceneTimecodeHint.
  ///
  /// In en, this message translates to:
  /// **'1h 12m'**
  String get createSceneTimecodeHint;

  /// No description provided for @createSceneExplainLabel.
  ///
  /// In en, this message translates to:
  /// **'Why it works'**
  String get createSceneExplainLabel;

  /// No description provided for @createSceneExplainHint.
  ///
  /// In en, this message translates to:
  /// **'Say what makes this moment special'**
  String get createSceneExplainHint;

  /// No description provided for @exploreRepliesButton.
  ///
  /// In en, this message translates to:
  /// **'View all {count} replies'**
  String exploreRepliesButton(int count);

  /// No description provided for @exploreStripConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get exploreStripConversation;

  /// No description provided for @exploreRepliesShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reply} other{{count} replies}}'**
  String exploreRepliesShort(int count);

  /// No description provided for @exploreNoRepliesYet.
  ///
  /// In en, this message translates to:
  /// **'No replies yet'**
  String get exploreNoRepliesYet;

  /// No description provided for @exploreBeFirstRespond.
  ///
  /// In en, this message translates to:
  /// **'Be the first to respond'**
  String get exploreBeFirstRespond;

  /// No description provided for @explorePeopleTalking.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person talking} other{{count} people talking}}'**
  String explorePeopleTalking(int count);

  /// No description provided for @exploreLastReply.
  ///
  /// In en, this message translates to:
  /// **'last reply {time}'**
  String exploreLastReply(String time);

  /// No description provided for @exploreNoVotesYet.
  ///
  /// In en, this message translates to:
  /// **'No votes yet'**
  String get exploreNoVotesYet;

  /// No description provided for @exploreAgreePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% agree'**
  String exploreAgreePercent(int percent);

  /// No description provided for @exploreDisagreePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% disagree'**
  String exploreDisagreePercent(int percent);

  /// No description provided for @exploreFor.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get exploreFor;

  /// No description provided for @exploreAgainst.
  ///
  /// In en, this message translates to:
  /// **'Against'**
  String get exploreAgainst;

  /// No description provided for @exploreBeFirstArgue.
  ///
  /// In en, this message translates to:
  /// **'Be the first to argue {side}'**
  String exploreBeFirstArgue(String side);

  /// No description provided for @explorePickedBy.
  ///
  /// In en, this message translates to:
  /// **'picked by {name}'**
  String explorePickedBy(String name);

  /// No description provided for @exploreThanksVoting.
  ///
  /// In en, this message translates to:
  /// **'Thanks for voting'**
  String get exploreThanksVoting;

  /// No description provided for @exploreJoinConversation.
  ///
  /// In en, this message translates to:
  /// **'Join the conversation'**
  String get exploreJoinConversation;

  /// No description provided for @homeCollectionsResizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resize collections'**
  String get homeCollectionsResizeLabel;

  /// No description provided for @homeFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Takes From Your Collections'**
  String get homeFeedTitle;

  /// No description provided for @homeFeedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No takes on the films in your collections yet.'**
  String get homeFeedEmpty;

  /// No description provided for @homeFeedShowAsRow.
  ///
  /// In en, this message translates to:
  /// **'Show as row'**
  String get homeFeedShowAsRow;

  /// No description provided for @homeFeedShowAsColumn.
  ///
  /// In en, this message translates to:
  /// **'Show as column'**
  String get homeFeedShowAsColumn;

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

  /// No description provided for @overviewNoFriendActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity from your friends yet.'**
  String get overviewNoFriendActivity;

  /// No description provided for @overviewShowMore.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get overviewShowMore;

  /// No description provided for @overviewShowLess.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get overviewShowLess;

  /// No description provided for @overviewReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Takes'**
  String get overviewReviewsTitle;

  /// No description provided for @overviewAddReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Add a take...'**
  String get overviewAddReviewHint;

  /// No description provided for @overviewYourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Take'**
  String get overviewYourReview;

  /// No description provided for @overviewFriendsReviews.
  ///
  /// In en, this message translates to:
  /// **'Friends\' Takes'**
  String get overviewFriendsReviews;

  /// No description provided for @overviewPopularReviews.
  ///
  /// In en, this message translates to:
  /// **'Popular Takes'**
  String get overviewPopularReviews;

  /// No description provided for @overviewSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get overviewSeeAll;

  /// No description provided for @reviewTrustedLabel.
  ///
  /// In en, this message translates to:
  /// **'from trusted viewers'**
  String get reviewTrustedLabel;

  /// No description provided for @reviewEveryoneTogether.
  ///
  /// In en, this message translates to:
  /// **'Everyone together: {value}'**
  String reviewEveryoneTogether(String value);

  /// No description provided for @reviewMostFelt.
  ///
  /// In en, this message translates to:
  /// **'Most felt:'**
  String get reviewMostFelt;

  /// No description provided for @reviewWhatIsTrusted.
  ///
  /// In en, this message translates to:
  /// **'What is “trusted”?'**
  String get reviewWhatIsTrusted;

  /// No description provided for @reviewTrustedNote.
  ///
  /// In en, this message translates to:
  /// **'Viewers earn trust when others find their takes well argued. Their votes count a little more, so the score feels fair and thoughtful.'**
  String get reviewTrustedNote;

  /// No description provided for @reviewReactionTitle.
  ///
  /// In en, this message translates to:
  /// **'How did it make you feel?'**
  String get reviewReactionTitle;

  /// No description provided for @reviewReactionHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the one that fits best.'**
  String get reviewReactionHint;

  /// No description provided for @reviewReactionLoved.
  ///
  /// In en, this message translates to:
  /// **'Loved it'**
  String get reviewReactionLoved;

  /// No description provided for @reviewReactionBrokeHeart.
  ///
  /// In en, this message translates to:
  /// **'Broke my heart'**
  String get reviewReactionBrokeHeart;

  /// No description provided for @reviewReactionBlewMind.
  ///
  /// In en, this message translates to:
  /// **'Blew my mind'**
  String get reviewReactionBlewMind;

  /// No description provided for @reviewReactionMadeCry.
  ///
  /// In en, this message translates to:
  /// **'Made me cry'**
  String get reviewReactionMadeCry;

  /// No description provided for @reviewReactionShocked.
  ///
  /// In en, this message translates to:
  /// **'Shocked me'**
  String get reviewReactionShocked;

  /// No description provided for @reviewReactionMadeLaugh.
  ///
  /// In en, this message translates to:
  /// **'Made me laugh'**
  String get reviewReactionMadeLaugh;

  /// No description provided for @reviewReactionBored.
  ///
  /// In en, this message translates to:
  /// **'Bored me'**
  String get reviewReactionBored;

  /// No description provided for @reviewReactionDisappointed.
  ///
  /// In en, this message translates to:
  /// **'Disappointed me'**
  String get reviewReactionDisappointed;

  /// No description provided for @reviewReactionMadeThink.
  ///
  /// In en, this message translates to:
  /// **'Made me think'**
  String get reviewReactionMadeThink;

  /// No description provided for @reviewReactionMasterpiece.
  ///
  /// In en, this message translates to:
  /// **'Masterpiece'**
  String get reviewReactionMasterpiece;

  /// No description provided for @reviewReactionTapToReact.
  ///
  /// In en, this message translates to:
  /// **'Tap to react'**
  String get reviewReactionTapToReact;

  /// No description provided for @reviewReactionChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get reviewReactionChange;

  /// No description provided for @reviewReactionPickOne.
  ///
  /// In en, this message translates to:
  /// **'Pick one'**
  String get reviewReactionPickOne;

  /// No description provided for @reviewReactionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get reviewReactionClose;

  /// No description provided for @reviewWhyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Want to add a line about why? It\'s optional.'**
  String get reviewWhyPrompt;

  /// No description provided for @reviewWhyHint.
  ///
  /// In en, this message translates to:
  /// **'What stayed with you?'**
  String get reviewWhyHint;

  /// No description provided for @reviewShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get reviewShare;

  /// No description provided for @reviewNoThanks.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get reviewNoThanks;

  /// No description provided for @reviewSharedThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for sharing your take!'**
  String get reviewSharedThanks;

  /// No description provided for @reviewCountedThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your reaction is counted.'**
  String get reviewCountedThanks;

  /// No description provided for @reviewReactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your reaction. Try again.'**
  String get reviewReactionFailed;

  /// No description provided for @reviewSummaryFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the reactions.'**
  String get reviewSummaryFailed;

  /// No description provided for @reviewDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Take'**
  String get reviewDetailTitle;

  /// No description provided for @reviewTakesTitle.
  ///
  /// In en, this message translates to:
  /// **'What people said'**
  String get reviewTakesTitle;

  /// No description provided for @reviewTakesHint.
  ///
  /// In en, this message translates to:
  /// **'Short takes from other viewers.'**
  String get reviewTakesHint;

  /// No description provided for @reviewMostHelpful.
  ///
  /// In en, this message translates to:
  /// **'Most helpful take'**
  String get reviewMostHelpful;

  /// No description provided for @sageNavUnread.
  ///
  /// In en, this message translates to:
  /// **'Has unread'**
  String get sageNavUnread;

  /// No description provided for @sageNavCloseMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get sageNavCloseMenu;

  /// No description provided for @reviewWriterBadge.
  ///
  /// In en, this message translates to:
  /// **'Writer'**
  String get reviewWriterBadge;

  /// No description provided for @reviewCommentsButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Comment} other{Comments {count}}}'**
  String reviewCommentsButton(int count);

  /// No description provided for @reviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get reviewCommentHint;

  /// No description provided for @reviewSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get reviewSend;

  /// No description provided for @reviewCommentsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load comments.'**
  String get reviewCommentsFailed;

  /// No description provided for @reviewCommentFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post that comment. Try again.'**
  String get reviewCommentFailed;

  /// No description provided for @reviewReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reviewReply;

  /// No description provided for @reviewReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String reviewReplyingTo(String name);

  /// No description provided for @reviewCancelReply.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get reviewCancelReply;

  /// No description provided for @reviewShowReplies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 reply} other{Show {count} replies}}'**
  String reviewShowReplies(int count);

  /// No description provided for @reviewHideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get reviewHideReplies;

  /// No description provided for @reviewTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get reviewTimeJustNow;

  /// No description provided for @reviewTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String reviewTimeMinutes(int count);

  /// No description provided for @reviewTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String reviewTimeHours(int count);

  /// No description provided for @reviewTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String reviewTimeDays(int count);

  /// No description provided for @reviewVoteChangedMyMind.
  ///
  /// In en, this message translates to:
  /// **'Changed my mind'**
  String get reviewVoteChangedMyMind;

  /// No description provided for @reviewVoteWellArgued.
  ///
  /// In en, this message translates to:
  /// **'Well argued'**
  String get reviewVoteWellArgued;

  /// No description provided for @reviewVoteDisagreeFair.
  ///
  /// In en, this message translates to:
  /// **'Disagree but fair'**
  String get reviewVoteDisagreeFair;

  /// No description provided for @reviewVoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update that vote. Try again.'**
  String get reviewVoteFailed;

  /// No description provided for @reviewTakeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post that. Try again.'**
  String get reviewTakeFailed;

  /// No description provided for @reviewTakesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No takes here yet.'**
  String get reviewTakesEmpty;

  /// No description provided for @reviewTakesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load takes.'**
  String get reviewTakesFailed;

  /// No description provided for @reviewRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get reviewRetry;

  /// No description provided for @overviewReviewBy.
  ///
  /// In en, this message translates to:
  /// **'Take by {name} on {date}'**
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

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

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
  /// **'Edit your bio…'**
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
  /// **'{count, plural, =1{1 film} other{{count} films}}'**
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
  /// **'Takes'**
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
  /// **'Why?…'**
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

  /// No description provided for @profileLanguageButton.
  ///
  /// In en, this message translates to:
  /// **'Manage languages'**
  String get profileLanguageButton;

  /// No description provided for @profileLanguageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get profileLanguageDialogTitle;

  /// No description provided for @profileLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get profileLanguageSystem;

  /// Profile: button that opens the light / dark appearance picker.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileThemeButton;

  /// Title of the appearance (light / dark) picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileThemeDialogTitle;

  /// Appearance option that follows the device light or dark setting.
  ///
  /// In en, this message translates to:
  /// **'Match system'**
  String get profileThemeSystem;

  /// Appearance option: light mode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// Appearance option: dark mode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

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

  /// No description provided for @angelBirdQuestion.
  ///
  /// In en, this message translates to:
  /// **'Want to join a debate about one of your top 5 movies? The Sage community would love to hear your opinion.'**
  String get angelBirdQuestion;

  /// No description provided for @angelBirdYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, let\'s debate'**
  String get angelBirdYes;

  /// No description provided for @angelBirdNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get angelBirdNotNow;

  /// No description provided for @angelBirdPickFilm.
  ///
  /// In en, this message translates to:
  /// **'Pick a film to debate'**
  String get angelBirdPickFilm;

  /// No description provided for @angelBirdEmptyTop5.
  ///
  /// In en, this message translates to:
  /// **'Your top 5 is empty. Add five films to start a debate.'**
  String get angelBirdEmptyTop5;

  /// No description provided for @angelBirdLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your top 5.'**
  String get angelBirdLoadFailed;

  /// No description provided for @angelBirdRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get angelBirdRetry;

  /// No description provided for @angelBirdReviewQuestion.
  ///
  /// In en, this message translates to:
  /// **'Want to open a debate about this take? Pick someone from this conversation to talk with.'**
  String get angelBirdReviewQuestion;

  /// No description provided for @angelBirdPickPerson.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to debate with?'**
  String get angelBirdPickPerson;

  /// No description provided for @angelBirdNoPeople.
  ///
  /// In en, this message translates to:
  /// **'Nobody to debate with yet. Wait for a comment on this take.'**
  String get angelBirdNoPeople;

  /// No description provided for @angelBirdPeopleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the people in this take.'**
  String get angelBirdPeopleFailed;

  /// No description provided for @debateWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}'**
  String debateWaitingTitle(String name);

  /// No description provided for @debateWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Your invite is sent. The debate starts as soon as {name} accepts.'**
  String debateWaitingBody(String name);

  /// No description provided for @debateDeclined.
  ///
  /// In en, this message translates to:
  /// **'{name} can\'t debate right now. Try someone else from the conversation.'**
  String debateDeclined(String name);

  /// No description provided for @debateInviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your invite. Try again.'**
  String get debateInviteFailed;

  /// No description provided for @debateLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the questions. Try again.'**
  String get debateLoadFailed;

  /// No description provided for @debateSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your answers. Try again.'**
  String get debateSubmitFailed;

  /// No description provided for @debateRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get debateRetry;

  /// No description provided for @debateCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get debateCancel;

  /// No description provided for @debateDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get debateDone;

  /// No description provided for @debateVsTitle.
  ///
  /// In en, this message translates to:
  /// **'You vs {name}'**
  String debateVsTitle(String name);

  /// No description provided for @debateQuestionCounter.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String debateQuestionCounter(int current, int total);

  /// No description provided for @debateResultWon.
  ///
  /// In en, this message translates to:
  /// **'You won the debate!'**
  String get debateResultWon;

  /// No description provided for @debateResultLost.
  ///
  /// In en, this message translates to:
  /// **'{name} won this round.'**
  String debateResultLost(String name);

  /// No description provided for @debateResultTied.
  ///
  /// In en, this message translates to:
  /// **'It\'s a tie.'**
  String get debateResultTied;

  /// No description provided for @debateScoreLine.
  ///
  /// In en, this message translates to:
  /// **'You {mine} · {name} {theirs}'**
  String debateScoreLine(int mine, String name, int theirs);

  /// No description provided for @debateSagePointsWon.
  ///
  /// In en, this message translates to:
  /// **'+{points} Sage points'**
  String debateSagePointsWon(int points);

  /// No description provided for @debateSagePointsLost.
  ///
  /// In en, this message translates to:
  /// **'{points} Sage points go to {name}.'**
  String debateSagePointsLost(int points, String name);

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK YOUR INNER FILM BUFF'**
  String get authTagline;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccountPrompt;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsMismatch;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authRepeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get authRepeatPassword;

  /// No description provided for @authHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccountPrompt;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordTooShort;

  /// No description provided for @authUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get authUsernameRequired;

  /// No description provided for @authUsernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 6 characters'**
  String get authUsernameTooShort;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. Sign in to continue.'**
  String get authAccountCreated;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithReddit.
  ///
  /// In en, this message translates to:
  /// **'Continue with Reddit'**
  String get authContinueWithReddit;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to pick up where you left off.'**
  String get authSignInSubtitle;

  /// No description provided for @authCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the community and start sharing your takes.'**
  String get authCreateAccountSubtitle;

  /// No description provided for @authMinLengthHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authMinLengthHint;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create your account. Please try again.'**
  String get authErrorRegisterFailed;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection and try again.'**
  String get authErrorNetwork;

  /// No description provided for @appWindowTitle.
  ///
  /// In en, this message translates to:
  /// **'My App'**
  String get appWindowTitle;

  /// No description provided for @findActionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get findActionAdd;

  /// No description provided for @findActionAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get findActionAdded;

  /// No description provided for @reviewTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get reviewTranslate;

  /// No description provided for @reviewShowOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get reviewShowOriginal;

  /// No description provided for @reviewTranslateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t translate this right now.'**
  String get reviewTranslateFailed;

  /// No description provided for @reviewQuote.
  ///
  /// In en, this message translates to:
  /// **'“{body}”'**
  String reviewQuote(String body);

  /// No description provided for @exploreCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get exploreCreateButton;

  /// No description provided for @topicCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create topic'**
  String get topicCreateTitle;

  /// No description provided for @topicFindMovie.
  ///
  /// In en, this message translates to:
  /// **'Find a movie'**
  String get topicFindMovie;

  /// No description provided for @topicSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search movies'**
  String get topicSearchHint;

  /// No description provided for @topicNoResults.
  ///
  /// In en, this message translates to:
  /// **'No movies found'**
  String get topicNoResults;

  /// No description provided for @topicChangeMovie.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get topicChangeMovie;

  /// No description provided for @topicTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get topicTypeLabel;

  /// No description provided for @topicTagReview.
  ///
  /// In en, this message translates to:
  /// **'Take'**
  String get topicTagReview;

  /// No description provided for @topicTagQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get topicTagQuestion;

  /// No description provided for @topicTagDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get topicTagDiscussion;

  /// No description provided for @topicTagHotTake.
  ///
  /// In en, this message translates to:
  /// **'Hot Take'**
  String get topicTagHotTake;

  /// No description provided for @topicReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Takes are about one movie and need how it made you feel.'**
  String get topicReviewHint;

  /// No description provided for @topicBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your take, question or discussion'**
  String get topicBodyHint;

  /// No description provided for @topicPostButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get topicPostButton;

  /// No description provided for @topicPostFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not post. Please try again.'**
  String get topicPostFailed;

  /// No description provided for @topicSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get topicSearchFailed;

  /// No description provided for @createTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to share.'**
  String get createTypeTitle;

  /// No description provided for @createTypeReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell people how a movie made you feel.'**
  String get createTypeReviewSubtitle;

  /// No description provided for @createTypeQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about a movie or share a photo.'**
  String get createTypeQuestionSubtitle;

  /// No description provided for @createTypeDiscussionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation about a movie or a photo.'**
  String get createTypeDiscussionSubtitle;

  /// No description provided for @createTypeHotTakeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a bold take about a film.'**
  String get createTypeHotTakeSubtitle;

  /// No description provided for @createWriteReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your take'**
  String get createWriteReviewTitle;

  /// No description provided for @createWriteQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your question'**
  String get createWriteQuestionTitle;

  /// No description provided for @createWriteDiscussionTitle.
  ///
  /// In en, this message translates to:
  /// **'Start the discussion'**
  String get createWriteDiscussionTitle;

  /// No description provided for @createWriteHotTakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your hot take'**
  String get createWriteHotTakeTitle;

  /// No description provided for @createReviewMovieTitle.
  ///
  /// In en, this message translates to:
  /// **'Which movie is it about?'**
  String get createReviewMovieTitle;

  /// No description provided for @createReviewMovieHint.
  ///
  /// In en, this message translates to:
  /// **'Your take appears on that movie\'s page.'**
  String get createReviewMovieHint;

  /// No description provided for @createFeelTitle.
  ///
  /// In en, this message translates to:
  /// **'How did it make you feel?'**
  String get createFeelTitle;

  /// No description provided for @createFeelHint.
  ///
  /// In en, this message translates to:
  /// **'Pick one reaction. It shows with your take.'**
  String get createFeelHint;

  /// No description provided for @createSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'What is it about?'**
  String get createSubjectTitle;

  /// No description provided for @createSubjectMovie.
  ///
  /// In en, this message translates to:
  /// **'A movie'**
  String get createSubjectMovie;

  /// No description provided for @createSubjectPhoto.
  ///
  /// In en, this message translates to:
  /// **'A photo'**
  String get createSubjectPhoto;

  /// No description provided for @createAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get createAddPhoto;

  /// No description provided for @createChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get createChangePhoto;

  /// No description provided for @createPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open your photos. Please try again.'**
  String get createPhotoFailed;

  /// No description provided for @createNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get createNext;

  /// No description provided for @leaderboardTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTabLabel;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Top critics'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ranked by reactions on their takes'**
  String get leaderboardSubtitle;

  /// No description provided for @leaderboardHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get leaderboardHowItWorks;

  /// No description provided for @leaderboardPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get leaderboardPeriodWeek;

  /// No description provided for @leaderboardPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get leaderboardPeriodMonth;

  /// No description provided for @leaderboardPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get leaderboardPeriodAll;

  /// No description provided for @leaderboardReactionsLabel.
  ///
  /// In en, this message translates to:
  /// **'reactions'**
  String get leaderboardReactionsLabel;

  /// No description provided for @leaderboardReactionsWord.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{reaction} other{reactions}}'**
  String leaderboardReactionsWord(int count);

  /// No description provided for @leaderboardReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 take} other{{count} takes}}'**
  String leaderboardReviewsCount(int count);

  /// No description provided for @leaderboardYouSuffix.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get leaderboardYouSuffix;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reactions yet this period.'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the leaderboard.'**
  String get leaderboardLoadFailed;

  /// No description provided for @leaderboardRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get leaderboardRetry;

  /// No description provided for @howRankingTitle.
  ///
  /// In en, this message translates to:
  /// **'How ranking works'**
  String get howRankingTitle;

  /// No description provided for @howStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Write a take'**
  String get howStep1Title;

  /// No description provided for @howStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Share a take on any film. It shows up in Explore and Friends.'**
  String get howStep1Body;

  /// No description provided for @howStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Collect reactions'**
  String get howStep2Title;

  /// No description provided for @howStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Readers react to your take. Every reaction is worth one point.'**
  String get howStep2Body;

  /// No description provided for @howStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Climb the board'**
  String get howStep3Title;

  /// No description provided for @howStep3Body.
  ///
  /// In en, this message translates to:
  /// **'The critics with the most reactions in the period take the podium.'**
  String get howStep3Body;

  /// No description provided for @howNoteReset.
  ///
  /// In en, this message translates to:
  /// **'This week resets every Monday at 00:00. This month and All time keep counting.'**
  String get howNoteReset;

  /// No description provided for @howNoteOncePerReview.
  ///
  /// In en, this message translates to:
  /// **'Each person can react once per take. Reacting to your own take doesn\'t count.'**
  String get howNoteOncePerReview;

  /// No description provided for @howNoteTie.
  ///
  /// In en, this message translates to:
  /// **'If two critics tie, the one who reached the total first ranks higher.'**
  String get howNoteTie;

  /// No description provided for @howNotePodium.
  ///
  /// In en, this message translates to:
  /// **'The top three wear a podium frame (gold, blue, bronze) on the board for the period shown.'**
  String get howNotePodium;

  /// No description provided for @howLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Levels and XP'**
  String get howLevelsTitle;

  /// No description provided for @howXpReview.
  ///
  /// In en, this message translates to:
  /// **'Write a take'**
  String get howXpReview;

  /// No description provided for @howXpComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get howXpComment;

  /// No description provided for @howXpReaction.
  ///
  /// In en, this message translates to:
  /// **'Receive a reaction'**
  String get howXpReaction;

  /// No description provided for @howXpValue.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String howXpValue(int xp);

  /// No description provided for @howLevelFoot.
  ///
  /// In en, this message translates to:
  /// **'Each level needs 50 XP more than the one before.'**
  String get howLevelFoot;

  /// No description provided for @profileBadgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get profileBadgesTitle;

  /// No description provided for @badgeWellArguedTitle.
  ///
  /// In en, this message translates to:
  /// **'Well argued'**
  String get badgeWellArguedTitle;

  /// No description provided for @badgeWellArguedDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive {count} “Well argued” reactions.'**
  String badgeWellArguedDesc(int count);

  /// No description provided for @badgeChangedMindTitle.
  ///
  /// In en, this message translates to:
  /// **'Changed my mind'**
  String get badgeChangedMindTitle;

  /// No description provided for @badgeChangedMindDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive {count} “Changed my mind” reactions.'**
  String badgeChangedMindDesc(int count);

  /// No description provided for @badgeDisagreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Disagree but fair'**
  String get badgeDisagreeTitle;

  /// No description provided for @badgeDisagreeDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive {count} “Disagree but fair” reactions.'**
  String badgeDisagreeDesc(int count);

  /// No description provided for @badgeTopCriticTitle.
  ///
  /// In en, this message translates to:
  /// **'Top critic'**
  String get badgeTopCriticTitle;

  /// No description provided for @badgeTopCriticDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish in the weekly top 3.'**
  String get badgeTopCriticDesc;

  /// No description provided for @badgeFirstTakeTitle.
  ///
  /// In en, this message translates to:
  /// **'First take'**
  String get badgeFirstTakeTitle;

  /// No description provided for @badgeFirstTakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Be the first person to share a take on a film.'**
  String get badgeFirstTakeDesc;

  /// No description provided for @achFilmCriticTitle.
  ///
  /// In en, this message translates to:
  /// **'Film critic'**
  String get achFilmCriticTitle;

  /// No description provided for @achFilmCriticDesc.
  ///
  /// In en, this message translates to:
  /// **'Write {count} takes.'**
  String achFilmCriticDesc(int count);

  /// No description provided for @achDebaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Debater'**
  String get achDebaterTitle;

  /// No description provided for @achDebaterDesc.
  ///
  /// In en, this message translates to:
  /// **'Get {count} “Well argued” reactions.'**
  String achDebaterDesc(int count);

  /// No description provided for @achLocalCinemaTitle.
  ///
  /// In en, this message translates to:
  /// **'Local cinema'**
  String get achLocalCinemaTitle;

  /// No description provided for @achLocalCinemaDesc.
  ///
  /// In en, this message translates to:
  /// **'Share takes on {count} Tunisian films.'**
  String achLocalCinemaDesc(int count);

  /// No description provided for @achComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get achComingSoon;

  /// No description provided for @frameNewcomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Newcomer'**
  String get frameNewcomerTitle;

  /// No description provided for @frameExplorerTitle.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get frameExplorerTitle;

  /// No description provided for @frameDebaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Debater'**
  String get frameDebaterTitle;

  /// No description provided for @frameTopCriticTitle.
  ///
  /// In en, this message translates to:
  /// **'Top critic'**
  String get frameTopCriticTitle;

  /// No description provided for @frameLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get frameLegendTitle;

  /// No description provided for @frameAlwaysUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Everyone starts with this frame.'**
  String get frameAlwaysUnlocked;

  /// No description provided for @frameLevelRequirement.
  ///
  /// In en, this message translates to:
  /// **'Reach Level {level}.'**
  String frameLevelRequirement(int level);

  /// No description provided for @frameDebaterRequirement.
  ///
  /// In en, this message translates to:
  /// **'Receive {count} “Well argued” reactions.'**
  String frameDebaterRequirement(int count);

  /// No description provided for @frameEquipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get frameEquipped;

  /// No description provided for @frameTapToEquip.
  ///
  /// In en, this message translates to:
  /// **'Tap to equip'**
  String get frameTapToEquip;

  /// No description provided for @frameUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get frameUnlocked;

  /// No description provided for @frameLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get frameLocked;

  /// No description provided for @frameUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t equip that frame. Try again.'**
  String get frameUpdateFailed;

  /// No description provided for @profileLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'LEVEL {level}'**
  String profileLevelLabel(int level);

  /// No description provided for @profileStatComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get profileStatComments;

  /// No description provided for @profileStatReactions.
  ///
  /// In en, this message translates to:
  /// **'Reactions'**
  String get profileStatReactions;

  /// No description provided for @profileFramesTitle.
  ///
  /// In en, this message translates to:
  /// **'Frames'**
  String get profileFramesTitle;

  /// No description provided for @profileXpProgress.
  ///
  /// In en, this message translates to:
  /// **'{into} / {span} XP to level {next}'**
  String profileXpProgress(int into, int span, int next);

  /// No description provided for @topicDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get topicDetailTitle;

  /// No description provided for @topicCommentsHeading.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No comments yet} =1{1 comment} other{{count} comments}}'**
  String topicCommentsHeading(int count);

  /// No description provided for @topicAboutFilm.
  ///
  /// In en, this message translates to:
  /// **'About this movie'**
  String get topicAboutFilm;

  /// No description provided for @topicBeFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to answer.'**
  String get topicBeFirst;

  /// No description provided for @authClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get authClose;

  /// No description provided for @authReasonSearch.
  ///
  /// In en, this message translates to:
  /// **'Log in to search and add films'**
  String get authReasonSearch;

  /// No description provided for @authReasonProfile.
  ///
  /// In en, this message translates to:
  /// **'Log in to open your profile'**
  String get authReasonProfile;

  /// No description provided for @authReasonExplore.
  ///
  /// In en, this message translates to:
  /// **'Log in to explore takes and topics'**
  String get authReasonExplore;

  /// No description provided for @authReasonNotifications.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your notifications'**
  String get authReasonNotifications;

  /// No description provided for @authReasonFilm.
  ///
  /// In en, this message translates to:
  /// **'Log in to open film details'**
  String get authReasonFilm;

  /// No description provided for @authReasonHome.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your films, friends and takes'**
  String get authReasonHome;

  /// No description provided for @authGuestPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your films and friends'**
  String get authGuestPromptTitle;

  /// No description provided for @authGuestPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Upcoming films and news are open to everyone. Sign in to build your lists and join the conversation.'**
  String get authGuestPromptBody;

  /// No description provided for @browseSectionDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get browseSectionDiscover;

  /// No description provided for @browseTopTakes.
  ///
  /// In en, this message translates to:
  /// **'Top 100 takes'**
  String get browseTopTakes;

  /// No description provided for @browsePopularFilms.
  ///
  /// In en, this message translates to:
  /// **'Most popular films'**
  String get browsePopularFilms;

  /// No description provided for @browseByYear.
  ///
  /// In en, this message translates to:
  /// **'Browse by year'**
  String get browseByYear;

  /// No description provided for @browseByStreaming.
  ///
  /// In en, this message translates to:
  /// **'Browse by streaming service'**
  String get browseByStreaming;

  /// No description provided for @browseSectionTopics.
  ///
  /// In en, this message translates to:
  /// **'Most popular topics'**
  String get browseSectionTopics;

  /// No description provided for @browsePolls.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get browsePolls;

  /// No description provided for @browseConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get browseConversations;

  /// No description provided for @browseScenes.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get browseScenes;

  /// No description provided for @browseQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get browseQuestions;

  /// No description provided for @browseHotTakes.
  ///
  /// In en, this message translates to:
  /// **'Hot takes'**
  String get browseHotTakes;

  /// No description provided for @browseSectionFilmSage.
  ///
  /// In en, this message translates to:
  /// **'FilmSage'**
  String get browseSectionFilmSage;

  /// No description provided for @browseNewHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get browseNewHere;

  /// No description provided for @browseSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social media'**
  String get browseSocialMedia;

  /// No description provided for @browseFollowUs.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get browseFollowUs;

  /// No description provided for @browseGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get browseGifts;

  /// No description provided for @browseContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get browseContact;

  /// No description provided for @browseTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use / Community policy'**
  String get browseTerms;

  /// No description provided for @browseYearsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a year'**
  String get browseYearsTitle;

  /// Decade heading on the Browse by year page, e.g. 1990s.
  ///
  /// In en, this message translates to:
  /// **'{decade}s'**
  String browseDecade(String decade);

  /// No description provided for @browseServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a streaming service'**
  String get browseServicesTitle;

  /// No description provided for @browseServicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No streaming services available.'**
  String get browseServicesEmpty;

  /// No description provided for @browseFilmsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No films here yet.'**
  String get browseFilmsEmpty;

  /// No description provided for @browseTakesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing posted here yet.'**
  String get browseTakesEmpty;

  /// No description provided for @browseComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get browseComingSoonTitle;

  /// No description provided for @browseComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re still working on this page. Check back soon.'**
  String get browseComingSoonBody;

  /// No description provided for @browseByGenre.
  ///
  /// In en, this message translates to:
  /// **'Browse by genre'**
  String get browseByGenre;

  /// No description provided for @browseByCountry.
  ///
  /// In en, this message translates to:
  /// **'Browse by country'**
  String get browseByCountry;

  /// No description provided for @browseByLanguage.
  ///
  /// In en, this message translates to:
  /// **'Browse by language'**
  String get browseByLanguage;

  /// No description provided for @browseGenresTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a genre'**
  String get browseGenresTitle;

  /// No description provided for @browseCountriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a country'**
  String get browseCountriesTitle;

  /// No description provided for @browseCountriesHint.
  ///
  /// In en, this message translates to:
  /// **'Popular films streaming in each country.'**
  String get browseCountriesHint;

  /// Title of the film list for one country.
  ///
  /// In en, this message translates to:
  /// **'Streaming in {country}'**
  String browseStreamingIn(String country);

  /// No description provided for @browseLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a language'**
  String get browseLanguagesTitle;

  /// No description provided for @browsePickEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pick from right now.'**
  String get browsePickEmpty;

  /// No description provided for @browseLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get browseLanguageEn;

  /// No description provided for @browseLanguageFr.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get browseLanguageFr;

  /// No description provided for @browseLanguageEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get browseLanguageEs;

  /// No description provided for @browseLanguageIt.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get browseLanguageIt;

  /// No description provided for @browseLanguageDe.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get browseLanguageDe;

  /// No description provided for @browseLanguagePt.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get browseLanguagePt;

  /// No description provided for @browseLanguageRu.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get browseLanguageRu;

  /// No description provided for @browseLanguageAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get browseLanguageAr;

  /// No description provided for @browseLanguageTr.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get browseLanguageTr;

  /// No description provided for @browseLanguageHi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get browseLanguageHi;

  /// No description provided for @browseLanguageKo.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get browseLanguageKo;

  /// No description provided for @browseLanguageJa.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get browseLanguageJa;

  /// No description provided for @browseLanguageZh.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get browseLanguageZh;

  /// No description provided for @browseLanguageSv.
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get browseLanguageSv;

  /// No description provided for @overviewPlayTrailer.
  ///
  /// In en, this message translates to:
  /// **'Play trailer'**
  String get overviewPlayTrailer;

  /// No description provided for @overviewTrailerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the trailer.'**
  String get overviewTrailerUnavailable;

  /// No description provided for @overviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get overviewLoading;

  /// No description provided for @overviewNoCastCrew.
  ///
  /// In en, this message translates to:
  /// **'No cast and crew information yet.'**
  String get overviewNoCastCrew;

  /// No description provided for @overviewOfferStream.
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get overviewOfferStream;

  /// No description provided for @overviewOfferFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get overviewOfferFree;

  /// No description provided for @overviewOfferTvProvider.
  ///
  /// In en, this message translates to:
  /// **'With a TV provider'**
  String get overviewOfferTvProvider;

  /// No description provided for @overviewOfferRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get overviewOfferRent;

  /// No description provided for @overviewOfferBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get overviewOfferBuy;

  /// No description provided for @overviewCloseTrailer.
  ///
  /// In en, this message translates to:
  /// **'Close trailer'**
  String get overviewCloseTrailer;

  /// No description provided for @filmSuggest.
  ///
  /// In en, this message translates to:
  /// **'Suggest'**
  String get filmSuggest;

  /// No description provided for @filmListFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your list. Try again.'**
  String get filmListFailed;

  /// No description provided for @filmFeelingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap to say how it made you feel'**
  String get filmFeelingsEmpty;

  /// No description provided for @filmFeelingsHint.
  ///
  /// In en, this message translates to:
  /// **'Pick up to 3 feelings.'**
  String get filmFeelingsHint;

  /// No description provided for @filmFeelingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 picked'**
  String filmFeelingsCount(String count);

  /// No description provided for @filmFeelingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get filmFeelingsSave;

  /// No description provided for @filmFeelingsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filmFeelingsClear;

  /// No description provided for @filmAudienceTitle.
  ///
  /// In en, this message translates to:
  /// **'The audience'**
  String get filmAudienceTitle;

  /// No description provided for @filmAudienceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reactions yet. Be the first to say how it made you feel.'**
  String get filmAudienceEmpty;

  /// No description provided for @filmAudiencePositive.
  ///
  /// In en, this message translates to:
  /// **'enjoyed it'**
  String get filmAudiencePositive;

  /// No description provided for @filmAudiencePeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person reacted} other{{count} people reacted}}'**
  String filmAudiencePeople(int count);

  /// No description provided for @filmYourTakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your take'**
  String get filmYourTakeTitle;

  /// No description provided for @filmTakeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 take} other{{count} takes}}'**
  String filmTakeCount(int count);

  /// No description provided for @filmTopTake.
  ///
  /// In en, this message translates to:
  /// **'TOP TAKE'**
  String get filmTopTake;

  /// No description provided for @filmShowMoreTakes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 more take} other{Show {count} more takes}}'**
  String filmShowMoreTakes(int count);

  /// No description provided for @filmShowLessTakes.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get filmShowLessTakes;

  /// No description provided for @filmShareYourTake.
  ///
  /// In en, this message translates to:
  /// **'Share your take'**
  String get filmShareYourTake;

  /// No description provided for @filmAddTake.
  ///
  /// In en, this message translates to:
  /// **'Add take'**
  String get filmAddTake;

  /// No description provided for @overviewFriendStoryNew.
  ///
  /// In en, this message translates to:
  /// **'{name}, new: {feeling}'**
  String overviewFriendStoryNew(String name, String feeling);

  /// No description provided for @overviewFriendStorySeen.
  ///
  /// In en, this message translates to:
  /// **'{name}: {feeling}'**
  String overviewFriendStorySeen(String name, String feeling);

  /// No description provided for @filmPersonFeelings.
  ///
  /// In en, this message translates to:
  /// **'Felt: {feelings}'**
  String filmPersonFeelings(String feelings);

  /// No description provided for @filmTakeComments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No comments} =1{1 comment} other{{count} comments}}'**
  String filmTakeComments(int count);

  /// No description provided for @filmFeelingsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get filmFeelingsDone;

  /// No description provided for @personBiography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get personBiography;

  /// No description provided for @personFilmography.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get personFilmography;

  /// No description provided for @personHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get personHeight;

  /// No description provided for @personBorn.
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get personBorn;

  /// No description provided for @personDied.
  ///
  /// In en, this message translates to:
  /// **'Died'**
  String get personDied;

  /// No description provided for @personNoFilms.
  ///
  /// In en, this message translates to:
  /// **'No movies found for this person yet.'**
  String get personNoFilms;

  /// No description provided for @personLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this person\'s page.'**
  String get personLoadFailed;

  /// No description provided for @personAsCharacter.
  ///
  /// In en, this message translates to:
  /// **'as {character}'**
  String personAsCharacter(String character);

  /// No description provided for @takeSkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Card skin'**
  String get takeSkinTitle;

  /// No description provided for @takeSkinNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get takeSkinNormal;

  /// No description provided for @takeSkinElectricThunder.
  ///
  /// In en, this message translates to:
  /// **'Electric thunder'**
  String get takeSkinElectricThunder;

  /// No description provided for @takeSkinPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get takeSkinPreview;

  /// No description provided for @takeSkinPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your take will appear here.'**
  String get takeSkinPreviewEmpty;

  /// No description provided for @takeSkinWriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your take'**
  String get takeSkinWriteTitle;

  /// No description provided for @reviewAlreadyShared.
  ///
  /// In en, this message translates to:
  /// **'You already shared a take for this film.'**
  String get reviewAlreadyShared;

  /// No description provided for @reviewNeedsFeeling.
  ///
  /// In en, this message translates to:
  /// **'Pick how the film made you feel first, then share your take.'**
  String get reviewNeedsFeeling;

  /// No description provided for @reviewYourTake.
  ///
  /// In en, this message translates to:
  /// **'Your take — others react to it'**
  String get reviewYourTake;

  /// No description provided for @reviewBeFirstComment.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment on this take.'**
  String get reviewBeFirstComment;

  /// No description provided for @takeMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get takeMenuTooltip;

  /// No description provided for @takeActionShare.
  ///
  /// In en, this message translates to:
  /// **'Send to friends'**
  String get takeActionShare;

  /// No description provided for @takeActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get takeActionEdit;

  /// No description provided for @takeActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get takeActionDelete;

  /// No description provided for @takeActionReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get takeActionReport;

  /// No description provided for @takeEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get takeEdited;

  /// No description provided for @takeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get takeCancel;

  /// No description provided for @takeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your take'**
  String get takeEditTitle;

  /// No description provided for @takeEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get takeEditSave;

  /// No description provided for @takeEditSaved.
  ///
  /// In en, this message translates to:
  /// **'Your take was updated.'**
  String get takeEditSaved;

  /// No description provided for @takeEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your changes. Try again.'**
  String get takeEditFailed;

  /// No description provided for @takeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this take?'**
  String get takeDeleteTitle;

  /// No description provided for @takeDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed for everyone, along with its comments.'**
  String get takeDeleteBody;

  /// No description provided for @takeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Take deleted.'**
  String get takeDeleted;

  /// No description provided for @takeDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete it. Try again.'**
  String get takeDeleteFailed;

  /// No description provided for @takeReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this take'**
  String get takeReportTitle;

  /// No description provided for @takeReportHint.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting it? Only moderators see reports.'**
  String get takeReportHint;

  /// No description provided for @takeReportSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get takeReportSpam;

  /// No description provided for @takeReportHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or bullying'**
  String get takeReportHarassment;

  /// No description provided for @takeReportHate.
  ///
  /// In en, this message translates to:
  /// **'Hate speech'**
  String get takeReportHate;

  /// No description provided for @takeReportSpoiler.
  ///
  /// In en, this message translates to:
  /// **'Unmarked spoiler'**
  String get takeReportSpoiler;

  /// No description provided for @takeReportOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get takeReportOther;

  /// No description provided for @takeReportDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get takeReportDetailsHint;

  /// No description provided for @takeReportSend.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get takeReportSend;

  /// No description provided for @takeReportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Our team will review it.'**
  String get takeReportThanks;

  /// No description provided for @takeReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the report. Try again.'**
  String get takeReportFailed;

  /// No description provided for @takeShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Send to friends'**
  String get takeShareTitle;

  /// No description provided for @takeShareMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Add a message (optional)'**
  String get takeShareMessageHint;

  /// No description provided for @takeShareNoFriends.
  ///
  /// In en, this message translates to:
  /// **'Add friends to send them takes.'**
  String get takeShareNoFriends;

  /// No description provided for @takeShareFriendsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your friends.'**
  String get takeShareFriendsFailed;

  /// No description provided for @takeShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send it. Try again.'**
  String get takeShareFailed;

  /// No description provided for @notificationTakeGone.
  ///
  /// In en, this message translates to:
  /// **'This take is no longer available.'**
  String get notificationTakeGone;

  /// No description provided for @mentionSuggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Mention a friend'**
  String get mentionSuggestionsLabel;

  /// No description provided for @takeShareSend.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Send} =1{Send to 1 friend} other{Send to {count} friends}}'**
  String takeShareSend(int count);

  /// No description provided for @takeShareSent.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sent to 1 friend} other{Sent to {count} friends}}'**
  String takeShareSent(int count);

  /// No description provided for @notificationTakeShared.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a take'**
  String notificationTakeShared(String name);

  /// No description provided for @notificationTakeMention.
  ///
  /// In en, this message translates to:
  /// **'{name} mentioned you in a comment'**
  String notificationTakeMention(String name);

  /// Spoiler question shown when sharing a take.
  ///
  /// In en, this message translates to:
  /// **'Does it have spoilers?'**
  String get takeSpoilerTitle;

  /// Spoiler question shown when sharing a take.
  ///
  /// In en, this message translates to:
  /// **'No spoilers'**
  String get takeSpoilerNo;

  /// Spoiler question shown when sharing a take.
  ///
  /// In en, this message translates to:
  /// **'Pick one so readers know what to expect.'**
  String get takeSpoilerHint;

  /// Spoiler question shown when sharing a take.
  ///
  /// In en, this message translates to:
  /// **'Say whether your take has spoilers before sharing.'**
  String get takeSpoilerRequired;

  /// Spoiler question shown when sharing a take.
  ///
  /// In en, this message translates to:
  /// **'Others will see it blurred until they tap to reveal.'**
  String get takeSpoilerBlurNote;

  /// Name of a review vote, read by screen readers and tooltips; the button shows only an icon.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get reviewVoteUp;

  /// Name of a review vote, read by screen readers and tooltips; the button shows only an icon.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get reviewVoteDraw;

  /// Name of a review vote, read by screen readers and tooltips; the button shows only an icon.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get reviewVoteDown;

  /// No description provided for @storyTake.
  ///
  /// In en, this message translates to:
  /// **'Shared a take on {film}'**
  String storyTake(String film);

  /// No description provided for @storyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Asked about {film}'**
  String storyQuestion(String film);

  /// No description provided for @storyDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Started a discussion on {film}'**
  String storyDiscussion(String film);

  /// No description provided for @storyHotTake.
  ///
  /// In en, this message translates to:
  /// **'Dropped a hot take on {film}'**
  String storyHotTake(String film);

  /// No description provided for @storyPoll.
  ///
  /// In en, this message translates to:
  /// **'Made a poll about {film}'**
  String storyPoll(String film);

  /// No description provided for @storyScene.
  ///
  /// In en, this message translates to:
  /// **'Shared a scene from {film}'**
  String storyScene(String film);

  /// No description provided for @storyComment.
  ///
  /// In en, this message translates to:
  /// **'Commented on a post about {film}'**
  String storyComment(String film);

  /// No description provided for @storyUnknownFilm.
  ///
  /// In en, this message translates to:
  /// **'a film'**
  String get storyUnknownFilm;

  /// No description provided for @storyOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get storyOpen;

  /// No description provided for @storyClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get storyClose;

  /// No description provided for @storyRingLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s story'**
  String storyRingLabel(String name);

  /// No description provided for @storiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends\' stories'**
  String get storiesTitle;

  /// No description provided for @inboxSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get inboxSearch;

  /// No description provided for @inboxSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get inboxSearchHint;

  /// No description provided for @inboxCloseSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get inboxCloseSearch;

  /// No description provided for @inboxUnreadOnly.
  ///
  /// In en, this message translates to:
  /// **'Show only unread'**
  String get inboxUnreadOnly;

  /// No description provided for @inboxAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get inboxAddFriend;

  /// No description provided for @inboxCreate.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get inboxCreate;

  /// No description provided for @inboxNewMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get inboxNewMessage;

  /// No description provided for @inboxCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create a group'**
  String get inboxCreateGroup;

  /// No description provided for @inboxCreateTopic.
  ///
  /// In en, this message translates to:
  /// **'Create a private topic'**
  String get inboxCreateTopic;

  /// No description provided for @inboxPrivateTopics.
  ///
  /// In en, this message translates to:
  /// **'Private topics'**
  String get inboxPrivateTopics;

  /// No description provided for @inboxNoTopics.
  ///
  /// In en, this message translates to:
  /// **'No topics yet. Start one with friends.'**
  String get inboxNoTopics;

  /// No description provided for @inboxNewTopic.
  ///
  /// In en, this message translates to:
  /// **'New private topic'**
  String get inboxNewTopic;

  /// No description provided for @inboxAllChats.
  ///
  /// In en, this message translates to:
  /// **'All chats'**
  String get inboxAllChats;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Message a friend to start chatting.'**
  String get inboxEmptyBody;

  /// No description provided for @inboxNoResults.
  ///
  /// In en, this message translates to:
  /// **'No conversations found'**
  String get inboxNoResults;

  /// No description provided for @inboxLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your messages.'**
  String get inboxLoadFailed;

  /// No description provided for @inboxYouSaid.
  ///
  /// In en, this message translates to:
  /// **'You: {text}'**
  String inboxYouSaid(String text);

  /// No description provided for @inboxNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get inboxNoMessagesYet;

  /// No description provided for @inboxGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get inboxGroupName;

  /// No description provided for @inboxTopicName.
  ///
  /// In en, this message translates to:
  /// **'Topic name'**
  String get inboxTopicName;

  /// No description provided for @inboxPickFriends.
  ///
  /// In en, this message translates to:
  /// **'Choose friends'**
  String get inboxPickFriends;

  /// No description provided for @inboxPickFriend.
  ///
  /// In en, this message translates to:
  /// **'Message a friend'**
  String get inboxPickFriend;

  /// No description provided for @inboxNoFriends.
  ///
  /// In en, this message translates to:
  /// **'Add friends first to chat with them.'**
  String get inboxNoFriends;

  /// No description provided for @inboxCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get inboxCreateAction;

  /// No description provided for @inboxCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get inboxCancel;

  /// No description provided for @inboxCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create it. Try again.'**
  String get inboxCreateFailed;

  /// No description provided for @inboxMembers.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String inboxMembers(int count);

  /// No description provided for @inboxGroupPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a group photo'**
  String get inboxGroupPhoto;

  /// No description provided for @inboxGroupDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get inboxGroupDescription;

  /// No description provided for @inboxPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Created, but the photo didn\'t upload.'**
  String get inboxPhotoFailed;

  /// No description provided for @chatOpenInfo.
  ///
  /// In en, this message translates to:
  /// **'Group info'**
  String get chatOpenInfo;

  /// No description provided for @groupInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Group info'**
  String get groupInfoTitle;

  /// No description provided for @groupInfoTopicTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic info'**
  String get groupInfoTopicTitle;

  /// No description provided for @groupInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get groupInfoDescription;

  /// No description provided for @groupInfoNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description yet.'**
  String get groupInfoNoDescription;

  /// No description provided for @groupInfoMembers.
  ///
  /// In en, this message translates to:
  /// **'Members · {count}'**
  String groupInfoMembers(int count);

  /// No description provided for @groupInfoYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get groupInfoYou;

  /// No description provided for @groupInfoCreator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get groupInfoCreator;

  /// No description provided for @inboxUnreadLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String inboxUnreadLabel(int count);

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get chatHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatStart.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get chatStart;

  /// No description provided for @chatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Message not sent. Try again.'**
  String get chatSendFailed;

  /// No description provided for @chatPrivateTopic.
  ///
  /// In en, this message translates to:
  /// **'Private topic · only members can see it'**
  String get chatPrivateTopic;

  /// No description provided for @inboxSelectChat.
  ///
  /// In en, this message translates to:
  /// **'Pick a conversation to start chatting'**
  String get inboxSelectChat;

  /// No description provided for @chatMenu.
  ///
  /// In en, this message translates to:
  /// **'Group menu'**
  String get chatMenu;

  /// No description provided for @chatShareGroup.
  ///
  /// In en, this message translates to:
  /// **'Share group'**
  String get chatShareGroup;

  /// No description provided for @chatBoostGroup.
  ///
  /// In en, this message translates to:
  /// **'Boost group'**
  String get chatBoostGroup;

  /// No description provided for @chatReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chatReport;

  /// No description provided for @chatLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get chatLeaveGroup;

  /// No description provided for @chatShareBody.
  ///
  /// In en, this message translates to:
  /// **'Send the group to a conversation.'**
  String get chatShareBody;

  /// No description provided for @chatSharedTo.
  ///
  /// In en, this message translates to:
  /// **'Shared to {name}'**
  String chatSharedTo(String name);

  /// No description provided for @chatBoosted.
  ///
  /// In en, this message translates to:
  /// **'Boost started for {name}'**
  String chatBoosted(String name);

  /// No description provided for @chatReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this group'**
  String get chatReportTitle;

  /// No description provided for @chatReportBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us what is wrong. Members are not notified.'**
  String get chatReportBody;

  /// No description provided for @chatReportSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or scam'**
  String get chatReportSpam;

  /// No description provided for @chatReportHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get chatReportHarassment;

  /// No description provided for @chatReportOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get chatReportOther;

  /// No description provided for @chatReportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent'**
  String get chatReportSent;

  /// No description provided for @chatCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatCancel;

  /// No description provided for @chatClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get chatClose;

  /// No description provided for @chatBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get chatBack;

  /// No description provided for @chatActionFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Try again.'**
  String get chatActionFailed;

  /// No description provided for @chatPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get chatPinned;

  /// No description provided for @chatPinnedCount.
  ///
  /// In en, this message translates to:
  /// **'Pinned ({count})'**
  String chatPinnedCount(int count);

  /// No description provided for @chatReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chatReply;

  /// No description provided for @chatReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String chatReplyingTo(String name);

  /// No description provided for @chatCancelReply.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get chatCancelReply;

  /// No description provided for @chatPin.
  ///
  /// In en, this message translates to:
  /// **'Pin message'**
  String get chatPin;

  /// No description provided for @chatUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin message'**
  String get chatUnpin;

  /// No description provided for @chatMessagePinned.
  ///
  /// In en, this message translates to:
  /// **'Message pinned'**
  String get chatMessagePinned;

  /// No description provided for @chatMessageUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Message unpinned'**
  String get chatMessageUnpinned;

  /// No description provided for @chatMention.
  ///
  /// In en, this message translates to:
  /// **'Mention {name}'**
  String chatMention(String name);

  /// No description provided for @chatViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get chatViewProfile;

  /// No description provided for @chatMoreReactions.
  ///
  /// In en, this message translates to:
  /// **'More reactions'**
  String get chatMoreReactions;

  /// No description provided for @chatNotified.
  ///
  /// In en, this message translates to:
  /// **'Notified {names}'**
  String chatNotified(String names);

  /// No description provided for @chatNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No one matches'**
  String get chatNoMatch;

  /// No description provided for @chatAdd.
  ///
  /// In en, this message translates to:
  /// **'Add photo, video, movie or poll'**
  String get chatAdd;

  /// No description provided for @chatEmojiButton.
  ///
  /// In en, this message translates to:
  /// **'Emoji, GIFs and stickers'**
  String get chatEmojiButton;

  /// No description provided for @chatAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to chat'**
  String get chatAddTitle;

  /// No description provided for @chatPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chatPhoto;

  /// No description provided for @chatPhotoBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo from your device.'**
  String get chatPhotoBody;

  /// No description provided for @chatVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get chatVideo;

  /// No description provided for @chatVideoBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a video from your device.'**
  String get chatVideoBody;

  /// No description provided for @chatMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get chatMovie;

  /// No description provided for @chatMovieBody.
  ///
  /// In en, this message translates to:
  /// **'Search a film and share it as a card.'**
  String get chatMovieBody;

  /// No description provided for @chatPoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get chatPoll;

  /// No description provided for @chatPollBody.
  ///
  /// In en, this message translates to:
  /// **'Ask the group a question.'**
  String get chatPollBody;

  /// No description provided for @chatSendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Send photo'**
  String get chatSendPhoto;

  /// No description provided for @chatSendVideo.
  ///
  /// In en, this message translates to:
  /// **'Send video'**
  String get chatSendVideo;

  /// No description provided for @chatShareMovie.
  ///
  /// In en, this message translates to:
  /// **'Share movie'**
  String get chatShareMovie;

  /// No description provided for @chatNewPoll.
  ///
  /// In en, this message translates to:
  /// **'New poll'**
  String get chatNewPoll;

  /// No description provided for @chatCaption.
  ///
  /// In en, this message translates to:
  /// **'Add a caption'**
  String get chatCaption;

  /// No description provided for @chatPollQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a question'**
  String get chatPollQuestion;

  /// No description provided for @chatPollOption.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String chatPollOption(int number);

  /// No description provided for @chatAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get chatAddOption;

  /// No description provided for @chatAllowedReactions.
  ///
  /// In en, this message translates to:
  /// **'Reactions allowed on this post'**
  String get chatAllowedReactions;

  /// No description provided for @chatAllowedReactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Members can react with the emojis you choose. They hold a message to see them.'**
  String get chatAllowedReactionsBody;

  /// No description provided for @chatPollInvalid.
  ///
  /// In en, this message translates to:
  /// **'Add a question and at least two options'**
  String get chatPollInvalid;

  /// No description provided for @chatFileTooBig.
  ///
  /// In en, this message translates to:
  /// **'That file is too big (12 MB max)'**
  String get chatFileTooBig;

  /// No description provided for @chatSearchMovie.
  ///
  /// In en, this message translates to:
  /// **'Search a movie'**
  String get chatSearchMovie;

  /// No description provided for @chatSearchMovieHint.
  ///
  /// In en, this message translates to:
  /// **'Film title'**
  String get chatSearchMovieHint;

  /// No description provided for @chatNoMovie.
  ///
  /// In en, this message translates to:
  /// **'No movie found.'**
  String get chatNoMovie;

  /// No description provided for @chatVotes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 vote} other{{count} votes}}'**
  String chatVotes(int count);

  /// No description provided for @chatPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Play video'**
  String get chatPlayVideo;

  /// No description provided for @chatGif.
  ///
  /// In en, this message translates to:
  /// **'GIF'**
  String get chatGif;

  /// No description provided for @chatSticker.
  ///
  /// In en, this message translates to:
  /// **'Sticker'**
  String get chatSticker;

  /// No description provided for @chatTabEmoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get chatTabEmoji;

  /// No description provided for @chatTabGif.
  ///
  /// In en, this message translates to:
  /// **'GIF'**
  String get chatTabGif;

  /// No description provided for @chatTabStickers.
  ///
  /// In en, this message translates to:
  /// **'Stickers'**
  String get chatTabStickers;

  /// No description provided for @chatSearchEmoji.
  ///
  /// In en, this message translates to:
  /// **'Find the perfect emoji'**
  String get chatSearchEmoji;

  /// No description provided for @chatSearchGif.
  ///
  /// In en, this message translates to:
  /// **'Search GIFs'**
  String get chatSearchGif;

  /// No description provided for @chatSearchStickers.
  ///
  /// In en, this message translates to:
  /// **'Search stickers'**
  String get chatSearchStickers;

  /// No description provided for @chatNothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found for “{query}”.'**
  String chatNothingFound(String query);

  /// No description provided for @chatCatFrequent.
  ///
  /// In en, this message translates to:
  /// **'Frequently used'**
  String get chatCatFrequent;

  /// No description provided for @chatCatFaces.
  ///
  /// In en, this message translates to:
  /// **'Faces'**
  String get chatCatFaces;

  /// No description provided for @chatCatHands.
  ///
  /// In en, this message translates to:
  /// **'Hands'**
  String get chatCatHands;

  /// No description provided for @chatCatObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get chatCatObjects;

  /// No description provided for @chatCatSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get chatCatSymbols;

  /// No description provided for @chatClosePicker.
  ///
  /// In en, this message translates to:
  /// **'Close picker'**
  String get chatClosePicker;

  /// No description provided for @sysPinned.
  ///
  /// In en, this message translates to:
  /// **'{name} pinned a message'**
  String sysPinned(String name);

  /// No description provided for @sysRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed {target} from the group'**
  String sysRemoved(String name, String target);

  /// No description provided for @sysLeft.
  ///
  /// In en, this message translates to:
  /// **'{name} left the group'**
  String sysLeft(String name);

  /// No description provided for @sysHeritage.
  ///
  /// In en, this message translates to:
  /// **'{name} made {target} Heritage creator'**
  String sysHeritage(String name, String target);

  /// No description provided for @sysPassed.
  ///
  /// In en, this message translates to:
  /// **'{name} passed the creator tag to {target} and left'**
  String sysPassed(String name, String target);

  /// No description provided for @sysVoteStarted.
  ///
  /// In en, this message translates to:
  /// **'{name} started a vote on keeping this group'**
  String sysVoteStarted(String name);

  /// No description provided for @sysVoteCancelled.
  ///
  /// In en, this message translates to:
  /// **'{name} cancelled the vote'**
  String sysVoteCancelled(String name);

  /// No description provided for @sysVoteKeep.
  ///
  /// In en, this message translates to:
  /// **'Most members voted to keep the group. Now choose a new owner.'**
  String get sysVoteKeep;

  /// No description provided for @sysVoteOwnerWon.
  ///
  /// In en, this message translates to:
  /// **'{target} won the vote and is now Heritage creator'**
  String sysVoteOwnerWon(String target);

  /// No description provided for @voteKeepTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep this group?'**
  String get voteKeepTitle;

  /// No description provided for @voteKeepBody.
  ///
  /// In en, this message translates to:
  /// **'{name} asked to leave. Members have {time} left to vote. Most votes decide; a tie keeps the group.'**
  String voteKeepBody(String name, String time);

  /// No description provided for @voteStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get voteStay;

  /// No description provided for @voteDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get voteDelete;

  /// No description provided for @voteKeepTally.
  ///
  /// In en, this message translates to:
  /// **'Stay {stay} · Delete {delete}'**
  String voteKeepTally(int stay, int delete);

  /// No description provided for @voteOwnPoll.
  ///
  /// In en, this message translates to:
  /// **'You can\'t vote on your own poll.'**
  String get voteOwnPoll;

  /// No description provided for @voteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel poll and stay creator'**
  String get voteCancel;

  /// No description provided for @voteOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Who should own this group?'**
  String get voteOwnerTitle;

  /// No description provided for @voteOwnerBody.
  ///
  /// In en, this message translates to:
  /// **'The group is staying. Pick one member other than yourself. {time} left.'**
  String voteOwnerBody(String time);

  /// No description provided for @voteOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a member to vote.'**
  String get voteOwnerHint;

  /// No description provided for @voteOwnerChange.
  ///
  /// In en, this message translates to:
  /// **'You can change your vote until the poll ends.'**
  String get voteOwnerChange;

  /// No description provided for @voteTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String voteTimeLeft(int hours, int minutes);

  /// No description provided for @voteRunning.
  ///
  /// In en, this message translates to:
  /// **'A vote is already running'**
  String get voteRunning;

  /// No description provided for @leaveCreatorTitle.
  ///
  /// In en, this message translates to:
  /// **'You created this group'**
  String get leaveCreatorTitle;

  /// No description provided for @leaveCreatorBody.
  ///
  /// In en, this message translates to:
  /// **'Before you leave, choose what happens to the group.'**
  String get leaveCreatorBody;

  /// No description provided for @leavePass.
  ///
  /// In en, this message translates to:
  /// **'Pass the creator tag'**
  String get leavePass;

  /// No description provided for @leavePassBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a member. They take over right away.'**
  String get leavePassBody;

  /// No description provided for @leaveVote.
  ///
  /// In en, this message translates to:
  /// **'Let the group decide'**
  String get leaveVote;

  /// No description provided for @leaveVoteBody.
  ///
  /// In en, this message translates to:
  /// **'Members vote on keeping or deleting the group, then on who owns it. Each vote takes 24 hours.'**
  String get leaveVoteBody;

  /// No description provided for @leavePickTitle.
  ///
  /// In en, this message translates to:
  /// **'Who takes over?'**
  String get leavePickTitle;

  /// No description provided for @leavePickBody.
  ///
  /// In en, this message translates to:
  /// **'They get the Heritage creator tag and keep report, share and boost.'**
  String get leavePickBody;

  /// No description provided for @leaveContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get leaveContinue;

  /// No description provided for @leavePassConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Pass the tag to {name} and leave?'**
  String leavePassConfirmTitle(String name);

  /// No description provided for @leavePassConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name} becomes Heritage creator right away. You will leave the group.'**
  String leavePassConfirmBody(String name);

  /// No description provided for @leavePassConfirm.
  ///
  /// In en, this message translates to:
  /// **'Pass tag and leave'**
  String get leavePassConfirm;

  /// No description provided for @leaveVoteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start the group vote?'**
  String get leaveVoteConfirmTitle;

  /// No description provided for @leaveVoteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Step 1: members vote to keep or delete the group for 24 hours. If most vote Stay, step 2 lets them choose the new owner for another 24 hours. You stay creator until it ends.'**
  String get leaveVoteConfirmBody;

  /// No description provided for @leaveVoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start vote'**
  String get leaveVoteConfirm;

  /// No description provided for @leaveSimpleTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {group}?'**
  String leaveSimpleTitle(String group);

  /// No description provided for @leaveSimpleBody.
  ///
  /// In en, this message translates to:
  /// **'You will stop seeing messages from this group.'**
  String get leaveSimpleBody;

  /// No description provided for @confirmType.
  ///
  /// In en, this message translates to:
  /// **'To confirm, type {name}'**
  String confirmType(String name);

  /// No description provided for @groupInfoSearch.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get groupInfoSearch;

  /// No description provided for @groupInfoNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No members match “{query}”.'**
  String groupInfoNoMatch(String query);

  /// No description provided for @groupInfoHeritage.
  ///
  /// In en, this message translates to:
  /// **'Heritage creator'**
  String get groupInfoHeritage;

  /// No description provided for @memberViewProfileBody.
  ///
  /// In en, this message translates to:
  /// **'See {name}\'s films and collections.'**
  String memberViewProfileBody(String name);

  /// No description provided for @memberMakeHeritage.
  ///
  /// In en, this message translates to:
  /// **'Make Heritage creator'**
  String get memberMakeHeritage;

  /// No description provided for @memberMakeHeritageBody.
  ///
  /// In en, this message translates to:
  /// **'{name} takes over the group. You become a regular member.'**
  String memberMakeHeritageBody(String name);

  /// No description provided for @memberRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get memberRemove;

  /// No description provided for @memberRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{name} loses access to the group and its messages.'**
  String memberRemoveBody(String name);

  /// No description provided for @memberMakeHeritageTitle.
  ///
  /// In en, this message translates to:
  /// **'Make {name} Heritage creator?'**
  String memberMakeHeritageTitle(String name);

  /// No description provided for @memberMakeHeritageConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name} gets the Heritage creator tag and can report, share and boost the group. You stay in the group as a regular member.'**
  String memberMakeHeritageConfirmBody(String name);

  /// No description provided for @memberRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String memberRemoveTitle(String name);

  /// No description provided for @memberRemoveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will lose access to {group} and won\'t see new messages.'**
  String memberRemoveConfirmBody(String name, String group);

  /// No description provided for @memberRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String memberRemoveConfirm(String name);

  /// No description provided for @chatVideoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play this video.'**
  String get chatVideoFailed;

  /// No description provided for @chatPauseVideo.
  ///
  /// In en, this message translates to:
  /// **'Pause video'**
  String get chatPauseVideo;

  /// No description provided for @chatFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get chatFullScreen;

  /// No description provided for @chatMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get chatMute;

  /// No description provided for @chatUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get chatUnmute;

  /// No description provided for @chatMutedToast.
  ///
  /// In en, this message translates to:
  /// **'Chat muted'**
  String get chatMutedToast;

  /// No description provided for @chatUnmutedToast.
  ///
  /// In en, this message translates to:
  /// **'Chat unmuted'**
  String get chatUnmutedToast;

  /// No description provided for @chatPinChat.
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get chatPinChat;

  /// No description provided for @chatUnpinChat.
  ///
  /// In en, this message translates to:
  /// **'Unpin from top'**
  String get chatUnpinChat;

  /// No description provided for @chatMarkUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get chatMarkUnread;

  /// No description provided for @chatMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get chatMarkRead;

  /// No description provided for @chatClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get chatClearHistory;

  /// No description provided for @chatClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the history?'**
  String get chatClearTitle;

  /// No description provided for @chatClearBody.
  ///
  /// In en, this message translates to:
  /// **'Every message so far disappears for you. The others still see them.'**
  String get chatClearBody;

  /// No description provided for @chatCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get chatCleared;

  /// No description provided for @chatDeleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get chatDeleteChat;

  /// No description provided for @chatDeleteChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this chat?'**
  String get chatDeleteChatTitle;

  /// No description provided for @chatDeleteChatBody.
  ///
  /// In en, this message translates to:
  /// **'It leaves your inbox and its history is cleared for you. It comes back if {name} writes again.'**
  String chatDeleteChatBody(String name);

  /// No description provided for @chatChatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted'**
  String get chatChatDeleted;

  /// No description provided for @chatBlock.
  ///
  /// In en, this message translates to:
  /// **'Block {name}'**
  String chatBlock(String name);

  /// No description provided for @chatUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock {name}'**
  String chatUnblock(String name);

  /// No description provided for @chatBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String chatBlockTitle(String name);

  /// No description provided for @chatBlockBody.
  ///
  /// In en, this message translates to:
  /// **'Neither of you can message the other until you unblock them. They won\'t be told.'**
  String get chatBlockBody;

  /// No description provided for @chatBlockedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} is blocked'**
  String chatBlockedToast(String name);

  /// No description provided for @chatUnblockedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} is unblocked'**
  String chatUnblockedToast(String name);

  /// No description provided for @chatYouBlocked.
  ///
  /// In en, this message translates to:
  /// **'You blocked {name}.'**
  String chatYouBlocked(String name);

  /// No description provided for @chatBlockedYou.
  ///
  /// In en, this message translates to:
  /// **'You can\'t reply to this conversation.'**
  String get chatBlockedYou;

  /// No description provided for @chatBlockedPeople.
  ///
  /// In en, this message translates to:
  /// **'Blocked people'**
  String get chatBlockedPeople;

  /// No description provided for @chatNoBlocked.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone.'**
  String get chatNoBlocked;

  /// No description provided for @chatUnblockShort.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get chatUnblockShort;

  /// No description provided for @chatCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get chatCopy;

  /// No description provided for @chatCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get chatCopied;

  /// No description provided for @chatEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get chatEdit;

  /// No description provided for @chatEditing.
  ///
  /// In en, this message translates to:
  /// **'Editing message'**
  String get chatEditing;

  /// No description provided for @chatCancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel editing'**
  String get chatCancelEdit;

  /// No description provided for @chatDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatDeleteMessage;

  /// No description provided for @chatDeleteMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get chatDeleteMessageTitle;

  /// No description provided for @chatDeleteMessageBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s deleted for everyone in the chat.'**
  String get chatDeleteMessageBody;

  /// No description provided for @chatMessageDeleted.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get chatMessageDeleted;

  /// No description provided for @chatEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get chatEdited;

  /// No description provided for @chatReportMessage.
  ///
  /// In en, this message translates to:
  /// **'Report message'**
  String get chatReportMessage;

  /// No description provided for @chatReportHate.
  ///
  /// In en, this message translates to:
  /// **'Hate speech'**
  String get chatReportHate;

  /// No description provided for @chatReportNsfw.
  ///
  /// In en, this message translates to:
  /// **'Sexual content'**
  String get chatReportNsfw;

  /// No description provided for @chatSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get chatSeen;

  /// No description provided for @chatAddMembers.
  ///
  /// In en, this message translates to:
  /// **'Add members'**
  String get chatAddMembers;

  /// No description provided for @chatAddMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to {name}'**
  String chatAddMembersTitle(String name);

  /// No description provided for @chatAddMembersNone.
  ///
  /// In en, this message translates to:
  /// **'All your friends are already here.'**
  String get chatAddMembersNone;

  /// No description provided for @chatAddSelected.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get chatAddSelected;

  /// No description provided for @chatMembersAdded.
  ///
  /// In en, this message translates to:
  /// **'Members added'**
  String get chatMembersAdded;

  /// No description provided for @chatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get chatConfirm;

  /// No description provided for @chatViewProfileMenu.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get chatViewProfileMenu;

  /// No description provided for @inboxChatOptions.
  ///
  /// In en, this message translates to:
  /// **'Options for {name}'**
  String inboxChatOptions(String name);

  /// No description provided for @inboxPinnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get inboxPinnedLabel;

  /// No description provided for @inboxMutedLabel.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get inboxMutedLabel;

  /// No description provided for @sysAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added {target}'**
  String sysAdded(String name, String target);

  /// No description provided for @homeTopicFirstReply.
  ///
  /// In en, this message translates to:
  /// **'Be the first to reply'**
  String get homeTopicFirstReply;

  /// No description provided for @homeFriendsActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends Activity'**
  String get homeFriendsActivityTitle;

  /// No description provided for @homeFriendsActivityResize.
  ///
  /// In en, this message translates to:
  /// **'Resize friends activity'**
  String get homeFriendsActivityResize;

  /// No description provided for @topicTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get topicTitleHint;

  /// No description provided for @topicSeeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get topicSeeMore;

  /// No description provided for @topicCommentsExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand comments'**
  String get topicCommentsExpand;

  /// No description provided for @topicCommentsShrink.
  ///
  /// In en, this message translates to:
  /// **'Shrink comments'**
  String get topicCommentsShrink;

  /// No description provided for @chatTakeShared.
  ///
  /// In en, this message translates to:
  /// **'Shared a take'**
  String get chatTakeShared;

  /// No description provided for @chatTopicShared.
  ///
  /// In en, this message translates to:
  /// **'Shared a topic'**
  String get chatTopicShared;

  /// No description provided for @chatTaggedYou.
  ///
  /// In en, this message translates to:
  /// **'Tagged you in a comment'**
  String get chatTaggedYou;

  /// No description provided for @chatYouTagged.
  ///
  /// In en, this message translates to:
  /// **'You tagged them in a comment'**
  String get chatYouTagged;

  /// No description provided for @chatTaggedThem.
  ///
  /// In en, this message translates to:
  /// **'Tagged them in a comment'**
  String get chatTaggedThem;

  /// No description provided for @chatYouSharedTopic.
  ///
  /// In en, this message translates to:
  /// **'You shared a topic'**
  String get chatYouSharedTopic;

  /// No description provided for @chatYouSharedTake.
  ///
  /// In en, this message translates to:
  /// **'You shared a take'**
  String get chatYouSharedTake;

  /// No description provided for @commentAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get commentAddPhoto;

  /// No description provided for @commentRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get commentRemovePhoto;

  /// No description provided for @takeFeltLabel.
  ///
  /// In en, this message translates to:
  /// **'Felt'**
  String get takeFeltLabel;

  /// Title and pen-button label for editing a home film list.
  ///
  /// In en, this message translates to:
  /// **'Edit {list}'**
  String homeEditList(String list);

  /// Edit film list page.
  ///
  /// In en, this message translates to:
  /// **'Add a film'**
  String get homeEditListAdd;

  /// Remove button label on the edit list page.
  ///
  /// In en, this message translates to:
  /// **'Remove {title}'**
  String homeEditListRemove(String title);

  /// Edit film list page.
  ///
  /// In en, this message translates to:
  /// **'No films here yet.'**
  String get homeEditListEmpty;

  /// Edit film list page.
  ///
  /// In en, this message translates to:
  /// **'Your Top 5 is full. Remove a film to add another.'**
  String get homeEditListFull;

  /// Small line under the Watched section title.
  ///
  /// In en, this message translates to:
  /// **'Films you\'ve already seen'**
  String get homeWatchedHint;

  /// Small line under the Watchlist section title.
  ///
  /// In en, this message translates to:
  /// **'Films you want to watch'**
  String get homeWatchlistHint;

  /// Hint on the Watchlist edit page's cover wall before the first touch.
  ///
  /// In en, this message translates to:
  /// **'Drag your finger over the covers'**
  String get homeLensHint;

  /// Open button for the picked film on the cover wall.
  ///
  /// In en, this message translates to:
  /// **'Open {title}'**
  String homeLensOpen(String title);

  /// Tooltip of the ⋮ menu on the edit list page.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get homeListMore;

  /// Menu item that shares the list as text.
  ///
  /// In en, this message translates to:
  /// **'Share your list'**
  String get homeListShare;

  /// Menu item and page title: the cover wall that lands on a random film.
  ///
  /// In en, this message translates to:
  /// **'Pick at random'**
  String get homeListRandom;

  /// Button on the random page that picks another film.
  ///
  /// In en, this message translates to:
  /// **'Pick another'**
  String get homeListShuffle;

  /// First line of a shared list.
  ///
  /// In en, this message translates to:
  /// **'My {list} on FilmSage:'**
  String homeListShareText(String list);

  /// The heart reaction on takes and topics (tooltip and screen reader).
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get takeHeartLike;

  /// Screen reader count of hearts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No likes} =1{1 like} other{{count} likes}}'**
  String takeHeartCount(int count);

  /// Movie lists: myListsTitle
  ///
  /// In en, this message translates to:
  /// **'My lists'**
  String get myListsTitle;

  /// Movie lists: myListsHint
  ///
  /// In en, this message translates to:
  /// **'Lists you made and posted'**
  String get myListsHint;

  /// Movie lists: friendsListsTitle
  ///
  /// In en, this message translates to:
  /// **'Friends\' lists'**
  String get friendsListsTitle;

  /// Movie lists: friendsListsHint
  ///
  /// In en, this message translates to:
  /// **'What your friends put together'**
  String get friendsListsHint;

  /// Movie lists: listNew
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get listNew;

  /// Movie lists: listsEmptyMine
  ///
  /// In en, this message translates to:
  /// **'Make your first list: give it a name and pick some films.'**
  String get listsEmptyMine;

  /// Movie lists: listCreateTitle
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get listCreateTitle;

  /// Movie lists: listNameLabel
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listNameLabel;

  /// Movie lists: listNameHint
  ///
  /// In en, this message translates to:
  /// **'Best heist films'**
  String get listNameHint;

  /// Movie lists: listSearchHint
  ///
  /// In en, this message translates to:
  /// **'Search films to add'**
  String get listSearchHint;

  /// Movie lists: listAddFilm
  ///
  /// In en, this message translates to:
  /// **'Add {title}'**
  String listAddFilm(String title);

  /// Movie lists: listRemoveFilm
  ///
  /// In en, this message translates to:
  /// **'Remove {title}'**
  String listRemoveFilm(String title);

  /// Movie lists: listPost
  ///
  /// In en, this message translates to:
  /// **'Post list'**
  String get listPost;

  /// Movie lists: listFilmCount
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 film} other{{count} films}}'**
  String listFilmCount(int count);

  /// Movie lists: listBy
  ///
  /// In en, this message translates to:
  /// **'By {name}'**
  String listBy(String name);

  /// Movie lists: listCommentsTitle
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get listCommentsTitle;

  /// Movie lists: listCommentHint
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get listCommentHint;

  /// Movie lists: listCommentsEmpty
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Say what you think of this list.'**
  String get listCommentsEmpty;

  /// Movie lists: listCommentCount
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No comments} =1{1 comment} other{{count} comments}}'**
  String listCommentCount(int count);

  /// Movie lists: listDelete
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get listDelete;

  /// Movie lists: listDeleteConfirm
  ///
  /// In en, this message translates to:
  /// **'Delete this list? This can\'t be undone.'**
  String get listDeleteConfirm;

  /// Movie lists: listCancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get listCancel;

  /// Movie lists: listPostFailed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post the list. Try again.'**
  String get listPostFailed;

  /// Movie lists: listLoadFailed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load lists.'**
  String get listLoadFailed;

  /// Movie lists: listPicked
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No films yet} =1{1 film picked} other{{count} films picked}}'**
  String listPicked(int count);

  /// Movie lists: listSearchEmpty
  ///
  /// In en, this message translates to:
  /// **'No films found.'**
  String get listSearchEmpty;

  /// Movie lists: listSendFailed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send. Try again.'**
  String get listSendFailed;

  /// Top-right button on a topic you did not write: save it to your profile.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get takeActionSave;

  /// Tooltip of the Save button once the topic is saved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get takeActionUnsave;

  /// Shown after saving a topic.
  ///
  /// In en, this message translates to:
  /// **'Saved to your profile'**
  String get takeSavedToast;

  /// Shown after unsaving a topic.
  ///
  /// In en, this message translates to:
  /// **'Removed from your saved topics'**
  String get takeUnsavedToast;

  /// Shown when saving a topic failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Try again.'**
  String get takeSaveFailed;

  /// Profile section with the topics you saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileSavedTitle;

  /// Empty state of the saved topics section.
  ///
  /// In en, this message translates to:
  /// **'Topics you save show up here.'**
  String get profileSavedEmpty;

  /// Top-right button on a list page: share it.
  ///
  /// In en, this message translates to:
  /// **'Share list'**
  String get listShare;

  /// First line of the shared text of a list; the films follow, one per line.
  ///
  /// In en, this message translates to:
  /// **'{name} — a list by {owner} on Film Wise'**
  String listShareText(String name, String owner);

  /// Top-right button on someone else's list: save it to your profile.
  ///
  /// In en, this message translates to:
  /// **'Save list'**
  String get listSave;

  /// Tooltip of the Save button once the list is saved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get listUnsave;

  /// Shown after saving a list.
  ///
  /// In en, this message translates to:
  /// **'List saved to your profile'**
  String get listSavedToast;

  /// Shown after unsaving a list.
  ///
  /// In en, this message translates to:
  /// **'List removed from your saved lists'**
  String get listUnsavedToast;

  /// Shown when saving a list failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the list. Try again.'**
  String get listSaveFailed;

  /// Top-right button on your own list: edit it.
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get listEdit;

  /// Title of the screen that edits a list.
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get listEditTitle;

  /// Button that saves the edited list.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get listSaveChanges;

  /// Profile section with the lists you saved.
  ///
  /// In en, this message translates to:
  /// **'Saved lists'**
  String get savedListsTitle;

  /// Subtitle of the saved lists section.
  ///
  /// In en, this message translates to:
  /// **'Lists you kept from others'**
  String get savedListsHint;

  /// Tooltip of the ⋮ menu on a list page (Share, Edit, Delete, Save).
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get listMenuTooltip;

  /// Share sheet of a list when you have no friends yet.
  ///
  /// In en, this message translates to:
  /// **'Add friends to send them lists.'**
  String get listShareNoFriends;

  /// Label on a list card a friend sent you in the chat.
  ///
  /// In en, this message translates to:
  /// **'Shared a list'**
  String get chatListShared;

  /// Label on a list card you sent in the chat.
  ///
  /// In en, this message translates to:
  /// **'You shared a list'**
  String get chatYouSharedList;

  /// Notifications: top-right action that marks every notification read.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// Notifications: filter tab showing everything.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsTabAll;

  /// Notifications: filter tab for takes friends sent you.
  ///
  /// In en, this message translates to:
  /// **'Takes'**
  String get notificationsTabTakes;

  /// Notifications: filter tab for comments that tagged you.
  ///
  /// In en, this message translates to:
  /// **'Mentions'**
  String get notificationsTabMentions;

  /// Notifications: filter tab for friend requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get notificationsTabRequests;

  /// Notifications: section heading over pending friend requests.
  ///
  /// In en, this message translates to:
  /// **'Friend requests'**
  String get notificationsGroupRequests;

  /// Notifications: section heading over unread notifications.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsGroupNew;

  /// Notifications: section heading over read notifications.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsGroupEarlier;

  /// Notifications: shown on a friend request after accepting it.
  ///
  /// In en, this message translates to:
  /// **'You\'re now friends'**
  String get notificationsNowFriends;

  /// Notifications: toast after declining a friend request, with Undo.
  ///
  /// In en, this message translates to:
  /// **'Request from {name} declined'**
  String notificationsRequestDeclined(String name);

  /// Notifications: action on the decline toast that brings the request back.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get notificationsUndo;

  /// Notifications: empty state of a filter tab.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get notificationsNothingHere;

  /// Notifications: short time for something under a minute old.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get notificationsTimeNow;

  /// Notifications: short time in minutes, like 5m.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String notificationsTimeMinutes(int count);

  /// Notifications: short time in hours, like 3h.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String notificationsTimeHours(int count);

  /// Notifications: time for something from yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsTimeYesterday;

  /// Notifications: short time in days, like 4d.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String notificationsTimeDays(int count);

  /// Notifications: screen-reader label for a tab's unread count.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String notificationsUnreadCount(int count);
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
      <String>['ar', 'en', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
