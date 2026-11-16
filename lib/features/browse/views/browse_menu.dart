import 'package:flutter/material.dart';

import '../../../core/auth/auth_gate.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../film_reviews/domain/take_tag.dart';
import '../data/browse_repository.dart';
import '../domain/browse_option.dart';
import 'browse_films_screen.dart';
import 'browse_pick_screen.dart';
import 'browse_takes_screen.dart';
import 'browse_years_screen.dart';
import 'info_page_screen.dart';
import 'streaming_services_screen.dart';

/// The browse options shown under the search field before the user types:
/// top takes, popular films, films by year or streaming service, takes by
/// kind, and the FilmSage info pages.
class BrowseMenu extends StatelessWidget {
  const BrowseMenu({super.key, this.repository});

  final BrowseRepository? repository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    // The lists come from signed-in endpoints, so guests log in first.
    void openFilms(String reason, Widget Function() screen) => requireAuth(
          context,
          reason: reason,
          action: () async {
            if (!context.mounted) return;
            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => screen()),
            );
          },
        );

    void openTakes(String title, TakeTag? tag) => openFilms(
          l10n.authReasonExplore,
          () =>
              BrowseTakesScreen(title: title, tag: tag, repository: repository),
        );

    void openInfo(String title, IconData icon) =>
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => InfoPageScreen(title: title, icon: icon),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Group(
          title: l10n.browseSectionDiscover,
          entries: [
            _Entry(
              Icons.emoji_events_outlined,
              l10n.browseTopTakes,
              () => openTakes(l10n.browseTopTakes, null),
            ),
            _Entry(
              Icons.local_fire_department_outlined,
              l10n.browsePopularFilms,
              () => openFilms(
                l10n.authReasonSearch,
                () => BrowseFilmsScreen(
                  title: l10n.browsePopularFilms,
                  repository: repository,
                ),
              ),
            ),
            _Entry(
              Icons.calendar_month_outlined,
              l10n.browseByYear,
              () => openFilms(
                l10n.authReasonSearch,
                () => BrowseYearsScreen(repository: repository),
              ),
            ),
            _Entry(
              Icons.live_tv_outlined,
              l10n.browseByStreaming,
              () => openFilms(
                l10n.authReasonSearch,
                () => StreamingServicesScreen(repository: repository),
              ),
            ),
            _Entry(
              Icons.category_outlined,
              l10n.browseByGenre,
              () => openFilms(
                l10n.authReasonSearch,
                () => _genrePicker(l10n),
              ),
            ),
            _Entry(
              Icons.flag_outlined,
              l10n.browseByCountry,
              () => openFilms(
                l10n.authReasonSearch,
                () => _countryPicker(l10n),
              ),
            ),
            _Entry(
              Icons.translate,
              l10n.browseByLanguage,
              () => openFilms(
                l10n.authReasonSearch,
                () => _languagePicker(l10n),
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spaceLg),
        _Group(
          title: l10n.browseSectionTopics,
          entries: [
            _Entry(
              Icons.poll_outlined,
              l10n.browsePolls,
              () => openTakes(l10n.browsePolls, TakeTag.poll),
            ),
            _Entry(
              Icons.forum_outlined,
              l10n.browseConversations,
              () => openTakes(l10n.browseConversations, TakeTag.discussion),
            ),
            _Entry(
              Icons.theaters_outlined,
              l10n.browseScenes,
              () => openTakes(l10n.browseScenes, TakeTag.scene),
            ),
            _Entry(
              Icons.help_outline,
              l10n.browseQuestions,
              () => openTakes(l10n.browseQuestions, TakeTag.question),
            ),
            _Entry(
              Icons.bolt_outlined,
              l10n.browseHotTakes,
              () => openTakes(l10n.browseHotTakes, TakeTag.hotTake),
            ),
          ],
        ),
        SizedBox(height: tokens.spaceLg),
        _Group(
          title: l10n.browseSectionFilmSage,
          entries: [
            for (final (icon, label) in [
              (Icons.waving_hand_outlined, l10n.browseNewHere),
              (Icons.public, l10n.browseSocialMedia),
              (Icons.person_add_alt_outlined, l10n.browseFollowUs),
              (Icons.card_giftcard_outlined, l10n.browseGifts),
              (Icons.mail_outline, l10n.browseContact),
              (Icons.gavel_outlined, l10n.browseTerms),
            ])
              _Entry(icon, label, () => openInfo(label, icon)),
          ],
        ),
      ],
    );
  }
}

extension on BrowseMenu {
  BrowseRepository get _repo => repository ?? ApiBrowseRepository();

  Widget _genrePicker(AppLocalizations l10n) => BrowsePickScreen(
        title: l10n.browseGenresTitle,
        load: () async => [
          for (final genre in await _repo.fetchGenres())
            BrowsePickOption(
              label: genre.name,
              screen: () => BrowseFilmsScreen(
                title: genre.name,
                genreId: genre.id,
                repository: repository,
              ),
            ),
        ],
      );

  Widget _countryPicker(AppLocalizations l10n) => BrowsePickScreen(
        title: l10n.browseCountriesTitle,
        subtitle: l10n.browseCountriesHint,
        load: () async => [
          for (final country in await _repo.fetchCountries())
            BrowsePickOption(
              label: country.name,
              imageUrl: country.flagUrl,
              screen: () => BrowseFilmsScreen(
                title: l10n.browseStreamingIn(country.name),
                country: country.code,
                repository: repository,
              ),
            ),
        ],
      );

  Widget _languagePicker(AppLocalizations l10n) {
    final options = [
      for (final code in browseLanguageCodes)
        (code: code, name: _languageName(l10n, code)),
    ]..sort((a, b) => a.name.compareTo(b.name));
    return BrowsePickScreen(
      title: l10n.browseLanguagesTitle,
      load: () async => [
        for (final option in options)
          BrowsePickOption(
            label: option.name,
            screen: () => BrowseFilmsScreen(
              title: option.name,
              language: option.code,
              repository: repository,
            ),
          ),
      ],
    );
  }
}

String _languageName(AppLocalizations l10n, String code) => switch (code) {
      'en' => l10n.browseLanguageEn,
      'fr' => l10n.browseLanguageFr,
      'es' => l10n.browseLanguageEs,
      'it' => l10n.browseLanguageIt,
      'de' => l10n.browseLanguageDe,
      'pt' => l10n.browseLanguagePt,
      'ru' => l10n.browseLanguageRu,
      'ar' => l10n.browseLanguageAr,
      'tr' => l10n.browseLanguageTr,
      'hi' => l10n.browseLanguageHi,
      'ko' => l10n.browseLanguageKo,
      'ja' => l10n.browseLanguageJa,
      'zh' => l10n.browseLanguageZh,
      'sv' => l10n.browseLanguageSv,
      _ => code.toUpperCase(),
    };

class _Entry {
  const _Entry(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// A titled card of tappable rows.
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.entries});

  final String title;
  final List<_Entry> entries;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        Material(
          color: AppColors.surface,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          child: Column(
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: 64,
                    color: AppColors.surfaceRaised,
                  ),
                _Row(entry: entries[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      button: true,
      label: entry.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: entry.onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.minTouchTarget + 8),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spaceMd,
              vertical: tokens.spaceSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child:
                      Icon(entry.icon, size: 20, color: AppColors.accentGlow),
                ),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: Text(
                    entry.label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
