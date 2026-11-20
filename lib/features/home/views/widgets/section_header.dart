import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Scales the title of every [SectionHeader] below it, so one page (the
/// home You tab) can use smaller section titles without touching others.
class SectionTitleScale extends InheritedWidget {
  const SectionTitleScale({
    super.key,
    required this.scale,
    required super.child,
  });

  final double scale;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SectionTitleScale>()?.scale ??
      1;

  @override
  bool updateShouldNotify(SectionTitleScale oldWidget) =>
      oldWidget.scale != scale;
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.action,
    this.onTitleTap,
    this.subtitle,
    this.onEdit,
    this.editLabel,
  });

  /// Space between a section title and its cards: 20% tighter than the
  /// old 8 px gap, measured from the title text to the content.
  static const double contentGap = 6;

  final String title;
  final String? trailing;
  final Widget? action;
  final VoidCallback? onTitleTap;

  /// A small muted line under the title.
  final String? subtitle;

  /// Shows a pen at the far end of the row that opens the list's edit
  /// page. [editLabel] names it for screen readers.
  final VoidCallback? onEdit;
  final String? editLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailingText = trailing;
    final actionWidget = action;
    final titleTap = onTitleTap;
    // Game-style section title (SAGE home): regular weight, pure white, no underline.
    final titleStyle = TextStyle(
      fontFamily: AppFonts.brand,
      fontSize: 16 * SectionTitleScale.of(context),
      fontWeight: FontWeight.w600,
      color: themed(
          const Color.fromARGB(191, 255, 255, 255), const Color(0xFF36322B)),
      decoration: TextDecoration.none,
    );

    final subtitleText = subtitle;
    final titleText = Semantics(
      header: true,
      button: titleTap != null,
      child: titleTap == null
          ? Text(title, style: titleStyle)
          : InkWell(
              onTap: titleTap,
              child: Text(title, style: titleStyle),
            ),
    );

    return Padding(
      padding: EdgeInsetsDirectional.zero,
      child: Row(
        children: [
          Expanded(
            // The title with a small line under it, like "Your Top 5" and
            // "Pick five films you love".
            child: subtitleText == null
                ? titleText
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      titleText,
                      const SizedBox(height: 2),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
          // The pen sits at the far end of the row.
          if (onEdit case final edit?)
            Semantics(
              button: true,
              label: editLabel,
              excludeSemantics: true,
              child: GestureDetector(
                key: const Key('section-edit'),
                behavior: HitTestBehavior.opaque,
                onTap: edit,
                // A wide, flat hit area keeps the header its usual height.
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 2, 6),
                  child: Icon(
                    BootstrapIcons.pencil,
                    size: 16 * SectionTitleScale.of(context),
                    color: titleStyle.color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
