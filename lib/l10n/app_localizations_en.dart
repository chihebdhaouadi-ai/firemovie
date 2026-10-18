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
}
