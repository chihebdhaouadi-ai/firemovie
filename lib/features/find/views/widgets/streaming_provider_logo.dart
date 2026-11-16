import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/movie.dart';

/// A streaming platform tile with its logo, name and (rent/buy) price.
/// The whole tile opens the platform's page for this film when it has a link.
class StreamingProviderLogo extends StatelessWidget {
  const StreamingProviderLogo({super.key, required this.provider});

  final StreamingProvider provider;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final name = provider.name;
    final url = provider.url;

    final logo = provider.logoUrl;
    final price = provider.price;

    final tile = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(
          color: AppColors.outline,
          width: tokens.borderWidth,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceSm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox.square(
                dimension: 32,
                child: logo == null
                    ? const ColoredBox(
                        color: AppColors.surface,
                        child: Icon(
                          Icons.live_tv,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: logo,
                        fit: BoxFit.cover,
                        memCacheWidth: 100,
                      ),
              ),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (price != null)
                    Text(
                      // Prices are for the backend's STREAMING_COUNTRY (US).
                      NumberFormat.simpleCurrency(name: 'USD').format(price),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (url == null) {
      return Semantics(label: name, child: tile);
    }

    return Semantics(
      button: true,
      label: name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          onTap: () => launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          ),
          child: tile,
        ),
      ),
    );
  }
}
