import '../../../../l10n/app_localizations.dart';

/// Display copy for the keys the backend returns in `progress`. The server
/// stays language-neutral; titles, descriptions and artwork live here.
class ProgressInfo {
  const ProgressInfo({
    required this.title,
    required this.description,
    this.asset,
  });

  final String title;
  final String description;

  /// Lottie artwork name under `assets/lottie/badge_<name>.json`.
  final String? asset;
}

ProgressInfo badgeInfo(AppLocalizations l10n, String key, int target) {
  return switch (key) {
    'well_argued' => ProgressInfo(
        title: l10n.badgeWellArguedTitle,
        description: l10n.badgeWellArguedDesc(target),
        asset: 'well',
      ),
    'changed_my_mind' => ProgressInfo(
        title: l10n.badgeChangedMindTitle,
        description: l10n.badgeChangedMindDesc(target),
        asset: 'changed',
      ),
    'disagree_but_fair' => ProgressInfo(
        title: l10n.badgeDisagreeTitle,
        description: l10n.badgeDisagreeDesc(target),
        asset: 'disagree',
      ),
    'top_critic' => ProgressInfo(
        title: l10n.badgeTopCriticTitle,
        description: l10n.badgeTopCriticDesc,
        asset: 'top',
      ),
    _ => ProgressInfo(
        title: l10n.badgeFirstTakeTitle,
        description: l10n.badgeFirstTakeDesc,
        asset: 'first',
      ),
  };
}

ProgressInfo achievementInfo(AppLocalizations l10n, String key, int target) {
  return switch (key) {
    'film_critic' => ProgressInfo(
        title: l10n.achFilmCriticTitle,
        description: l10n.achFilmCriticDesc(target),
        asset: 'film',
      ),
    'debater' => ProgressInfo(
        title: l10n.achDebaterTitle,
        description: l10n.achDebaterDesc(target),
        asset: 'debater',
      ),
    _ => ProgressInfo(
        title: l10n.achLocalCinemaTitle,
        description: l10n.achLocalCinemaDesc(target),
        asset: 'local',
      ),
  };
}

/// Frame name plus the sentence explaining how to unlock it. Frames are earned
/// through achievements and badges, never through level; the description reuses
/// the matching achievement's copy so no new strings are needed.
ProgressInfo frameInfo(AppLocalizations l10n, String key, int target) {
  return switch (key) {
    'explorer' => ProgressInfo(
        title: l10n.frameExplorerTitle,
        description: achievementInfo(l10n, 'film_critic', target).description,
      ),
    'debater' => ProgressInfo(
        title: l10n.frameDebaterTitle,
        description: l10n.frameDebaterRequirement(target),
      ),
    'gold' => ProgressInfo(
        title: l10n.frameTopCriticTitle,
        description: badgeInfo(l10n, 'top_critic', target).description,
      ),
    'legend' => ProgressInfo(
        title: l10n.frameLegendTitle,
        description: achievementInfo(l10n, 'local_cinema', target).description,
      ),
    _ => ProgressInfo(
        title: l10n.frameNewcomerTitle,
        description: l10n.frameAlwaysUnlocked,
      ),
  };
}
