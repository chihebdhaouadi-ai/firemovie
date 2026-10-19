// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String homePointsLabel(int points) {
    return '$points Points';
  }

  @override
  String get homeTop5Title => 'Your Top 5';

  @override
  String get homeTop5Hint => 'Pick five films you love';

  @override
  String get homeTop5AddLabel => 'Add a film to your Top 5';

  @override
  String get homeRecommendTitle => 'Recommend me';

  @override
  String get homeRecommendHint =>
      'Pick exactly 3 films to generate a recommendation';

  @override
  String homePickSlotEmpty(int index) {
    return 'Empty pick slot $index';
  }

  @override
  String get homeGenerateButton => 'GENERATE';

  @override
  String homeGenerateDisabledHint(int remaining) {
    return 'Pick $remaining more film(s) to enable';
  }

  @override
  String get homeGenerating => 'Generating…';

  @override
  String get homeGenerateSuccess => 'Recommendation ready';

  @override
  String get homeQuickActionsLabel => 'Quick actions';

  @override
  String get homeQuickActionSearch => 'Search';

  @override
  String get homeQuickActionAddFilm => 'Add film';

  @override
  String get homeWatchedTitle => 'Watched';

  @override
  String get homeWatchlistTitle => 'Watchlist';

  @override
  String get homePopularTitle => 'Popular With Friends';

  @override
  String homeFilmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films',
      one: '1 film',
    );
    return '$_temp0';
  }

  @override
  String homeAddTileLabel(String section) {
    return 'Add to $section';
  }

  @override
  String homeFilmTileSemantics(String title, String section) {
    return '$title, $section';
  }

  @override
  String homeRemoveFilm(String title) {
    return 'Remove $title';
  }

  @override
  String get homeSectionEmptyTitle => 'Nothing here yet';

  @override
  String get homeSectionEmptyAction => 'Add a film';

  @override
  String get homeSectionErrorTitle => 'Couldn\'t load this list';

  @override
  String get homeSectionErrorRetry => 'Retry';

  @override
  String homeRemovedSnackbar(String title) {
    return 'Removed $title';
  }

  @override
  String get homeUndo => 'Undo';

  @override
  String get homeTop5FullSnackbar => 'Your Top 5 is full. Remove a film first.';

  @override
  String get homeRecommendFullSnackbar => 'You can pick up to 3 films.';

  @override
  String get homeGenericErrorSnackbar =>
      'Something went wrong. Please try again.';

  @override
  String get findTitleTop5 => 'Add to Top 5';

  @override
  String get findTitleWatched => 'Add to Watched';

  @override
  String get findTitleWatchlist => 'Add to Watchlist';

  @override
  String get findTitleGenerate => 'Pick a film';

  @override
  String get findTitleSearch => 'Find a film';

  @override
  String get findBodySearch => 'All films';

  @override
  String get findSearchHint => 'Name of film…';

  @override
  String get findSearchClear => 'Clear search';

  @override
  String get findSearchSubmit => 'Search';

  @override
  String get findMinCharsTitle => 'Keep typing';

  @override
  String get findMinCharsBody => 'Type at least 2 characters to search.';

  @override
  String get findLoadingTitle => 'Searching films…';

  @override
  String findEmptyTitle(String query) {
    return 'No results for “$query”';
  }

  @override
  String get findEmptyTip1 => 'Check the spelling or try another title.';

  @override
  String get findEmptyTip2 => 'Try a shorter keyword or a director’s name.';

  @override
  String get findErrorTitle => 'Couldn’t search right now';

  @override
  String get findErrorRetry => 'Retry';

  @override
  String get findOfflineTitle => 'You’re offline';

  @override
  String get findOfflineBody => 'Search and adding are disabled while offline.';

  @override
  String get findNoMoreResults => 'End of results';

  @override
  String get findLoadMore => 'Load more';

  @override
  String get findRecentTitle => 'Recent searches';

  @override
  String get findRecentClear => 'Clear';

  @override
  String get findRecentSwipeDelete => 'Remove recent search';

  @override
  String get findRecentEmpty => 'No recent searches yet.';

  @override
  String get findDirectedBy => 'Directed by';

  @override
  String get findGenreChip => 'Genre';

  @override
  String get findAddToTop5 => 'Add to Top 5';

  @override
  String get findAddToWatched => 'Add to Watched';

  @override
  String get findAddToWatchlist => 'Add to Watchlist';

  @override
  String get findAddToPick => 'Add to picks';

  @override
  String findResultSemantics(
      String title, String year, String director, String action) {
    return '$title, $year, directed by $director. $action';
  }

  @override
  String findAddedSemantics(String title, String target) {
    return '$title is already in $target';
  }

  @override
  String findResultDetailsAction(String title) {
    return 'Open details for $title';
  }

  @override
  String get findViewDetails => 'Details';

  @override
  String get findSendToFriend => 'Send to a friend';

  @override
  String findAddedSnackbar(String target) {
    return 'Added to $target';
  }

  @override
  String get findUndo => 'Undo';

  @override
  String findRemovedSnackbar(String target) {
    return 'Removed from $target';
  }

  @override
  String get findMovedToWatched => 'Moved to Watched';

  @override
  String findReplaceSlotTitle(String current) {
    return 'Replace $current?';
  }

  @override
  String findReplaceSlotBody(String current, String replacement) {
    return 'This spot is already taken by $current. Replace it with $replacement?';
  }

  @override
  String get findReplace => 'Replace';

  @override
  String get findCancel => 'Cancel';

  @override
  String get findTop5FullTitle => 'Top 5 is full';

  @override
  String get findTop5FullBody => 'Remove a film before adding to your Top 5.';

  @override
  String get findAlreadyWatchedTitle => 'Already watched';

  @override
  String get findAlreadyWatchedBody =>
      'You can’t add an already-watched film to your Watchlist.';

  @override
  String get findAlreadyInListTitle => 'Already added';

  @override
  String findAlreadyInListBody(String title, String target) {
    return '$title is already in $target.';
  }

  @override
  String get findGenericErrorTitle => 'Something went wrong';

  @override
  String get findGenericErrorBody => 'Please try again.';

  @override
  String get findDetailsErrorTitle => 'Couldn’t load the film';

  @override
  String get findDetailsRetry => 'Retry';

  @override
  String get findDetailsCast => 'Cast';

  @override
  String get findDetailsOverview => 'Overview';

  @override
  String findDetailsRuntime(int minutes) {
    return '$minutes min';
  }

  @override
  String findDetailsVote(String value) {
    return '$value stars';
  }

  @override
  String get findWatchNow => 'Watch now';

  @override
  String get findAttribution =>
      'Film data and posters via TMDB. Streaming availability via JustWatch.';

  @override
  String get overviewBack => 'Back';

  @override
  String overviewRating(String value) {
    return '$value / 10';
  }

  @override
  String get overviewNoRating => 'No rating yet';

  @override
  String get overviewWhereToWatch => 'Where to watch?';

  @override
  String get overviewNoStreaming => 'No streaming providers found';

  @override
  String overviewRatingsCount(int count) {
    return 'Ratings: $count filmwiser';
  }

  @override
  String overviewStarsValue(String value) {
    return '$value out of 5 stars';
  }

  @override
  String get overviewTrailer => 'Trailer';

  @override
  String get overviewStreamLabel => 'Stream';

  @override
  String get overviewRentLabel => 'Rent';

  @override
  String get overviewBuyLabel => 'Buy';

  @override
  String get overviewNoGenres => 'No genres listed';

  @override
  String get overviewTabGenres => 'GENRES';

  @override
  String get overviewTabCast => 'CAST';

  @override
  String get overviewTabCrew => 'CREW';

  @override
  String get overviewTabProd => 'PROD';

  @override
  String get overviewActivityTitle => 'Activity From Friends';

  @override
  String get overviewWantsToWatch => 'Wants to watch';

  @override
  String get overviewReviewsTitle => 'Reviews';

  @override
  String get overviewAddReviewHint => 'Add a review...';

  @override
  String get overviewYourReview => 'Your Review';

  @override
  String get overviewFriendsReviews => 'Friends Reviews';

  @override
  String get overviewPopularReviews => 'Popular Reviews';

  @override
  String get overviewSeeAll => 'See All';

  @override
  String overviewReviewBy(String name, String date) {
    return 'Review by $name on $date';
  }

  @override
  String get homeOpenProfile => 'Open profile';

  @override
  String get profileBack => 'Back';

  @override
  String get profileSearchTooltip => 'Search';

  @override
  String get profileMoreTooltip => 'More options';

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileBioHint => 'Edit your bio..';

  @override
  String get profileChat => 'Chat';

  @override
  String get profileFollow => 'Follow';

  @override
  String get profileSend => 'Send';

  @override
  String get profileAchievementsTitle => 'Achievements';

  @override
  String get profileAchievementRookie => 'CINEPHILE ROOKIE';

  @override
  String get profileAchievementMaster => 'CINEPHILE MASTER';

  @override
  String get profileAchievementLegend => 'CINEPHILE LEGEND';

  @override
  String profileAchievementFilms(int count) {
    return '$count films';
  }

  @override
  String get profileClaim => 'Claim';

  @override
  String get profileStatisticsTitle => 'Statistics';

  @override
  String get profileStatWatched => 'Watched';

  @override
  String get profileStatWatchlist => 'Watchlist';

  @override
  String get profileStatReviews => 'Reviews';

  @override
  String get profileStatRewards => 'Rewards';

  @override
  String get profileBlockTitle => 'You want to block this user?';

  @override
  String get profileBlockReasonHint => 'Why?..';

  @override
  String get profileBlockYes => 'Yes';

  @override
  String get profileBlockNo => 'No';

  @override
  String get profileErrorTitle => 'We couldn\'t load your profile.';

  @override
  String get profileRetry => 'Try again';

  @override
  String get onboardingFinishLater => 'Finish later';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingFinish => 'Finish';

  @override
  String get onboardingSkip => 'Skip for now';

  @override
  String get onboardingSaveFailed =>
      'Couldn\'t save that. Check your connection and try again.';

  @override
  String get onboardingAvatarTitle => 'Add a profile photo';

  @override
  String get onboardingAvatarBody =>
      'Pick a picture so people can recognise you. JPG, PNG or WebP, up to 5 MB.';

  @override
  String get onboardingChoosePhoto => 'Choose photo';

  @override
  String get onboardingPhotoSaved => 'Profile photo saved';

  @override
  String get onboardingCoverTitle => 'Add a cover photo';

  @override
  String get onboardingCoverBody => 'A wide image behind your profile header.';

  @override
  String get onboardingChooseCover => 'Choose cover';

  @override
  String get onboardingCoverSaved => 'Cover saved';

  @override
  String get onboardingBioTitle => 'Write a short bio';

  @override
  String get onboardingBioBody => 'Tell people what kind of films you love.';

  @override
  String get onboardingBioHint => 'A few words about your taste in film';

  @override
  String get onboardingTop5Title => 'Choose your top 5 movies';

  @override
  String get onboardingTop5Body =>
      'Your favourite films, shown first on your profile.';

  @override
  String onboardingTop5Progress(int count) {
    return '$count of 5 chosen';
  }

  @override
  String get onboardingWatchedTitle => 'Add movies you\'ve watched';

  @override
  String get onboardingWatchedBody => 'Log the films you have already seen.';

  @override
  String get onboardingWatchlistTitle => 'Add movies to watch';

  @override
  String get onboardingWatchlistBody =>
      'Save the films you plan to watch next.';

  @override
  String onboardingFilmsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films added',
      one: '1 film added',
    );
    return '$_temp0';
  }

  @override
  String get onboardingSearchFilms => 'Search films';

  @override
  String get profileNotificationsTooltip => 'Notifications';

  @override
  String get profileEditPhoto => 'Edit photo';

  @override
  String get profileEditCover => 'Edit cover';

  @override
  String get profileEditBio => 'Edit bio';

  @override
  String get profileEditBioTitle => 'Edit your bio';

  @override
  String get profileSave => 'Save';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileSaveFailed => 'Couldn\'t save that. Try again.';

  @override
  String get profileNoConnections => 'No one here yet.';

  @override
  String get friendAdd => 'Add friend';

  @override
  String get friendCancelRequest => 'Cancel request';

  @override
  String get friendAccept => 'Accept';

  @override
  String get friendDecline => 'Decline';

  @override
  String get friendFriends => 'Friends';

  @override
  String get friendRequestSent => 'Friend request sent.';

  @override
  String get friendActionFailed =>
      'Couldn\'t update the friend request. Try again.';

  @override
  String get friendRequestGone => 'This request is no longer available.';

  @override
  String get friendAlreadyConnected =>
      'You\'re already friends or have a pending request.';

  @override
  String get searchPeopleTitle => 'Find people';

  @override
  String get searchPeopleHint => 'Search by username';

  @override
  String get searchPeopleMinChars => 'Type at least 2 characters.';

  @override
  String get searchPeopleEmpty => 'No users found.';

  @override
  String get searchPeopleFailed => 'Couldn\'t search right now. Try again.';

  @override
  String get suggestMovieAction => 'Suggest a movie';

  @override
  String get suggestionTitle => 'Suggest a movie';

  @override
  String get suggestionSearchHint => 'Search a movie title';

  @override
  String get suggestionSearchMinChars => 'Type at least 2 characters.';

  @override
  String get suggestionSearchEmpty => 'No movies found.';

  @override
  String get suggestionSearchFailed => 'Couldn\'t search right now. Try again.';

  @override
  String get suggestionMovieSection => 'Movie';

  @override
  String get suggestionPickMovie => 'Pick a movie to suggest.';

  @override
  String get suggestionChangeMovie => 'Change movie';

  @override
  String get suggestionRecipientsSection => 'Send to';

  @override
  String get suggestionSelectAll => 'Select all';

  @override
  String get suggestionNoFriends =>
      'Add friends first to send them suggestions.';

  @override
  String get suggestionFriendsFailed => 'Couldn\'t load your friends.';

  @override
  String get suggestionCommentHint => 'Add a comment (optional)';

  @override
  String get suggestionSend => 'Send suggestion';

  @override
  String get suggestionSent => 'Suggestion sent.';

  @override
  String get suggestionFailed => 'Couldn\'t send the suggestion. Try again.';

  @override
  String get suggestionNotFriends =>
      'You can only suggest movies to friends. Update your selection and try again.';

  @override
  String notificationMovieSuggestion(String name, String title) {
    return '$name suggested $title to you.';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String get notificationsFailed => 'Couldn\'t load notifications.';

  @override
  String notificationFriendRequest(String name) {
    return '$name sent you a friend request.';
  }

  @override
  String notificationFriendAccepted(String name) {
    return '$name accepted your friend request.';
  }
}
