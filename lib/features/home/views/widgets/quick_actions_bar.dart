import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({
    super.key,
    required this.onSearch,
    required this.onAddFilm,
  });

  final VoidCallback onSearch;
  final VoidCallback onAddFilm;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final style = OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      minimumSize: Size(0, tokens.minTouchTarget),
      padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.spaceLg),
      side: BorderSide(color: AppColors.outline, width: tokens.borderWidth),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
    );

    return Semantics(
      container: true,
      label: l10n.homeQuickActionsLabel,
      child: Wrap(
        spacing: tokens.spaceSm,
        runSpacing: tokens.spaceSm,
        children: [
          OutlinedButton.icon(
            style: style,
            onPressed: () {
              HapticFeedback.selectionClick();
              onSearch();
            },
            icon: Icon(Icons.search, size: tokens.iconSmall),
            label: Text(l10n.homeQuickActionSearch),
          ),
          OutlinedButton.icon(
            style: style,
            onPressed: () {
              HapticFeedback.selectionClick();
              onAddFilm();
            },
            icon: Icon(Icons.add, size: tokens.iconSmall),
            label: Text(l10n.homeQuickActionAddFilm),
          ),
        ],
      ),
    );
  }
}
