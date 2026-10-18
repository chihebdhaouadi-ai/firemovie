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
    return '$count Films';
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
}
