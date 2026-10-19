import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OverviewPanel extends StatelessWidget {
  const OverviewPanel({super.key, required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final border = borderColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: border == null
            ? null
            : Border.all(color: border, width: tokens.borderWidth),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: child,
      ),
    );
  }
}

class OverviewChip extends StatelessWidget {
  const OverviewChip({super.key, required this.label, this.leading});

  final String label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final leading = this.leading;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: tokens.spaceSm,
          vertical: tokens.spaceXs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading,
              SizedBox(width: tokens.spaceXs),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.accentGlow,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
