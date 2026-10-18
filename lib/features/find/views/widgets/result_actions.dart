import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/movie.dart';

/// Builds a bottom sheet with the actions for a result row.
///
/// Used when the screen has no fixed target (global app-bar search) and from
/// the long-press menu on any result.
class ResultActions {
  const ResultActions._();

  /// Options that map to an actual add target.
  static List<({AddTarget target, bool disabled})> targetOptions(
      BuildContext context) {
    return [
      (target: AddTarget.top5, disabled: false),
      (target: AddTarget.watched, disabled: false),
      (target: AddTarget.watchlist, disabled: false),
    ];
  }

  static String labelFor(BuildContext context, AddTarget target) =>
      switch (target) {
        AddTarget.top5 => context.l10n.findAddToTop5,
        AddTarget.watched => context.l10n.findAddToWatched,
        AddTarget.watchlist => context.l10n.findAddToWatchlist,
        AddTarget.generatePick => context.l10n.findAddToPick,
      };

  /// The icon used per target row.
  static IconData iconFor(AddTarget target) => switch (target) {
        AddTarget.top5 => Icons.star_rounded,
        AddTarget.watched => Icons.check_circle_outline,
        AddTarget.watchlist => Icons.playlist_add,
        AddTarget.generatePick => Icons.add_circle_outline,
      };

  /// Shows a modal bottom sheet to choose a destination for [movie].
  ///
  /// Returns the chosen [AddTarget], or null if dismissed.
  static Future<AddTarget?> showChooseTarget(
    BuildContext context, {
    required Movie movie,
    bool canPick = false,
  }) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    return showModalBottomSheet<AddTarget>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              tokens.spaceLg,
              tokens.spaceSm,
              tokens.spaceLg,
              tokens.spaceLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                SizedBox(height: tokens.spaceMd),
                for (final option in targetOptions(sheetContext))
                  ListTile(
                    minTileHeight: tokens.minTouchTarget,
                    contentPadding: EdgeInsetsDirectional.zero,
                    leading: Icon(
                      iconFor(option.target),
                      color: AppColors.accentGlow,
                    ),
                    title: Text(labelFor(sheetContext, option.target)),
                    onTap: () => Navigator.of(sheetContext).pop(option.target),
                  ),
                if (canPick) ...[
                  ListTile(
                    minTileHeight: tokens.minTouchTarget,
                    contentPadding: EdgeInsetsDirectional.zero,
                    leading: Icon(
                      iconFor(AddTarget.generatePick),
                      color: AppColors.accentGlow,
                    ),
                    title: Text(l10n.findAddToPick),
                    onTap: () =>
                        Navigator.of(sheetContext).pop(AddTarget.generatePick),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
