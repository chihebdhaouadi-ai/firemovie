import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../data/browse_repository.dart';
import 'browse_films_screen.dart';

/// Step 1 of Browse by year: pick a year, grouped by decade, newest first.
/// Step 2 is [BrowseFilmsScreen] for that year.
class BrowseYearsScreen extends StatelessWidget {
  const BrowseYearsScreen({super.key, this.repository, this.now});

  final BrowseRepository? repository;

  /// Overridable clock for tests.
  final DateTime? now;

  static const firstYear = 1920;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    // Next year too: release dates for many of its films are already known.
    final lastYear = (now ?? DateTime.now()).year + 1;
    final decades = [
      for (var d = lastYear - lastYear % 10; d >= firstYear; d -= 10) d,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.browseYearsTitle),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: ListView.builder(
              padding: EdgeInsets.all(tokens.spaceLg),
              itemCount: decades.length,
              itemBuilder: (context, index) {
                final decade = decades[index];
                final years = [
                  for (var y = decade + 9; y >= decade; y--)
                    if (y <= lastYear && y >= firstYear) y,
                ];
                return Padding(
                  padding: EdgeInsets.only(bottom: tokens.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.browseDecade('$decade'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: tokens.spaceSm),
                      Wrap(
                        spacing: tokens.spaceSm,
                        runSpacing: tokens.spaceSm,
                        children: [
                          for (final year in years)
                            ActionChip(
                              label: Text('$year'),
                              backgroundColor: AppColors.surface,
                              side: const BorderSide(color: AppColors.outline),
                              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () => Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => BrowseFilmsScreen(
                                    title: '$year',
                                    year: year,
                                    repository: repository,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
