import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/motion.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../../core/widgets/sage_nav_bar/sage_nav_tokens.dart';
import '../home_tab.dart';

/// You / Friends / Films as a segmented control with a sliding blue pill.
class HomeTabBar extends StatelessWidget {
  const HomeTabBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.friendsHasUnread = false,
    this.collapse = 0,
  });

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;
  final bool friendsHasUnread;

  /// How far the home header has collapsed (0..1); the bar's labels and
  /// corners get a little smaller with it. The parent sets the height.
  final double collapse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = HomeTab.values;
    final index = tabs.indexOf(selected);

    final c = collapse.clamp(0.0, 1.0);

    return Container(
      height: 38 - 8 * c,
      padding: EdgeInsets.all(3 - c),
      decoration: BoxDecoration(
        color: LuxeColors.surface,
        borderRadius: BorderRadius.circular(13 - 3 * c),
        border: Border.all(color: LuxeColors.hair),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth / tabs.length;
          // The unread dot sits on a button's corner and may poke out.
          return Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration:
                    motionDuration(context, const Duration(milliseconds: 300)),
                curve: Curves.easeOutCubic,
                left: width * index,
                top: 0,
                bottom: 0,
                width: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10 - 2 * c),
                    gradient: LuxeColors.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: LuxeColors.accent.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Fill the whole bar so each label centers vertically.
              Positioned.fill(
                child: Row(
                  children: [
                    for (final tab in tabs)
                      Expanded(
                        child: _HomeTabButton(
                          label: switch (tab) {
                            HomeTab.you => l10n.homeTabYou,
                            HomeTab.friends => l10n.homeInboxTitle,
                            HomeTab.films => l10n.homeCollectionsTitle,
                          },
                          selected: tab == selected,
                          fontSize: 14 - 1.5 * c,
                          showUnread:
                              tab == HomeTab.friends && friendsHasUnread,
                          unreadLabel: l10n.sageNavUnread,
                          onTap: () => onSelected(tab),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.label,
    required this.selected,
    required this.fontSize,
    required this.showUnread,
    required this.unreadLabel,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double fontSize;
  final bool showUnread;
  final String unreadLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      value: showUnread ? unreadLabel : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          // The unread dot rides on the label's top-end corner, like a
          // superscript, inside the button.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedDefaultTextStyle(
                duration:
                    motionDuration(context, const Duration(milliseconds: 200)),
                style: TextStyle(
                  color: selected ? Colors.white : LuxeColors.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  letterSpacing: .2,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showUnread)
                const PositionedDirectional(
                  end: -9,
                  top: -2,
                  child: DecoratedBox(
                    key: Key('home-tab-unread-dot'),
                    decoration: BoxDecoration(
                      color: SageNavTokens.unreadColor,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: 8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
