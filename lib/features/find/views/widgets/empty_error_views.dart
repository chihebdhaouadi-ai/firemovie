import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';

/// A centered message with an optional icon and optional action.
class FindMessageView extends StatelessWidget {
  const FindMessageView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final action = onAction;
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.spaceXl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textMuted, size: 44),
              SizedBox(height: tokens.spaceMd),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              if (body != null) ...[
                SizedBox(height: tokens.spaceXs),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
              if (action != null) ...[
                SizedBox(height: tokens.spaceLg),
                SizedBox(
                  height: tokens.minTouchTarget,
                  child: FilledButton.icon(
                    onPressed: action,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(actionLabel ?? ''),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Keep typing" prompt for queries shorter than 2 chars.
class MinCharsPrompt extends StatelessWidget {
  const MinCharsPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FindMessageView(
      icon: Icons.search_off,
      title: l10n.findMinCharsTitle,
      body: l10n.findMinCharsBody,
    );
  }
}

/// Empty results with tips.
class EmptyResults extends StatelessWidget {
  const EmptyResults({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FindMessageView(
      icon: Icons.movie_filter_outlined,
      title: l10n.findEmptyTitle(query),
      body: '${l10n.findEmptyTip1}\n${l10n.findEmptyTip2}',
    );
  }
}

/// Search error with retry.
class SearchError extends StatelessWidget {
  const SearchError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FindMessageView(
      icon: Icons.cloud_off,
      title: l10n.findErrorTitle,
      actionLabel: l10n.findErrorRetry,
      onAction: onRetry,
    );
  }
}

/// Offline message.
class OfflineMessage extends StatelessWidget {
  const OfflineMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FindMessageView(
      icon: Icons.wifi_off,
      title: l10n.findOfflineTitle,
      body: l10n.findOfflineBody,
    );
  }
}
