import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/movie.dart';

/// A streaming platform tile showing its underlined name.
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

    final nameText = Text(
      name,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelMedium?.copyWith(
        color: AppColors.textPrimary,
        decoration: TextDecoration.underline,
      ),
    );

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
        child: Center(child: nameText),
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
