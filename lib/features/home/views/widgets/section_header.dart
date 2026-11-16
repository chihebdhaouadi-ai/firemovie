import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.action,
    this.onTitleTap,
  });

  final String title;
  final String? trailing;
  final Widget? action;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailingText = trailing;
    final actionWidget = action;
    final titleTap = onTitleTap;
    // Game-style section title (SAGE home): regular weight, pure white, no underline.
    const titleStyle = TextStyle(
      fontFamily: AppFonts.brand,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color.fromARGB(191, 255, 255, 255),
      decoration: TextDecoration.none,
    );

    return Padding(
      padding: EdgeInsetsDirectional.zero,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              button: titleTap != null,
              child: titleTap == null
                  ? Text(title, style: titleStyle)
                  : InkWell(
                      onTap: titleTap,
                      child: Text(title, style: titleStyle),
                    ),
            ),
          ),
          if (trailingText != null)
            Flexible(
              child: Text(
                trailingText,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ),
          if (actionWidget != null) actionWidget,
        ],
      ),
    );
  }
}
