import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailingText = trailing;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceSm),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
          ),
          if (trailingText != null)
            Flexible(
              child: Text(
                trailingText,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}
