import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/views/widgets/take_summary_card.dart' show absoluteApiUrl;

/// Photo attached to a question or discussion. Hidden if it fails to load.
class TakePhoto extends StatelessWidget {
  const TakePhoto({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: CachedNetworkImage(
          // The server may send a path ("/media/...") rather than a full URL.
          imageUrl: absoluteApiUrl(url) ?? url,
          fit: BoxFit.cover,
          placeholder: (_, __) => ColoredBox(color: AppColors.surfaceRaised),
          errorWidget: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
