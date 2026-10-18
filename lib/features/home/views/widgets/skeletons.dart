import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';

class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({super.key, required this.child});

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

class PosterSkeleton extends StatelessWidget {
  const PosterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AspectRatio(
      aspectRatio: tokens.posterAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: const ColoredBox(color: AppColors.surfaceRaised),
      ),
    );
  }
}

class PosterSkeletonRow extends StatelessWidget {
  const PosterSkeletonRow({super.key, required this.tileWidth, this.count = 4});

  final double tileWidth;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      height: tokens.posterHeight(tileWidth),
      child: SkeletonShimmer(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          separatorBuilder: (context, index) => SizedBox(width: tokens.spaceSm),
          itemBuilder: (context, index) => SizedBox(
            width: tileWidth,
            child: const PosterSkeleton(),
          ),
        ),
      ),
    );
  }
}
