import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SectionStatusCard extends StatelessWidget {
  const SectionStatusCard({
    super.key,
    required this.message,
    required this.actionIcon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = actionLabel;
    final action = onAction;

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.all(tokens.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          if (label != null && action != null) ...[
            SizedBox(height: tokens.spaceSm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: action,
                icon: Icon(actionIcon, size: tokens.iconSmall),
                label: Text(label),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentGlow,
                  minimumSize:
                      Size(tokens.minTouchTarget, tokens.minTouchTarget),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
