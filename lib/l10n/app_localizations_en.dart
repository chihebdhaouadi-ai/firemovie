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
  String get homeFriendsFilmsTitle => 'Popular with Friends';

  @override
  String get homeFriendsReviewsTitle => 'Friends\' latest takes';

  @override
  String get homeMyTakesTitle => 'My takes';

  @override
  String get homeComingSoon => 'Coming soon';

  @override
  String get homeInboxTitle => 'Inbox';

  @override
  String get homeInboxSoonTitle => 'Under construction';

  @override
  String get homeInboxSoonBody =>
      'Messages with your friends will land here soon.';

  @override
  String get homeFriendsReviewsEmpty =>
      'Your friends haven\'t posted any takes yet.';

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
  String get exploreReviewButton => 'Take';

  @override
  String get exploreSubtitle =>
      'Discover takes, conversations and questions about films.';

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
  String get exploreFilterReviews => 'Takes';

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
  String get homeFeedTitle => 'Takes From Your Collections';

  @override
  String get homeFeedEmpty => 'No takes on the films in your collections yet.';

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
  String get overviewReviewsTitle => 'Takes';

  @override
  String get overviewAddReviewHint => 'Add a take...';

  @override
  String get overviewYourReview => 'Your Take';

  @override
  String get overviewFriendsReviews => 'Friends\' Takes';

  @override
  String get overviewPopularReviews => 'Popular Takes';

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
  String get reviewDetailTitle => 'Take';

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
    return 'Take by $name on $date';
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
  String get profileStatReviews => 'Takes';

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
  String get profileThemeButton => 'Appearance';

  @override
  String get profileThemeDialogTitle => 'Appearance';

  @override
  String get profileThemeSystem => 'Match system';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

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
      'Want to open a debate about this take? Pick someone from this conversation to talk with.';

  @override
  String get angelBirdPickPerson => 'Who do you want to debate with?';

  @override
  String get angelBirdNoPeople =>
      'Nobody to debate with yet. Wait for a comment on this take.';

  @override
  String get angelBirdPeopleFailed => 'Could not load the people in this take.';

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
  String get topicTagReview => 'Take';

  @override
  String get topicTagQuestion => 'Question';

  @override
  String get topicTagDiscussion => 'Discussion';

  @override
  String get topicTagHotTake => 'Hot Take';

  @override
  String get topicReviewHint =>
      'Takes are about one movie and need how it made you feel.';

  @override
  String get topicBodyHint => 'Write your take, question or discussion';

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
  String get createWriteReviewTitle => 'Write your take';

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
      'Your take appears on that movie\'s page.';

  @override
  String get createFeelTitle => 'How did it make you feel?';

  @override
  String get createFeelHint => 'Pick one reaction. It shows with your take.';

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
  String get leaderboardTitle => 'Top critics';

  @override
  String get leaderboardSubtitle => 'Ranked by reactions on their takes';

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
      other: '$count takes',
      one: '1 take',
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
  String get howStep1Title => 'Write a take';

  @override
  String get howStep1Body =>
      'Share a take on any film. It shows up in Explore and Friends.';

  @override
  String get howStep2Title => 'Collect reactions';

  @override
  String get howStep2Body =>
      'Readers react to your take. Every reaction is worth one point.';

  @override
  String get howStep3Title => 'Climb the board';

  @override
  String get howStep3Body =>
      'The critics with the most reactions in the period take the podium.';

  @override
  String get howNoteReset =>
      'This week resets every Monday at 00:00. This month and All time keep counting.';

  @override
  String get howNoteOncePerReview =>
      'Each person can react once per take. Reacting to your own take doesn\'t count.';

  @override
  String get howNoteTie =>
      'If two critics tie, the one who reached the total first ranks higher.';

  @override
  String get howNotePodium =>
      'The top three wear a podium frame (gold, blue, bronze) on the board for the period shown.';

  @override
  String get howLevelsTitle => 'Levels and XP';

  @override
  String get howXpReview => 'Write a take';

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
  String get badgeFirstTakeDesc =>
      'Be the first person to share a take on a film.';

  @override
  String get achFilmCriticTitle => 'Film critic';

  @override
  String achFilmCriticDesc(int count) {
    return 'Write $count takes.';
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
    return 'Share takes on $count Tunisian films.';
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
  String get authReasonExplore => 'Log in to explore takes and topics';

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
  String overviewFriendStoryNew(String name, String feeling) {
    return '$name, new: $feeling';
  }

  @override
  String overviewFriendStorySeen(String name, String feeling) {
    return '$name: $feeling';
  }

  @override
  String filmPersonFeelings(String feelings) {
    return 'Felt: $feelings';
  }

  @override
  String filmTakeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'No comments',
    );
    return '$_temp0';
  }

  @override
  String get filmFeelingsDone => 'Done';

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

  @override
  String get takeSkinTitle => 'Card skin';

  @override
  String get takeSkinNormal => 'Normal';

  @override
  String get takeSkinElectricThunder => 'Electric thunder';

  @override
  String get takeSkinPreview => 'Preview';

  @override
  String get takeSkinPreviewEmpty => 'Your take will appear here.';

  @override
  String get takeSkinWriteTitle => 'Write your take';

  @override
  String get reviewAlreadyShared => 'You already shared a take for this film.';

  @override
  String get reviewNeedsFeeling =>
      'Pick how the film made you feel first, then share your take.';

  @override
  String get reviewYourTake => 'Your take — others react to it';

  @override
  String get reviewBeFirstComment => 'Be the first to comment on this take.';

  @override
  String get takeMenuTooltip => 'More options';

  @override
  String get takeActionShare => 'Send to friends';

  @override
  String get takeActionEdit => 'Edit';

  @override
  String get takeActionDelete => 'Delete';

  @override
  String get takeActionReport => 'Report';

  @override
  String get takeEdited => 'edited';

  @override
  String get takeCancel => 'Cancel';

  @override
  String get takeEditTitle => 'Edit your take';

  @override
  String get takeEditSave => 'Save';

  @override
  String get takeEditSaved => 'Your take was updated.';

  @override
  String get takeEditFailed => 'Couldn\'t save your changes. Try again.';

  @override
  String get takeDeleteTitle => 'Delete this take?';

  @override
  String get takeDeleteBody =>
      'It will be removed for everyone, along with its comments.';

  @override
  String get takeDeleted => 'Take deleted.';

  @override
  String get takeDeleteFailed => 'Couldn\'t delete it. Try again.';

  @override
  String get takeReportTitle => 'Report this take';

  @override
  String get takeReportHint =>
      'Why are you reporting it? Only moderators see reports.';

  @override
  String get takeReportSpam => 'Spam';

  @override
  String get takeReportHarassment => 'Harassment or bullying';

  @override
  String get takeReportHate => 'Hate speech';

  @override
  String get takeReportSpoiler => 'Unmarked spoiler';

  @override
  String get takeReportOther => 'Something else';

  @override
  String get takeReportDetailsHint => 'Add details (optional)';

  @override
  String get takeReportSend => 'Send report';

  @override
  String get takeReportThanks => 'Thanks. Our team will review it.';

  @override
  String get takeReportFailed => 'Couldn\'t send the report. Try again.';

  @override
  String get takeShareTitle => 'Send to friends';

  @override
  String get takeShareMessageHint => 'Add a message (optional)';

  @override
  String get takeShareNoFriends => 'Add friends to send them takes.';

  @override
  String get takeShareFriendsFailed => 'Couldn\'t load your friends.';

  @override
  String get takeShareFailed => 'Couldn\'t send it. Try again.';

  @override
  String get notificationTakeGone => 'This take is no longer available.';

  @override
  String get mentionSuggestionsLabel => 'Mention a friend';

  @override
  String takeShareSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send to $count friends',
      one: 'Send to 1 friend',
      zero: 'Send',
    );
    return '$_temp0';
  }

  @override
  String takeShareSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sent to $count friends',
      one: 'Sent to 1 friend',
    );
    return '$_temp0';
  }

  @override
  String notificationTakeShared(String name) {
    return '$name sent you a take';
  }

  @override
  String notificationTakeMention(String name) {
    return '$name mentioned you in a comment';
  }

  @override
  String get takeSpoilerTitle => 'Does it have spoilers?';

  @override
  String get takeSpoilerNo => 'No spoilers';

  @override
  String get takeSpoilerHint => 'Pick one so readers know what to expect.';

  @override
  String get takeSpoilerRequired =>
      'Say whether your take has spoilers before sharing.';

  @override
  String get takeSpoilerBlurNote =>
      'Others will see it blurred until they tap to reveal.';

  @override
  String get reviewVoteUp => 'Up';

  @override
  String get reviewVoteDraw => 'Draw';

  @override
  String get reviewVoteDown => 'Down';

  @override
  String storyTake(String film) {
    return 'Shared a take on $film';
  }

  @override
  String storyQuestion(String film) {
    return 'Asked about $film';
  }

  @override
  String storyDiscussion(String film) {
    return 'Started a discussion on $film';
  }

  @override
  String storyHotTake(String film) {
    return 'Dropped a hot take on $film';
  }

  @override
  String storyPoll(String film) {
    return 'Made a poll about $film';
  }

  @override
  String storyScene(String film) {
    return 'Shared a scene from $film';
  }

  @override
  String storyComment(String film) {
    return 'Commented on a post about $film';
  }

  @override
  String get storyUnknownFilm => 'a film';

  @override
  String get storyOpen => 'Open';

  @override
  String get storyClose => 'Close';

  @override
  String storyRingLabel(String name) {
    return '$name\'s story';
  }

  @override
  String get storiesTitle => 'Friends\' stories';

  @override
  String get inboxSearch => 'Search';

  @override
  String get inboxSearchHint => 'Search conversations';

  @override
  String get inboxCloseSearch => 'Close search';

  @override
  String get inboxUnreadOnly => 'Show only unread';

  @override
  String get inboxAddFriend => 'Add friend';

  @override
  String get inboxCreate => 'New chat';

  @override
  String get inboxNewMessage => 'New message';

  @override
  String get inboxCreateGroup => 'Create a group';

  @override
  String get inboxCreateTopic => 'Create a private topic';

  @override
  String get inboxPrivateTopics => 'Private topics';

  @override
  String get inboxNoTopics => 'No topics yet. Start one with friends.';

  @override
  String get inboxNewTopic => 'New private topic';

  @override
  String get inboxAllChats => 'All chats';

  @override
  String get inboxEmptyTitle => 'No conversations yet';

  @override
  String get inboxEmptyBody => 'Message a friend to start chatting.';

  @override
  String get inboxNoResults => 'No conversations found';

  @override
  String get inboxLoadFailed => 'Couldn\'t load your messages.';

  @override
  String inboxYouSaid(String text) {
    return 'You: $text';
  }

  @override
  String get inboxNoMessagesYet => 'No messages yet';

  @override
  String get inboxGroupName => 'Group name';

  @override
  String get inboxTopicName => 'Topic name';

  @override
  String get inboxPickFriends => 'Choose friends';

  @override
  String get inboxPickFriend => 'Message a friend';

  @override
  String get inboxNoFriends => 'Add friends first to chat with them.';

  @override
  String get inboxCreateAction => 'Create';

  @override
  String get inboxCancel => 'Cancel';

  @override
  String get inboxCreateFailed => 'Couldn\'t create it. Try again.';

  @override
  String inboxMembers(int count) {
    return '$count members';
  }

  @override
  String get inboxGroupPhoto => 'Add a group photo';

  @override
  String get inboxGroupDescription => 'Description (optional)';

  @override
  String get inboxPhotoFailed => 'Created, but the photo didn\'t upload.';

  @override
  String get chatOpenInfo => 'Group info';

  @override
  String get groupInfoTitle => 'Group info';

  @override
  String get groupInfoTopicTitle => 'Topic info';

  @override
  String get groupInfoDescription => 'Description';

  @override
  String get groupInfoNoDescription => 'No description yet.';

  @override
  String groupInfoMembers(int count) {
    return 'Members · $count';
  }

  @override
  String get groupInfoYou => 'You';

  @override
  String get groupInfoCreator => 'Creator';

  @override
  String inboxUnreadLabel(int count) {
    return '$count unread';
  }

  @override
  String get chatHint => 'Send a message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatStart => 'Start the conversation';

  @override
  String get chatSendFailed => 'Message not sent. Try again.';

  @override
  String get chatPrivateTopic => 'Private topic · only members can see it';

  @override
  String get inboxSelectChat => 'Pick a conversation to start chatting';

  @override
  String get chatMenu => 'Group menu';

  @override
  String get chatShareGroup => 'Share group';

  @override
  String get chatBoostGroup => 'Boost group';

  @override
  String get chatReport => 'Report';

  @override
  String get chatLeaveGroup => 'Leave group';

  @override
  String get chatShareBody => 'Send the group to a conversation.';

  @override
  String chatSharedTo(String name) {
    return 'Shared to $name';
  }

  @override
  String chatBoosted(String name) {
    return 'Boost started for $name';
  }

  @override
  String get chatReportTitle => 'Report this group';

  @override
  String get chatReportBody =>
      'Tell us what is wrong. Members are not notified.';

  @override
  String get chatReportSpam => 'Spam or scam';

  @override
  String get chatReportHarassment => 'Harassment';

  @override
  String get chatReportOther => 'Something else';

  @override
  String get chatReportSent => 'Report sent';

  @override
  String get chatCancel => 'Cancel';

  @override
  String get chatClose => 'Close';

  @override
  String get chatBack => 'Back';

  @override
  String get chatActionFailed => 'That didn\'t work. Try again.';

  @override
  String get chatPinned => 'Pinned';

  @override
  String chatPinnedCount(int count) {
    return 'Pinned ($count)';
  }

  @override
  String get chatReply => 'Reply';

  @override
  String chatReplyingTo(String name) {
    return 'Replying to $name';
  }

  @override
  String get chatCancelReply => 'Cancel reply';

  @override
  String get chatPin => 'Pin message';

  @override
  String get chatUnpin => 'Unpin message';

  @override
  String get chatMessagePinned => 'Message pinned';

  @override
  String get chatMessageUnpinned => 'Message unpinned';

  @override
  String chatMention(String name) {
    return 'Mention $name';
  }

  @override
  String get chatViewProfile => 'View profile';

  @override
  String get chatMoreReactions => 'More reactions';

  @override
  String chatNotified(String names) {
    return 'Notified $names';
  }

  @override
  String get chatNoMatch => 'No one matches';

  @override
  String get chatAdd => 'Add photo, video, movie or poll';

  @override
  String get chatEmojiButton => 'Emoji, GIFs and stickers';

  @override
  String get chatAddTitle => 'Add to chat';

  @override
  String get chatPhoto => 'Photo';

  @override
  String get chatPhotoBody => 'Choose a photo from your device.';

  @override
  String get chatVideo => 'Video';

  @override
  String get chatVideoBody => 'Choose a video from your device.';

  @override
  String get chatMovie => 'Movie';

  @override
  String get chatMovieBody => 'Search a film and share it as a card.';

  @override
  String get chatPoll => 'Poll';

  @override
  String get chatPollBody => 'Ask the group a question.';

  @override
  String get chatSendPhoto => 'Send photo';

  @override
  String get chatSendVideo => 'Send video';

  @override
  String get chatShareMovie => 'Share movie';

  @override
  String get chatNewPoll => 'New poll';

  @override
  String get chatCaption => 'Add a caption';

  @override
  String get chatPollQuestion => 'Ask a question';

  @override
  String chatPollOption(int number) {
    return 'Option $number';
  }

  @override
  String get chatAddOption => 'Add option';

  @override
  String get chatAllowedReactions => 'Reactions allowed on this post';

  @override
  String get chatAllowedReactionsBody =>
      'Members can react with the emojis you choose. They hold a message to see them.';

  @override
  String get chatPollInvalid => 'Add a question and at least two options';

  @override
  String get chatFileTooBig => 'That file is too big (12 MB max)';

  @override
  String get chatSearchMovie => 'Search a movie';

  @override
  String get chatSearchMovieHint => 'Film title';

  @override
  String get chatNoMovie => 'No movie found.';

  @override
  String chatVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String get chatPlayVideo => 'Play video';

  @override
  String get chatGif => 'GIF';

  @override
  String get chatSticker => 'Sticker';

  @override
  String get chatTabEmoji => 'Emoji';

  @override
  String get chatTabGif => 'GIF';

  @override
  String get chatTabStickers => 'Stickers';

  @override
  String get chatSearchEmoji => 'Find the perfect emoji';

  @override
  String get chatSearchGif => 'Search GIFs';

  @override
  String get chatSearchStickers => 'Search stickers';

  @override
  String chatNothingFound(String query) {
    return 'Nothing found for “$query”.';
  }

  @override
  String get chatCatFrequent => 'Frequently used';

  @override
  String get chatCatFaces => 'Faces';

  @override
  String get chatCatHands => 'Hands';

  @override
  String get chatCatObjects => 'Objects';

  @override
  String get chatCatSymbols => 'Symbols';

  @override
  String get chatClosePicker => 'Close picker';

  @override
  String sysPinned(String name) {
    return '$name pinned a message';
  }

  @override
  String sysRemoved(String name, String target) {
    return '$name removed $target from the group';
  }

  @override
  String sysLeft(String name) {
    return '$name left the group';
  }

  @override
  String sysHeritage(String name, String target) {
    return '$name made $target Heritage creator';
  }

  @override
  String sysPassed(String name, String target) {
    return '$name passed the creator tag to $target and left';
  }

  @override
  String sysVoteStarted(String name) {
    return '$name started a vote on keeping this group';
  }

  @override
  String sysVoteCancelled(String name) {
    return '$name cancelled the vote';
  }

  @override
  String get sysVoteKeep =>
      'Most members voted to keep the group. Now choose a new owner.';

  @override
  String sysVoteOwnerWon(String target) {
    return '$target won the vote and is now Heritage creator';
  }

  @override
  String get voteKeepTitle => 'Keep this group?';

  @override
  String voteKeepBody(String name, String time) {
    return '$name asked to leave. Members have $time left to vote. Most votes decide; a tie keeps the group.';
  }

  @override
  String get voteStay => 'Stay';

  @override
  String get voteDelete => 'Delete';

  @override
  String voteKeepTally(int stay, int delete) {
    return 'Stay $stay · Delete $delete';
  }

  @override
  String get voteOwnPoll => 'You can\'t vote on your own poll.';

  @override
  String get voteCancel => 'Cancel poll and stay creator';

  @override
  String get voteOwnerTitle => 'Who should own this group?';

  @override
  String voteOwnerBody(String time) {
    return 'The group is staying. Pick one member other than yourself. $time left.';
  }

  @override
  String get voteOwnerHint => 'Tap a member to vote.';

  @override
  String get voteOwnerChange => 'You can change your vote until the poll ends.';

  @override
  String voteTimeLeft(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get voteRunning => 'A vote is already running';

  @override
  String get leaveCreatorTitle => 'You created this group';

  @override
  String get leaveCreatorBody =>
      'Before you leave, choose what happens to the group.';

  @override
  String get leavePass => 'Pass the creator tag';

  @override
  String get leavePassBody => 'Pick a member. They take over right away.';

  @override
  String get leaveVote => 'Let the group decide';

  @override
  String get leaveVoteBody =>
      'Members vote on keeping or deleting the group, then on who owns it. Each vote takes 24 hours.';

  @override
  String get leavePickTitle => 'Who takes over?';

  @override
  String get leavePickBody =>
      'They get the Heritage creator tag and keep report, share and boost.';

  @override
  String get leaveContinue => 'Continue';

  @override
  String leavePassConfirmTitle(String name) {
    return 'Pass the tag to $name and leave?';
  }

  @override
  String leavePassConfirmBody(String name) {
    return '$name becomes Heritage creator right away. You will leave the group.';
  }

  @override
  String get leavePassConfirm => 'Pass tag and leave';

  @override
  String get leaveVoteConfirmTitle => 'Start the group vote?';

  @override
  String get leaveVoteConfirmBody =>
      'Step 1: members vote to keep or delete the group for 24 hours. If most vote Stay, step 2 lets them choose the new owner for another 24 hours. You stay creator until it ends.';

  @override
  String get leaveVoteConfirm => 'Start vote';

  @override
  String leaveSimpleTitle(String group) {
    return 'Leave $group?';
  }

  @override
  String get leaveSimpleBody =>
      'You will stop seeing messages from this group.';

  @override
  String confirmType(String name) {
    return 'To confirm, type $name';
  }

  @override
  String get groupInfoSearch => 'Search members';

  @override
  String groupInfoNoMatch(String query) {
    return 'No members match “$query”.';
  }

  @override
  String get groupInfoHeritage => 'Heritage creator';

  @override
  String memberViewProfileBody(String name) {
    return 'See $name\'s films and collections.';
  }

  @override
  String get memberMakeHeritage => 'Make Heritage creator';

  @override
  String memberMakeHeritageBody(String name) {
    return '$name takes over the group. You become a regular member.';
  }

  @override
  String get memberRemove => 'Remove from group';

  @override
  String memberRemoveBody(String name) {
    return '$name loses access to the group and its messages.';
  }

  @override
  String memberMakeHeritageTitle(String name) {
    return 'Make $name Heritage creator?';
  }

  @override
  String memberMakeHeritageConfirmBody(String name) {
    return '$name gets the Heritage creator tag and can report, share and boost the group. You stay in the group as a regular member.';
  }

  @override
  String memberRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String memberRemoveConfirmBody(String name, String group) {
    return '$name will lose access to $group and won\'t see new messages.';
  }

  @override
  String memberRemoveConfirm(String name) {
    return 'Remove $name';
  }

  @override
  String get chatVideoFailed => 'Couldn\'t play this video.';

  @override
  String get chatPauseVideo => 'Pause video';

  @override
  String get chatFullScreen => 'Full screen';

  @override
  String get chatMute => 'Mute';

  @override
  String get chatUnmute => 'Unmute';

  @override
  String get chatMutedToast => 'Chat muted';

  @override
  String get chatUnmutedToast => 'Chat unmuted';

  @override
  String get chatPinChat => 'Pin to top';

  @override
  String get chatUnpinChat => 'Unpin from top';

  @override
  String get chatMarkUnread => 'Mark as unread';

  @override
  String get chatMarkRead => 'Mark as read';

  @override
  String get chatClearHistory => 'Clear history';

  @override
  String get chatClearTitle => 'Clear the history?';

  @override
  String get chatClearBody =>
      'Every message so far disappears for you. The others still see them.';

  @override
  String get chatCleared => 'History cleared';

  @override
  String get chatDeleteChat => 'Delete chat';

  @override
  String get chatDeleteChatTitle => 'Delete this chat?';

  @override
  String chatDeleteChatBody(String name) {
    return 'It leaves your inbox and its history is cleared for you. It comes back if $name writes again.';
  }

  @override
  String get chatChatDeleted => 'Chat deleted';

  @override
  String chatBlock(String name) {
    return 'Block $name';
  }

  @override
  String chatUnblock(String name) {
    return 'Unblock $name';
  }

  @override
  String chatBlockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get chatBlockBody =>
      'Neither of you can message the other until you unblock them. They won\'t be told.';

  @override
  String chatBlockedToast(String name) {
    return '$name is blocked';
  }

  @override
  String chatUnblockedToast(String name) {
    return '$name is unblocked';
  }

  @override
  String chatYouBlocked(String name) {
    return 'You blocked $name.';
  }

  @override
  String get chatBlockedYou => 'You can\'t reply to this conversation.';

  @override
  String get chatBlockedPeople => 'Blocked people';

  @override
  String get chatNoBlocked => 'You haven\'t blocked anyone.';

  @override
  String get chatUnblockShort => 'Unblock';

  @override
  String get chatCopy => 'Copy text';

  @override
  String get chatCopied => 'Copied';

  @override
  String get chatEdit => 'Edit';

  @override
  String get chatEditing => 'Editing message';

  @override
  String get chatCancelEdit => 'Cancel editing';

  @override
  String get chatDeleteMessage => 'Delete';

  @override
  String get chatDeleteMessageTitle => 'Delete this message?';

  @override
  String get chatDeleteMessageBody => 'It\'s deleted for everyone in the chat.';

  @override
  String get chatMessageDeleted => 'This message was deleted';

  @override
  String get chatEdited => 'edited';

  @override
  String get chatReportMessage => 'Report message';

  @override
  String get chatReportHate => 'Hate speech';

  @override
  String get chatReportNsfw => 'Sexual content';

  @override
  String get chatSeen => 'Seen';

  @override
  String get chatAddMembers => 'Add members';

  @override
  String chatAddMembersTitle(String name) {
    return 'Add to $name';
  }

  @override
  String get chatAddMembersNone => 'All your friends are already here.';

  @override
  String get chatAddSelected => 'Add';

  @override
  String get chatMembersAdded => 'Members added';

  @override
  String get chatConfirm => 'Confirm';

  @override
  String get chatViewProfileMenu => 'View profile';

  @override
  String inboxChatOptions(String name) {
    return 'Options for $name';
  }

  @override
  String get inboxPinnedLabel => 'Pinned';

  @override
  String get inboxMutedLabel => 'Muted';

  @override
  String sysAdded(String name, String target) {
    return '$name added $target';
  }

  @override
  String get homeTopicFirstReply => 'Be the first to reply';

  @override
  String get homeFriendsActivityTitle => 'Friends Activity';

  @override
  String get homeFriendsActivityResize => 'Resize friends activity';

  @override
  String get topicTitleHint => 'Title (optional)';

  @override
  String get topicSeeMore => 'See more';

  @override
  String get topicCommentsExpand => 'Expand comments';

  @override
  String get topicCommentsShrink => 'Shrink comments';

  @override
  String get chatTakeShared => 'Shared a take';

  @override
  String get chatTopicShared => 'Shared a topic';

  @override
  String get chatTaggedYou => 'Tagged you in a comment';

  @override
  String get chatYouTagged => 'You tagged them in a comment';

  @override
  String get chatTaggedThem => 'Tagged them in a comment';

  @override
  String get chatYouSharedTopic => 'You shared a topic';

  @override
  String get chatYouSharedTake => 'You shared a take';

  @override
  String get commentAddPhoto => 'Add a photo';

  @override
  String get commentRemovePhoto => 'Remove photo';

  @override
  String get takeFeltLabel => 'Felt';

  @override
  String homeEditList(String list) {
    return 'Edit $list';
  }

  @override
  String get homeEditListAdd => 'Add a film';

  @override
  String homeEditListRemove(String title) {
    return 'Remove $title';
  }

  @override
  String get homeEditListEmpty => 'No films here yet.';

  @override
  String get homeEditListFull =>
      'Your Top 5 is full. Remove a film to add another.';

  @override
  String get homeWatchedHint => 'Films you\'ve already seen';

  @override
  String get homeWatchlistHint => 'Films you want to watch';

  @override
  String get homeLensHint => 'Drag your finger over the covers';

  @override
  String homeLensOpen(String title) {
    return 'Open $title';
  }

  @override
  String get homeListMore => 'More options';

  @override
  String get homeListShare => 'Share your list';

  @override
  String get homeListRandom => 'Pick at random';

  @override
  String get homeListShuffle => 'Pick another';

  @override
  String homeListShareText(String list) {
    return 'My $list on FilmSage:';
  }

  @override
  String get takeHeartLike => 'Like';

  @override
  String takeHeartCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
      zero: 'No likes',
    );
    return '$_temp0';
  }

  @override
  String get myListsTitle => 'My lists';

  @override
  String get myListsHint => 'Lists you made and posted';

  @override
  String get friendsListsTitle => 'Friends\' lists';

  @override
  String get friendsListsHint => 'What your friends put together';

  @override
  String get listNew => 'New list';

  @override
  String get listsEmptyMine =>
      'Make your first list: give it a name and pick some films.';

  @override
  String get listCreateTitle => 'New list';

  @override
  String get listNameLabel => 'List name';

  @override
  String get listNameHint => 'Best heist films';

  @override
  String get listSearchHint => 'Search films to add';

  @override
  String listAddFilm(String title) {
    return 'Add $title';
  }

  @override
  String listRemoveFilm(String title) {
    return 'Remove $title';
  }

  @override
  String get listPost => 'Post list';

  @override
  String listFilmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films',
      one: '1 film',
    );
    return '$_temp0';
  }

  @override
  String listBy(String name) {
    return 'By $name';
  }

  @override
  String get listCommentsTitle => 'Comments';

  @override
  String get listCommentHint => 'Add a comment';

  @override
  String get listCommentsEmpty =>
      'No comments yet. Say what you think of this list.';

  @override
  String listCommentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'No comments',
    );
    return '$_temp0';
  }

  @override
  String get listDelete => 'Delete list';

  @override
  String get listDeleteConfirm => 'Delete this list? This can\'t be undone.';

  @override
  String get listCancel => 'Cancel';

  @override
  String get listPostFailed => 'Couldn\'t post the list. Try again.';

  @override
  String get listLoadFailed => 'Couldn\'t load lists.';

  @override
  String listPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films picked',
      one: '1 film picked',
      zero: 'No films yet',
    );
    return '$_temp0';
  }

  @override
  String get listSearchEmpty => 'No films found.';

  @override
  String get listSendFailed => 'Couldn\'t send. Try again.';

  @override
  String get takeActionSave => 'Save';

  @override
  String get takeActionUnsave => 'Remove from saved';

  @override
  String get takeSavedToast => 'Saved to your profile';

  @override
  String get takeUnsavedToast => 'Removed from your saved topics';

  @override
  String get takeSaveFailed => 'Couldn\'t save. Try again.';

  @override
  String get profileSavedTitle => 'Saved';

  @override
  String get profileSavedEmpty => 'Topics you save show up here.';

  @override
  String get listShare => 'Share list';

  @override
  String listShareText(String name, String owner) {
    return '$name — a list by $owner on Film Wise';
  }

  @override
  String get listSave => 'Save list';

  @override
  String get listUnsave => 'Remove from saved';

  @override
  String get listSavedToast => 'List saved to your profile';

  @override
  String get listUnsavedToast => 'List removed from your saved lists';

  @override
  String get listSaveFailed => 'Couldn\'t save the list. Try again.';

  @override
  String get listEdit => 'Edit list';

  @override
  String get listEditTitle => 'Edit list';

  @override
  String get listSaveChanges => 'Save changes';

  @override
  String get savedListsTitle => 'Saved lists';

  @override
  String get savedListsHint => 'Lists you kept from others';

  @override
  String get listMenuTooltip => 'More';

  @override
  String get listShareNoFriends => 'Add friends to send them lists.';

  @override
  String get chatListShared => 'Shared a list';

  @override
  String get chatYouSharedList => 'You shared a list';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsTabAll => 'All';

  @override
  String get notificationsTabTakes => 'Takes';

  @override
  String get notificationsTabMentions => 'Mentions';

  @override
  String get notificationsTabRequests => 'Requests';

  @override
  String get notificationsGroupRequests => 'Friend requests';

  @override
  String get notificationsGroupNew => 'New';

  @override
  String get notificationsGroupEarlier => 'Earlier';

  @override
  String get notificationsNowFriends => 'You\'re now friends';

  @override
  String notificationsRequestDeclined(String name) {
    return 'Request from $name declined';
  }

  @override
  String get notificationsUndo => 'Undo';

  @override
  String get notificationsNothingHere => 'Nothing here yet.';

  @override
  String get notificationsTimeNow => 'now';

  @override
  String notificationsTimeMinutes(int count) {
    return '${count}m';
  }

  @override
  String notificationsTimeHours(int count) {
    return '${count}h';
  }

  @override
  String get notificationsTimeYesterday => 'Yesterday';

  @override
  String notificationsTimeDays(int count) {
    return '${count}d';
  }

  @override
  String notificationsUnreadCount(int count) {
    return '$count unread';
  }
}
