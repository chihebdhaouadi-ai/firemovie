import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../find/data/movie.dart';
import '../../../find/views/widgets/streaming_provider_logo.dart';
import 'overview_panel.dart';

class WhereToWatchCard extends StatelessWidget {
  const WhereToWatchCard({super.key, required this.providers});

  final WatchProviders? providers;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final available = providers?.available ?? const <StreamingProvider>[];

    return OverviewPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.overviewWhereToWatch,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, tokens.minTouchTarget),
                  side: BorderSide(
                    color: AppColors.outline,
                    width: tokens.borderWidth,
                  ),
                ),
                icon: Icon(Icons.play_arrow_rounded, size: tokens.iconSmall),
                label: Text(l10n.overviewTrailer),
              ),
            ],
          ),
          if (available.isNotEmpty) ...[
            SizedBox(height: tokens.spaceSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: tokens.spaceSm,
              children: [
                for (final provider in available)
                  StreamingProviderLogo(provider: provider),
              ],
            ),
          ] else ...[
            SizedBox(height: tokens.spaceSm),
            Text(
              l10n.overviewNoStreaming,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

