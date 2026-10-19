import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../find/data/movie.dart';
import 'overview_panel.dart';

class WhereToWatchCard extends StatelessWidget {
  const WhereToWatchCard({super.key, required this.providers});

  final WatchProviders? providers;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final flatrate = providers?.flatrate ?? const <StreamingProvider>[];
    final rent = providers?.rent ?? const <StreamingProvider>[];
    final buy = providers?.buy ?? const <StreamingProvider>[];
    final hasAny = flatrate.isNotEmpty || rent.isNotEmpty || buy.isNotEmpty;

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
          if (hasAny) ...[
            _ProviderGroup(label: l10n.overviewStreamLabel, items: flatrate),
            _ProviderGroup(label: l10n.overviewRentLabel, items: rent),
            _ProviderGroup(label: l10n.overviewBuyLabel, items: buy),
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

class _ProviderGroup extends StatelessWidget {
  const _ProviderGroup({required this.label, required this.items});

  final String label;
  final List<StreamingProvider> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: tokens.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: tokens.spaceXs),
          Wrap(
            spacing: tokens.spaceSm,
            runSpacing: tokens.spaceSm,
            children: [
              for (final provider in items)
                OverviewChip(
                  label: provider.name,
                  leading: _ProviderLogo(url: provider.logoUrl),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final logoUrl = url;
    if (logoUrl == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: SizedBox(
        width: tokens.logoHeight,
        height: tokens.logoHeight,
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
