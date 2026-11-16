import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/luxe_palette.dart';

class OverviewPanel extends StatelessWidget {
  const OverviewPanel({super.key, required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final border = borderColor;

    return DecoratedBox(
      // Home palette: matte surface with a hairline border.
      decoration: BoxDecoration(
        color: LuxeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border ?? LuxeColors.hair,
          width: border == null ? 1 : tokens.borderWidth,
        ),
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
        color: LuxeColors.surface2,
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
