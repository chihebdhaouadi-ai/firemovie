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
  String get homeCollectionsTitle => 'Collections';

  @override
  String get homeTabYou => 'You';

  @override
  String get homeTabFriends => 'Friends';

  @override
  String get homeTabExplore => 'Explore';

  @override
  String get homeTabFilms => 'Films';

  @override
  String get homePopularTakesTitle => 'Popular takes';

  @override
  String get homeTrendingTopicsTitle => 'Trending topics';

  @override
  String get homeTrendingEmpty => 'No questions or discussions this week yet.';

  @override
  String get homeLatestArticlesTitle => 'Latest articles';

  @override
  String get homeUpcomingThisMonthTitle => 'Upcoming Films';

  @override
  String upcomingNotOutYet(String title, String date) {
    return '$title is not out yet. It releases on $date.';
  }

  @override
  String get homePopularThisWeekTitle => 'Popular Films';

  @override
  String get homeFriendsFilmsTitle => 'Friends\' films this week';

  @override
  String get homeFriendsReviewsTitle => 'Friends\' latest reviews';

  @override
  String get homeMyTakesTitle => 'My takes';

  @override
  String get homeComingSoon => 'Coming soon';

  @override
  String get homeFriendsReviewsEmpty =>
      'Your friends haven\'t posted any reviews yet.';

  @override
  String get homeMyTakesEmpty => 'You haven\'t shared any takes yet.';

  @override
  String get homeUnderConstruction => 'This section is under construction.';

  @override
  String get exploreSkipStamp => 'SKIP';

  @override
  String get exploreOpenStamp => 'OPEN';

  @override
  String get exploreCaughtUp => 'You are all caught up';

  @override
  String get exploreReviewButton => 'Review';

  @override
  String get exploreSubtitle =>
      'Discover reviews, conversations and questions about films.';

  @override
  String get createSceneMovieHint =>
      'Your scene appears in that movie\'s discussion.';

  @override
  String get createPollQuestionHint => 'What do you want to ask?';

  @override
  String get exploreFilterAll => 'All';

  @override
  String get exploreFilterConversations => 'Conversations';

  @override
  String get exploreFilterPolls => 'Polls';

  @override
  String get exploreFilterScenes => 'Scenes';

  @override
  String get exploreFilterQuestions => 'Questions';

  @override
  String get exploreFilterReviews => 'Reviews';

  @override
  String get exploreSpoilerReveal => 'Tap to reveal';

  @override
  String get topicTagPoll => 'Poll';

  @override
  String get topicTagScene => 'Scene';

  @override
  String get topicSpoilerLabel => 'Contains spoilers';

  @override
  String get pollVoteHint => 'Tap an option to vote';

  @override
  String get pollChangeVoteHint => 'Tap another option to change your vote';

  @override
  String pollVoteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String get createTypePollSubtitle =>
      'Let people vote between 2 and 4 options.';

  @override
  String get createTypeSceneSubtitle =>
      'Pick one moment from a film and explain why it works.';

  @override
  String get createWritePollTitle => 'Write your poll question';

  @override
  String get createPollOptionsTitle => 'Add the options';

  @override
  String get createPollOptionsHint => 'Give 2 to 4 choices. People pick one.';

  @override
  String createPollOptionLabel(int number) {
    return 'Option $number';
  }

  @override
  String get createPollAddOption => 'Add option';

  @override
  String get createPollRemoveOption => 'Remove option';

  @override
  String get createSceneTitle => 'Describe the scene';

  @override
  String get createSceneNameLabel => 'Scene';

  @override
  String get createSceneNameHint => 'The interrogation room';

  @override
  String get createSceneTimecodeLabel => 'Timecode (optional)';

  @override
  String get createSceneTimecodeHint => '1h 12m';

  @override
  String get createSceneExplainLabel => 'Why it works';

  @override
  String get createSceneExplainHint => 'Say what makes this moment special';

  @override
  String exploreRepliesButton(int count) {
    return 'View all $count replies';
  }

  @override
  String get exploreStripConversation => 'Conversation';

  @override
  String exploreRepliesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
    );
    return '$_temp0';
  }

  @override
  String get exploreNoRepliesYet => 'No replies yet';

  @override
  String get exploreBeFirstRespond => 'Be the first to respond';

  @override
  String explorePeopleTalking(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people talking',
      one: '1 person talking',
    );
    return '$_temp0';
  }

  @override
  String exploreLastReply(String time) {
    return 'last reply $time';
  }

  @override
  String get exploreNoVotesYet => 'No votes yet';

  @override
  String exploreAgreePercent(int percent) {
    return '$percent% agree';
  }

  @override
  String exploreDisagreePercent(int percent) {
    return '$percent% disagree';
  }

  @override
  String get exploreFor => 'For';

  @override
  String get exploreAgainst => 'Against';

  @override
  String exploreBeFirstArgue(String side) {
    return 'Be the first to argue $side';
  }

  @override
  String explorePickedBy(String name) {
    return 'picked by $name';
  }

  @override
  String get exploreThanksVoting => 'Thanks for voting';

  @override
  String get exploreJoinConversation => 'Join the conversation';

  @override
  String get homeCollectionsResizeLabel => 'Resize collections';

  @override
  String get homeFeedTitle => 'Reviews From Your Collections';

  @override
  String get homeFeedEmpty =>
      'No reviews on the films in your collections yet.';

  @override
  String get homeFeedShowAsRow => 'Show as row';

  @override
  String get homeFeedShowAsColumn => 'Show as column';

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
  String get homeGenericErrorSnackbar =>
      'Something went wrong. Please try again.';

  @override
  String get findTitleTop5 => 'Add to Top 5';

  @override
  String get findTitleWatched => 'Add to Watched';

  @override
  String get findTitleWatchlist => 'Add to Watchlist';

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
  String get overviewNoFriendActivity => 'No activity from your friends yet.';

  @override
  String get overviewShowMore => 'more';

  @override
  String get overviewShowLess => 'less';

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
  String get reviewTrustedLabel => 'from trusted viewers';

  @override
  String reviewEveryoneTogether(String value) {
    return 'Everyone together: $value';
  }

  @override
  String get reviewMostFelt => 'Most felt:';

  @override
  String get reviewWhatIsTrusted => 'What is “trusted”?';

  @override
  String get reviewTrustedNote =>
      'Viewers earn trust when others find their takes well argued. Their votes count a little more, so the score feels fair and thoughtful.';

  @override
  String get reviewReactionTitle => 'How did it make you feel?';

  @override
  String get reviewReactionHint => 'Tap the one that fits best.';

  @override
  String get reviewReactionLoved => 'Loved it';

  @override
  String get reviewReactionBrokeHeart => 'Broke my heart';

  @override
  String get reviewReactionBlewMind => 'Blew my mind';

  @override
  String get reviewReactionMadeCry => 'Made me cry';

  @override
  String get reviewReactionShocked => 'Shocked me';

  @override
  String get reviewReactionMadeLaugh => 'Made me laugh';

  @override
  String get reviewReactionBored => 'Bored me';

  @override
  String get reviewReactionDisappointed => 'Disappointed me';

  @override
  String get reviewReactionMadeThink => 'Made me think';

  @override
  String get reviewReactionMasterpiece => 'Masterpiece';

  @override
  String get reviewReactionTapToReact => 'Tap to react';

  @override
  String get reviewReactionChange => 'Change';

  @override
  String get reviewReactionPickOne => 'Pick one';

  @override
  String get reviewReactionClose => 'Close';

  @override
  String get reviewWhyPrompt => 'Want to add a line about why? It\'s optional.';

  @override
  String get reviewWhyHint => 'What stayed with you?';

  @override
  String get reviewShare => 'Share';

  @override
  String get reviewNoThanks => 'No thanks';

  @override
  String get reviewSharedThanks => 'Thanks for sharing your take!';

  @override
  String get reviewCountedThanks => 'Thanks! Your reaction is counted.';

  @override
  String get reviewReactionFailed => 'Couldn\'t save your reaction. Try again.';

  @override
  String get reviewSummaryFailed => 'Couldn\'t load the reactions.';

  @override
  String get reviewDetailTitle => 'Reviews';

  @override
  String get reviewTakesTitle => 'What people said';

  @override
  String get reviewTakesHint => 'Short takes from other viewers.';

  @override
  String get reviewMostHelpful => 'Most helpful take';

  @override
  String get sageNavUnread => 'Has unread';

  @override
  String get sageNavCloseMenu => 'Close menu';

  @override
  String get reviewWriterBadge => 'Writer';

  @override
  String reviewCommentsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Comments $count',
      zero: 'Comment',
    );
    return '$_temp0';
  }

  @override
  String get reviewCommentHint => 'Add a comment';

  @override
  String get reviewSend => 'Send';

  @override
  String get reviewCommentsFailed => 'Couldn\'t load comments.';

  @override
  String get reviewCommentFailed => 'Couldn\'t post that comment. Try again.';

  @override
  String get reviewReply => 'Reply';

  @override
  String reviewReplyingTo(String name) {
    return 'Replying to $name';
  }

  @override
  String get reviewCancelReply => 'Cancel reply';

  @override
  String reviewShowReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count replies',
      one: 'Show 1 reply',
    );
    return '$_temp0';
  }

  @override
  String get reviewHideReplies => 'Hide replies';

  @override
  String get reviewTimeJustNow => 'Just now';

  @override
  String reviewTimeMinutes(int count) {
    return '${count}m ago';
  }

  @override
  String reviewTimeHours(int count) {
    return '${count}h ago';
  }

  @override
  String reviewTimeDays(int count) {
    return '${count}d ago';
  }

  @override
  String get reviewVoteChangedMyMind => 'Changed my mind';

  @override
  String get reviewVoteWellArgued => 'Well argued';

  @override
  String get reviewVoteDisagreeFair => 'Disagree but fair';

  @override
  String get reviewVoteFailed => 'Couldn\'t update that vote. Try again.';

  @override
  String get reviewTakeFailed => 'Couldn\'t post that. Try again.';

  @override
  String get reviewTakesEmpty => 'No takes here yet.';

  @override
  String get reviewTakesFailed => 'Couldn\'t load takes.';

  @override
  String get reviewRetry => 'Try again';

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
  String get profileLogout => 'Log out';

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileBioHint => 'Edit your bio…';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films',
      one: '1 film',
    );
    return '$_temp0';
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
  String get profileBlockReasonHint => 'Why?…';

  @override
  String get profileBlockYes => 'Yes';

  @override
  String get profileBlockNo => 'No';

  @override
  String get profileErrorTitle => 'We couldn\'t load your profile.';

  @override
  String get profileRetry => 'Try again';

  @override
  String get profileLanguageButton => 'Manage languages';

  @override
  String get profileLanguageDialogTitle => 'App language';

  @override
  String get profileLanguageSystem => 'System default';

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

  @override
  String get angelBirdQuestion =>
      'Want to join a debate about one of your top 5 movies? The Sage community would love to hear your opinion.';

  @override
  String get angelBirdYes => 'Yes, let\'s debate';

  @override
  String get angelBirdNotNow => 'Not now';

  @override
  String get angelBirdPickFilm => 'Pick a film to debate';

  @override
  String get angelBirdEmptyTop5 =>
      'Your top 5 is empty. Add five films to start a debate.';

  @override
  String get angelBirdLoadFailed => 'Couldn\'t load your top 5.';

  @override
  String get angelBirdRetry => 'Try again';

  @override
  String get angelBirdReviewQuestion =>
      'Want to open a debate about this review? Pick someone from this conversation to talk with.';

  @override
  String get angelBirdPickPerson => 'Who do you want to debate with?';

  @override
  String get angelBirdNoPeople =>
      'Nobody to debate with yet. Wait for a comment on this review.';

  @override
  String get angelBirdPeopleFailed =>
      'Could not load the people in this review.';

  @override
  String debateWaitingTitle(String name) {
    return 'Waiting for $name';
  }

  @override
  String debateWaitingBody(String name) {
    return 'Your invite is sent. The debate starts as soon as $name accepts.';
  }

  @override
  String debateDeclined(String name) {
    return '$name can\'t debate right now. Try someone else from the conversation.';
  }

  @override
  String get debateInviteFailed => 'Couldn\'t send your invite. Try again.';

  @override
  String get debateLoadFailed => 'Couldn\'t load the questions. Try again.';

  @override
  String get debateSubmitFailed => 'Couldn\'t send your answers. Try again.';

  @override
  String get debateRetry => 'Try again';

  @override
  String get debateCancel => 'Cancel';

  @override
  String get debateDone => 'Done';

  @override
  String debateVsTitle(String name) {
    return 'You vs $name';
  }

  @override
  String debateQuestionCounter(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get debateResultWon => 'You won the debate!';

  @override
  String debateResultLost(String name) {
    return '$name won this round.';
  }

  @override
  String get debateResultTied => 'It\'s a tie.';

  @override
  String debateScoreLine(int mine, String name, int theirs) {
    return 'You $mine · $name $theirs';
  }

  @override
  String debateSagePointsWon(int points) {
    return '+$points Sage points';
  }

  @override
  String debateSagePointsLost(int points, String name) {
    return '$points Sage points go to $name.';
  }

  @override
  String get authTagline => 'UNLOCK YOUR INNER FILM BUFF';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authNoAccountPrompt => 'Don\'t have an account?';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authPasswordsMismatch => 'Passwords do not match';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authUsername => 'Username';

  @override
  String get authRepeatPassword => 'Repeat password';

  @override
  String get authHaveAccountPrompt => 'Already have an account?';

  @override
  String get authEmailRequired => 'Please enter your email';

  @override
  String get authEmailInvalid => 'Please enter a valid email';

  @override
  String get authPasswordRequired => 'Please enter your password';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get authUsernameRequired => 'Please enter a username';

  @override
  String get authUsernameTooShort => 'Username must be at least 6 characters';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authAccountCreated =>
      'Account created successfully. Sign in to continue.';

  @override
  String get authOr => 'or';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithReddit => 'Continue with Reddit';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInSubtitle => 'Sign in to pick up where you left off.';

  @override
  String get authCreateAccountSubtitle =>
      'Join the community and start sharing your takes.';

  @override
  String get authMinLengthHint => 'At least 6 characters';

  @override
  String get authErrorInvalidCredentials =>
      'Incorrect email or password. Please try again.';

  @override
  String get authErrorRegisterFailed =>
      'Could not create your account. Please try again.';

  @override
  String get authErrorNetwork =>
      'Could not reach the server. Check your connection and try again.';

  @override
  String get appWindowTitle => 'My App';

  @override
  String get findActionAdd => 'Add';

  @override
  String get findActionAdded => 'Added';

  @override
  String get reviewTranslate => 'Translate';

  @override
  String get reviewShowOriginal => 'Show original';

  @override
  String get reviewTranslateFailed => 'Couldn\'t translate this right now.';

  @override
  String reviewQuote(String body) {
    return '“$body”';
  }

  @override
  String get exploreCreateButton => 'Create';

  @override
  String get topicCreateTitle => 'Create topic';

  @override
  String get topicFindMovie => 'Find a movie';

  @override
  String get topicSearchHint => 'Search movies';

  @override
  String get topicNoResults => 'No movies found';

  @override
  String get topicChangeMovie => 'Change';

  @override
  String get topicTypeLabel => 'Type';

  @override
  String get topicTagReview => 'Review';

  @override
  String get topicTagQuestion => 'Question';

  @override
  String get topicTagDiscussion => 'Discussion';

  @override
  String get topicTagHotTake => 'Hot Take';

  @override
  String get topicReviewHint =>
      'Reviews are about one movie and need how it made you feel.';

  @override
  String get topicBodyHint => 'Write your review, question or discussion';

  @override
  String get topicPostButton => 'Post';

  @override
  String get topicPostFailed => 'Could not post. Please try again.';

  @override
  String get topicSearchFailed => 'Search failed. Please try again.';

  @override
  String get createTypeTitle => 'Choose what you want to share.';

  @override
  String get createTypeReviewSubtitle =>
      'Tell people how a movie made you feel.';

  @override
  String get createTypeQuestionSubtitle =>
      'Ask about a movie or share a photo.';

  @override
  String get createTypeDiscussionSubtitle =>
      'Start a conversation about a movie or a photo.';

  @override
  String get createTypeHotTakeSubtitle => 'Share a bold take about a film.';

  @override
  String get createWriteReviewTitle => 'Write your review';

  @override
  String get createWriteQuestionTitle => 'Write your question';

  @override
  String get createWriteDiscussionTitle => 'Start the discussion';

  @override
  String get createWriteHotTakeTitle => 'Write your hot take';

  @override
  String get createReviewMovieTitle => 'Which movie is it about?';

  @override
  String get createReviewMovieHint =>
      'Your review appears on that movie\'s page.';

  @override
  String get createFeelTitle => 'How did it make you feel?';

  @override
  String get createFeelHint => 'Pick one reaction. It shows with your review.';

  @override
  String get createSubjectTitle => 'What is it about?';

  @override
  String get createSubjectMovie => 'A movie';

  @override
  String get createSubjectPhoto => 'A photo';

  @override
  String get createAddPhoto => 'Choose a photo';

  @override
  String get createChangePhoto => 'Change photo';

  @override
  String get createPhotoFailed =>
      'Could not open your photos. Please try again.';

  @override
  String get createNext => 'Next';

  @override
  String get leaderboardTabLabel => 'Leaderboard';

  @override
  String get leaderboardTitle => 'Top reviewers';

  @override
  String get leaderboardSubtitle => 'Ranked by reactions on their reviews';

  @override
  String get leaderboardHowItWorks => 'How it works';

  @override
  String get leaderboardPeriodWeek => 'This week';

  @override
  String get leaderboardPeriodMonth => 'This month';

  @override
  String get leaderboardPeriodAll => 'All time';

  @override
  String get leaderboardReactionsLabel => 'reactions';

  @override
  String leaderboardReactionsWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'reactions',
      one: 'reaction',
    );
    return '$_temp0';
  }

  @override
  String leaderboardReviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String get leaderboardYouSuffix => '(you)';

  @override
  String get leaderboardEmpty => 'No reactions yet this period.';

  @override
  String get leaderboardLoadFailed => 'We couldn\'t load the leaderboard.';

  @override
  String get leaderboardRetry => 'Try again';

  @override
  String get howRankingTitle => 'How ranking works';

  @override
  String get howStep1Title => 'Write a review';

  @override
  String get howStep1Body =>
      'Review any film. It shows up in Explore and Friends.';

  @override
  String get howStep2Title => 'Collect reactions';

  @override
  String get howStep2Body =>
      'Readers react to your take. Every reaction is worth one point.';

  @override
  String get howStep3Title => 'Climb the board';

  @override
  String get howStep3Body =>
      'The reviewers with the most reactions in the period take the podium.';

  @override
  String get howNoteReset =>
      'This week resets every Monday at 00:00. This month and All time keep counting.';

  @override
  String get howNoteOncePerReview =>
      'Each person can react once per review. Reacting to your own review doesn\'t count.';

  @override
  String get howNoteTie =>
      'If two reviewers tie, the one who reached the total first ranks higher.';

  @override
  String get howNotePodium =>
      'The top three wear a podium frame (gold, blue, bronze) on the board for the period shown.';

  @override
  String get howLevelsTitle => 'Levels and XP';

  @override
  String get howXpReview => 'Write a review';

  @override
  String get howXpComment => 'Write a comment';

  @override
  String get howXpReaction => 'Receive a reaction';

  @override
  String howXpValue(int xp) {
    return '+$xp XP';
  }

  @override
  String get howLevelFoot => 'Each level needs 50 XP more than the one before.';

  @override
  String get profileBadgesTitle => 'Badges';

  @override
  String get badgeWellArguedTitle => 'Well argued';

  @override
  String badgeWellArguedDesc(int count) {
    return 'Receive $count “Well argued” reactions.';
  }

  @override
  String get badgeChangedMindTitle => 'Changed my mind';

  @override
  String badgeChangedMindDesc(int count) {
    return 'Receive $count “Changed my mind” reactions.';
  }

  @override
  String get badgeDisagreeTitle => 'Disagree but fair';

  @override
  String badgeDisagreeDesc(int count) {
    return 'Receive $count “Disagree but fair” reactions.';
  }

  @override
  String get badgeTopCriticTitle => 'Top critic';

  @override
  String get badgeTopCriticDesc => 'Finish in the weekly top 3.';

  @override
  String get badgeFirstTakeTitle => 'First take';

  @override
  String get badgeFirstTakeDesc => 'Be the first person to review a film.';

  @override
  String get achFilmCriticTitle => 'Film critic';

  @override
  String achFilmCriticDesc(int count) {
    return 'Write $count reviews.';
  }

  @override
  String get achDebaterTitle => 'Debater';

  @override
  String achDebaterDesc(int count) {
    return 'Get $count “Well argued” reactions.';
  }

  @override
  String get achLocalCinemaTitle => 'Local cinema';

  @override
  String achLocalCinemaDesc(int count) {
    return 'Review $count Tunisian films.';
  }

  @override
  String get achComingSoon => 'Coming soon';

  @override
  String get frameNewcomerTitle => 'Newcomer';

  @override
  String get frameExplorerTitle => 'Explorer';

  @override
  String get frameDebaterTitle => 'Debater';

  @override
  String get frameTopCriticTitle => 'Top critic';

  @override
  String get frameLegendTitle => 'Legend';

  @override
  String get frameAlwaysUnlocked => 'Everyone starts with this frame.';

  @override
  String frameLevelRequirement(int level) {
    return 'Reach Level $level.';
  }

  @override
  String frameDebaterRequirement(int count) {
    return 'Receive $count “Well argued” reactions.';
  }

  @override
  String get frameEquipped => 'Equipped';

  @override
  String get frameTapToEquip => 'Tap to equip';

  @override
  String get frameUnlocked => 'Unlocked';

  @override
  String get frameLocked => 'Locked';

  @override
  String get frameUpdateFailed => 'Couldn\'t equip that frame. Try again.';

  @override
  String profileLevelLabel(int level) {
    return 'LEVEL $level';
  }

  @override
  String get profileStatComments => 'Comments';

  @override
  String get profileStatReactions => 'Reactions';

  @override
  String get profileFramesTitle => 'Frames';

  @override
  String profileXpProgress(int into, int span, int next) {
    return '$into / $span XP to level $next';
  }

  @override
  String get topicDetailTitle => 'Topic';

  @override
  String topicCommentsHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'No comments yet',
    );
    return '$_temp0';
  }

  @override
  String get topicAboutFilm => 'About this movie';

  @override
  String get topicBeFirst => 'Be the first to answer.';

  @override
  String get authClose => 'Close';

  @override
  String get authReasonSearch => 'Log in to search and add films';

  @override
  String get authReasonProfile => 'Log in to open your profile';

  @override
  String get authReasonExplore => 'Log in to explore reviews and takes';

  @override
  String get authReasonNotifications => 'Log in to see your notifications';

  @override
  String get authReasonFilm => 'Log in to open film details';

  @override
  String get authReasonHome => 'Log in to see your films, friends and takes';

  @override
  String get authGuestPromptTitle => 'Sign in to see your films and friends';

  @override
  String get authGuestPromptBody =>
      'Upcoming films and news are open to everyone. Sign in to build your lists and join the conversation.';

  @override
  String get browseSectionDiscover => 'Discover';

  @override
  String get browseTopTakes => 'Top 100 takes';

  @override
  String get browsePopularFilms => 'Most popular films';

  @override
  String get browseByYear => 'Browse by year';

  @override
  String get browseByStreaming => 'Browse by streaming service';

  @override
  String get browseSectionTopics => 'Most popular topics';

  @override
  String get browsePolls => 'Polls';

  @override
  String get browseConversations => 'Conversations';

  @override
  String get browseScenes => 'Scenes';

  @override
  String get browseQuestions => 'Questions';

  @override
  String get browseHotTakes => 'Hot takes';

  @override
  String get browseSectionFilmSage => 'FilmSage';

  @override
  String get browseNewHere => 'New here?';

  @override
  String get browseSocialMedia => 'Social media';

  @override
  String get browseFollowUs => 'Follow us';

  @override
  String get browseGifts => 'Gifts';

  @override
  String get browseContact => 'Contact';

  @override
  String get browseTerms => 'Terms of use / Community policy';

  @override
  String get browseYearsTitle => 'Pick a year';

  @override
  String browseDecade(String decade) {
    return '${decade}s';
  }

  @override
  String get browseServicesTitle => 'Pick a streaming service';

  @override
  String get browseServicesEmpty => 'No streaming services available.';

  @override
  String get browseFilmsEmpty => 'No films here yet.';

  @override
  String get browseTakesEmpty => 'Nothing posted here yet.';

  @override
  String get browseComingSoonTitle => 'Coming soon';

  @override
  String get browseComingSoonBody =>
      'We\'re still working on this page. Check back soon.';

  @override
  String get browseByGenre => 'Browse by genre';

  @override
  String get browseByCountry => 'Browse by country';

  @override
  String get browseByLanguage => 'Browse by language';

  @override
  String get browseGenresTitle => 'Pick a genre';

  @override
  String get browseCountriesTitle => 'Pick a country';

  @override
  String get browseCountriesHint => 'Popular films streaming in each country.';

  @override
  String browseStreamingIn(String country) {
    return 'Streaming in $country';
  }

  @override
  String get browseLanguagesTitle => 'Pick a language';

  @override
  String get browsePickEmpty => 'Nothing to pick from right now.';

  @override
  String get browseLanguageEn => 'English';

  @override
  String get browseLanguageFr => 'French';

  @override
  String get browseLanguageEs => 'Spanish';

  @override
  String get browseLanguageIt => 'Italian';

  @override
  String get browseLanguageDe => 'German';

  @override
  String get browseLanguagePt => 'Portuguese';

  @override
  String get browseLanguageRu => 'Russian';

  @override
  String get browseLanguageAr => 'Arabic';

  @override
  String get browseLanguageTr => 'Turkish';

  @override
  String get browseLanguageHi => 'Hindi';

  @override
  String get browseLanguageKo => 'Korean';

  @override
  String get browseLanguageJa => 'Japanese';

  @override
  String get browseLanguageZh => 'Chinese';

  @override
  String get browseLanguageSv => 'Swedish';

  @override
  String get overviewPlayTrailer => 'Play trailer';

  @override
  String get overviewTrailerUnavailable => 'Couldn\'t open the trailer.';

  @override
  String get overviewLoading => 'Loading…';

  @override
  String get overviewNoCastCrew => 'No cast and crew information yet.';

  @override
  String get overviewOfferStream => 'Stream';

  @override
  String get overviewOfferFree => 'Free';

  @override
  String get overviewOfferTvProvider => 'With a TV provider';

  @override
  String get overviewOfferRent => 'Rent';

  @override
  String get overviewOfferBuy => 'Buy';

  @override
  String get overviewCloseTrailer => 'Close trailer';

  @override
  String get filmSuggest => 'Suggest';

  @override
  String get filmListFailed => 'Couldn\'t update your list. Try again.';

  @override
  String get filmFeelingsEmpty => 'Tap to say how it made you feel';

  @override
  String get filmFeelingsHint => 'Pick up to 3 feelings.';

  @override
  String filmFeelingsCount(String count) {
    return '$count of 3 picked';
  }

  @override
  String get filmFeelingsSave => 'Save';

  @override
  String get filmFeelingsClear => 'Clear';

  @override
  String get filmAudienceTitle => 'The audience';

  @override
  String get filmAudienceEmpty =>
      'No reactions yet. Be the first to say how it made you feel.';

  @override
  String get filmAudiencePositive => 'enjoyed it';

  @override
  String filmAudiencePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people reacted',
      one: '1 person reacted',
    );
    return '$_temp0';
  }

  @override
  String get filmYourTakeTitle => 'Your take';

  @override
  String filmTakeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count takes',
      one: '1 take',
    );
    return '$_temp0';
  }

  @override
  String get filmTopTake => 'TOP TAKE';

  @override
  String filmShowMoreTakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count more takes',
      one: 'Show 1 more take',
    );
    return '$_temp0';
  }

  @override
  String get filmShowLessTakes => 'Show less';

  @override
  String get filmShareYourTake => 'Share your take';

  @override
  String get filmAddTake => 'Add take';

  @override
  String get personBiography => 'Biography';

  @override
  String get personFilmography => 'Movies';

  @override
  String get personHeight => 'Height';

  @override
  String get personBorn => 'Born';

  @override
  String get personDied => 'Died';

  @override
  String get personNoFilms => 'No movies found for this person yet.';

  @override
  String get personLoadFailed => 'Couldn\'t load this person\'s page.';

  @override
  String personAsCharacter(String character) {
    return 'as $character';
  }
}
