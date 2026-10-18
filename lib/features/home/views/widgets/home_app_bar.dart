import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Row(
      children: [
        Image.asset(
          'assets/LogoWise.png',
          height: tokens.logoHeight,
          excludeFromSemantics: true,
        ),
        const Spacer(),
        Flexible(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: tokens.spaceMd,
                vertical: tokens.spaceXs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.star_rounded,
                      size: tokens.iconSmall,
                      color: AppColors.accentGlow,
                    ),
                  ),
                  SizedBox(width: tokens.spaceXs),
                  Flexible(
                    child: Text(
                      l10n.homePointsLabel(points),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
