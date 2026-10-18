import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';

class GenerateButton extends StatelessWidget {
  const GenerateButton({
    super.key,
    required this.enabled,
    required this.generating,
    required this.remaining,
    required this.onPressed,
  });

  final bool enabled;
  final bool generating;
  final int remaining;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed();
                }
              : null,
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(tokens.generateButtonHeight),
            backgroundColor: AppColors.primaryButton,
            foregroundColor: AppColors.onPrimaryButton,
            disabledBackgroundColor: AppColors.surfaceRaised,
            disabledForegroundColor: AppColors.textMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (generating) ...[
                SizedBox(
                  width: tokens.iconSmall,
                  height: tokens.iconSmall,
                  child: CircularProgressIndicator(
                    strokeWidth: tokens.borderWidth * 2,
                    color: AppColors.onPrimaryButton,
                  ),
                ),
                SizedBox(width: tokens.spaceSm),
              ],
              Flexible(
                child: Text(
                  generating ? l10n.homeGenerating : l10n.homeGenerateButton,
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
        if (!enabled && !generating) ...[
          SizedBox(height: tokens.spaceSm),
          Text(
            l10n.homeGenerateDisabledHint(remaining),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}
