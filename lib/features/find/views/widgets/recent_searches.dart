import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';

/// Horizontal list of recent searches, tappable to reuse and swipeable/clearable.
class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.terms,
    required this.onSelected,
    required this.onClear,
  });

  final List<String> terms;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    if (terms.isEmpty) {
      return _EmptyRow(title: l10n.findRecentEmpty);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.findRecentTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: Text(l10n.findRecentClear),
            ),
          ],
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: terms.length,
            separatorBuilder: (_, __) => SizedBox(width: tokens.spaceSm),
            itemBuilder: (context, index) {
              final term = terms[index];
              return InputChip(
                avatar: const Icon(
                  Icons.history,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                label: Text(term),
                onPressed: () => onSelected(term),
                onDeleted: null,
                deleteButtonTooltipMessage: l10n.findRecentSwipeDelete,
                backgroundColor: AppColors.surfaceRaised,
                side: BorderSide(color: AppColors.outline, width: 0.5),
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        vertical: context.tokens.spaceLg,
      ),
      child: Row(
        children: [
          Icon(Icons.manage_search, color: AppColors.textMuted),
          SizedBox(width: context.tokens.spaceSm),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}
