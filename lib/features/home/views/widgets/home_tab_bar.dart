import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
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
  });

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;
  final bool friendsHasUnread;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = HomeTab.values;
    final index = tabs.indexOf(selected);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LuxeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LuxeColors.hair),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth / tabs.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: width * index,
                top: 0,
                bottom: 0,
                width: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                            HomeTab.friends => l10n.homeTabFriends,
                            HomeTab.films => l10n.homeTabFilms,
                          },
                          selected: tab == selected,
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
    required this.showUnread,
    required this.unreadLabel,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool showUnread;
  final String unreadLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      button: true,
      selected: selected,
      value: showUnread ? unreadLabel : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: showUnread ? tokens.spaceMd + tokens.spaceSm : 0,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: selected ? Colors.white : LuxeColors.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: .2,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (showUnread)
              PositionedDirectional(
                end: tokens.spaceSm,
                top: tokens.spaceSm,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: SageNavTokens.unreadColor,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: SageNavTokens.unreadDotSize,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
