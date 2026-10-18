import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';

class PosterSkeletonRow extends StatelessWidget {
  const PosterSkeletonRow({super.key, required this.tileWidth, this.count = 4});

  final double tileWidth;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final height = tokens.posterHeight(tileWidth);

    final row = ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (context, index) => SizedBox(width: tokens.spaceSm),
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: ColoredBox(
          color: AppColors.surfaceRaised,
          child: SizedBox(width: tileWidth, height: height),
        ),
      ),
    );

    return SizedBox(
      height: height,
      child: ExcludeSemantics(
        child: MediaQuery.disableAnimationsOf(context)
            ? row
            : Shimmer.fromColors(
                baseColor: AppColors.surface,
                highlightColor: AppColors.surfaceRaised,
                child: row,
              ),
      ),
    );
  }
}
