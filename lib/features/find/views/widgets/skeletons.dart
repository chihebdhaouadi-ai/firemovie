import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';

/// Shimmer wrapper that respects reduce-motion.
class FindShimmer extends StatelessWidget {
  const FindShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final content = ExcludeSemantics(child: child);
    if (MediaQuery.disableAnimationsOf(context)) return content;
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceRaised,
      child: content,
    );
  }
}

/// A row skeleton shaped like a search result.
class ResultRowSkeleton extends StatelessWidget {
  const ResultRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        vertical: tokens.spaceXs,
        horizontal: tokens.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46 / tokens.posterAspectRatio,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
            ),
          ),
          SizedBox(width: tokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 180,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: tokens.spaceXs),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spaceMd),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// A list of result-row skeletons.
class ResultListSkeleton extends StatelessWidget {
  const ResultListSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return FindShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (context, index) => const ResultRowSkeleton(),
      ),
    );
  }
}
